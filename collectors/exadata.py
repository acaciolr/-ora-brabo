"""
collectors/exadata.py
Exadata: Cell servers, Smart Scan, Flash Cache, offload statistics.
All queries run only when Exadata is detected (exa.detected = True).

Cache keys produced:
  exa.detected          bool
  exa.cells             list[dict]  — cell servers from v$cell_config
  exa.smart_scan        dict        — Smart Scan / Storage Index / offload %
  exa.flash_cache       dict        — Flash Cache hit %
  exa.offload           dict        — raw offload sysstat counters
  exa.sql_offload       list[dict]  — top SQLs by IB bytes saved
  exa.cell_waits        list[dict]  — cell wait events (gv$system_event)
  exa.hcc_objects       list[dict]  — HCC-compressed tables
  exa.params            list[dict]  — Exadata-specific db parameters
"""
from __future__ import annotations
import logging
from collectors.base import BaseCollector

log = logging.getLogger(__name__)

# ── Detection ─────────────────────────────────────────────────────────────────

_SQL_DETECT = """
SELECT COUNT(*) AS cnt
FROM v$sysstat
WHERE name = 'cell physical IO bytes eligible for predicate offload'
"""

# ── Cell servers ──────────────────────────────────────────────────────────────

_SQL_CELLS = """
SELECT
    cell_name,
    cell_path        AS ip_address,
    interconnect_ip,
    cell_status,
    cell_version
FROM v$cell_config
WHERE cell_status = 'online'
ORDER BY cell_name
"""

# ── Smart Scan / Storage Index ────────────────────────────────────────────────

_SQL_SMART_SCAN = """
SELECT
    s.name,
    s.value
FROM v$sysstat s
WHERE s.name IN (
    'cell physical IO bytes eligible for predicate offload',
    'cell physical IO bytes saved by storage index',
    'cell physical IO interconnect bytes returned by smart scan',
    'cell physical IO bytes sent directly to DB node to balance CPU',
    'cell smart IO session cache hits',
    'cell smart IO session cache misses',
    'physical read total bytes',
    'physical write total bytes'
)
"""

# ── Flash Cache ───────────────────────────────────────────────────────────────

_SQL_FLASH_CACHE = """
SELECT
    name,
    value
FROM v$sysstat
WHERE name IN (
    'cell flash cache read hits',
    'physical reads cache',
    'cell IO uncompressed bytes'
)
"""

# ── Offload raw counters ──────────────────────────────────────────────────────

_SQL_OFFLOAD = """
SELECT
    name,
    value
FROM v$sysstat
WHERE name IN (
    'cell physical IO bytes eligible for predicate offload',
    'cell physical IO interconnect bytes',
    'cell physical IO bytes saved by columnar cache',
    'cell scans',
    'cell blocks helped by bloom filter',
    'cell blocks processed by storage layer',
    'cell blocks returned by predicate offload'
)
"""

# ── Top SQLs by Exadata offload efficiency ────────────────────────────────────
# Uses IO_CELL_OFFLOAD_ELIGIBLE_BYTES / IO_INTERCONNECT_BYTES — only populated
# on Exadata. Filters out system schemas and zero-eligible sqls.

_SQL_SQL_OFFLOAD = """
SELECT * FROM (
    SELECT
        sql_id,
        SUBSTR(sql_text, 1, 80)                            AS sql_text,
        executions,
        io_cell_offload_eligible_bytes / 1073741824        AS eligible_gb,
        io_interconnect_bytes / 1073741824                 AS ib_gb,
        CASE
            WHEN io_cell_offload_eligible_bytes > 0
            THEN ROUND(
                (1 - io_interconnect_bytes / io_cell_offload_eligible_bytes) * 100, 1)
            ELSE 0
        END                                                AS offload_pct,
        io_cell_uncompressed_bytes / 1073741824            AS uncompressed_gb,
        parsing_schema_name                                AS schema_name
    FROM gv$sql
    WHERE io_cell_offload_eligible_bytes > 0
      AND parsing_schema_name NOT IN (
            'SYS','SYSTEM','DBSNMP','SYSMAN','MDSYS','XDB','WMSYS',
            'APEX_PUBLIC_USER','FLOWS_FILES')
    ORDER BY io_cell_offload_eligible_bytes DESC
) WHERE ROWNUM <= 15
"""

# ── Cell wait events (system-level) ──────────────────────────────────────────

_SQL_CELL_WAITS = """
SELECT
    event,
    total_waits,
    ROUND(time_waited / 100, 2)            AS time_waited_secs,
    ROUND(average_wait / 100, 2)           AS avg_wait_ms,
    wait_class
FROM gv$system_event
WHERE event LIKE 'cell%'
  AND total_waits > 0
ORDER BY time_waited DESC
FETCH FIRST 20 ROWS ONLY
"""

# Oracle 11g-safe version (no FETCH FIRST)
_SQL_CELL_WAITS_11G = """
SELECT * FROM (
    SELECT
        event,
        total_waits,
        ROUND(time_waited / 100, 2)        AS time_waited_secs,
        ROUND(average_wait / 100, 2)       AS avg_wait_ms,
        wait_class
    FROM gv$system_event
    WHERE event LIKE 'cell%'
      AND total_waits > 0
    ORDER BY time_waited DESC
) WHERE ROWNUM <= 20
"""

# ── HCC-compressed tables ─────────────────────────────────────────────────────

_SQL_HCC = """
SELECT * FROM (
    SELECT
        owner,
        table_name,
        compress_for,
        num_rows,
        ROUND(blocks * 8192 / 1048576, 1)  AS size_mb,
        last_analyzed
    FROM dba_tables
    WHERE compress_for IN (
        'QUERY HIGH', 'QUERY LOW',
        'ARCHIVE HIGH', 'ARCHIVE LOW',
        'COLUMN STORE'
    )
    AND owner NOT IN ('SYS','SYSTEM','SYSMAN','DBSNMP')
    ORDER BY blocks DESC NULLS LAST
) WHERE ROWNUM <= 20
"""

# ── Exadata-specific parameters ───────────────────────────────────────────────

_SQL_PARAMS = """
SELECT * FROM (
    SELECT
        name,
        value,
        description
    FROM gv$parameter
    WHERE (
        name LIKE 'cell%'
        OR name IN (
            'db_file_multiblock_read_count',
            'parallel_degree_policy',
            'result_cache_mode',
            'inmemory_size',
            'heat_map',
            'db_big_table_cache_percent_target'
        )
    )
    AND value IS NOT NULL
    AND value != '0'
    ORDER BY name
) WHERE ROWNUM <= 30
"""


class ExadataCollector(BaseCollector):

    def __init__(self, conn_manager, cache, interval: int = 30) -> None:
        super().__init__(conn_manager, cache, interval)
        self._detected: bool | None = None  # None = not yet checked
        self._db_version: int = 19          # assume 19c by default

    async def collect(self) -> None:
        # ── Step 1: Detect Exadata once ──────────────────────────────────
        if self._detected is None:
            row = await self.conn.fetch_one(_SQL_DETECT)
            self._detected = (row is not None and int(row.get("cnt", 0)) > 0)
            self.cache.set("exa.detected", self._detected, ttl=3600)
            log.info("Exadata detected: %s", self._detected)

        if not self._detected:
            return

        # ── Step 2: Cell servers ──────────────────────────────────────────
        cells = await self.conn.execute_query(_SQL_CELLS)
        self.cache.set("exa.cells", cells, ttl=60)

        # ── Step 3: Smart Scan stats ──────────────────────────────────────
        smart_rows = await self.conn.execute_query(_SQL_SMART_SCAN)
        smart = {r["name"]: int(r["value"] or 0) for r in smart_rows}
        eligible    = smart.get("cell physical IO bytes eligible for predicate offload", 0)
        saved_si    = smart.get("cell physical IO bytes saved by storage index", 0)
        returned    = smart.get("cell physical IO interconnect bytes returned by smart scan", 0)
        phys_total  = smart.get("physical read total bytes", 1) or 1
        smart_pct   = (returned / phys_total * 100) if phys_total else 0
        storidx_pct = (saved_si / eligible * 100) if eligible else 0
        offload_pct = ((eligible - returned) / eligible * 100) if eligible else 0
        self.cache.set("exa.smart_scan", {
            "eligible_gb":               eligible / 1073741824,
            "saved_by_storage_index_gb": saved_si / 1073741824,
            "returned_gb":               returned / 1073741824,
            "smart_scan_pct":            smart_pct,
            "storage_index_pct":         storidx_pct,
            "offload_efficiency_pct":    offload_pct,
        }, ttl=self.interval + 2)

        # ── Step 4: Flash Cache ───────────────────────────────────────────
        flash_rows = await self.conn.execute_query(_SQL_FLASH_CACHE)
        flash = {r["name"]: int(r["value"] or 0) for r in flash_rows}
        hits    = flash.get("cell flash cache read hits", 0)
        reads   = flash.get("physical reads cache", 1) or 1
        hit_pct = (hits / reads * 100) if reads else 0
        self.cache.set("exa.flash_cache", {
            "hits":    hits,
            "reads":   reads,
            "hit_pct": hit_pct,
        }, ttl=self.interval + 2)

        # ── Step 5: Offload raw counters ──────────────────────────────────
        offload_rows = await self.conn.execute_query(_SQL_OFFLOAD)
        offload = {r["name"]: int(r["value"] or 0) for r in offload_rows}
        self.cache.set("exa.offload", offload, ttl=self.interval + 2)

        # ── Step 6: Top SQL by offload efficiency ─────────────────────────
        sql_rows = await self.conn.execute_query(_SQL_SQL_OFFLOAD)
        self.cache.set("exa.sql_offload", sql_rows or [], ttl=self.interval * 2)

        # ── Step 7: Cell wait events ──────────────────────────────────────
        cw_rows = await self.conn.execute_query(_SQL_CELL_WAITS_11G)
        self.cache.set("exa.cell_waits", cw_rows or [], ttl=self.interval + 2)

        # ── Step 8: HCC objects ───────────────────────────────────────────
        hcc_rows = await self.conn.execute_query(_SQL_HCC)
        self.cache.set("exa.hcc_objects", hcc_rows or [], ttl=120)

        # ── Step 9: Exadata parameters ────────────────────────────────────
        param_rows = await self.conn.execute_query(_SQL_PARAMS)
        self.cache.set("exa.params", param_rows or [], ttl=300)

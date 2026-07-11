"""
collectors/dg.py
Data Guard: v$dataguard_stats, v$managed_standby, v$archive_dest_status.
Cache key: dg.*
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_DETECT = """
SELECT database_role, protection_mode FROM v$database
"""

_SQL_DG_STATS = """
SELECT
    name,
    value,
    unit,
    time_computed
FROM v$dataguard_stats
ORDER BY name
"""

_SQL_STANDBY_PROCESS = """
SELECT
    process,
    status,
    thread#     AS thread,
    sequence#   AS sequence,
    block#,
    blocks
FROM v$managed_standby
ORDER BY process
"""

_SQL_GV_STANDBY_PROCESS = """
SELECT
    ms.inst_id,
    ms.process,
    ms.status,
    ms.thread#      AS thread,
    ms.sequence#    AS sequence,
    ms.block#,
    ms.blocks,
    NVL(ms.delay_mins, 0) AS delay_mins
FROM gv$managed_standby ms
ORDER BY ms.inst_id, ms.process
"""

_SQL_ARCHIVE_DEST = """
SELECT
    dest_id,
    dest_name,
    status,
    target,
    archiver,
    schedule,
    destination,
    applied_seq#    AS applied_seq,
    error
FROM v$archive_dest_status
WHERE status != 'INACTIVE'
ORDER BY dest_id
"""

_SQL_ARCHIVE_GAP = """
SELECT
    thread#,
    low_sequence#   AS low_seq,
    high_sequence#  AS high_seq
FROM v$archive_gap
"""

_SQL_LOG_HISTORY = """
SELECT
    MAX(sequence#)  AS last_sequence,
    thread#
FROM v$log_history
GROUP BY thread#
"""


class DataGuardCollector(BaseCollector):

    _role: str = ""

    async def collect(self) -> None:
        role_row = await self.conn.fetch_one(_SQL_DETECT)
        if not role_row:
            return

        self._role = role_row.get("database_role", "")
        self.cache.set("dg.role", self._role, ttl=60)
        self.cache.set("dg.protection_mode", role_row.get("protection_mode", ""), ttl=60)

        # DG stats (lag etc.) — available on standby and primary
        dg_stats = await self.conn.execute_query(_SQL_DG_STATS)
        stats_map = {r["name"]: r for r in dg_stats}
        self.cache.set("dg.stats", stats_map, ttl=self.interval + 2)

        # Managed standby processes (V$ + GV$ for RAC per-instance)
        mrp = await self.conn.execute_query(_SQL_STANDBY_PROCESS)
        self.cache.set("dg.standby_processes", mrp, ttl=self.interval + 2)

        gv_mrp = await self.conn.execute_query(_SQL_GV_STANDBY_PROCESS)
        self.cache.set("dg.rac_processes", gv_mrp, ttl=self.interval + 2)

        # Archive destinations
        dests = await self.conn.execute_query(_SQL_ARCHIVE_DEST)
        self.cache.set("dg.archive_dests", dests, ttl=self.interval + 2)

        # Archive gap
        gaps = await self.conn.execute_query(_SQL_ARCHIVE_GAP)
        self.cache.set("dg.archive_gap", gaps, ttl=self.interval + 2)

        # Last applied sequence
        log_hist = await self.conn.execute_query(_SQL_LOG_HISTORY)
        self.cache.set("dg.log_history", log_hist, ttl=self.interval + 2)

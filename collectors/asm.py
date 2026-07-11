"""
collectors/asm.py
ASM diskgroups + FRA (Fast Recovery Area) usage.
Cache keys: asm.diskgroups, asm.fra
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_DISKGROUPS = """
SELECT
    group_number,
    name,
    state,
    type,
    ROUND(total_mb / 1024, 2)   AS total_gb,
    ROUND(free_mb / 1024, 2)    AS free_gb,
    ROUND((total_mb - free_mb) / 1024, 2) AS used_gb,
    ROUND((total_mb - free_mb) / NULLIF(total_mb, 0) * 100, 1) AS used_pct,
    offline_disks,
    rebalance,
    allocation_unit_size / 1048576 AS au_mb
FROM v$asm_diskgroup
ORDER BY name
"""

_SQL_FRA = """
SELECT
    space_limit / 1073741824            AS fra_total_gb,
    space_used / 1073741824             AS fra_used_gb,
    space_reclaimable / 1073741824      AS fra_reclaimable_gb,
    ROUND(space_used / NULLIF(space_limit,0) * 100, 2) AS used_pct,
    number_of_files
FROM v$recovery_file_dest
"""

_SQL_FRA_FILES = """
SELECT
    file_type,
    percent_space_used,
    percent_space_reclaimable,
    number_of_files
FROM v$flash_recovery_area_usage
ORDER BY percent_space_used DESC
"""

_SQL_ARCHIVE_RATE = """
SELECT
    ROUND(SUM(blocks * block_size) / COUNT(*) / 1048576, 2) AS avg_archive_mb
FROM v$archived_log
WHERE completion_time >= SYSDATE - 1/24
  AND standby_dest = 'NO'
"""

_SQL_DISKS = """
SELECT
    d.group_number,
    g.name                                                       AS diskgroup_name,
    d.disk_number,
    d.name                                                       AS disk_name,
    d.path,
    d.mode_status,
    d.state,
    d.header_status,
    ROUND(d.total_mb)                                            AS total_mb,
    ROUND(d.free_mb)                                             AS free_mb,
    ROUND((d.total_mb - d.free_mb) / NULLIF(d.total_mb, 0) * 100, 1) AS used_pct,
    d.reads,
    d.writes,
    ROUND(d.read_time  / NULLIF(d.reads,  0) * 1000, 2)         AS avg_read_ms,
    ROUND(d.write_time / NULLIF(d.writes, 0) * 1000, 2)         AS avg_write_ms,
    d.failgroup,
    d.label
FROM v$asm_disk d
JOIN v$asm_diskgroup g ON d.group_number = g.group_number
WHERE d.group_number > 0
ORDER BY g.name, d.disk_number
"""


class ASMCollector(BaseCollector):

    async def collect(self) -> None:
        # Diskgroups — try v$asm_diskgroup (available from DB connection if +ASM or local)
        dg = await self.conn.execute_query(_SQL_DISKGROUPS)
        self.cache.set("asm.diskgroups", dg, ttl=self.interval + 2)

        # FRA
        fra = await self.conn.fetch_one(_SQL_FRA)
        self.cache.set("asm.fra", fra, ttl=self.interval + 2)

        fra_files = await self.conn.execute_query(_SQL_FRA_FILES)
        self.cache.set("asm.fra_files", fra_files, ttl=self.interval + 2)

        # Archive generation rate
        archive_rate = await self.conn.fetch_one(_SQL_ARCHIVE_RATE)
        self.cache.set("asm.archive_rate_mb", (archive_rate or {}).get("avg_archive_mb", 0), ttl=60)

        # Individual disks grouped by diskgroup
        disks = await self.conn.execute_query(_SQL_DISKS)
        self.cache.set("asm.disks", disks, ttl=self.interval + 2)

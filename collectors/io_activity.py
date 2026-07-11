"""
collectors/io_activity.py
I/O Activity, Load Profile, Redo, and Undo monitoring.
Cache keys: io.file_stats, io.function_stats, io.load_profile,
            io.redo_logs, io.redo_log_files, io.redo_switches_per_hour,
            io.undo_stats, io.undo_extents
"""
from __future__ import annotations

from collectors.base import BaseCollector

_SQL_FILE_STATS = """
SELECT f.file#, f.name, f.ts#, t.name AS tablespace_name,
    s.phyrds, s.phywrts,
    ROUND(s.readtim/NULLIF(s.phyrds,0)*10,2)   AS avg_read_ms,
    ROUND(s.writetim/NULLIF(s.phywrts,0)*10,2)  AS avg_write_ms,
    ROUND(s.phyrds*8192/1048576,2)              AS read_mb,
    ROUND(s.phywrts*8192/1048576,2)             AS write_mb
FROM v$filestat s JOIN v$datafile f ON s.file# = f.file#
JOIN v$tablespace t ON f.ts# = t.ts#
ORDER BY (s.phyrds + s.phywrts) DESC
"""

_SQL_FUNCTION_STATS = """
SELECT function_name,
    large_read_reqs, large_write_reqs, small_read_reqs, small_write_reqs,
    ROUND(large_read_servicetime/NULLIF(large_read_reqs,0),2)  AS avg_large_read_ms,
    ROUND(small_read_servicetime/NULLIF(small_read_reqs,0),2)  AS avg_small_read_ms,
    ROUND((large_read_megabytes + small_read_megabytes),2)     AS total_read_mb,
    ROUND((large_write_megabytes + small_write_megabytes),2)   AS total_write_mb
FROM v$iostat_function
ORDER BY (large_read_reqs + small_read_reqs + large_write_reqs + small_write_reqs) DESC
"""

_SQL_LOAD_PROFILE = """
SELECT metric_name, value, metric_unit
FROM v$sysmetric
WHERE group_id = 2
  AND metric_name IN (
    'DB Time Per Sec','CPU Usage Per Sec','Redo Generated Per Sec',
    'Logical Reads Per Sec','Physical Reads Per Sec','Physical Writes Per Sec',
    'Hard Parses Per Sec','Executions Per Sec','User Calls Per Sec',
    'Transactions Per Sec','User Rollbacks Per Sec','DB Block Gets Per Sec',
    'Consistent Gets Per Sec','User Commits Per Sec'
  )
"""

_SQL_REDO_LOGS = """
SELECT l.group#, l.members, l.bytes/1048576 AS size_mb,
    l.status, l.archived, l.sequence#, l.first_time
FROM v$log l ORDER BY l.group#
"""

_SQL_REDO_LOG_FILES = """
SELECT lf.group#, lf.member, lf.status, lf.type
FROM v$logfile lf ORDER BY lf.group#, lf.member
"""

_SQL_REDO_SWITCHES = """
SELECT TO_CHAR(first_time,'YYYY-MM-DD HH24') AS hour_slot,
    COUNT(*) AS switches
FROM v$log_history
WHERE first_time >= SYSDATE - 1
GROUP BY TO_CHAR(first_time,'YYYY-MM-DD HH24')
ORDER BY hour_slot DESC
"""

_SQL_UNDO_STATS = """
SELECT * FROM (
    SELECT begin_time, end_time, undoblks, txncount, maxquerylen,
        maxconcurrency, ssolderrcnt, nospaceerrcnt, activeblks, unexpiredblks
    FROM v$undostat ORDER BY end_time DESC
) WHERE ROWNUM <= 10
"""

_SQL_UNDO_EXTENTS = """
SELECT status, COUNT(*) AS ext_count, ROUND(SUM(bytes)/1048576,2) AS total_mb
FROM dba_undo_extents GROUP BY status
"""


class IOActivityCollector(BaseCollector):

    async def collect(self) -> None:
        ttl = self.interval + 2

        file_stats = await self.conn.execute_query(_SQL_FILE_STATS)
        self.cache.set("io.file_stats", file_stats or [], ttl=ttl)

        func_stats = await self.conn.execute_query(_SQL_FUNCTION_STATS)
        self.cache.set("io.function_stats", func_stats or [], ttl=ttl)

        load_profile = await self.conn.execute_query(_SQL_LOAD_PROFILE)
        self.cache.set("io.load_profile", load_profile or [], ttl=ttl)

        redo_logs = await self.conn.execute_query(_SQL_REDO_LOGS)
        self.cache.set("io.redo_logs", redo_logs or [], ttl=60)

        redo_log_files = await self.conn.execute_query(_SQL_REDO_LOG_FILES)
        self.cache.set("io.redo_log_files", redo_log_files or [], ttl=60)

        redo_switches = await self.conn.execute_query(_SQL_REDO_SWITCHES)
        self.cache.set("io.redo_switches_per_hour", redo_switches or [], ttl=60)

        undo_stats = await self.conn.execute_query(_SQL_UNDO_STATS)
        self.cache.set("io.undo_stats", undo_stats or [], ttl=ttl)

        undo_extents = await self.conn.execute_query(_SQL_UNDO_EXTENTS)
        self.cache.set("io.undo_extents", undo_extents or [], ttl=60)

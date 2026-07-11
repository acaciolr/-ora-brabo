"""
collectors/rman.py
RMAN: active session monitor (Doc ID 1487262.1), history, backup sets.
Cache keys: rman.sessions, rman.longops, rman.wait_events, rman.disk_io,
            rman.tape_io, rman.perf_summary, rman.active, rman.history, rman.backup_sets
"""

from __future__ import annotations

from collectors.base import BaseCollector

# ── Section 1: Active RMAN sessions via gv$session ───────────────────────────
_SQL_SESSIONS = """
SELECT
    s.inst_id,
    s.sid,
    s.serial#                                               AS serial_num,
    p.spid                                                  AS os_pid,
    s.username,
    s.client_info,
    s.status,
    s.program,
    ROUND((SYSDATE - s.logon_time) * 24 * 60)              AS session_mins
FROM gv$session s, gv$process p
WHERE s.paddr   = p.addr
  AND s.inst_id = p.inst_id
  AND (UPPER(s.program)     LIKE '%RMAN%'
       OR UPPER(s.client_info) LIKE 'RMAN%')
ORDER BY s.inst_id, s.sid
"""

# ── Section 2: Channel-level progress (gv$session_longops) ───────────────────
_SQL_LONGOPS = """
SELECT
    o.inst_id,
    o.sid,
    s.serial#                                               AS serial_num,
    s.client_info                                           AS channel,
    o.opname                                                AS operation,
    o.context,
    o.sofar,
    o.totalwork,
    ROUND(o.sofar / NULLIF(o.totalwork, 0) * 100, 2)       AS pct_complete,
    o.time_remaining,
    o.elapsed_seconds                                       AS elapsed_secs,
    ROUND(o.sofar / GREATEST(o.elapsed_seconds, 1), 2)     AS mb_per_sec
FROM gv$session_longops o, gv$session s
WHERE o.opname     LIKE 'RMAN%'
  AND o.opname NOT LIKE '%aggregate%'
  AND o.sid      = s.sid
  AND o.inst_id  = s.inst_id
  AND o.totalwork   != 0
  AND o.sofar        <> o.totalwork
ORDER BY o.inst_id, o.sid, o.start_time
"""

# ── Section 3: Current wait events (active RMAN sessions) ────────────────────
_SQL_WAIT_EVENTS = """
SELECT
    s.inst_id,
    s.sid,
    s.serial#                                               AS serial_num,
    s.client_info                                           AS channel,
    s.seq#                                                  AS seq_num,
    s.event,
    s.state,
    ROUND(s.wait_time_micro / 1000000, 2)                   AS wait_secs,
    s.p1text,
    s.p1,
    s.p2text,
    s.p2
FROM gv$session s
WHERE (UPPER(s.program)     LIKE '%RMAN%'
       OR UPPER(s.client_info) LIKE 'RMAN%')
  AND s.wait_time = 0
  AND s.action   IS NOT NULL
  AND s.status    = 'ACTIVE'
ORDER BY s.inst_id, s.sid
"""

# ── Section 4: Disk I/O progress (gv$backup_async_io) — no date filter ───────
_SQL_DISK_IO = """
SELECT
    a.inst_id,
    a.sid,
    s.serial#                                               AS serial_num,
    s.client_info                                           AS channel,
    a.status,
    a.open_time,
    ROUND(a.bytes       / 1048576, 2)                       AS sofar_mb,
    ROUND(a.total_bytes / 1048576, 2)                       AS total_mb,
    ROUND(a.bytes / NULLIF(a.total_bytes, 0) * 100, 2)      AS pct_complete,
    a.io_count,
    a.type,
    SUBSTR(a.filename, -50)                                 AS filename
FROM gv$backup_async_io a, gv$session s
WHERE a.status NOT IN ('UNKNOWN')
  AND a.sid      = s.sid
  AND a.inst_id  = s.inst_id
ORDER BY a.inst_id, a.sid, pct_complete DESC
"""

# ── Section 5: Tape I/O progress (gv$backup_sync_io) ─────────────────────────
_SQL_TAPE_IO = """
SELECT
    a.inst_id,
    a.sid,
    s.serial#                                               AS serial_num,
    s.client_info                                           AS channel,
    a.type,
    a.status,
    a.open_time,
    ROUND(a.bytes       / 1048576, 2)                       AS sofar_mb,
    ROUND(a.total_bytes / 1048576, 2)                       AS total_mb,
    a.buffer_size,
    a.buffer_count
FROM gv$backup_sync_io a, gv$session s
WHERE a.status NOT IN ('UNKNOWN')
  AND a.sid      = s.sid
  AND a.inst_id  = s.inst_id
ORDER BY a.inst_id, a.sid
"""

# ── Section 6: Overall performance summary ────────────────────────────────────
_SQL_PERF_SUMMARY = """
SELECT
    COUNT(DISTINCT s.sid)                                               AS active_channels,
    SUM(CASE WHEN o.sofar > 0 THEN 1 ELSE 0 END)                       AS working_channels,
    ROUND(SUM(o.sofar)       / 1024, 2)                                 AS total_processed_gb,
    ROUND(SUM(o.totalwork)   / 1024, 2)                                 AS total_work_gb,
    ROUND(AVG(o.sofar / NULLIF(o.totalwork, 0) * 100), 2)              AS avg_pct_complete,
    MAX(o.time_remaining)                                               AS max_eta_secs,
    ROUND(AVG(o.sofar / GREATEST(o.elapsed_seconds, 1)), 2)             AS avg_mb_per_sec
FROM gv$session s
LEFT JOIN gv$session_longops o
    ON  s.sid      = o.sid
    AND s.inst_id  = o.inst_id
    AND o.opname  LIKE 'RMAN%'
    AND o.opname  NOT LIKE '%aggregate%'
    AND o.totalwork != 0
WHERE (UPPER(s.program)     LIKE '%RMAN%'
       OR UPPER(s.client_info) LIKE 'RMAN%')
  AND s.status = 'ACTIVE'
"""

# ── Legacy: v$rman_status for history/sets (unchanged) ───────────────────────
_SQL_HISTORY = """
SELECT * FROM (
    SELECT
        rs.row_type,
        rs.operation,
        rs.status,
        rs.input_type,
        rs.start_time,
        rs.end_time,
        rs.elapsed_seconds,
        rs.input_bytes / 1048576         AS input_mb,
        rs.output_bytes / 1048576        AS output_mb,
        rs.input_bytes_per_sec / 1048576 AS throughput_mb_s,
        rs.output_bytes_display,
        rs.time_taken_display,
        rs.compression_ratio
    FROM v$rman_status rs
    WHERE rs.row_type IN ('RMAN STATUS', 'BACKUP')
      AND rs.start_time >= SYSDATE - 7
    ORDER BY rs.start_time DESC
)
WHERE ROWNUM <= 50
"""

_SQL_BACKUP_SETS = """
SELECT * FROM (
    SELECT
        bs.set_count,
        bs.set_stamp,
        bs.backup_type,
        bs.controlfile_included,
        bs.status,
        bs.device_type,
        bs.start_time,
        bs.completion_time,
        bs.elapsed_seconds,
        bs.bytes / 1048576 AS size_mb,
        bs.compressed,
        bs.tag
    FROM v$backup_set bs
    WHERE bs.start_time >= SYSDATE - 7
    ORDER BY bs.start_time DESC
)
WHERE ROWNUM <= 30
"""


class RMANCollector(BaseCollector):

    async def collect(self) -> None:
        # ── Active RMAN monitor (6 sections) ─────────────────────────────
        sessions     = await self.conn.execute_query(_SQL_SESSIONS)
        longops      = await self.conn.execute_query(_SQL_LONGOPS)
        wait_events  = await self.conn.execute_query(_SQL_WAIT_EVENTS)
        disk_io      = await self.conn.execute_query(_SQL_DISK_IO)
        tape_io      = await self.conn.execute_query(_SQL_TAPE_IO)
        perf_summary = await self.conn.fetch_one(_SQL_PERF_SUMMARY)

        self.cache.set("rman.sessions",     sessions,     ttl=self.interval + 2)
        self.cache.set("rman.longops",      longops,      ttl=self.interval + 2)
        self.cache.set("rman.wait_events",  wait_events,  ttl=self.interval + 2)
        self.cache.set("rman.disk_io",      disk_io,      ttl=self.interval + 2)
        self.cache.set("rman.tape_io",      tape_io,      ttl=self.interval + 2)
        self.cache.set("rman.perf_summary", perf_summary, ttl=self.interval + 2)

        # ── Legacy / history ─────────────────────────────────────────────
        history     = await self.conn.execute_query(_SQL_HISTORY)
        backup_sets = await self.conn.execute_query(_SQL_BACKUP_SETS)
        self.cache.set("rman.history",     history,     ttl=60)
        self.cache.set("rman.backup_sets", backup_sets, ttl=60)

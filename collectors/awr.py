"""
collectors/awr.py
AWR snapshots, ADDM findings, ASH sampling.
Cache keys: awr.snapshots, awr.addm, ash.samples
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_SNAPS = """
SELECT * FROM (
    SELECT
        snap_id,
        dbid,
        instance_number,
        begin_interval_time,
        end_interval_time
    FROM dba_hist_snapshot
    ORDER BY snap_id DESC
)
WHERE ROWNUM <= 48
"""

_SQL_ADDM = """
SELECT * FROM (
    SELECT
        task_name,
        advisor_name,
        status,
        error_message,
        to_char(execution_start, 'YYYY-MM-DD HH24:MI') AS exec_start
    FROM dba_advisor_tasks
    WHERE advisor_name = 'ADDM'
    ORDER BY execution_start DESC
)
WHERE ROWNUM <= 10
"""

_SQL_ADDM_FINDINGS = """
SELECT
    f.task_name,
    f.finding_name,
    f.type,
    f.impact_absolute,
    f.message
FROM dba_advisor_findings f
WHERE f.task_name IN (
    SELECT task_name FROM (
        SELECT task_name FROM dba_advisor_tasks
        WHERE advisor_name = 'ADDM'
        ORDER BY execution_start DESC
    ) WHERE ROWNUM = 1
)
ORDER BY f.impact_absolute DESC
"""

_SQL_ASH = """
SELECT * FROM (
    SELECT
        sample_time,
        inst_id,
        session_id,
        session_serial#     AS serial,
        user_id,
        sql_id,
        sql_plan_hash_value,
        event,
        wait_class,
        session_state,
        machine,
        module,
        action,
        blocking_session,
        time_waited
    FROM gv$active_session_history
    WHERE sample_time >= SYSTIMESTAMP - INTERVAL '10' MINUTE
    ORDER BY sample_time DESC
) WHERE ROWNUM <= 500
"""

_SQL_AWR_TOP_SQL = """
SELECT * FROM (
    SELECT
        h.sql_id,
        ROUND(SUM(h.elapsed_time_delta)/1e6, 1)  AS elapsed_secs,
        ROUND(SUM(h.cpu_time_delta)/1e6, 1)       AS cpu_secs,
        SUM(h.executions_delta)                    AS executions,
        SUM(h.buffer_gets_delta)                   AS buffer_gets,
        SUM(h.disk_reads_delta)                    AS disk_reads,
        ROUND(SUM(h.clwait_delta)/1e6, 1)         AS cluster_wait_secs,
        SUBSTR(MAX(t.sql_text), 1, 80)             AS sql_text
    FROM dba_hist_sqlstat h
    JOIN dba_hist_snapshot sn ON sn.snap_id = h.snap_id AND sn.dbid = h.dbid
    LEFT JOIN dba_hist_sqltext t ON t.sql_id = h.sql_id AND t.dbid = h.dbid
    WHERE sn.end_interval_time >= SYSDATE - 1/24
    GROUP BY h.sql_id
    ORDER BY elapsed_secs DESC NULLS LAST
) WHERE ROWNUM <= 15
"""

_SQL_AWR_TOP_WAITS = """
SELECT * FROM (
    SELECT
        e.event_name,
        SUM(e.waits_delta)                         AS total_waits,
        ROUND(SUM(e.time_waited_delta)/1e6, 1)     AS time_waited_secs,
        ROUND(SUM(e.time_waited_delta) / NULLIF(SUM(e.waits_delta),0) / 1000, 2) AS avg_wait_ms,
        MAX(e.wait_class)                          AS wait_class
    FROM dba_hist_system_event e
    JOIN dba_hist_snapshot sn ON sn.snap_id = e.snap_id AND sn.dbid = e.dbid
    WHERE sn.end_interval_time >= SYSDATE - 1/24
      AND e.wait_class != 'Idle'
    GROUP BY e.event_name
    ORDER BY time_waited_secs DESC NULLS LAST
) WHERE ROWNUM <= 15
"""

_SQL_AWR_SYSSTAT = """
SELECT * FROM (
    SELECT
        s.stat_name,
        SUM(s.value_delta) AS total_delta
    FROM dba_hist_sysstat s
    JOIN dba_hist_snapshot sn ON sn.snap_id = s.snap_id AND sn.dbid = s.dbid
    WHERE sn.end_interval_time >= SYSDATE - 1/24
      AND s.stat_name IN (
        'DB time', 'CPU used by this session', 'physical read total bytes',
        'physical write total bytes', 'redo size', 'user calls',
        'execute count', 'hard parses', 'parse time elapsed',
        'sorts (disk)', 'table scans (long tables)'
      )
    GROUP BY s.stat_name
    ORDER BY s.stat_name
) WHERE ROWNUM <= 20
"""

_SQL_TABLESPACES = """
SELECT
    t.tablespace_name,
    t.status,
    ROUND(NVL(d.bytes_alloc, 0) / 1048576, 2)                   AS total_mb,
    ROUND(NVL(d.bytes_alloc - NVL(f.bytes_free, 0), 0) / 1048576, 2) AS used_mb,
    ROUND(NVL(f.bytes_free, 0) / 1048576, 2)                    AS free_mb,
    ROUND((NVL(d.bytes_alloc - NVL(f.bytes_free,0), 0)) /
          NULLIF(d.bytes_alloc, 0) * 100, 1)                    AS used_pct,
    d.autoext
FROM dba_tablespaces t
LEFT JOIN (
    SELECT tablespace_name,
           SUM(bytes) AS bytes_alloc,
           MAX(DECODE(autoextensible,'YES',1,0)) AS autoext
    FROM dba_data_files
    GROUP BY tablespace_name
) d ON d.tablespace_name = t.tablespace_name
LEFT JOIN (
    SELECT tablespace_name, SUM(bytes) AS bytes_free
    FROM dba_free_space
    GROUP BY tablespace_name
) f ON f.tablespace_name = t.tablespace_name
ORDER BY used_pct DESC NULLS LAST
"""


class AWRCollector(BaseCollector):

    async def collect(self) -> None:
        snaps = await self.conn.execute_query(_SQL_SNAPS)
        self.cache.set("awr.snapshots", snaps, ttl=300)

        addm = await self.conn.execute_query(_SQL_ADDM)
        self.cache.set("awr.addm_tasks", addm, ttl=300)

        findings = await self.conn.execute_query(_SQL_ADDM_FINDINGS)
        self.cache.set("awr.addm_findings", findings, ttl=300)

        ash = await self.conn.execute_query(_SQL_ASH)
        self.cache.set("ash.samples", ash, ttl=self.interval + 2)

        ts = await self.conn.execute_query(_SQL_TABLESPACES)
        self.cache.set("awr.tablespaces", ts, ttl=60)

        top_sql = await self.conn.execute_query(_SQL_AWR_TOP_SQL)
        self.cache.set("awr.top_sql", top_sql or [], ttl=120)

        top_waits = await self.conn.execute_query(_SQL_AWR_TOP_WAITS)
        self.cache.set("awr.top_waits", top_waits or [], ttl=120)

        sysstat_rows = await self.conn.execute_query(_SQL_AWR_SYSSTAT)
        sysstat = {r["stat_name"]: r["total_delta"] for r in (sysstat_rows or [])}
        self.cache.set("awr.sysstat", sysstat, ttl=120)

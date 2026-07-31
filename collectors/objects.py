"""
collectors/objects.py
Segment statistics, stale stats, scheduler jobs, wait chains,
SQL Plan Baselines, and Parallel Query monitoring.
Cache keys: obj.top_segments, obj.stale_stats, obj.scheduler_jobs,
            obj.scheduler_history, obj.wait_chains, obj.plan_baselines,
            obj.px_sessions, obj.biggest_segments
"""
from __future__ import annotations

from collectors.base import BaseCollector

_SQL_BIGGEST_SEGMENTS = """
SELECT * FROM (
    SELECT owner, segment_name, segment_type, tablespace_name,
           bytes / 1048576 AS size_mb
    FROM dba_segments
    WHERE owner NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','XDB','APEX_PUBLIC_USER','OUTLN','ORACLE_OCM')
    ORDER BY bytes DESC
) WHERE ROWNUM <= 20
"""

_SQL_TOP_SEGMENTS = """
SELECT * FROM (
    SELECT owner, object_name, object_type, tablespace_name, statistic_name, value
    FROM v$segment_statistics
    WHERE statistic_name IN ('logical reads','physical reads','row lock waits',
                             'buffer busy waits','ITL waits','db block changes')
      AND value > 0
      AND owner NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','XDB','APEX_PUBLIC_USER')
    ORDER BY value DESC
) WHERE ROWNUM <= 50
"""

_SQL_STALE_STATS = """
SELECT * FROM (
    SELECT t.owner, t.table_name, t.num_rows, t.last_analyzed,
        t.stale_stats, t.stattype_locked,
        ROUND((SYSDATE - t.last_analyzed),1) AS days_since_analyze,
        m.inserts + m.updates + m.deletes AS dml_since_analyze
    FROM dba_tab_statistics t
    LEFT JOIN dba_tab_modifications m
        ON t.owner = m.table_owner AND t.table_name = m.table_name
    WHERE t.owner NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','XDB','OUTLN','ORACLE_OCM')
      AND (t.stale_stats = 'YES' OR t.last_analyzed IS NULL
           OR t.last_analyzed < SYSDATE - 7)
    ORDER BY (m.inserts + m.updates + m.deletes) DESC NULLS LAST,
             t.last_analyzed ASC NULLS FIRST
) WHERE ROWNUM <= 30
"""

# Thin mode can't fetch TIMESTAMP WITH TIME ZONE that use a named region
# (DPY-3022), so CAST the scheduler date columns to plain TIMESTAMP.
_SQL_SCHEDULER_JOBS = """
SELECT owner, job_name, job_type, state, enabled,
    CAST(last_start_date AS TIMESTAMP)  AS last_start_date,
    last_run_duration,
    CAST(next_run_date AS TIMESTAMP)    AS next_run_date,
    run_count, failure_count,
    max_failures, comments
FROM dba_scheduler_jobs
WHERE owner NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','ORACLE_OCM','XDB')
ORDER BY state DESC, failure_count DESC, next_run_date
"""

# actual_start_date is TIMESTAMP WITH TIME ZONE (DPY-3022 in thin) and
# additional_info is a CLOB (ORA-00932 when wrapped in a ROWNUM inline view),
# so cast the date and reduce the CLOB to VARCHAR2 with SUBSTR.
_SQL_SCHEDULER_HISTORY = """
SELECT * FROM (
    SELECT owner, job_name, status, error#,
        CAST(actual_start_date AS TIMESTAMP)  AS actual_start_date,
        run_duration,
        cpu_used,
        SUBSTR(additional_info, 1, 200)       AS additional_info
    FROM dba_scheduler_job_run_details
    WHERE owner NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','ORACLE_OCM','XDB')
    ORDER BY actual_start_date DESC
) WHERE ROWNUM <= 50
"""

_SQL_WAIT_CHAINS = """
SELECT * FROM (
    SELECT chain_id, chain_is_cycle,
        chain_signature       AS chain_attribute,
        num_waiters,
        instance              AS instance_id,
        osid, pid, sid, sess_serial#,
        wait_id,
        blocker_sid           AS blocker_wait_id,
        in_wait_secs, time_since_last_wait_secs,
        wait_event_text
    FROM v$wait_chains
    ORDER BY chain_id, wait_id
) WHERE ROWNUM <= 100
"""

_SQL_PLAN_BASELINES = """
SELECT * FROM (
    SELECT sql_handle, plan_name, sql_text,
        creator, origin, parsing_schema_name,
        enabled, accepted, fixed, reproduced, autopurge,
        last_executed, last_modified, created,
        executions, elapsed_time/1000000 AS elapsed_sec,
        cpu_time/1000000 AS cpu_sec, buffer_gets
    FROM dba_sql_plan_baselines
    ORDER BY last_executed DESC NULLS LAST
) WHERE ROWNUM <= 50
"""

_SQL_PX_SESSIONS = """
SELECT * FROM (
    SELECT s.inst_id, s.sid, s.serial#, s.username, s.status,
        p.req_degree AS requested_dop, p.degree AS actual_dop,
        p.server_group, p.server_set,
        s.sql_id, s.event, s.seconds_in_wait
    FROM gv$session s JOIN gv$px_session p
        ON s.sid = p.sid AND s.inst_id = p.inst_id
    WHERE p.qcsid != p.sid
) WHERE ROWNUM <= 30
"""


class ObjectsCollector(BaseCollector):

    async def collect(self) -> None:
        ttl = self.interval + 2

        top_segments = await self.conn.execute_query(_SQL_TOP_SEGMENTS)
        self.cache.set("obj.top_segments", top_segments or [], ttl=ttl)

        stale_stats = await self.conn.execute_query(_SQL_STALE_STATS)
        self.cache.set("obj.stale_stats", stale_stats or [], ttl=300)

        scheduler_jobs = await self.conn.execute_query(_SQL_SCHEDULER_JOBS)
        self.cache.set("obj.scheduler_jobs", scheduler_jobs or [], ttl=60)

        scheduler_history = await self.conn.execute_query(_SQL_SCHEDULER_HISTORY)
        self.cache.set("obj.scheduler_history", scheduler_history or [], ttl=60)

        wait_chains = await self.conn.execute_query(_SQL_WAIT_CHAINS)
        self.cache.set("obj.wait_chains", wait_chains or [], ttl=ttl)

        plan_baselines = await self.conn.execute_query(_SQL_PLAN_BASELINES)
        self.cache.set("obj.plan_baselines", plan_baselines or [], ttl=300)

        px_sessions = await self.conn.execute_query(_SQL_PX_SESSIONS)
        self.cache.set("obj.px_sessions", px_sessions or [], ttl=ttl)

        biggest_segments = await self.conn.execute_query(_SQL_BIGGEST_SEGMENTS)
        self.cache.set("obj.biggest_segments", biggest_segments or [], ttl=300)

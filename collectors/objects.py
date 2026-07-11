"""
collectors/objects.py
Segment statistics, stale stats, scheduler jobs, wait chains,
SQL Plan Baselines, and Parallel Query monitoring.
Cache keys: obj.top_segments, obj.stale_stats, obj.scheduler_jobs,
            obj.scheduler_history, obj.wait_chains, obj.plan_baselines,
            obj.px_sessions
"""
from __future__ import annotations

from collectors.base import BaseCollector

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

_SQL_SCHEDULER_JOBS = """
SELECT owner, job_name, job_type, state, enabled,
    last_start_date, last_run_duration,
    next_run_date, run_count, failure_count,
    max_failures, comments
FROM dba_scheduler_jobs
WHERE owner NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','ORACLE_OCM','XDB')
ORDER BY state DESC, failure_count DESC, next_run_date
"""

_SQL_SCHEDULER_HISTORY = """
SELECT * FROM (
    SELECT owner, job_name, status, error#,
        actual_start_date, run_duration,
        cpu_used, additional_info
    FROM dba_scheduler_job_run_details
    WHERE owner NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','ORACLE_OCM','XDB')
    ORDER BY actual_start_date DESC
) WHERE ROWNUM <= 50
"""

_SQL_WAIT_CHAINS = """
SELECT * FROM (
    SELECT chain_id, chain_is_cycle, chain_attribute,
        num_waiters, instance_id, osid, pid, sid, sess_serial#,
        wait_id, blocker_wait_id,
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
        p.slave_sets, p.px_servers_requested, p.px_servers_allocated,
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

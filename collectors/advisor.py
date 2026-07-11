"""
collectors/advisor.py
Oracle Advisor Framework + SQL Monitor.
Cache keys: advisor.oracle_advisors, advisor.sql_monitor
"""
from __future__ import annotations
import logging
from collectors.base import BaseCollector

log = logging.getLogger(__name__)

_SQL_ADVISORS = """
SELECT * FROM (
    SELECT
        advisor_name,
        COUNT(*)                               AS task_count,
        SUM(CASE WHEN status='COMPLETED' THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN status='ERROR' THEN 1 ELSE 0 END)     AS errors,
        TO_CHAR(MAX(execution_end),'YYYY-MM-DD HH24:MI')    AS last_run,
        MAX(status)                            AS last_status
    FROM dba_advisor_tasks
    WHERE advisor_name IN (
        'ADDM','SQL Tuning Advisor','SQL Access Advisor',
        'Segment Advisor','Undo Advisor','SGA Advisor','PGA Advisor',
        'Buffer Cache Advisor','Shared Pool Advisor','Streams Pool Advisor',
        'Java Pool Advisor','MTTR Advisor','SQL Performance Analyzer',
        'Database Replay','Compression Advisor','Tablespace Advisor'
    )
    GROUP BY advisor_name
    ORDER BY advisor_name
) WHERE ROWNUM <= 20
"""

_SQL_ADVISOR_FINDINGS = """
SELECT * FROM (
    SELECT
        t.advisor_name,
        f.finding_name,
        f.type,
        ROUND(f.impact_absolute, 1)            AS impact,
        f.message
    FROM dba_advisor_findings f
    JOIN dba_advisor_tasks t ON t.task_name = f.task_name
    WHERE t.advisor_name IN ('ADDM','SQL Tuning Advisor','Segment Advisor','Undo Advisor','SGA Advisor','PGA Advisor')
      AND f.task_name IN (
            SELECT task_name FROM (
                SELECT task_name, ROW_NUMBER() OVER (PARTITION BY advisor_name ORDER BY execution_end DESC) rn
                FROM dba_advisor_tasks WHERE status='COMPLETED'
            ) WHERE rn = 1
      )
    ORDER BY f.impact_absolute DESC NULLS LAST
) WHERE ROWNUM <= 20
"""

_SQL_SQL_MONITOR = """
SELECT * FROM (
    SELECT
        sql_id,
        SUBSTR(sql_text, 1, 80)               AS sql_text,
        status,
        username,
        TO_CHAR(last_active_time,'HH24:MI:SS') AS last_active,
        ROUND(elapsed_time/1e6, 1)             AS elapsed_secs,
        ROUND(cpu_time/1e6, 1)                 AS cpu_secs,
        buffer_gets,
        disk_reads,
        rows_processed,
        sid,
        inst_id,
        sql_plan_hash_value
    FROM v$sql_monitor
    WHERE last_active_time > SYSDATE - 1/24
    ORDER BY elapsed_time DESC NULLS LAST
) WHERE ROWNUM <= 20
"""

_SQL_SQL_PLAN_MONITOR = """
SELECT
    sql_id,
    plan_line_id,
    operation,
    object_name,
    cardinality,
    output_rows,
    starts,
    actual_rows,
    elapsed_time/1e6       AS elapsed_secs,
    cpu_time/1e6           AS cpu_secs,
    physical_read_requests AS disk_reads,
    physical_write_requests AS disk_writes,
    status
FROM v$sql_plan_monitor
WHERE sql_id = (
    SELECT sql_id FROM (
        SELECT sql_id FROM v$sql_monitor
        WHERE last_active_time > SYSDATE - 1/24
        ORDER BY elapsed_time DESC NULLS LAST
    ) WHERE ROWNUM = 1
)
ORDER BY plan_line_id
"""


class AdvisorCollector(BaseCollector):

    async def collect(self) -> None:
        advisors = await self.conn.execute_query(_SQL_ADVISORS)
        self.cache.set("advisor.oracle_advisors", advisors or [], ttl=300)

        adv_findings = await self.conn.execute_query(_SQL_ADVISOR_FINDINGS)
        self.cache.set("advisor.oracle_findings", adv_findings or [], ttl=300)

        monitor = await self.conn.execute_query(_SQL_SQL_MONITOR)
        self.cache.set("advisor.sql_monitor", monitor or [], ttl=self.interval + 2)

        if monitor:
            plan = await self.conn.execute_query(_SQL_SQL_PLAN_MONITOR)
            self.cache.set("advisor.sql_plan", plan or [], ttl=self.interval + 2)
        else:
            self.cache.set("advisor.sql_plan", [], ttl=self.interval + 2)

"""
collectors/sql.py
Top SQL by CPU, elapsed, buffer gets, disk reads.
Cache key: sql.top
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_TOP = """
SELECT * FROM (
    SELECT
        s.sql_id,
        s.executions,
        ROUND(s.elapsed_time / 1e6, 2)                  AS elapsed_sec,
        ROUND(s.cpu_time / 1e6, 2)                       AS cpu_sec,
        s.buffer_gets,
        s.disk_reads,
        s.rows_processed,
        s.parse_calls,
        s.sharable_mem / 1024                            AS sharable_kb,
        s.module,
        s.parsing_schema_name,
        SUBSTR(s.sql_text, 1, 120)                       AS sql_text_short,
        ROUND(s.cpu_time / NULLIF(s.executions, 0) / 1e6, 4) AS cpu_per_exec,
        ROUND(s.elapsed_time / NULLIF(s.executions, 0) / 1e6, 4) AS ela_per_exec,
        ROUND(s.buffer_gets / NULLIF(s.executions, 0), 0)    AS gets_per_exec
    FROM gv$sql s
    WHERE s.executions > 0
      AND s.parsing_schema_name NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN')
    ORDER BY s.cpu_time DESC
)
WHERE ROWNUM <= 30
"""

_SQL_TEXT_FULL = """
SELECT sql_fulltext
FROM   v$sqlarea
WHERE  sql_id = :sql_id
"""

_SQL_EXPLAIN = """
EXPLAIN PLAN SET STATEMENT_ID = :stmt_id FOR
"""


class SQLCollector(BaseCollector):

    async def collect(self) -> None:
        rows = await self.conn.execute_query(_SQL_TOP)
        self.cache.set("sql.top", rows, ttl=self.interval + 2)

        # Scalar aggregates for graph ring-buffers
        if rows:
            total_cpu     = sum(float(r.get("cpu_sec", 0) or 0)      for r in rows)
            total_elapsed = sum(float(r.get("elapsed_sec", 0) or 0)   for r in rows)
            total_buf_k   = sum(int(r.get("buffer_gets", 0) or 0)     for r in rows) / 1000.0
            self.cache.set("sql.total_cpu_sec",     total_cpu,     ttl=self.interval + 2)
            self.cache.set("sql.total_elapsed_sec", total_elapsed,  ttl=self.interval + 2)
            self.cache.set("sql.total_buffer_gets", total_buf_k,    ttl=self.interval + 2)

    async def fetch_full_text(self, sql_id: str) -> str:
        row = await self.conn.fetch_one(_SQL_TEXT_FULL, {"sql_id": sql_id})
        if row:
            text = row.get("sql_fulltext")
            return str(text) if text else ""
        return ""

    async def fetch_explain_plan(self, sql_id: str) -> list[dict]:
        sql = """
            SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(:sql_id, NULL, 'ALLSTATS LAST'))
        """
        return await self.conn.execute_query(sql, {"sql_id": sql_id})

    async def fetch_sql_monitor(self, sql_id: str) -> list[dict]:
        sql = """
            SELECT
                sql_id,
                status,
                elapsed_time / 1e6 AS elapsed_sec,
                cpu_time / 1e6     AS cpu_sec,
                buffer_gets,
                disk_reads,
                sql_plan_hash_value
            FROM v$sql_monitor
            WHERE sql_id = :sql_id
            ORDER BY last_refresh_time DESC
        """
        return await self.conn.execute_query(sql, {"sql_id": sql_id})

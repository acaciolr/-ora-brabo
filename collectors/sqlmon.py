"""
collectors/sqlmon.py
Real-Time SQL Monitor — GV$SQL_MONITOR.
Cache keys: sqlmon.active, sqlmon.recent
"""
from __future__ import annotations

from collectors.base import BaseCollector

_SQL_MONITOR = """
SELECT * FROM (
    SELECT m.inst_id, m.key, m.sid, m.sql_id, m.sql_exec_id, m.status,
        m.username, m.module, m.program,
        ROUND(m.elapsed_time/1000000,2)   AS elapsed_sec,
        ROUND(m.cpu_time/1000000,2)       AS cpu_sec,
        m.buffer_gets, m.disk_reads,
        ROUND(m.physical_write_bytes/1048576,2) AS phys_write_mb,
        m.fetches, m.executions,
        m.px_servers_requested, m.px_servers_allocated,
        ROUND(m.io_interconnect_bytes/1048576,2) AS interconnect_mb,
        m.sql_text
    FROM gv$sql_monitor m
    WHERE m.status IN ('EXECUTING','DONE (ERROR)','DONE')
    ORDER BY m.last_refresh_time DESC
) WHERE ROWNUM <= 30
"""


class SQLMonitorCollector(BaseCollector):

    async def collect(self) -> None:
        ttl = self.interval + 2

        rows = await self.conn.execute_query(_SQL_MONITOR)
        rows = rows or []

        active = [r for r in rows if r.get("status") == "EXECUTING"]
        recent = [r for r in rows if r.get("status") != "EXECUTING"]

        self.cache.set("sqlmon.active", active, ttl=ttl)
        self.cache.set("sqlmon.recent", recent, ttl=ttl)

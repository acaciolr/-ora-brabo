"""
collectors/waits.py
Top system wait events and active session waits.
Cache keys: waits.system_top, waits.active_sessions
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_SYSTEM_WAITS = """
SELECT * FROM (
    SELECT
        e.event,
        e.wait_class,
        e.total_waits,
        e.total_timeouts,
        ROUND(e.time_waited_micro / 1e6, 2)              AS time_waited_sec,
        ROUND(e.time_waited_micro / NULLIF(e.total_waits,0) / 1000, 2) AS avg_wait_ms
    FROM gv$system_event e
    WHERE e.wait_class != 'Idle'
    ORDER BY e.time_waited_micro DESC
)
WHERE ROWNUM <= 20
"""

_SQL_ACTIVE_WAITS = """
SELECT
    s.inst_id,
    s.sid,
    s.username,
    s.event,
    s.wait_class,
    s.seconds_in_wait,
    s.state,
    s.p1text, s.p1,
    s.p2text, s.p2,
    s.sql_id
FROM gv$session s
WHERE s.type = 'USER'
  AND s.wait_class != 'Idle'
  AND s.status = 'ACTIVE'
ORDER BY s.seconds_in_wait DESC
"""

_SQL_WAIT_CLASS = """
SELECT
    wait_class,
    COUNT(*) AS session_count,
    ROUND(AVG(seconds_in_wait), 2) AS avg_wait_sec
FROM gv$session
WHERE type = 'USER'
  AND wait_class != 'Idle'
  AND status = 'ACTIVE'
GROUP BY wait_class
ORDER BY session_count DESC
"""


class WaitsCollector(BaseCollector):

    async def collect(self) -> None:
        system_waits = await self.conn.execute_query(_SQL_SYSTEM_WAITS)
        self.cache.set("waits.system_top", system_waits, ttl=self.interval + 2)

        active_waits = await self.conn.execute_query(_SQL_ACTIVE_WAITS)
        self.cache.set("waits.active_sessions", active_waits, ttl=self.interval + 2)

        wait_class = await self.conn.execute_query(_SQL_WAIT_CLASS)
        self.cache.set("waits.by_class", wait_class, ttl=self.interval + 2)

        # Scalar aggregates for graph ring-buffers
        non_idle = [w for w in system_waits if w.get("wait_class", "") != "Idle"]
        top_wait  = float(non_idle[0].get("time_waited_sec", 0) or 0) if non_idle else 0.0
        total_sec = sum(float(w.get("time_waited_sec", 0) or 0) for w in non_idle)
        self.cache.set("waits.top_wait_sec",       top_wait,          ttl=self.interval + 2)
        self.cache.set("waits.non_idle_total_sec", total_sec,         ttl=self.interval + 2)
        self.cache.set("waits.active_count",       float(len(active_waits)), ttl=self.interval + 2)

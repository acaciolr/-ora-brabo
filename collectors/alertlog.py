"""
collectors/alertlog.py
Alert log monitoring — ORA- errors, incidents, problems.
Cache keys: alertlog.recent, alertlog.incidents
"""
from __future__ import annotations

from collectors.base import BaseCollector

_SQL_ALERT_LOG = """
SELECT * FROM (
    SELECT originating_timestamp, message_text, message_level,
        component_id, host_id, instance_id
    FROM v$diag_alert_ext
    WHERE message_text LIKE 'ORA-%'
       OR message_level <= 2
    ORDER BY originating_timestamp DESC
) WHERE ROWNUM <= 100
"""

_SQL_INCIDENTS = """
SELECT p.problem_id, p.problem_key, p.last_incident_id,
    COUNT(i.incident_id) AS incident_count,
    MAX(i.create_time)   AS last_time
FROM v$diag_problem p
JOIN v$diag_incident i ON p.problem_id = i.problem_id
GROUP BY p.problem_id, p.problem_key, p.last_incident_id
ORDER BY MAX(i.create_time) DESC
"""


class AlertLogCollector(BaseCollector):

    async def collect(self) -> None:
        ttl = self.interval + 2

        recent = await self.conn.execute_query(_SQL_ALERT_LOG)
        self.cache.set("alertlog.recent", recent or [], ttl=ttl)

        incidents = await self.conn.execute_query(_SQL_INCIDENTS)
        self.cache.set("alertlog.incidents", incidents or [], ttl=60)

"""
collectors/rac.py
RAC instance overview: GV$INSTANCE, GV$SYSSTAT, GCS/GES stats.
Cache key: rac.instances, rac.detected
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_DETECT = """
SELECT value FROM v$parameter WHERE name = 'cluster_database'
"""

_SQL_INSTANCES = """
SELECT
    i.inst_id,
    i.instance_name,
    i.host_name,
    i.status,
    i.startup_time,
    (SELECT COUNT(*) FROM gv$session s
     WHERE s.inst_id = i.inst_id AND s.type = 'USER') AS total_sessions,
    (SELECT COUNT(*) FROM gv$session s
     WHERE s.inst_id = i.inst_id AND s.type = 'USER' AND s.status = 'ACTIVE') AS active_sessions
FROM gv$instance i
ORDER BY i.inst_id
"""

_SQL_GC_STATS = """
SELECT
    inst_id,
    name,
    value
FROM gv$sysstat
WHERE name IN (
    'gc cr blocks received',
    'gc current blocks received',
    'gc cr block receive time',
    'gc current block receive time',
    'gc cr blocks served',
    'gc current blocks served'
)
ORDER BY inst_id, name
"""

_SQL_INTERCONNECT = """
SELECT
    inst_id,
    name,
    ip_address,
    is_public,
    source
FROM gv$cluster_interconnects
ORDER BY inst_id
"""

_SQL_SERVICES = """
SELECT
    s.name,
    s.network_name,
    s.enabled,
    s.goal,
    s.clb_goal,
    NVL2(sv.name, 'RUNNING', 'STOPPED') AS svc_status,
    sv.inst_id
FROM dba_services s
LEFT JOIN (
    SELECT DISTINCT name, MIN(inst_id) AS inst_id FROM gv$active_services GROUP BY name
) sv ON sv.name = s.name
WHERE s.name NOT IN ('SYS$BACKGROUND','SYS$USERS','SYS$AUTOTASK')
ORDER BY s.name
"""


class RACCollector(BaseCollector):

    _is_rac: bool | None = None

    async def collect(self) -> None:
        # Detect RAC once
        if self._is_rac is None:
            row = await self.conn.fetch_one(_SQL_DETECT)
            self._is_rac = (row or {}).get("value", "FALSE").upper() == "TRUE"
            self.cache.set("rac.detected", self._is_rac, ttl=300)

        if not self._is_rac:
            return

        instances = await self.conn.execute_query(_SQL_INSTANCES)
        self.cache.set("rac.instances", instances, ttl=self.interval + 2)

        gc_stats = await self.conn.execute_query(_SQL_GC_STATS)
        self.cache.set("rac.gc_stats", self._pivot_gc(gc_stats), ttl=self.interval + 2)

        interconnect = await self.conn.execute_query(_SQL_INTERCONNECT)
        self.cache.set("rac.interconnect", interconnect, ttl=60)

        services = await self.conn.execute_query(_SQL_SERVICES)
        self.cache.set("rac.services", services or [], ttl=30)

    def _pivot_gc(self, rows: list[dict]) -> dict[int, dict]:
        """Return {inst_id: {stat_name: value}}."""
        result: dict[int, dict] = {}
        for r in rows:
            inst = r["inst_id"]
            result.setdefault(inst, {})[r["name"]] = r["value"]

        # Compute GC latency (microseconds per block)
        for inst, stats in result.items():
            cr_blocks = stats.get("gc cr blocks received", 0) or 1
            cr_time   = stats.get("gc cr block receive time", 0) or 0
            cu_blocks = stats.get("gc current blocks received", 0) or 1
            cu_time   = stats.get("gc current block receive time", 0) or 0
            stats["gc_cr_latency_ms"]  = round(cr_time / cr_blocks / 1000, 3)
            stats["gc_cur_latency_ms"] = round(cu_time / cu_blocks / 1000, 3)

        return result

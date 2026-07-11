"""
collectors/health.py
Collects: CPU, memory, SGA, PGA, sessions, key rates.
Cache keys: health.*
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_SYSSTAT = """
SELECT name, value
FROM   v$sysstat
WHERE  name IN (
    'logons cumulative',
    'execute count',
    'redo size',
    'hard parses',
    'user commits',
    'user rollbacks',
    'physical reads',
    'logical reads',
    'bytes sent via SQL*Net to client',
    'bytes received via SQL*Net from client'
)
"""

_SQL_SESSIONS = """
SELECT
    COUNT(*)                                           AS total_sessions,
    SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_sessions
FROM v$session
WHERE type = 'USER'
"""

_SQL_SGA = """
SELECT
    SUM(bytes) / 1024 / 1024  AS sga_mb
FROM v$sgastat
"""

_SQL_PGA = """
SELECT value / 1024 / 1024 AS pga_mb
FROM   v$pgastat
WHERE  name = 'total PGA allocated'
"""

_SQL_CPU = """
SELECT
    ROUND(value, 2) AS cpu_pct
FROM v$osstat
WHERE stat_name = 'LOAD'
"""

_SQL_MEMORY = """
SELECT
    ROUND(free_memory_mb, 1) AS free_mb,
    ROUND(total_memory_mb, 1) AS total_mb
FROM (
    SELECT
        (SELECT value FROM v$osstat WHERE stat_name = 'FREE_MEMORY_BYTES') / 1048576 AS free_memory_mb,
        (SELECT value FROM v$osstat WHERE stat_name = 'PHYSICAL_MEMORY_BYTES') / 1048576 AS total_memory_mb
    FROM dual
)
"""

_SQL_DB_INFO = """
SELECT
    d.dbid,
    d.name            AS db_name,
    d.db_unique_name,
    d.open_mode,
    d.database_role,
    d.flashback_on,
    d.log_mode,
    d.cdb,
    i.version,
    i.host_name,
    i.instance_name,
    i.startup_time,
    i.status          AS inst_status,
    i.instance_number
FROM v$database d, v$instance i
"""


class HealthCollector(BaseCollector):

    _prev_stats: dict = {}

    async def collect(self) -> None:
        # DB identity
        db_info = await self.conn.fetch_one(_SQL_DB_INFO)
        if db_info:
            self.cache.set("health.db_info", db_info, ttl=30)

        # Sessions
        sess = await self.conn.fetch_one(_SQL_SESSIONS)
        if sess:
            self.cache.set("health.total_sessions",  sess["total_sessions"],  ttl=self.interval + 2)
            self.cache.set("health.active_sessions", sess["active_sessions"], ttl=self.interval + 2)

        # SGA
        sga = await self.conn.fetch_one(_SQL_SGA)
        if sga:
            self.cache.set("health.sga_mb", sga["sga_mb"], ttl=30)

        # PGA
        pga = await self.conn.fetch_one(_SQL_PGA)
        if pga:
            self.cache.set("health.pga_mb", pga["pga_mb"], ttl=self.interval + 2)

        # CPU Load
        cpu = await self.conn.fetch_one(_SQL_CPU)
        if cpu:
            self.cache.set("health.cpu_load", cpu["cpu_pct"], ttl=self.interval + 2)

        # Memory
        mem = await self.conn.fetch_one(_SQL_MEMORY)
        if mem:
            self.cache.set("health.memory", mem, ttl=self.interval + 2)

        # Rate metrics
        stats = await self.conn.execute_query(_SQL_SYSSTAT)
        stats_map = {r["name"]: r["value"] for r in stats}
        rates = self._compute_rates(stats_map)
        self.cache.set("health.rates", rates, ttl=self.interval + 2)

    def _compute_rates(self, current: dict) -> dict:
        """Compute per-second rates by diffing against previous snapshot."""
        rates: dict = {}
        if not self._prev_stats:
            self._prev_stats = current
            return rates

        interval = self.interval or 5

        def rate(key: str) -> float:
            prev = self._prev_stats.get(key, 0) or 0
            curr = current.get(key, 0) or 0
            delta = max(0, curr - prev)
            return round(delta / interval, 2)

        rates["logons_per_sec"]       = rate("logons cumulative")
        rates["executes_per_sec"]     = rate("execute count")
        rates["redo_mb_per_sec"]      = round(rate("redo size") / 1_048_576, 4)
        rates["hard_parses_per_sec"]  = rate("hard parses")
        rates["commits_per_sec"]      = rate("user commits")
        rates["rollbacks_per_sec"]    = rate("user rollbacks")
        rates["physical_reads_per_sec"] = rate("physical reads")
        rates["logical_reads_per_sec"]  = rate("logical reads")
        rates["net_sent_mb_per_sec"]    = round(rate("bytes sent via SQL*Net to client") / 1_048_576, 4)
        rates["net_recv_mb_per_sec"]    = round(rate("bytes received via SQL*Net from client") / 1_048_576, 4)

        self._prev_stats = current
        return rates

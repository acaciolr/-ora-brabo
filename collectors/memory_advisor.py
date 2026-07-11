"""
collectors/memory_advisor.py
Memory advisory, buffer pool, latch, and mutex monitoring.
Cache keys: mem.sga_advice, mem.pga_advice, mem.pga_stats, mem.buffer_pool,
            mem.db_cache_advice, mem.resize_ops, mem.latches, mem.mutex_sleep
"""
from __future__ import annotations

from collectors.base import BaseCollector

_SQL_SGA_ADVICE = """
SELECT sga_size, sga_size_factor,
    ROUND(estd_db_time,2)         AS estd_db_time,
    ROUND(estd_db_time_factor,4)  AS estd_db_time_factor,
    estd_physical_reads
FROM v$sga_target_advice ORDER BY sga_size
"""

_SQL_PGA_ADVICE = """
SELECT pga_target_for_estimate/1048576 AS pga_target_mb,
    pga_target_factor,
    ROUND(estd_pga_cache_hit_percentage,2) AS estd_hit_pct,
    estd_overalloc_count
FROM v$pga_target_advice ORDER BY pga_target_for_estimate
"""

_SQL_PGA_STATS = """
SELECT name, value FROM v$pgastat
WHERE name IN ('aggregate PGA target parameter','aggregate PGA auto target',
               'global memory bound','total PGA inuse','total PGA allocated',
               'maximum PGA allocated','total freeable PGA memory',
               'PGA memory freed back to OS','total PGA used for auto workareas',
               'over allocation count','bytes processed','extra bytes read/written',
               'cache hit percentage','recompute count (total)')
"""

_SQL_BUFFER_POOL = """
SELECT name, block_size,
    ROUND(physical_reads*block_size/1048576,2)   AS phys_read_mb,
    ROUND(physical_writes*block_size/1048576,2)  AS phys_write_mb,
    db_block_gets + consistent_gets              AS logical_reads,
    ROUND((1 - physical_reads/NULLIF(db_block_gets+consistent_gets,0))*100,2) AS hit_pct,
    free_buffer_wait, write_complete_wait, buffer_busy_wait
FROM v$buffer_pool_statistics ORDER BY name
"""

_SQL_DB_CACHE_ADVICE = """
SELECT size_for_estimate/1048576 AS cache_size_mb, size_factor,
    ROUND(estd_physical_read_factor,4) AS estd_phys_read_factor,
    estd_physical_reads
FROM v$db_cache_advice
WHERE block_size = (SELECT value FROM v$parameter WHERE name='db_block_size')
  AND advice_status = 'ON'
ORDER BY size_for_estimate
"""

_SQL_RESIZE_OPS = """
SELECT * FROM (
    SELECT component, oper_type, oper_mode,
        ROUND(initial_size/1048576,1) AS initial_mb,
        ROUND(target_size/1048576,1)  AS target_mb,
        ROUND(final_size/1048576,1)   AS final_mb,
        status, start_time, end_time,
        ROUND((end_time-start_time)*86400,1) AS duration_sec
    FROM v$memory_resize_ops
    ORDER BY start_time DESC
) WHERE ROWNUM <= 20
"""

_SQL_LATCHES = """
SELECT * FROM (
    SELECT name, gets, misses,
        ROUND(misses/NULLIF(gets,0)*100,4) AS miss_pct,
        sleeps, spin_gets, wait_time/100 AS wait_ms
    FROM v$latch
    WHERE gets > 0
    ORDER BY sleeps DESC
) WHERE ROWNUM <= 20
"""

_SQL_MUTEX_SLEEP = """
SELECT * FROM (
    SELECT mutex_type, location, sleeps, wait_time/1000 AS wait_ms
    FROM v$mutex_sleep
    ORDER BY sleeps DESC
) WHERE ROWNUM <= 20
"""


class MemoryAdvisorCollector(BaseCollector):

    async def collect(self) -> None:
        ttl = self.interval + 2

        sga_advice = await self.conn.execute_query(_SQL_SGA_ADVICE)
        self.cache.set("mem.sga_advice", sga_advice or [], ttl=60)

        pga_advice = await self.conn.execute_query(_SQL_PGA_ADVICE)
        self.cache.set("mem.pga_advice", pga_advice or [], ttl=60)

        pga_stats = await self.conn.execute_query(_SQL_PGA_STATS)
        self.cache.set("mem.pga_stats", pga_stats or [], ttl=ttl)

        buffer_pool = await self.conn.execute_query(_SQL_BUFFER_POOL)
        self.cache.set("mem.buffer_pool", buffer_pool or [], ttl=ttl)

        db_cache_advice = await self.conn.execute_query(_SQL_DB_CACHE_ADVICE)
        self.cache.set("mem.db_cache_advice", db_cache_advice or [], ttl=60)

        resize_ops = await self.conn.execute_query(_SQL_RESIZE_OPS)
        self.cache.set("mem.resize_ops", resize_ops or [], ttl=60)

        latches = await self.conn.execute_query(_SQL_LATCHES)
        self.cache.set("mem.latches", latches or [], ttl=ttl)

        mutex_sleep = await self.conn.execute_query(_SQL_MUTEX_SLEEP)
        self.cache.set("mem.mutex_sleep", mutex_sleep or [], ttl=ttl)

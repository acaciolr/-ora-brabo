"""
core/scheduler.py
Async scheduler — drives all collectors at configurable intervals.
"""

from __future__ import annotations

import asyncio
import logging

from core.cache import MetricsCache
from core.connection_manager import ConnectionManager
from collectors.sessions import SessionsCollector
from collectors.sql import SQLCollector
from collectors.waits import WaitsCollector
from collectors.rac import RACCollector
from collectors.dg import DataGuardCollector
from collectors.asm import ASMCollector
from collectors.rman import RMANCollector
from collectors.awr import AWRCollector
from collectors.health import HealthCollector
from collectors.exadata import ExadataCollector
from collectors.advisor import AdvisorCollector
from collectors.pdb import PDBCollector
from collectors.io_activity import IOActivityCollector
from collectors.memory_advisor import MemoryAdvisorCollector
from collectors.objects import ObjectsCollector
from collectors.sqlmon import SQLMonitorCollector
from collectors.alertlog import AlertLogCollector

log = logging.getLogger(__name__)


class Scheduler:
    """
    Runs all metric collectors concurrently.
    Each collector has its own interval to avoid thundering-herd.
    """

    def __init__(
        self,
        conn_manager: ConnectionManager,
        cache: MetricsCache,
        refresh_interval: int = 5,
    ) -> None:
        self.conn_manager = conn_manager
        self.cache = cache
        self.refresh_interval = refresh_interval
        self._running = False
        self._tasks: list[asyncio.Task] = []

        # Instantiate collectors
        self.collectors = [
            HealthCollector(conn_manager, cache, interval=refresh_interval),
            SessionsCollector(conn_manager, cache, interval=refresh_interval),
            SQLCollector(conn_manager, cache, interval=refresh_interval * 2),
            WaitsCollector(conn_manager, cache, interval=refresh_interval),
            RACCollector(conn_manager, cache, interval=refresh_interval),
            DataGuardCollector(conn_manager, cache, interval=refresh_interval * 2),
            ASMCollector(conn_manager, cache, interval=refresh_interval * 3),
            RMANCollector(conn_manager, cache, interval=refresh_interval * 2),
            AWRCollector(conn_manager, cache, interval=60),
            ExadataCollector(conn_manager, cache, interval=30),
            AdvisorCollector(conn_manager, cache, interval=refresh_interval * 2),
            PDBCollector(conn_manager, cache, interval=refresh_interval * 2),
            IOActivityCollector(conn_manager, cache, interval=15),
            MemoryAdvisorCollector(conn_manager, cache, interval=30),
            ObjectsCollector(conn_manager, cache, interval=60),
            SQLMonitorCollector(conn_manager, cache, interval=10),
            AlertLogCollector(conn_manager, cache, interval=30),
        ]

    # Collectors backing the first-visible panels (Dashboard/Sessions/SQL/
    # Waits). Primed first so the initial screen paints almost immediately.
    _PRIME_PRIORITY = 4

    async def run(self) -> None:
        self._running = True
        log.info("Scheduler started with %d collectors.", len(self.collectors))

        # ── Phase 1: prime the cache with one immediate collection ──
        # Dashboard-critical collectors first, then the rest — all concurrent
        # (bounded by the pool). This fills panels in ~1s instead of waiting
        # out a per-collector startup stagger.
        priority = self.collectors[: self._PRIME_PRIORITY]
        rest     = self.collectors[self._PRIME_PRIORITY :]
        await asyncio.gather(*(self._safe_collect(c) for c in priority),
                             return_exceptions=True)
        await asyncio.gather(*(self._safe_collect(c) for c in rest),
                             return_exceptions=True)
        log.info("Initial collection complete; entering steady state.")

        # ── Phase 2: steady-state interval loops (sleep-first, already primed) ──
        self._tasks = [
            asyncio.create_task(self._steady_loop(c), name=c.__class__.__name__)
            for c in self.collectors
        ]
        await asyncio.gather(*self._tasks, return_exceptions=True)

    async def stop(self) -> None:
        self._running = False
        for task in self._tasks:
            task.cancel()
        await asyncio.gather(*self._tasks, return_exceptions=True)
        log.info("Scheduler stopped.")

    async def _safe_collect(self, collector: "BaseCollector") -> None:
        """Run one collection, swallowing errors so one bad collector never
        blocks the others."""
        try:
            await collector.collect()
        except asyncio.CancelledError:
            raise
        except Exception as exc:
            log.warning("Collector %s error: %s", collector.__class__.__name__, exc)

    async def _steady_loop(self, collector: "BaseCollector") -> None:
        """Interval loop after priming: sleep first, then re-collect."""
        while self._running:
            try:
                await asyncio.sleep(collector.interval)
            except asyncio.CancelledError:
                break
            if not self._running:
                break
            await self._safe_collect(collector)

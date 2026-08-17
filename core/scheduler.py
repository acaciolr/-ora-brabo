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
from collectors.plan_hist import PlanHistCollector
from collectors.jobs import JobsCollector

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

        # ── Interval tiers (seconds) by query weight ─────────────────────
        # realtime : light queries you watch live (Health/Waits)
        # fast     : moderate, still frequent (Sessions/SQL/RAC/SQL Monitor)
        # medium   : slow-changing (ASM/DG/RMAN/IO/PDB)
        # slow     : advisory / seldom-changing
        # heavy    : expensive scans — kept spaced out to protect a prod DB
        rt    = min(refresh_interval, 2)
        fast  = max(refresh_interval, 3)
        med   = max(refresh_interval * 2, 12)
        slow  = 30
        heavy = 60

        # Order matters: the first _PRIME_PRIORITY collectors back the
        # first-visible panels and are primed first on startup.
        self.collectors = [
            HealthCollector(conn_manager, cache, interval=rt),
            WaitsCollector(conn_manager, cache, interval=rt),
            SessionsCollector(conn_manager, cache, interval=fast),
            SQLCollector(conn_manager, cache, interval=fast),
            RACCollector(conn_manager, cache, interval=fast),
            SQLMonitorCollector(conn_manager, cache, interval=fast),
            DataGuardCollector(conn_manager, cache, interval=med),
            ASMCollector(conn_manager, cache, interval=med),
            RMANCollector(conn_manager, cache, interval=med),
            IOActivityCollector(conn_manager, cache, interval=med),
            PDBCollector(conn_manager, cache, interval=med),
            JobsCollector(conn_manager, cache, interval=med),
            ExadataCollector(conn_manager, cache, interval=slow),
            AdvisorCollector(conn_manager, cache, interval=slow),
            MemoryAdvisorCollector(conn_manager, cache, interval=slow),
            AWRCollector(conn_manager, cache, interval=heavy),
            ObjectsCollector(conn_manager, cache, interval=heavy),
            AlertLogCollector(conn_manager, cache, interval=heavy),
            PlanHistCollector(conn_manager, cache, interval=heavy),
        ]
        self._by_name = {c.__class__.__name__: c for c in self.collectors}

    # Collectors backing the first-visible panels (Dashboard/Waits/Sessions/
    # SQL). Primed first so the initial screen paints almost immediately.
    _PRIME_PRIORITY = 4

    # Which collector(s) feed each panel — used to refresh on panel switch.
    _PANEL_COLLECTORS = {
        "dashboard":     ["HealthCollector", "WaitsCollector", "RACCollector"],
        "sessions":      ["SessionsCollector"],
        "topsql":        ["SQLCollector"],
        "waits":         ["WaitsCollector"],
        "locks":         ["SessionsCollector"],
        "rac":           ["RACCollector"],
        "dataguard":     ["DataGuardCollector"],
        "asm":           ["ASMCollector"],
        "rman":          ["RMANCollector"],
        "awr":           ["AWRCollector"],
        "ash":           ["AWRCollector"],
        "advisor":       ["AdvisorCollector"],
        "exadata":       ["ExadataCollector"],
        "pdb":           ["PDBCollector"],
        "io":            ["IOActivityCollector"],
        "memory":        ["MemoryAdvisorCollector"],
        "segments":      ["ObjectsCollector"],
        "sqlmonitor":    ["SQLMonitorCollector"],
        "alertlog":      ["AlertLogCollector"],
        "waitchains":    ["ObjectsCollector"],
        "planbaselines": ["ObjectsCollector"],
        "parallelquery": ["ObjectsCollector"],
        "planhist":      ["PlanHistCollector"],
        "jobs":          ["JobsCollector"],
    }

    def collect_now(self, panel_key: str) -> None:
        """Fire a one-shot collection for the collector(s) behind a panel, so
        switching to it shows fresh data immediately instead of waiting for the
        next interval. No-op for panels without a collector (e.g. report)."""
        if not self._running:
            return
        for name in self._PANEL_COLLECTORS.get(panel_key, []):
            collector = self._by_name.get(name)
            if collector is not None:
                asyncio.create_task(self._safe_collect(collector))

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

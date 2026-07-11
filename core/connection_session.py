"""
core/connection_session.py
Bundles one Oracle connection with its own cache, scheduler and advisor engine.
Each tab in the UI corresponds to exactly one ConnectionSession.
"""
from __future__ import annotations

import asyncio
import logging
import uuid

from advisor.engine import AdvisorEngine
from core.config import AppConfig
from core.connection_manager import ConnectionManager
from core.cache import MetricsCache
from core.scheduler import Scheduler

log = logging.getLogger(__name__)


class ConnectionSession:
    """All runtime objects for one Oracle connection (one tab)."""

    _HEALTH_INTERVAL  = 15   # seconds between health checks
    _HEALTH_THRESHOLD = 3    # consecutive failures before marking unhealthy

    def __init__(self, config: AppConfig) -> None:
        self.id: str = uuid.uuid4().hex[:8]
        self.config = config
        self.conn_manager = ConnectionManager(config)
        self.cache = MetricsCache()
        self.scheduler: Scheduler | None = None
        self.advisor: AdvisorEngine | None = None
        self.connected: bool = False
        self.is_healthy: bool = True
        self._tasks: list[asyncio.Task] = []

    @property
    def label(self) -> str:
        """Tab label — uses db_name once connected, falls back to service@host."""
        if self.config.demo:
            return self.config.label or "DEMO — ORCL@oraserver01"
        if self.config.label:
            return self.config.label
        db_info = self.cache.get("health.db_info") or {}
        db_name = db_info.get("db_name")
        host_short = self.config.host.split(".")[0] if self.config.host else ""
        name = db_name or self.config.service
        return f"{name}@{host_short}"

    async def connect(self) -> None:
        """Open pool, start scheduler and advisor tasks (or demo runner)."""
        if self.config.demo:
            await self._start_demo()
            return

        await self.conn_manager.connect()
        self.connected = True

        self.scheduler = Scheduler(
            conn_manager=self.conn_manager,
            cache=self.cache,
            refresh_interval=self.config.refresh_interval,
        )
        self.advisor = AdvisorEngine(
            conn_manager=self.conn_manager,
            cache=self.cache,
            interval=self.config.advisor_eval_interval_sec,
        )
        self._tasks = [
            asyncio.create_task(self.scheduler.run(),       name=f"sched-{self.id}"),
            asyncio.create_task(self.advisor.run(),         name=f"adv-{self.id}"),
            asyncio.create_task(self._health_check_loop(), name=f"health-{self.id}"),
        ]
        log.info("Session %s connected: %s", self.id, self.label)

    async def _health_check_loop(self) -> None:
        """Periodically checks connectivity; attempts reconnect on failure."""
        failures = 0
        await asyncio.sleep(self._HEALTH_INTERVAL)
        while True:
            try:
                row = await self.conn_manager.fetch_one("SELECT 1 AS ok FROM DUAL", {})
                if row is not None:
                    if not self.is_healthy:
                        log.info("Session %s recovered — marking healthy", self.id)
                        self.is_healthy = True
                    failures = 0
                else:
                    raise RuntimeError("DUAL returned no rows")
            except asyncio.CancelledError:
                break
            except Exception as exc:
                failures += 1
                log.warning("Session %s health check #%d failed: %s", self.id, failures, exc)
                if failures >= self._HEALTH_THRESHOLD and self.is_healthy:
                    self.is_healthy = False
                    log.error("Session %s marked unhealthy", self.id)
                if not self.is_healthy:
                    try:
                        await self.conn_manager.close()
                        await self.conn_manager.connect()
                        self.is_healthy = True
                        failures = 0
                        log.info("Session %s reconnected successfully", self.id)
                    except Exception as re_exc:
                        log.warning("Session %s reconnect failed: %s", self.id, re_exc)
            try:
                await asyncio.sleep(self._HEALTH_INTERVAL)
            except asyncio.CancelledError:
                break

    async def _start_demo(self) -> None:
        """Start demo mode — no DB, fake data only."""
        from core.demo_data import DemoRunner
        self._demo_runner = DemoRunner(self.cache, interval=self.config.refresh_interval)
        self.connected = True
        self._tasks = [
            asyncio.create_task(self._demo_runner.run(), name=f"demo-{self.id}"),
        ]
        log.info("Demo session %s started.", self.id)

    async def close(self) -> None:
        """Cancel tasks and close connection pool."""
        if hasattr(self, "_demo_runner"):
            self._demo_runner.stop()
        if self.scheduler:
            await self.scheduler.stop()
        for task in self._tasks:
            task.cancel()
        await asyncio.gather(*self._tasks, return_exceptions=True)
        if not self.config.demo:
            await self.conn_manager.close()
        self.connected = False
        log.info("Session %s closed.", self.id)

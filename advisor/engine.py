"""
advisor/engine.py
Continuous advisor: reads cache, applies rules, produces findings.
Cache key: advisor.findings
"""

from __future__ import annotations

import asyncio
import logging
import time
from dataclasses import dataclass, field
from enum import Enum

from core.cache import MetricsCache
from core.connection_manager import ConnectionManager

log = logging.getLogger(__name__)


class Severity(str, Enum):
    CRITICAL = "CRITICAL"
    WARNING  = "WARNING"
    INFO     = "INFO"


@dataclass
class Finding:
    severity: Severity
    category: str
    title: str
    detail: str
    suggestion: str
    impact: str = ""
    sql_id: str = ""
    timestamp: float = field(default_factory=time.monotonic)


class AdvisorEngine:
    """
    Rule-based advisor. Runs every N seconds, reads the metrics cache
    and generates prioritized recommendations.
    """

    def __init__(
        self,
        conn_manager: ConnectionManager,
        cache: MetricsCache,
        interval: int = 30,
    ) -> None:
        self.conn = conn_manager
        self.cache = cache
        self.interval = interval
        self._running = False

    async def run(self) -> None:
        self._running = True
        while self._running:
            try:
                findings = await self._evaluate()
                self.cache.set("advisor.findings", findings, ttl=self.interval + 5)
            except Exception as exc:
                log.warning("Advisor error: %s", exc)
            await asyncio.sleep(self.interval)

    async def stop(self) -> None:
        self._running = False

    # ------------------------------------------------------------------
    # Evaluation
    # ------------------------------------------------------------------

    async def _evaluate(self) -> list[Finding]:
        findings: list[Finding] = []
        findings.extend(self._check_top_sql())
        findings.extend(self._check_sessions())
        findings.extend(self._check_waits())
        findings.extend(self._check_tablespaces())
        findings.extend(self._check_rman())
        findings.extend(self._check_dg())
        findings.extend(self._check_fra())
        findings.extend(self._check_health())
        # Sort: CRITICAL first, then WARNING, then INFO
        order = {Severity.CRITICAL: 0, Severity.WARNING: 1, Severity.INFO: 2}
        findings.sort(key=lambda f: order[f.severity])
        return findings[:50]  # cap at 50 visible findings

    # ------------------------------------------------------------------
    # Rules
    # ------------------------------------------------------------------

    def _check_top_sql(self) -> list[Finding]:
        findings: list[Finding] = []
        sql_top: list[dict] = self.cache.get("sql.top", [])
        if not sql_top:
            return findings

        total_cpu = sum(r.get("cpu_sec", 0) or 0 for r in sql_top)

        for row in sql_top[:10]:
            cpu_sec = row.get("cpu_sec", 0) or 0
            gets    = row.get("buffer_gets", 0) or 0
            execs   = row.get("executions", 1) or 1
            sql_id  = row.get("sql_id", "")
            schema  = row.get("parsing_schema_name", "")
            text    = row.get("sql_text_short", "")

            pct_cpu = (cpu_sec / total_cpu * 100) if total_cpu > 0 else 0

            if pct_cpu > 30:
                findings.append(Finding(
                    severity   = Severity.CRITICAL,
                    category   = "Top SQL",
                    title      = f"SQL_ID {sql_id} consuming {pct_cpu:.0f}% of total CPU",
                    detail     = f"Schema: {schema} | Executions: {execs:,} | CPU/exec: {cpu_sec/execs:.3f}s\n{text}",
                    suggestion = "Consider index tuning, SQL rewrite, or result cache.",
                    impact     = f"CPU -{pct_cpu:.0f}%",
                    sql_id     = sql_id,
                ))
            elif pct_cpu > 15:
                findings.append(Finding(
                    severity   = Severity.WARNING,
                    category   = "Top SQL",
                    title      = f"SQL_ID {sql_id} consuming {pct_cpu:.0f}% of total CPU",
                    detail     = f"Schema: {schema} | Buffer Gets: {gets:,}",
                    suggestion = "Review execution plan. Check for full table scans.",
                    sql_id     = sql_id,
                ))

            gets_per_exec = gets / execs
            if gets_per_exec > 1_000_000:
                findings.append(Finding(
                    severity   = Severity.WARNING,
                    category   = "Top SQL",
                    title      = f"SQL_ID {sql_id} doing {gets_per_exec/1e6:.1f}M buffer gets/exec",
                    detail     = f"Schema: {schema} | Total gets: {gets:,}",
                    suggestion = "Likely missing index or Cartesian join. Run EXPLAIN PLAN.",
                    sql_id     = sql_id,
                ))

        return findings

    def _check_sessions(self) -> list[Finding]:
        findings: list[Finding] = []
        total    = self.cache.get("sessions.total_count", 0) or 0
        active   = self.cache.get("sessions.active_count", 0) or 0

        if total > 500:
            findings.append(Finding(
                severity   = Severity.WARNING,
                category   = "Sessions",
                title      = f"High session count: {total}",
                detail     = f"Active: {active}",
                suggestion = "Consider connection pooling (DRCP or application pool).",
            ))

        # Blocking sessions
        sessions: list[dict] = self.cache.get("sessions.list", [])
        blockers = {r["blocking_session"] for r in sessions if r.get("blocking_session")}
        if len(blockers) > 3:
            findings.append(Finding(
                severity   = Severity.CRITICAL,
                category   = "Locks",
                title      = f"{len(blockers)} blocking sessions detected",
                detail     = f"Blocker SIDs: {', '.join(str(b) for b in list(blockers)[:10])}",
                suggestion = "Navigate to F5 Locks panel. Kill blocker(s) if appropriate.",
            ))

        return findings

    def _check_waits(self) -> list[Finding]:
        findings: list[Finding] = []
        waits: list[dict] = self.cache.get("waits.system_top", [])
        for w in waits[:5]:
            event   = w.get("event", "")
            avg_ms  = w.get("avg_wait_ms", 0) or 0
            wclass  = w.get("wait_class", "")

            if "log file sync" in event and avg_ms > 20:
                findings.append(Finding(
                    severity   = Severity.WARNING,
                    category   = "Waits",
                    title      = f"'log file sync' avg {avg_ms:.1f}ms — possible I/O contention",
                    detail     = f"Wait class: {wclass}",
                    suggestion = "Check redo log I/O. Consider moving redo to faster disk or ASM.",
                ))
            elif "db file sequential read" in event and avg_ms > 15:
                findings.append(Finding(
                    severity   = Severity.WARNING,
                    category   = "Waits",
                    title      = f"'db file sequential read' avg {avg_ms:.1f}ms",
                    detail     = "Single-block reads are slow. Check storage latency.",
                    suggestion = "Review AWR for high-I/O segments. Check storage health.",
                ))
            elif "buffer busy waits" in event:
                findings.append(Finding(
                    severity   = Severity.WARNING,
                    category   = "Waits",
                    title      = "Buffer busy waits detected",
                    detail     = f"Avg wait: {avg_ms:.1f}ms",
                    suggestion = "Check for hot blocks. Consider reverse key indexes or partitioning.",
                ))

        return findings

    def _check_tablespaces(self) -> list[Finding]:
        findings: list[Finding] = []
        ts_list: list[dict] = self.cache.get("awr.tablespaces", [])
        for ts in ts_list:
            pct  = ts.get("used_pct") or 0
            name = ts.get("tablespace_name", "")
            free = ts.get("free_mb", 0) or 0
            auto = ts.get("autoext", 0)

            if pct >= 95 and not auto:
                findings.append(Finding(
                    severity   = Severity.CRITICAL,
                    category   = "Storage",
                    title      = f"Tablespace {name} at {pct:.1f}% — no AUTOEXTEND",
                    detail     = f"Free: {free:.0f} MB",
                    suggestion = "Add datafile or enable AUTOEXTEND immediately.",
                ))
            elif pct >= 85 and not auto:
                findings.append(Finding(
                    severity   = Severity.WARNING,
                    category   = "Storage",
                    title      = f"Tablespace {name} at {pct:.1f}%",
                    detail     = f"Free: {free:.0f} MB | AUTOEXTEND: OFF",
                    suggestion = "Monitor closely. Add datafile proactively.",
                ))

        return findings

    def _check_rman(self) -> list[Finding]:
        findings: list[Finding] = []
        history: list[dict] = self.cache.get("rman.history", [])
        failed = [r for r in history if r.get("status") == "FAILED"]
        if failed:
            findings.append(Finding(
                severity   = Severity.CRITICAL,
                category   = "RMAN",
                title      = f"{len(failed)} RMAN backup(s) FAILED in last 7 days",
                detail     = f"Last failure: {failed[0].get('start_time', 'unknown')}",
                suggestion = "Check RMAN log. Navigate to F9 RMAN panel.",
            ))
        return findings

    def _check_dg(self) -> list[Finding]:
        findings: list[Finding] = []
        stats: dict = self.cache.get("dg.stats", {})
        if not stats:
            return findings

        lag = stats.get("Apply Lag", {}).get("value", "")
        if lag and lag != "+00 00:00:00":
            findings.append(Finding(
                severity   = Severity.WARNING,
                category   = "Data Guard",
                title      = f"Apply Lag detected: {lag}",
                detail     = "Standby is behind primary.",
                suggestion = "Check MRP process. Navigate to F7 Data Guard panel.",
            ))

        transport_lag = stats.get("Transport Lag", {}).get("value", "")
        if transport_lag and transport_lag != "+00 00:00:00":
            findings.append(Finding(
                severity   = Severity.WARNING,
                category   = "Data Guard",
                title      = f"Transport Lag detected: {transport_lag}",
                detail     = "Redo transport to standby is delayed.",
                suggestion = "Check network and LOG_ARCHIVE_DEST configuration.",
            ))

        return findings

    def _check_fra(self) -> list[Finding]:
        findings: list[Finding] = []
        fra: dict | None = self.cache.get("asm.fra")
        if not fra:
            return findings
        pct = fra.get("used_pct", 0) or 0
        if pct >= 85:
            findings.append(Finding(
                severity   = Severity.CRITICAL if pct >= 95 else Severity.WARNING,
                category   = "FRA",
                title      = f"FRA usage at {pct:.1f}%",
                detail     = f"Used: {fra.get('fra_used_gb', 0):.1f} GB / {fra.get('fra_total_gb', 0):.1f} GB",
                suggestion = "Delete obsolete backups or increase DB_RECOVERY_FILE_DEST_SIZE.",
            ))
        return findings

    def _check_health(self) -> list[Finding]:
        findings: list[Finding] = []
        cpu = self.cache.get("health.cpu_load", 0) or 0
        if cpu > 8:
            findings.append(Finding(
                severity   = Severity.WARNING,
                category   = "System",
                title      = f"OS load average is high: {cpu}",
                detail     = "System may be CPU-constrained.",
                suggestion = "Check Top SQL and active sessions for runaway queries.",
            ))
        rates: dict = self.cache.get("health.rates", {})
        hp = rates.get("hard_parses_per_sec", 0) or 0
        if hp > 100:
            findings.append(Finding(
                severity   = Severity.WARNING,
                category   = "Performance",
                title      = f"Hard parses/sec: {hp:.0f}",
                detail     = "High hard parse rate increases latch contention.",
                suggestion = "Use bind variables. Check cursor_sharing parameter.",
            ))
        return findings

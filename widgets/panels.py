"""
widgets/panels.py
All Textual panels — one class per F-key screen.
Dolphie-inspired professional layout using Rich Table.grid(), Panel, Columns, and charts helpers.
"""

from __future__ import annotations

import asyncio
import logging
import time
from datetime import datetime
from typing import TYPE_CHECKING

from rich import box as rich_box
from rich.console import Group, RenderableType
from rich.table import Table
from rich.text import Text
from rich.panel import Panel
from rich.columns import Columns
from rich.tree import Tree
from textual.app import ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal
from textual.widget import Widget
from textual.widgets import DataTable, Label, Static

from core.cache import MetricsCache
from core.connection_manager import ConnectionManager
from widgets.charts import (
    Graph, sparkline, pct_bar, fmt, color_for_pct,
    spark_row, wait_bar, metric_row,
)
from widgets.confirm_modal import ConfirmModal

if TYPE_CHECKING:
    pass

log = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

SEVERITY_COLORS = {"CRITICAL": "bold red", "WARNING": "bold yellow", "INFO": "cyan"}


# ---------------------------------------------------------------------------
# Base panel
# ---------------------------------------------------------------------------

class BasePanel(Widget):
    REFRESH_RATE: int = 1   # seconds between refresh_data() calls; subclasses override

    DEFAULT_CSS = """
    BasePanel {
        height: 100%;
        overflow-y: auto;
        background: $surface;
        padding: 0 1;
    }
    .hidden { display: none; }
    """

    def __init__(self, conn_manager: ConnectionManager, cache: MetricsCache, **kwargs) -> None:
        super().__init__(**kwargs)
        self.conn = conn_manager
        self.cache = cache
        self._last_refresh: float = 0.0

    async def tick(self) -> None:
        """Called every second; gates refresh_data() via REFRESH_RATE."""
        now = time.monotonic()
        if now - self._last_refresh >= self.REFRESH_RATE:
            self._last_refresh = now
            await self.refresh_data()

    async def refresh_data(self) -> None:
        self.refresh()


# ---------------------------------------------------------------------------
# 1. DASHBOARD
# ---------------------------------------------------------------------------

class DashboardPanel(BasePanel):

    DEFAULT_CSS = BasePanel.DEFAULT_CSS + """
    #dash-charts {
        height: 14;
        margin: 0;
        padding: 0;
    }
    #dash-charts Graph {
        width: 1fr;
        height: 14;
        margin: 0 1;
    }
    """

    def compose(self) -> ComposeResult:
        yield Static(id="dash-header")
        yield Static(id="dash-metrics")
        with Horizontal(id="dash-charts"):
            yield Graph(
                "CPU Load",
                color=(84, 239, 174),      # green
                unit="",
                id="graph-cpu",
            )
            yield Graph(
                "Active Sessions",
                color=(68, 180, 255),      # blue
                unit="",
                id="graph-sessions",
            )
            yield Graph(
                "Redo MB/s",
                color=(252, 213, 121),     # yellow
                unit="",
                id="graph-redo",
            )
            yield Graph(
                "Executes/s",
                color=(191, 121, 252),     # purple
                unit="",
                id="graph-exec",
            )
        yield Static(id="dash-waits")
        yield Static(id="dash-rac-dg")
        yield Static(id="dash-exa")

    async def refresh_data(self) -> None:
        self._render_header()
        self._render_metrics()
        self._render_graphs()
        self._render_waits()
        self._render_rac_dg()
        self._render_exa()

    def _render_header(self) -> None:
        info: dict = self.cache.get("health.db_info", {}) or {}
        startup = info.get("startup_time")
        uptime = "N/A"
        if startup:
            delta = datetime.now() - startup
            d, s = divmod(int(delta.total_seconds()), 86400)
            h, s = divmod(s, 3600)
            m, s = divmod(s, 60)
            uptime = f"{d}d {h:02d}:{m:02d}:{s:02d}"

        role = info.get("database_role", "?")
        role_color = "green" if role == "PRIMARY" else "yellow"
        open_mode = info.get("open_mode", "?")
        open_color = "green" if open_mode == "READ WRITE" else "yellow"

        t = Table.grid(expand=True, padding=(0, 2))
        t.add_column(ratio=2)
        t.add_column(ratio=2)
        t.add_column(ratio=2)
        t.add_column(ratio=2)
        t.add_column(ratio=2)
        t.add_row(
            f"[bold cyan]{info.get('db_name', '?')}[/] ({info.get('db_unique_name', '?')})",
            f"[dim]v[/]{info.get('version', '?')}",
            f"[{role_color}]{role}[/]",
            f"[{open_color}]{open_mode}[/]",
            f"[dim]up[/] [bold]{uptime}[/]",
        )
        t.add_row(
            f"[dim]host:[/] {info.get('host_name', '?')}",
            f"[dim]inst:[/] {info.get('instance_name', '?')}",
            f"[dim]log:[/] {info.get('log_mode', '?')}",
            f"[dim]cdb:[/] {info.get('cdb', 'NO')}",
            f"[dim]flashback:[/] {info.get('flashback_on', '?')}",
        )
        self.query_one("#dash-header", Static).update(
            Panel(t, title="[bold white] ORA BRABO [/]", border_style="blue", padding=(0, 1))
        )

    def _render_metrics(self) -> None:
        total   = self.cache.get("health.total_sessions", 0) or 0
        active  = self.cache.get("health.active_sessions", 0) or 0
        sga_mb  = self.cache.get("health.sga_mb", 0) or 0
        pga_mb  = self.cache.get("health.pga_mb", 0) or 0
        cpu     = self.cache.get("health.cpu_load", 0) or 0
        rates   = self.cache.get("health.rates", {}) or {}
        mem     = self.cache.get("health.memory", {}) or {}

        free_mb  = mem.get("free_mb", 0) or 0
        total_mb = mem.get("total_mb", 1) or 1
        mem_pct  = (1 - free_mb / total_mb) * 100

        # Blocked sessions
        sessions = self.cache.get("sessions.list", []) or []
        blocked = sum(1 for s in sessions if s.get("blocking_session"))

        blocked_color = "red" if blocked > 0 else "green"

        # CPU load bar (scaled: assume max useful load = 16)
        cpu_pct = min(cpu / 16 * 100, 100)
        cpu_color = color_for_pct(cpu_pct)

        # ── Column 1: Health ───────────────────────────────────────────
        health_t = Table.grid(padding=(0, 1))
        health_t.add_column(width=16)
        health_t.add_column()
        health_t.add_row("[dim]CPU Load[/]",    f"[{cpu_color}]{cpu:.2f}[/]")
        health_t.add_row("[dim][/]",             pct_bar(cpu_pct, width=14, show_pct=False))
        health_t.add_row("[dim]Sessions[/]",
                         f"[bold]{total}[/] total  [green]{active}[/] act  [{blocked_color}]{blocked}[/] blk")
        health_t.add_row("[dim]Redo MB/s[/]",   f"[yellow]{rates.get('redo_mb_per_sec', 0):.2f}[/]")
        health_t.add_row("[dim]Logons/s[/]",    fmt(rates.get("logons_per_sec"), 2))

        # ── Column 2: Performance ─────────────────────────────────────
        phys_reads = rates.get("physical_reads_per_sec", 0) or 0
        pr_color   = "red" if phys_reads > 10000 else ("yellow" if phys_reads > 1000 else "green")
        perf_t = Table.grid(padding=(0, 1))
        perf_t.add_column(width=16)
        perf_t.add_column()
        perf_t.add_row("[dim]Executes/s[/]",   f"[bold]{rates.get('executes_per_sec', 0):,.0f}[/]")
        perf_t.add_row("[dim]Hard Parses/s[/]", f"[yellow]{rates.get('hard_parses_per_sec', 0):.1f}[/]")
        perf_t.add_row("[dim]Commits/s[/]",     fmt(rates.get("commits_per_sec"), 1))
        perf_t.add_row("[dim]Rollbacks/s[/]",   fmt(rates.get("rollbacks_per_sec"), 2))
        perf_t.add_row("[dim]Phys Reads/s[/]",  f"[{pr_color}]{phys_reads:,.0f}[/]")

        # ── Column 3: Memory ──────────────────────────────────────────
        total_mb = mem.get("total_mb", 0) or 0
        mem_t = Table.grid(padding=(0, 1))
        mem_t.add_column(width=16)
        mem_t.add_column()
        mem_t.add_row("[dim]SGA[/]",       f"[bold]{sga_mb:,.0f}[/] MB")
        mem_t.add_row("[dim]PGA[/]",       f"[bold]{pga_mb:,.0f}[/] MB")
        mem_t.add_row("[dim]RAM Used[/]",  pct_bar(mem_pct, width=14, show_pct=True))
        mem_t.add_row("[dim]RAM Free[/]",  f"{free_mb:,.0f} MB")
        mem_t.add_row("[dim]Total RAM[/]", f"[dim]{total_mb/1024:,.1f} GB[/]")

        outer = Table.grid(expand=True, padding=(0, 2))
        outer.add_column(ratio=1)
        outer.add_column(ratio=1)
        outer.add_column(ratio=1)
        outer.add_row(
            Panel(health_t, title="[bold green]Health[/]", border_style="green", padding=(0, 1)),
            Panel(perf_t,   title="[bold cyan]Performance[/]", border_style="cyan", padding=(0, 1)),
            Panel(mem_t,    title="[bold magenta]Memory[/]", border_style="magenta", padding=(0, 1)),
        )
        self.query_one("#dash-metrics", Static).update(outer)

    def _render_graphs(self) -> None:
        """Push history values into the Dolphie-style plotext Graph widgets."""
        cpu_hist = self.cache.get_history_values("health.cpu_load")
        sess_hist = self.cache.get_history_values("health.active_sessions")

        rates_hist = self.cache.get_history_values("health.rates")
        redo_hist = [
            r.get("redo_mb_per_sec", 0) if isinstance(r, dict) else 0
            for r in rates_hist
        ]
        exec_hist = [
            r.get("executes_per_sec", 0) if isinstance(r, dict) else 0
            for r in rates_hist
        ]

        self.query_one("#graph-cpu",      Graph).update_data([float(v) for v in cpu_hist])
        self.query_one("#graph-sessions", Graph).update_data([float(v) for v in sess_hist])
        self.query_one("#graph-redo",     Graph).update_data([float(v) for v in redo_hist])
        self.query_one("#graph-exec",     Graph).update_data([float(v) for v in exec_hist])

    def _render_waits(self) -> None:
        waits = self.cache.get("waits.system_top", []) or []
        # Filter out idle waits for dashboard display
        visible = [w for w in waits if w.get("wait_class", "") != "Idle"][:6]
        max_time = max((w.get("time_waited_secs", 0) or 0 for w in visible), default=1) or 1

        lines = Text()
        for w in visible:
            lines.append_text(wait_bar(
                event=str(w.get("event", "")),
                time_s=float(w.get("time_waited_secs", 0) or 0),
                max_time=max_time,
                wait_class=str(w.get("wait_class", "")),
                bar_width=20,
            ))
            lines.append("\n")

        if not visible:
            lines.append("  No significant wait events.", style="dim")

        self.query_one("#dash-waits", Static).update(
            Panel(lines, title="[bold yellow]Top Wait Events[/]", border_style="yellow", padding=(0, 1))
        )

    def _render_rac_dg(self) -> None:
        # ── RAC ───────────────────────────────────────────────────────
        is_rac    = self.cache.get("rac.detected", False)
        instances = self.cache.get("rac.instances", []) or []
        info: dict = self.cache.get("health.db_info", {}) or {}

        if is_rac and instances:
            rac_t = Table(show_header=True, header_style="bold magenta",
                          box=None, padding=(0, 1), expand=True)
            rac_t.add_column("Inst",   width=5)
            rac_t.add_column("Host",   ratio=2)
            rac_t.add_column("Status", width=8)
            rac_t.add_column("Sess",   width=6, justify="right")
            rac_t.add_column("Active", width=6, justify="right")
            for row in instances:
                status = str(row.get("status", ""))
                sc = "green" if status == "OPEN" else "red"
                rac_t.add_row(
                    str(row.get("inst_id", "")),
                    str(row.get("host_name", "")),
                    Text(status, style=sc),
                    str(row.get("total_sessions", "")),
                    str(row.get("active_sessions", "")),
                )
            rac_body: RenderableType = rac_t
            rac_border = "magenta"
            rac_title  = "[bold magenta]RAC Instances[/]"
        else:
            # Single instance — show key facts so height matches DG panel
            total  = self.cache.get("health.total_sessions",  0) or 0
            active = self.cache.get("health.active_sessions", 0) or 0
            si = Table.grid(padding=(0, 1), expand=True)
            si.add_column(width=18, style="dim")
            si.add_column()
            si.add_row("Topology:",    Text("Single Instance", style="cyan"))
            si.add_row("Instance:",    Text(str(info.get("instance_name", "N/A")), style="white"))
            si.add_row("Host:",        Text(str(info.get("host_name",     "N/A")), style="dim"))
            si.add_row("Status:",      Text(str(info.get("open_mode",     "N/A")),
                                           style="green" if info.get("open_mode") == "READ WRITE" else "yellow"))
            si.add_row("Sessions:",    Text(f"{active} active / {total} total", style="white"))
            rac_body   = si
            rac_border = "#30363d"
            rac_title  = "[bold #8b949e]RAC[/]"

        rac_panel = Panel(rac_body, title=rac_title, border_style=rac_border, padding=(0, 1))

        # ── Data Guard ────────────────────────────────────────────────
        role  = self.cache.get("dg.role", "") or ""
        stats = self.cache.get("dg.stats", {}) or {}
        mode  = self.cache.get("dg.protection_mode", "") or "N/A"

        if role:
            apply_lag     = stats.get("Apply Lag",     {}).get("value", "N/A")
            transport_lag = stats.get("Transport Lag", {}).get("value", "N/A")
            gap_list      = self.cache.get("dg.archive_gap", []) or []
            gap           = len(gap_list) if isinstance(gap_list, list) else (1 if gap_list else 0)
            gap_color     = "red" if gap > 0 else "green"
            role_color    = "green" if role == "PRIMARY" else "yellow"

            dg_t = Table.grid(padding=(0, 1), expand=True)
            dg_t.add_column(width=18, style="dim")
            dg_t.add_column()
            dg_t.add_row("Role:",           Text(role, style=role_color))
            dg_t.add_row("Protection:",     Text(mode, style="white"))
            dg_t.add_row("Apply Lag:",      Text(str(apply_lag),     style="yellow"))
            dg_t.add_row("Transport Lag:",  Text(str(transport_lag), style="yellow"))
            dg_t.add_row("Archive Gap:",    Text(str(gap),           style=gap_color))
            dg_panel = Panel(dg_t, title="[bold yellow]Data Guard[/]",
                             border_style="yellow", padding=(0, 1))
        else:
            dg_t = Table.grid(padding=(0, 1), expand=True)
            dg_t.add_column(width=18, style="dim")
            dg_t.add_column()
            dg_t.add_row("Role:",          Text("N/A", style="dim"))
            dg_t.add_row("Protection:",    Text("N/A", style="dim"))
            dg_t.add_row("Apply Lag:",     Text("N/A", style="dim"))
            dg_t.add_row("Transport Lag:", Text("N/A", style="dim"))
            dg_t.add_row("Archive Gap:",   Text("N/A", style="dim"))
            dg_panel = Panel(dg_t, title="[bold #8b949e]Data Guard[/]",
                             border_style="#30363d", padding=(0, 1))

        # Rich Table (not grid) equalizes row height across both cells
        outer = Table(show_header=False, box=None, expand=True,
                      show_edge=False, padding=(0, 1))
        outer.add_column(ratio=1)
        outer.add_column(ratio=1)
        outer.add_row(rac_panel, dg_panel)
        self.query_one("#dash-rac-dg", Static).update(outer)

    def _render_exa(self) -> None:
        is_exa = self.cache.get("exa.detected", False)
        if not is_exa:
            self.query_one("#dash-exa", Static).update(Text(""))
            return

        smart = self.cache.get("exa.smart_scan", {}) or {}
        flash = self.cache.get("exa.flash_cache", {}) or {}

        t = Table.grid(expand=True, padding=(0, 2))
        t.add_column(ratio=1)
        t.add_column(ratio=1)
        t.add_column(ratio=1)
        t.add_row(
            f"[bold yellow]EXADATA[/]  Smart Scan: [cyan]{smart.get('smart_scan_pct', 0):.1f}%[/]",
            f"Storage Index savings: [cyan]{smart.get('storage_index_pct', 0):.1f}%[/]",
            f"Flash Cache hit: [cyan]{flash.get('hit_pct', 0):.1f}%[/]",
        )
        self.query_one("#dash-exa", Static).update(
            Panel(t, title="[bold yellow]Exadata[/]", border_style="yellow", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 2. SESSIONS
# ---------------------------------------------------------------------------

class SessionsPanel(BasePanel):

    BINDINGS = [
        Binding("d", "session_detail", "Detail",       show=True),
        Binding("/", "toggle_filter",  "Filter",        show=True),
    ]

    def compose(self) -> ComposeResult:
        from textual.widgets import Input
        yield Static(id="sess-label")
        yield Input(placeholder="Filter: username / sql_id / machine / event …",
                    id="sess-filter", classes="hidden")
        yield DataTable(id="sess-table")

    async def refresh_data(self) -> None:
        from textual.widgets import Input
        sessions = self.cache.get("sessions.list", []) or []

        # Apply filter
        try:
            filter_val = self.query_one("#sess-filter", Input).value.lower().strip()
        except Exception:
            filter_val = ""
        if filter_val:
            sessions = [s for s in sessions if any(
                filter_val in str(s.get(k, "") or "").lower()
                for k in ("username", "sql_id", "machine", "event", "program", "module")
            )]

        dt: DataTable = self.query_one("#sess-table")
        if not dt.columns:
            dt.add_columns(
                "I", "SID", "Serial", "Username", "Status",
                "Event", "Wait Class", "SQL_ID",
                "Machine", "Program", "Blocking", "Wait(s)",
            )
        cursor = dt.cursor_row
        dt.clear()
        for r in sessions:
            status = r.get("status", "")
            blocking = r.get("blocking_session")
            if blocking:
                row_style = "red"
            elif status == "ACTIVE":
                row_style = "green"
            else:
                row_style = "dim"

            wait_class = str(r.get("wait_class", "") or "")
            event = str(r.get("event", "") or "")

            dt.add_row(
                str(r.get("inst_id", "") or ""),
                str(r.get("sid", "")),
                str(r.get("serial", "")),
                str(r.get("username", "") or ""),
                Text.from_markup(f"[{row_style}]{status}[/]"),
                Text.from_markup(f"[{row_style}]{event}[/]"),
                wait_class,
                str(r.get("sql_id", "") or ""),
                str(r.get("machine", "") or ""),
                str(r.get("program", "") or ""),
                Text.from_markup(f"[red]{blocking}[/]") if blocking else Text(""),
                str(r.get("last_call_et", "") or ""),
            )

        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))

        lbl: Static = self.query_one("#sess-label")
        total  = self.cache.get("sessions.total_count", len(sessions))
        active = self.cache.get("sessions.active_count", 0)
        blocked = sum(1 for s in sessions if s.get("blocking_session"))
        blocked_color = "red" if blocked > 0 else "green"
        filter_hint = " [cyan][/Filter on][/]" if filter_val else ""
        lbl.update(
            f"[bold]Total:[/] {total}  "
            f"[bold green]Active:[/] {active}  "
            f"[{blocked_color}]Blocked:[/] {blocked}  "
            f"[dim]  K=Kill  T=Trace  D=Detail  /=Filter[/]{filter_hint}"
        )

    def action_toggle_filter(self) -> None:
        from textual.widgets import Input
        inp = self.query_one("#sess-filter", Input)
        if "hidden" in inp.classes:
            inp.remove_class("hidden")
            inp.focus()
        else:
            inp.add_class("hidden")
            inp.value = ""
            self.query_one("#sess-table").focus()

    async def action_session_detail(self) -> None:
        from widgets.session_detail_screen import SessionDetailScreen
        dt = self.query_one("#sess-table", DataTable)
        sessions = self.cache.get("sessions.list", []) or []
        row = dt.cursor_row
        if row < 0 or row >= len(sessions):
            return
        self.app.push_screen(SessionDetailScreen(sessions[row]))

    async def action_kill(self) -> None:
        row = self.query_one("#sess-table", DataTable).cursor_row
        sessions = self.cache.get("sessions.list", []) or []
        if row >= len(sessions):
            return
        s   = sessions[row]
        sql = f"ALTER SYSTEM KILL SESSION '{s['sid']},{s['serial']}' IMMEDIATE"

        async def _do_kill() -> None:
            ok = await self.conn.execute_ddl(sql)
            self.app.notify(
                f"Kill {'OK' if ok else 'FAILED'}: {s['sid']},{s['serial']}",
                severity="information" if ok else "error",
            )

        def on_confirm(confirmed: bool) -> None:
            if confirmed:
                asyncio.create_task(_do_kill())

        self.app.push_screen(ConfirmModal(
            title="Kill Oracle Session",
            body=f"Kill SID {s['sid']}, Serial# {s['serial']} "
                 f"({s.get('username', '?')} @ {s.get('machine', '?')})?",
            command=sql,
        ), on_confirm)

    async def action_trace(self) -> None:
        row = self.query_one("#sess-table", DataTable).cursor_row
        sessions = self.cache.get("sessions.list", []) or []
        if row >= len(sessions):
            return
        s   = sessions[row]
        sql = (f"EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE"
               f"({s['sid']},{s['serial']},TRUE,TRUE)")

        async def _do_trace() -> None:
            ok = await self.conn.execute_ddl(sql)
            self.app.notify(
                f"Trace {'enabled' if ok else 'FAILED'}: {s['sid']},{s['serial']}",
                severity="information" if ok else "error",
            )

        def on_confirm(confirmed: bool) -> None:
            if confirmed:
                asyncio.create_task(_do_trace())

        self.app.push_screen(ConfirmModal(
            title="Enable SQL Trace",
            body=f"Enable 10046 trace on SID {s['sid']}, Serial# {s['serial']} "
                 f"({s.get('username', '?')})?",
            command=sql,
        ), on_confirm)


# ---------------------------------------------------------------------------
# 3. TOP SQL
# ---------------------------------------------------------------------------

class TopSQLPanel(BasePanel):

    BINDINGS = [
        Binding("enter", "show_explain", "Explain Plan", show=True),
        Binding("s",     "input_sql_id", "SQL ID...",    show=True),
    ]

    DEFAULT_CSS = BasePanel.DEFAULT_CSS + """
    #sql-charts {
        height: 12;
        margin: 0;
        padding: 0;
    }
    #sql-charts Graph {
        width: 1fr;
        height: 12;
        margin: 0 1;
    }
    """

    # cache the list so the row-highlight handler can read it without re-fetching
    _sql_top: list[dict] = []

    def compose(self) -> ComposeResult:
        yield Static(id="sql-header")
        with Horizontal(id="sql-charts"):
            yield Graph("CPU Seconds (Top SQL)", color=(252,  89,  86), unit="s", id="graph-sql-cpu")
            yield Graph("Elapsed Seconds",       color=( 68, 180, 255), unit="s", id="graph-sql-ela")
            yield Graph("Buffer Gets (K)",       color=(226, 183,  20), unit="K", id="graph-sql-buf")
        yield DataTable(id="sql-table")
        yield Static(id="sql-preview")

    # ── Event: update preview when the cursor moves ──────────────────
    def on_data_table_row_highlighted(self, event: DataTable.RowHighlighted) -> None:
        rows = self._sql_top
        idx  = event.cursor_row
        if not rows or idx < 0 or idx >= len(rows):
            return
        r       = rows[idx]
        sql_id  = str(r.get("sql_id", "") or "")
        schema  = str(r.get("parsing_schema_name", "") or "?")
        sql_txt = str(r.get("sql_text", "") or r.get("sql_text_short", "") or "")

        prev = Text()
        prev.append(f"  SQL ID: ", style="dim")
        prev.append(f"{sql_id}    ", style="bold cyan")
        prev.append(f"Schema: ", style="dim")
        prev.append(f"{schema}\n  ", style="cyan")
        prev.append(sql_txt[:300], style="dim")

        self.query_one("#sql-preview", Static).update(
            Panel(prev, title="[bold #bbc8e8]SQL Preview[/]",
                  border_style="#384c7a", padding=(0, 1))
        )

    async def refresh_data(self) -> None:
        sql_top = self.cache.get("sql.top", []) or []
        self._sql_top = sql_top

        total_cpu  = sum(float(r.get("cpu_secs") or r.get("cpu_sec") or 0) for r in sql_top) or 1
        total_ela  = sum(float(r.get("elapsed_secs") or r.get("elapsed_sec") or 0) for r in sql_top)
        total_exec = sum(int(r.get("executions", 0) or 0) for r in sql_top)
        total_buf  = sum(int(r.get("buffer_gets", 0) or 0) for r in sql_top)
        total_disk = sum(int(r.get("disk_reads", 0) or 0) for r in sql_top)

        # dominant schema
        from collections import Counter
        schemas = Counter(str(r.get("parsing_schema_name","") or "") for r in sql_top if r.get("parsing_schema_name"))
        top_schema = schemas.most_common(1)[0][0] if schemas else "—"

        # ── Header: aggregate stats ────────────────────────────────────
        h = Table.grid(expand=True, padding=(0, 3))
        h.add_column(ratio=1)
        h.add_column(ratio=1)
        h.add_column(ratio=1)
        h.add_row(
            f"[dim]Statements:[/] [bold white]{len(sql_top)}[/]",
            f"[dim]Total CPU:[/] [bold red]{total_cpu:,.1f}s[/]",
            f"[dim]Total Elapsed:[/] [bold yellow]{total_ela:,.1f}s[/]",
        )
        h.add_row(
            f"[dim]Top Schema:[/] [bold cyan]{top_schema}[/]",
            f"[dim]Total Execs:[/] [white]{total_exec:,}[/]",
            f"[dim]Buffer Gets:[/] [white]{total_buf / 1e6:,.1f}M[/]  "
            f"[dim]Disk Reads:[/] [white]{total_disk:,}[/]",
        )
        h.add_row(
            Text.from_markup("[dim]Enter[/]=Explain Plan"),
            Text.from_markup("[dim]S[/]=SQL ID direto"),
            Text.from_markup("[dim]↑↓[/]=Navegar  Preview automático"),
        )
        self.query_one("#sql-header", Static).update(
            Panel(h, title="[bold white]Top SQL por CPU[/]",
                  border_style="blue", padding=(0, 1))
        )

        # ── DataTable ─────────────────────────────────────────────────
        dt: DataTable = self.query_one("#sql-table")
        if not dt.columns:
            dt.add_columns(
                "#", "SQL ID", "Schema",
                "Execs", "Elapsed(s)", "CPU(s)", "CPU%",
                "Buffer Gets", "Disk Reads", "Avg(ms)",
            )
        dt.border_title = (
            f"Top SQL  [{len(sql_top)} statements]  "
            "Enter=Explain Plan   S=SQL ID"
        )
        cursor = dt.cursor_row
        dt.clear()

        for rank, r in enumerate(sql_top, 1):
            cpu_sec  = float(r.get("cpu_secs") or r.get("cpu_sec") or 0)
            ela_sec  = float(r.get("elapsed_secs") or r.get("elapsed_sec") or 0)
            cpu_pct  = cpu_sec / total_cpu * 100
            buf      = int(r.get("buffer_gets", 0) or 0)
            disk     = int(r.get("disk_reads", 0) or 0)
            avg_ms   = float(r.get("avg_elapsed_ms", 0) or 0)
            schema   = str(r.get("parsing_schema_name", "") or "")

            # CPU bar — 10 chars wide
            cpu_color  = "bold red" if cpu_pct >= 30 else ("yellow" if cpu_pct >= 10 else "green")
            bar_filled = int(cpu_pct / 100 * 10)
            cpu_bar    = Text()
            cpu_bar.append("█" * bar_filled,        style=cpu_color)
            cpu_bar.append("░" * (10 - bar_filled),  style="dim")
            cpu_bar.append(f" {cpu_pct:4.1f}%",      style=cpu_color)

            # rank badge
            rank_style = "bold red" if rank == 1 else ("yellow" if rank == 2 else "dim")

            dt.add_row(
                Text(str(rank), style=rank_style, justify="right"),
                Text(str(r.get("sql_id", "")), style="cyan"),
                Text(schema, style="dim"),
                Text(f"{int(r.get('executions', 0) or 0):,}", justify="right"),
                Text(f"{ela_sec:,.1f}",  justify="right", style="yellow"),
                Text(f"{cpu_sec:,.1f}",  justify="right", style="red"),
                cpu_bar,
                Text(f"{buf / 1e6:,.2f}M"  if buf  >= 1_000_000 else f"{buf:,}",   justify="right"),
                Text(f"{disk:,}",  justify="right", style="dim"),
                Text(f"{avg_ms:,.1f}", justify="right", style="dim"),
                key=str(r.get("sql_id", "")),
            )

        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))

        # seed preview with first row if no cursor set yet
        if sql_top and cursor == 0:
            r       = sql_top[0]
            sql_txt = str(r.get("sql_text", "") or "")
            prev    = Text()
            prev.append(f"  SQL ID: ", style="dim")
            prev.append(f"{r.get('sql_id','')}    ", style="bold cyan")
            prev.append(f"Schema: ", style="dim")
            prev.append(f"{r.get('parsing_schema_name','?')}\n  ", style="cyan")
            prev.append(sql_txt[:300], style="dim")
            self.query_one("#sql-preview", Static).update(
                Panel(prev, title="[bold #bbc8e8]SQL Preview[/]",
                      border_style="#384c7a", padding=(0, 1))
            )

        # ── Trend graphs ──────────────────────────────────────────────
        self.query_one("#graph-sql-cpu", Graph).update_data(
            [float(v) for v in self.cache.get_history_values("sql.total_cpu_sec")])
        self.query_one("#graph-sql-ela", Graph).update_data(
            [float(v) for v in self.cache.get_history_values("sql.total_elapsed_sec")])
        self.query_one("#graph-sql-buf", Graph).update_data(
            [float(v) for v in self.cache.get_history_values("sql.total_buffer_gets")])

    _SQL_PLAN = """
        SELECT
            p.id              AS plan_line_id,
            p.depth,
            p.operation
                || CASE WHEN p.options IS NOT NULL THEN ' ' || p.options ELSE '' END
                               AS operation,
            p.object_name,
            p.cardinality,
            p.cost,
            p.bytes,
            p.access_predicates,
            p.filter_predicates
        FROM v$sql_plan p
        WHERE p.sql_id      = :sql_id
          AND p.child_number = (
              SELECT MIN(child_number) FROM v$sql_plan WHERE sql_id = :sql_id
          )
        ORDER BY p.id
    """

    _SQL_FULLTEXT = """
        SELECT sql_fulltext FROM v$sqlarea WHERE sql_id = :sql_id AND ROWNUM = 1
    """

    async def _fetch_explain(self, sql_id: str, sql_short: str = "") -> tuple[str, list[dict]]:
        txt_row = await self.conn.fetch_one(self._SQL_FULLTEXT, {"sql_id": sql_id})
        sql_txt = str((txt_row or {}).get("sql_fulltext") or sql_short)
        plan    = await self.conn.execute_query(self._SQL_PLAN, {"sql_id": sql_id})
        return sql_txt, plan

    async def action_show_explain(self) -> None:
        from widgets.explain_screen import ExplainScreen
        dt: DataTable = self.query_one("#sql-table")
        sql_top = self.cache.get("sql.top", []) or []
        row_idx = dt.cursor_row
        if row_idx < 0 or row_idx >= len(sql_top):
            self.app.notify("No SQL selected", severity="warning")
            return
        r      = sql_top[row_idx]
        sql_id = str(r.get("sql_id", ""))
        if not sql_id:
            self.app.notify("No SQL ID for selected row", severity="warning")
            return
        self.app.notify(f"Fetching plan for {sql_id}…", timeout=3)
        sql_txt, plan = await self._fetch_explain(sql_id, str(r.get("sql_text_short", "")))
        self.app.push_screen(ExplainScreen(sql_id, sql_txt, plan))

    def action_input_sql_id(self) -> None:
        from widgets.sql_input_screen import SQLInputScreen
        async def on_result(sql_id: str | None) -> None:
            if not sql_id:
                return
            from widgets.explain_screen import ExplainScreen
            self.app.notify(f"Fetching plan for {sql_id}…", timeout=3)
            sql_txt, plan = await self._fetch_explain(sql_id)
            self.app.push_screen(ExplainScreen(sql_id, sql_txt, plan))
        self.app.push_screen(SQLInputScreen(), on_result)


# ---------------------------------------------------------------------------
# 4. WAITS
# ---------------------------------------------------------------------------

class WaitsPanel(BasePanel):

    DEFAULT_CSS = BasePanel.DEFAULT_CSS + """
    #waits-charts {
        height: 12;
        margin: 0;
        padding: 0;
    }
    #waits-charts Graph {
        width: 1fr;
        height: 12;
        margin: 0 1;
    }
    """

    # wait class → display color
    _WC_COLOR: dict[str, str] = {
        "User I/O":      "bold blue",
        "System I/O":    "blue",
        "Concurrency":   "bold yellow",
        "Application":   "bold red",
        "Commit":        "yellow",
        "Configuration": "magenta",
        "Network":       "cyan",
        "Cluster":       "bold cyan",
        "Administrative":"dim magenta",
        "Scheduler":     "dim cyan",
        "Idle":          "dim",
        "Other":         "white",
    }

    def _wc_color(self, wc: str) -> str:
        return self._WC_COLOR.get(wc, "white")

    def compose(self) -> ComposeResult:
        yield Static(id="waits-header")
        with Horizontal(id="waits-charts"):
            yield Graph("Top Wait Event (s)",   color=(240, 124,  23), unit="s", id="graph-wait-top")
            yield Graph("Non-Idle Total (s)",   color=(252,  89,  86), unit="s", id="graph-wait-total")
            yield Graph("Active Wait Sessions", color=( 68, 180, 255), unit="",  id="graph-wait-active")
        yield DataTable(id="waits-table")
        yield Static(id="waits-class")

    async def refresh_data(self) -> None:
        waits  = self.cache.get("waits.system_top", []) or []
        by_cls = self.cache.get("waits.by_class",   []) or []
        active = self.cache.get("waits.active_sessions", []) or []

        non_idle  = [w for w in waits if w.get("wait_class", "") != "Idle"]
        total_sec = sum(float(w.get("time_waited_secs", 0) or w.get("time_waited_sec", 0) or 0)
                        for w in non_idle)
        top_event = non_idle[0].get("event", "—") if non_idle else "—"
        top_class = non_idle[0].get("wait_class", "—") if non_idle else "—"
        n_active  = len(active)

        # ── Header: aggregate stats ────────────────────────────────────
        h = Table.grid(expand=True, padding=(0, 3))
        h.add_column(ratio=1); h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Non-Idle Events:[/] [bold white]{len(non_idle)}[/]",
            f"[dim]Active Waiting:[/] [bold red]{n_active}[/]",
            f"[dim]Total Wait Time:[/] [bold yellow]{total_sec:,.1f}s[/]",
        )
        h.add_row(
            f"[dim]Top Event:[/] [bold cyan]{top_event[:40]}[/]",
            f"[dim]Top Class:[/] [{self._wc_color(top_class)}]{top_class}[/]",
            f"[dim]Wait Classes Active:[/] [white]{len(by_cls)}[/]",
        )
        self.query_one("#waits-header", Static).update(
            Panel(h, title="[bold white]Wait Event Monitor[/]",
                  border_style="yellow", padding=(0, 1))
        )

        # ── Main event table ───────────────────────────────────────────
        dt: DataTable = self.query_one("#waits-table")
        if not dt.columns:
            dt.add_columns(
                "#", "Event", "Wait Class",
                "Time (s)", "Avg (ms)", "Total Waits", "% Non-Idle",
            )
        dt.border_title = (
            f"System Wait Events  [{len(non_idle)} non-idle / {len(waits)} total]"
        )
        cursor = dt.cursor_row
        dt.clear()

        max_sec   = float(non_idle[0].get("time_waited_secs", 0) or 1) if non_idle else 1.0
        total_bar = total_sec or 1.0

        for rank, w in enumerate(waits, 1):
            wc     = str(w.get("wait_class", "") or "")
            is_idle = wc == "Idle"
            color  = "dim" if is_idle else self._wc_color(wc)
            t_sec  = float(w.get("time_waited_secs", 0) or w.get("time_waited_sec", 0) or 0)
            avg_ms = float(w.get("avg_wait_ms", 0) or 0)
            waits_ = int(w.get("total_waits", 0) or 0)
            pct    = t_sec / total_bar * 100 if not is_idle else 0.0

            # severity color for time
            t_color = "bold red" if avg_ms > 10 else ("yellow" if avg_ms > 1 else color)

            # % bar — 10 chars
            bar_fill = int(pct / 100 * 10)
            bar_t    = Text()
            bar_t.append("█" * bar_fill,          style=color)
            bar_t.append("░" * (10 - bar_fill),   style="dim")
            bar_t.append(f"  {pct:5.1f}%",        style=color)

            rank_style = ("bold red" if rank == 1 else
                          ("yellow"  if rank == 2 else
                           ("dim"    if is_idle   else "dim")))

            dt.add_row(
                Text(str(rank), style=rank_style, justify="right"),
                Text(str(w.get("event", "")), style="dim" if is_idle else "white"),
                Text(wc, style=color),
                Text(f"{t_sec:,.1f}", justify="right", style=t_color),
                Text(f"{avg_ms:,.2f}", justify="right",
                     style="bold red" if avg_ms > 10 else ("yellow" if avg_ms > 1 else "dim")),
                Text(f"{waits_:,}", justify="right", style="dim"),
                bar_t if not is_idle else Text("—", style="dim", justify="right"),
                key=str(w.get("event", rank)),
            )

        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))

        # ── Wait class summary ─────────────────────────────────────────
        cls_t = Table(show_header=True, header_style="bold #bbc8e8",
                      box=rich_box.SIMPLE_HEAD, padding=(0, 2), expand=True)
        cls_t.add_column("Wait Class",     width=20)
        cls_t.add_column("Sessions",       width=9,  justify="right")
        cls_t.add_column("Avg Wait",       width=11, justify="right")
        cls_t.add_column("Distribution",   ratio=1)

        total_cls = sum(int(c.get("session_count", 0) or 0) for c in by_cls) or 1
        for c in by_cls:
            avg  = float(c.get("avg_wait_sec", 0) or 0)
            sess = int(c.get("session_count", 0) or 0)
            wc   = str(c.get("wait_class", "") or "")
            clr       = self._wc_color(wc)
            avg_color = "bold red" if avg > 1 else ("yellow" if avg > 0.1 else "green")
            pct       = sess / total_cls * 100
            cls_t.add_row(
                Text(wc, style=clr),
                Text(str(sess), justify="right"),
                Text(f"{avg:.3f}s", style=avg_color, justify="right"),
                pct_bar(pct, width=20, show_pct=True),
            )
        if not by_cls:
            cls_t.add_row(Text("No active wait class data", style="dim"), "", "", "")

        self.query_one("#waits-class", Static).update(
            Panel(cls_t, title="[bold cyan]Wait Class Summary[/]",
                  border_style="cyan", padding=(0, 0))
        )

        # ── Trend graphs ──────────────────────────────────────────────
        self.query_one("#graph-wait-top",    Graph).update_data(
            [float(v) for v in self.cache.get_history_values("waits.top_wait_sec")])
        self.query_one("#graph-wait-total",  Graph).update_data(
            [float(v) for v in self.cache.get_history_values("waits.non_idle_total_sec")])
        self.query_one("#graph-wait-active", Graph).update_data(
            [float(v) for v in self.cache.get_history_values("waits.active_count")])


# ---------------------------------------------------------------------------
# 5. LOCKS
# ---------------------------------------------------------------------------

class LocksPanel(BasePanel):

    def compose(self) -> ComposeResult:
        yield Static(id="locks-summary")
        yield Static(id="locks-detail")

    @staticmethod
    def _fmt_ctime(ctime: int) -> str:
        if ctime < 60:
            return f"{ctime} SECOND(s)"
        elif ctime < 3600:
            return f"{ctime // 60} MINUTE(s) and {ctime % 60} SECOND(s)"
        return f"{ctime // 3600} HOUR(s) and {(ctime % 3600) // 60} MINUTE(s)"

    async def refresh_data(self) -> None:
        from collections import Counter

        blockers = self.cache.get("locks.blockers", []) or []
        waiters  = self.cache.get("locks.waiters",  []) or []
        objects  = self.cache.get("locks.objects",  []) or []

        if not blockers:
            self.query_one("#locks-summary", Static).update(
                Panel(Text("  No blocking sessions detected.", style="dim green"),
                      title="[bold green]Lock Monitor — DBA BRABO[/]", border_style="green")
            )
            self.query_one("#locks-detail", Static).update(Text(""))
            return

        # ── Summary table: one row per blocker ────────────────────────
        sum_t = Table(
            show_header=True, header_style="bold white on red",
            box=rich_box.ROUNDED, padding=(0, 2), expand=True,
        )
        sum_t.add_column("SID",       width=6,  justify="right", style="bold red")
        sum_t.add_column("Instance",  width=10)
        sum_t.add_column("User",      width=14, style="cyan")
        sum_t.add_column("Type",      width=5)
        sum_t.add_column("Held For",  min_width=22)
        sum_t.add_column("Wait",      width=5, justify="center")
        sum_t.add_column("Objs",      width=5, justify="center")
        sum_t.add_column("OS PID",    width=8)
        sum_t.add_column("SQL ID",    width=16, style="cyan")
        sum_t.add_column("Kill Command", ratio=1)

        for b in blockers:
            sid     = b.get("sid", "?")
            serial  = b.get("serial_num", "?")
            inst_id = b.get("inst_id", 1)
            ctime   = int(b.get("ctime_secs", 0) or 0)
            bw      = [w for w in waiters if w.get("id1") == b.get("id1") and w.get("id2") == b.get("id2")]
            bo      = [o for o in objects if str(o.get("sid","")) == str(sid)]
            tc      = "bold red" if ctime > 3600 else ("yellow" if ctime > 60 else "green")
            kill    = f"KILL SESSION '{sid},{serial},@{inst_id}' IMMEDIATE"
            sum_t.add_row(
                str(sid),
                str(b.get("instance_name","?")),
                str(b.get("username","?")),
                str(b.get("lock_type","TX")),
                Text.from_markup(f"[{tc}]{self._fmt_ctime(ctime)}[/]"),
                Text.from_markup(f"[{'bold red' if bw else 'dim'}]{len(bw)}[/]"),
                Text.from_markup(f"[magenta]{len(bo)}[/]"),
                str(b.get("os_pid","") or "—"),
                str(b.get("sql_id","") or "—"),
                Text.from_markup(f"[dim yellow]ALTER SYSTEM {kill}[/]"),
            )

        self.query_one("#locks-summary", Static).update(Panel(
            sum_t,
            title=(f"[bold red]Lock Monitor — DBA BRABO — "
                   f"{len(blockers)} Blocker(s) / {len(waiters)} Waiter(s) — "
                   f"[K] Kill First[/]"),
            border_style="red", padding=(0, 0),
        ))

        # ── Per-blocker drill-down ─────────────────────────────────────
        blocker_panels: list[RenderableType] = []

        for idx, b in enumerate(blockers):
            sid      = b.get("sid",          "?")
            serial   = b.get("serial_num",   "?")
            username = b.get("username",      "?") or "?"
            status   = b.get("status",       "?") or "?"
            osuser   = b.get("osuser",       "?") or "?"
            machine  = b.get("machine",      "?") or "?"
            program  = b.get("program",      "?") or "?"
            instance = b.get("instance_name","?") or "?"
            host     = b.get("host_name",    "?") or "?"
            inst_id  = b.get("inst_id",      1)
            sql_id   = b.get("sql_id",       "")  or ""
            os_pid   = b.get("os_pid",       "")  or "—"
            sql_hash = b.get("sql_hash_value", 0)
            ctime    = int(b.get("ctime_secs", 0) or 0)

            bw = [w for w in waiters if w.get("id1") == b.get("id1") and w.get("id2") == b.get("id2")]
            bo = [o for o in objects if str(o.get("sid","")) == str(sid)]
            kill_cmd   = f"ALTER SYSTEM KILL SESSION '{sid},{serial},@{inst_id}' IMMEDIATE"
            ctime_color = "bold red" if ctime > 3600 else ("bold yellow" if ctime > 60 else "bold green")

            # ── Info grid ─────────────────────────────────────────────
            info = Table.grid(padding=(0, 2), expand=True)
            info.add_column(width=24, style="dim")
            info.add_column(min_width=20)
            info.add_column(width=22, style="dim")
            info.add_column()

            info.add_row("Usuário Bloqueador:", Text(username,  style="bold cyan"),
                         "Status:",            Text(status, style="green" if status == "ACTIVE" else "red"))
            info.add_row("SID:",               Text(str(sid),   style="bold red"),
                         "Serial#:",           str(serial))
            info.add_row("Instância (Inst ID):",
                         Text(f"{instance}  [@{inst_id}]", style="magenta"),
                         "Servidor Host:",     Text(host, style="dim"))
            info.add_row("OS Usuário:",        Text(osuser, style="dim"),
                         "Machine:",           Text(machine[:40], style="dim"))
            info.add_row("Program:",           Text(program[:40], style="dim"),
                         "OS PID:",            Text(str(os_pid), style="dim"))

            info_panel = Panel(info, title="[bold #bbc8e8]DATABASE INFORMATION[/]",
                               border_style="#384c7a", padding=(0, 1))

            # ── Time lock bar ─────────────────────────────────────────
            time_text = Text()
            time_text.append("  TIME LOCK: ", style="bold")
            time_text.append(self._fmt_ctime(ctime), style=ctime_color)
            # visual time bar (max 2h for scaling)
            filled = min(32, int(ctime / 7200 * 32))
            time_text.append(f"  [", style="dim")
            time_text.append("█" * filled, style=ctime_color)
            time_text.append("░" * (32 - filled), style="dim")
            time_text.append("]", style="dim")

            # ── Kill command ──────────────────────────────────────────
            kill_text = Text()
            kill_text.append("  💀  KILL SESSION:\n      ", style="bold red")
            kill_text.append(kill_cmd, style="bold yellow")

            # ── SQL info ──────────────────────────────────────────────
            sql_text = Text()
            if sql_id and sql_hash:
                sql_text.append("  SQL_ID:  ", style="dim")
                sql_text.append(f"{sql_id}\n", style="bold cyan")
                sql_text.append(f"  QUERY:   select sql_fulltext from gv$sql where sql_id='{sql_id}';",
                                style="dim")
            else:
                sql_text.append("  (no active SQL at this moment)", style="dim")

            # ── Locked objects table ──────────────────────────────────
            if bo:
                obj_t = Table(show_header=True, header_style="bold magenta",
                              box=rich_box.SIMPLE_HEAD, padding=(0, 2), expand=True)
                obj_t.add_column("Owner",       width=16)
                obj_t.add_column("Object Name", ratio=2)
                obj_t.add_column("Type",        width=14)
                obj_t.add_column("Lock Mode",   ratio=1)
                for o in bo:
                    mode = str(o.get("lock_mode_desc","?"))
                    mc   = ("bold red"  if "Exclusive" in mode else
                            "yellow"    if "Row-X"     in mode else
                            "cyan")
                    obj_t.add_row(
                        str(o.get("owner","?")),
                        f"[bold]{o.get('object_name','?')}[/]",
                        f"[dim]{o.get('object_type','?')}[/]",
                        Text(mode, style=mc),
                    )
                obj_counts = Counter(o.get("object_type","?") for o in bo)
                obj_title  = "  LOCKED OBJECTS (%d): %s" % (
                    len(bo),
                    "  ".join(f"{c}× {t}" for t, c in obj_counts.items())
                )
                obj_section: RenderableType = Panel(obj_t,
                    title=f"[bold magenta]{obj_title}[/]",
                    border_style="magenta", padding=(0, 0))
            else:
                obj_section = Text("  No locked objects found in DBA_OBJECTS.", style="dim")

            # ── Waiters table ─────────────────────────────────────────
            if bw:
                wait_t = Table(show_header=True, header_style="bold yellow",
                               box=rich_box.SIMPLE_HEAD, padding=(0, 2), expand=True)
                wait_t.add_column("SID",     width=6,  justify="right", style="yellow")
                wait_t.add_column("Serial",  width=8,  justify="right")
                wait_t.add_column("Inst",    width=5,  justify="center")
                wait_t.add_column("DB User", width=16, style="cyan")
                wait_t.add_column("OS User", width=14, style="dim")
                wait_t.add_column("Lock",    width=5)
                wait_t.add_column("SQL ID",  width=16, style="cyan")
                for w in bw:
                    wait_t.add_row(
                        str(w.get("waiter_sid",    "?")),
                        str(w.get("waiter_serial", "?")),
                        str(w.get("inst_id",       "?")),
                        str(w.get("waiter_username","?") or "?"),
                        str(w.get("waiter_osuser", "?")),
                        str(w.get("lock_type",     "?")),
                        str(w.get("waiter_sql_id", "") or "—"),
                    )
                wait_section: RenderableType = Panel(wait_t,
                    title=f"[bold yellow]BLOQUEADOS ({len(bw)} waiter(s))[/]",
                    border_style="yellow", padding=(0, 0))
            else:
                wait_section = Panel(
                    Text("  No waiters found.", style="dim"),
                    title="[bold yellow]BLOQUEADOS[/]", border_style="dim yellow")

            blocker_panels.append(Panel(
                Group(info_panel, time_text, kill_text, sql_text, obj_section, wait_section),
                title=(f"[bold red]BLOQUEADOR #{idx+1} — "
                       f"SID {sid} — {username} @ {instance}[/]"),
                border_style="red", padding=(1, 1),
            ))

        self.query_one("#locks-detail", Static).update(
            Group(*blocker_panels)
        )

    async def action_kill(self) -> None:
        """Kill the first blocking session."""
        blockers = self.cache.get("locks.blockers", []) or []
        if not blockers:
            # Fallback to sessions-based detection
            sessions     = self.cache.get("sessions.list", []) or []
            blocker_sids = sorted({r["blocking_session"] for r in sessions if r.get("blocking_session")})
            if not blocker_sids:
                self.app.notify("No blocking sessions to kill.", severity="warning")
                return
            bsid    = blocker_sids[0]
            blocker = next((r for r in sessions if r["sid"] == bsid), None)
            serial  = (blocker or {}).get("serial", 1)
            sql     = f"ALTER SYSTEM KILL SESSION '{bsid},{serial}' IMMEDIATE"
            body    = f"Kill SID {bsid}, Serial# {serial} ({(blocker or {}).get('username', '?')})?"
        else:
            b       = blockers[0]
            sid     = b.get("sid", "?")
            serial  = b.get("serial_num", 1)
            inst_id = b.get("inst_id", 1)
            sql     = f"ALTER SYSTEM KILL SESSION '{sid},{serial},@{inst_id}' IMMEDIATE"
            b_waiters = [w for w in (self.cache.get("locks.waiters", []) or [])
                         if w.get("id1") == b.get("id1") and w.get("id2") == b.get("id2")]
            body    = (f"Kill blocker SID {sid}, Serial# {serial} @inst {inst_id} "
                       f"({b.get('username','?')}) — blocking {len(b_waiters)} session(s)?")

        async def _do_kill(sql=sql) -> None:
            ok = await self.conn.execute_ddl(sql)
            self.app.notify(
                f"Kill: {'OK' if ok else 'FAILED'}  [{sql[:60]}]",
                severity="warning" if ok else "error",
            )

        def on_confirm(confirmed: bool) -> None:
            if confirmed:
                asyncio.create_task(_do_kill())

        self.app.push_screen(ConfirmModal(
            title="Kill Blocking Session",
            body=body,
            command=sql,
        ), on_confirm)


# ---------------------------------------------------------------------------
# 6. RAC
# ---------------------------------------------------------------------------

class RACPanel(BasePanel):

    def compose(self) -> ComposeResult:
        yield Static(id="rac-overview")
        yield Static(id="rac-services")
        yield Static(id="rac-gc")
        yield Static(id="rac-sessions")

    async def refresh_data(self) -> None:
        is_rac       = self.cache.get("rac.detected", False)
        instances    = self.cache.get("rac.instances", []) or []
        gc_stats     = self.cache.get("rac.gc_stats", {}) or {}
        interconnect = self.cache.get("rac.interconnect", []) or []
        sessions     = self.cache.get("sessions.list", []) or []
        diskgroups   = self.cache.get("asm.diskgroups", []) or []
        services     = self.cache.get("rac.services", []) or []

        if not is_rac:
            self.query_one("#rac-overview", Static).update(
                Panel(Text("Single Instance — RAC not detected.", style="dim"), border_style="dim")
            )
            for wid in ("#rac-services", "#rac-gc", "#rac-sessions"):
                self.query_one(wid, Static).update(Text(""))
            return

        ic_by_inst = {ic.get("inst_id"): ic for ic in interconnect}
        if isinstance(gc_stats, list):
            gc_by_inst = {g.get("inst_id"): g for g in gc_stats}
        else:
            gc_by_inst = gc_stats

        # ── Cluster Overview table ────────────────────────────────────────
        ov_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=None, padding=(0, 2), expand=True)
        ov_t.add_column("Inst", width=5)
        ov_t.add_column("Instance Name", width=14)
        ov_t.add_column("Host", ratio=2)
        ov_t.add_column("Interconnect IP", width=16)
        ov_t.add_column("Status", width=10)
        ov_t.add_column("Sessions", width=14)
        ov_t.add_column("GC CR (ms)", width=12, justify="right")
        ov_t.add_column("GC Cur (ms)", width=12, justify="right")
        ov_t.add_column("Startup Time", width=20)

        for inst in instances:
            iid    = inst.get("inst_id")
            ic     = ic_by_inst.get(iid, {})
            gc     = gc_by_inst.get(iid, {})
            status = str(inst.get("status", ""))
            sc     = "green" if status in ("OPEN", "ACTIVE") else "red"
            gc_cr  = float((gc or {}).get("gc_cr_latency_ms") or (gc or {}).get("gc_latency_ms") or 0)
            gc_cur = float((gc or {}).get("gc_cur_latency_ms") or 0)
            lc     = "red" if gc_cr > 5 else ("yellow" if gc_cr > 2 else "green")
            asess  = inst.get("active_sessions", 0)
            tsess  = inst.get("total_sessions", 0)
            ip     = ic.get("ip_address") or ic.get("ip") or "—"
            stime  = inst.get("startup_time")
            stime_s = stime.strftime("%Y-%m-%d %H:%M") if hasattr(stime, "strftime") else str(stime or "—")
            ov_t.add_row(
                str(iid),
                f"[bold]{inst.get('instance_name', '')}[/]",
                inst.get("host_name", ""),
                ip,
                f"[{sc}]{status}[/]",
                f"[green]{asess}[/] / {tsess}",
                f"[{lc}]{gc_cr:.2f}[/]",
                f"[{lc}]{gc_cur:.2f}[/]",
                f"[dim]{stime_s}[/]",
            )

        # ASM diskgroup summary row
        if diskgroups:
            ov_t.add_row("", Text.from_markup("[dim]Interconnect:[/] " + ", ".join(
                f"{ic.get('ip_address','?')}" for ic in interconnect
            )), "", "", "", "", "", "", "")

        self.query_one("#rac-overview", Static).update(
            Panel(ov_t, title="[bold magenta]RAC Cluster Instances[/]",
                  border_style="magenta", padding=(0, 1))
        )

        # ── Services ──────────────────────────────────────────────────────
        svc_t = Table(show_header=True, header_style="bold #bbc8e8",
                      box=None, padding=(0, 2), expand=True)
        svc_t.add_column("Service Name",  ratio=2)
        svc_t.add_column("Network Name",  ratio=3)
        svc_t.add_column("Status",        width=10)
        svc_t.add_column("Enabled",       width=9)
        svc_t.add_column("Goal",          width=8)
        svc_t.add_column("Inst",          width=5)

        for svc in services:
            status = str(svc.get("svc_status", "UNKNOWN"))
            sc     = "green" if status == "RUNNING" else "red"
            ena    = str(svc.get("enabled", "NO"))
            ec     = "green" if ena == "YES" else "yellow"
            svc_t.add_row(
                f"[bold]{svc.get('name', '')}[/]",
                f"[dim]{svc.get('network_name', '')}[/]",
                f"[{sc}]{status}[/]",
                f"[{ec}]{ena}[/]",
                str(svc.get("goal", "")),
                str(svc.get("inst_id", "") or "—"),
            )
        if not services:
            svc_t.add_row("[dim]No services data[/]", "", "", "", "", "")

        self.query_one("#rac-services", Static).update(
            Panel(svc_t, title="[bold cyan]RAC Services[/]", border_style="cyan", padding=(0, 1))
        )

        # ── GC Statistics ────────────────────────────────────────────────
        gc_t = Table(show_header=True, header_style="bold cyan",
                     box=None, padding=(0, 1), expand=True)
        gc_t.add_column("Inst", width=5)
        gc_t.add_column("GC CR Blocks Recv", justify="right", width=20)
        gc_t.add_column("GC Cur Blocks Recv", justify="right", width=20)
        gc_t.add_column("GC CR Blocks Srv",   justify="right", width=18)
        gc_t.add_column("GC Cur Blocks Srv",  justify="right", width=18)
        gc_t.add_column("CR Latency (ms)",    justify="right", width=16)
        gc_t.add_column("Cur Latency (ms)",   justify="right", width=16)

        for inst in instances:
            iid    = inst.get("inst_id")
            gc     = gc_by_inst.get(iid, {})
            gc_cr  = float((gc or {}).get("gc_cr_latency_ms") or (gc or {}).get("gc_latency_ms") or 0)
            gc_cur = float((gc or {}).get("gc_cur_latency_ms") or 0)
            lc     = "red" if gc_cr > 5 else ("yellow" if gc_cr > 2 else "green")
            gc_t.add_row(
                str(iid),
                f"{int((gc or {}).get('gc_cr_blocks_received', 0)):,}",
                f"{int((gc or {}).get('gc_current_blocks_received', 0)):,}",
                f"{int((gc or {}).get('gc_cr_blocks_served', 0)):,}",
                f"{int((gc or {}).get('gc_current_blocks_served', 0)):,}",
                f"[{lc}]{gc_cr:.3f}[/]",
                f"[{lc}]{gc_cur:.3f}[/]",
            )

        self.query_one("#rac-gc", Static).update(
            Panel(gc_t, title="[bold cyan]Cache Fusion / GC Statistics[/]", border_style="cyan", padding=(0, 1))
        )

        # ── Active Cluster Sessions ──────────────────────────────────────
        sess_t = Table(show_header=True, header_style="bold",
                       box=None, padding=(0, 1), expand=True)
        sess_t.add_column("Inst", width=5)
        sess_t.add_column("SID", width=6)
        sess_t.add_column("Username", width=14)
        sess_t.add_column("Status", width=8)
        sess_t.add_column("SQL ID", width=14)
        sess_t.add_column("Wait Event", ratio=2)
        sess_t.add_column("Blocking", width=9)

        active_sessions = [s for s in sessions if s.get("status") == "ACTIVE"]
        for s in active_sessions[:30]:
            blocking = s.get("blocking_session")
            sc       = "red" if blocking else "green"
            sess_t.add_row(
                str(s.get("inst_id", "") or ""),
                f"[{sc}]{s.get('sid', '')}[/]",
                str(s.get("username", "") or ""),
                f"[{sc}]{s.get('status', '')}[/]",
                str(s.get("sql_id", "") or ""),
                str(s.get("wait_event", s.get("event", "")) or ""),
                f"[red]{blocking}[/]" if blocking else "",
            )
        if not active_sessions:
            sess_t.add_row("", "[dim]No active sessions[/]", "", "", "", "", "")

        self.query_one("#rac-sessions", Static).update(
            Panel(sess_t, title="[bold white]Active Cluster Sessions[/]",
                  border_style="magenta", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 7. DATA GUARD
# ---------------------------------------------------------------------------

class DataGuardPanel(BasePanel):
    REFRESH_RATE = 5

    def compose(self) -> ComposeResult:
        yield Static(id="dg-overview")
        yield Static(id="dg-gap")
        yield Static(id="dg-processes")
        yield Static(id="dg-rac")
        yield Static(id="dg-dests")

    async def refresh_data(self) -> None:
        role    = self.cache.get("dg.role", "") or "NOT DETECTED"
        mode    = self.cache.get("dg.protection_mode", "") or ""
        stats   = self.cache.get("dg.stats", {}) or {}
        procs   = self.cache.get("dg.standby_processes", []) or []
        dests   = self.cache.get("dg.archive_dests", []) or []
        gaps    = self.cache.get("dg.archive_gap", []) or []
        log_h   = self.cache.get("dg.log_history", []) or []
        db_info = self.cache.get("health.db_info", {}) or {}

        stdby_host  = self.cache.get("dg.standby_host", "") or "—"
        stdby_name  = self.cache.get("dg.standby_unique_name", "") or "—"
        primary_name = db_info.get("db_unique_name", "—") or "—"
        primary_host = db_info.get("host_name", "—") or "—"

        role_color = "green" if role == "PRIMARY" else "yellow"
        gap_count  = len(gaps) if isinstance(gaps, list) else (1 if gaps else 0)
        gap_color  = "red" if gap_count > 0 else "green"

        # Extract stat values safely
        def stat_val(key):
            v = stats.get(key)
            return v.get("value", "N/A") if isinstance(v, dict) else str(v or "N/A")

        apply_lag     = stat_val("Apply Lag")
        transport_lag = stat_val("Transport Lag")
        redo_rate     = stat_val("Redo Generated")

        lag_color = "green" if apply_lag in ("N/A", "+00 00:00:00.0", "") else "yellow"

        # ── Overview (Dolphie-style: side-by-side info grid) ─────────────
        ov_t = Table(show_header=False, box=None, padding=(0, 3), expand=True)
        ov_t.add_column(width=22, style="dim")
        ov_t.add_column(ratio=1)
        ov_t.add_column(width=22, style="dim")
        ov_t.add_column(ratio=1)

        ov_t.add_row("Role",           Text.from_markup(f"[{role_color}][b]{role}[/b][/]"),
                     "Protection Mode", mode)
        ov_t.add_row("Primary DB",    Text.from_markup(f"[bold]{primary_name}[/]"),
                     "Standby DB",    Text.from_markup(f"[cyan]{stdby_name}[/]"))
        ov_t.add_row("Primary Host",  primary_host,
                     "Standby Host",  stdby_host)
        ov_t.add_row("Apply Lag",     Text.from_markup(f"[{lag_color}]{apply_lag}[/]"),
                     "Transport Lag", Text.from_markup(f"[yellow]{transport_lag}[/]"))
        ov_t.add_row("Redo Rate",     Text.from_markup(f"[cyan]{redo_rate}[/]"),
                     "Archive Gap",   Text.from_markup(f"[{gap_color}]{gap_count} gap(s)[/]"))

        self.query_one("#dg-overview", Static).update(
            Panel(ov_t, title=f"[bold yellow]Data Guard — {role}[/]",
                  border_style="yellow", padding=(0, 1))
        )

        # ── Gap Monitor ───────────────────────────────────────────────────
        gap_text = Text()
        if isinstance(gaps, list) and gaps:
            gap_text.append("  Archive Gaps Detected:\n\n", style="bold red")
            for g in gaps:
                gap_text.append(
                    f"  Thread #{g.get('thread', g.get('thread#','?'))}  "
                    f"Low Seq: {g.get('low_seq', g.get('low_sequence#','?'))}  "
                    f"High Seq: {g.get('high_seq', g.get('high_sequence#','?'))}\n",
                    style="red",
                )
        else:
            gap_text.append("  ✓ No archive gaps detected.\n", style="green")

        if log_h:
            gap_text.append("\n  Last Applied Sequences:\n", style="dim")
            for lh in log_h:
                gap_text.append(
                    f"    Thread {lh.get('thread#', lh.get('thread','?'))}: "
                    f"Sequence {lh.get('last_sequence','?')}\n",
                    style="dim",
                )

        self.query_one("#dg-gap", Static).update(
            Panel(gap_text,
                  title=f"[bold {'red' if gap_count else 'green'}]Archive Gap Monitor[/]",
                  border_style="red" if gap_count else "green", padding=(0, 1))
        )

        # ── Standby Processes ─────────────────────────────────────────────
        pt = Table(show_header=True, header_style="bold", box=None,
                   padding=(0, 1), expand=True)
        for col in ["Process", "Status", "Thread", "Sequence", "Block", "Delay (min)"]:
            pt.add_column(col)
        for p in procs:
            pstatus  = str(p.get("status", ""))
            ps_color = "green" if "APPLY" in pstatus or "RECEIV" in pstatus else "yellow"
            pt.add_row(
                f"[bold]{p.get('process', '')}[/]",
                f"[{ps_color}]{pstatus}[/]",
                str(p.get("thread", p.get("thread#", ""))),
                str(p.get("sequence", p.get("sequence#", ""))),
                str(p.get("block", p.get("block#", ""))),
                str(p.get("delay_mins", 0)),
            )
        if not procs:
            pt.add_row("[dim]No standby process data[/]", "", "", "", "", "")

        self.query_one("#dg-processes", Static).update(
            Panel(pt, title="[bold cyan]Standby Processes (MRP / RFS / ARCH)[/]",
                  border_style="cyan", padding=(0, 1))
        )

        # ── RAC per-instance standby processes ───────────────────────────
        rac_procs = self.cache.get("dg.rac_processes", []) or []
        if rac_procs:
            # Group by inst_id
            instances: dict[int, list] = {}
            for p in rac_procs:
                iid = int(p.get("inst_id", 1))
                instances.setdefault(iid, []).append(p)

            rac_t = Table(show_header=True, header_style="bold magenta", box=None,
                          padding=(0, 1), expand=True)
            for col in ["Inst", "Process", "Status", "Thread", "Sequence", "Delay(min)"]:
                rac_t.add_column(col)
            for iid in sorted(instances):
                for p in instances[iid]:
                    pstatus  = str(p.get("status", ""))
                    ps_color = "green" if "APPLY" in pstatus or "RECEIV" in pstatus else "yellow"
                    rac_t.add_row(
                        f"[bold magenta]{iid}[/]",
                        f"[bold]{p.get('process', '')}[/]",
                        f"[{ps_color}]{pstatus}[/]",
                        str(p.get("thread", p.get("thread#", ""))),
                        str(p.get("sequence", p.get("sequence#", ""))),
                        str(p.get("delay_mins", 0)),
                    )
            rac_render: RenderableType = rac_t
        else:
            rac_render = Text("  RAC DG: single-instance or no data.", style="dim")

        self.query_one("#dg-rac", Static).update(
            Panel(rac_render, title="[bold magenta]RAC — Standby Processes per Instance (GV$)[/]",
                  border_style="magenta", padding=(0, 1))
        )

        # ── Archive Destinations ──────────────────────────────────────────
        dt = Table(show_header=True, header_style="bold", box=None,
                   padding=(0, 1), expand=True)
        for col in ["Dest ID", "Name", "Status", "Target", "Destination", "Applied Seq", "Error"]:
            dt.add_column(col)
        for dest in dests:
            err     = dest.get("error", "") or ""
            dstatus = str(dest.get("status", ""))
            ds_c    = "red" if err or dstatus == "ERROR" else "green"
            dt.add_row(
                str(dest.get("dest_id", "")),
                str(dest.get("dest_name", "")),
                f"[{ds_c}]{dstatus}[/]",
                str(dest.get("target", "")),
                str(dest.get("destination", "")),
                str(dest.get("applied_seq", "")),
                f"[red]{err}[/]" if err else "[dim]—[/]",
            )
        if not dests:
            dt.add_row("[dim]No destination data[/]", "", "", "", "", "", "")

        self.query_one("#dg-dests", Static).update(
            Panel(dt, title="[bold yellow]Archive Destinations[/]",
                  border_style="yellow", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 8. ASM
# ---------------------------------------------------------------------------

class ASMPanel(BasePanel):
    REFRESH_RATE = 5

    def compose(self) -> ComposeResult:
        yield Static(id="asm-capacity")
        yield Static(id="asm-dg")
        yield Static(id="asm-disks")
        yield Static(id="asm-fra")
        yield Static(id="asm-large")

    async def refresh_data(self) -> None:
        dgs        = self.cache.get("asm.diskgroups",    []) or []
        fra        = self.cache.get("asm.fra",           {}) or {}
        fra_files  = self.cache.get("asm.fra_files",     []) or []
        arch_rate  = self.cache.get("asm.archive_rate_mb", 0) or 0
        large_segs = self.cache.get("asm.large_segments", []) or []

        # ── Capacity overview ──────────────────────────────────────────
        cap_t = Table.grid(padding=(0, 2), expand=True)
        cap_t.add_column(width=10)
        cap_t.add_column(width=28)
        cap_t.add_column(width=14)
        cap_t.add_column(width=14)
        cap_t.add_column()

        total_all_gb = 0.0
        free_all_gb  = 0.0

        for dg in dgs:
            total_mb  = float(dg.get("total_mb", 0) or 0)
            free_mb   = float(dg.get("free_mb", 0) or 0)
            usable_mb = float(dg.get("usable_file_mb", 0) or 0)
            pct       = float(dg.get("pct_used", 0) or dg.get("used_pct", 0) or 0)
            total_gb  = total_mb / 1024
            usable_gb = usable_mb / 1024
            total_all_gb += total_gb
            free_all_gb  += free_mb / 1024

            # Future projection for archive-heavy groups
            if arch_rate > 0 and dg.get("name") in ("FRA", "RECO", "ARCHIVE"):
                daily_mb  = arch_rate * 86400
                days_left = free_mb / daily_mb if daily_mb > 0 else 9999
                dc        = "red" if days_left < 7 else ("yellow" if days_left < 30 else "green")
                days_str  = f"[{dc}]{days_left:.0f}d until full[/]"
            else:
                days_str = "[dim]—[/]"

            cap_t.add_row(
                f"[bold]{dg.get('name', '')}[/]",
                pct_bar(pct, width=26, show_pct=True),
                f"[dim]{total_gb:.1f} GB total[/]",
                f"[green]{usable_gb:.1f} GB usable[/]",
                days_str,
            )

        used_all_gb = total_all_gb - free_all_gb
        overall_pct = (used_all_gb / total_all_gb * 100) if total_all_gb else 0
        cap_t.add_row(
            "[bold dim]ALL[/]",
            pct_bar(overall_pct, width=26, show_pct=True),
            f"[dim]{total_all_gb:.1f} GB total[/]",
            f"[green]{free_all_gb:.1f} GB free[/]",
            f"[dim]archive: {arch_rate:.2f} MB/s[/]",
        )

        self.query_one("#asm-capacity", Static).update(
            Panel(cap_t, title="[bold blue]Storage Capacity Overview[/]", border_style="blue", padding=(0, 1))
        )

        # ── Diskgroup detail table ─────────────────────────────────────
        t = Table(show_header=True, header_style="bold blue", box=None, padding=(0, 1))
        for col in ["Diskgroup", "Type", "State", "Total GB", "Free GB", "Used%", "Usable GB", "Disks"]:
            t.add_column(col)

        for dg in dgs:
            pct       = float(dg.get("pct_used", 0) or dg.get("used_pct", 0) or 0)
            total_mb  = float(dg.get("total_mb", 0) or 0)
            free_mb   = float(dg.get("free_mb", 0) or 0)
            usable_mb = float(dg.get("usable_file_mb", 0) or 0)
            state     = str(dg.get("state", ""))
            sc        = "green" if state == "MOUNTED" else "red"
            t.add_row(
                f"[bold]{dg.get('name', '')}[/]",
                str(dg.get("type", "")),
                f"[{sc}]{state}[/]",
                fmt(total_mb / 1024, 1),
                fmt(free_mb / 1024, 1),
                pct_bar(pct, width=12, show_pct=True),
                fmt(usable_mb / 1024, 1),
                str(dg.get("num_disks", dg.get("offline_disks", ""))),
            )

        self.query_one("#asm-dg", Static).update(
            Panel(t, title="[bold blue]ASM Diskgroups[/]", border_style="blue", padding=(0, 1))
        )

        # ── Disk listing grouped by diskgroup ─────────────────────────
        disks = self.cache.get("asm.disks", []) or []
        if disks:
            # Group by diskgroup_name
            by_dg: dict[str, list] = {}
            for d in disks:
                key = str(d.get("diskgroup_name", "?"))
                by_dg.setdefault(key, []).append(d)

            disk_t = Table(show_header=True, header_style="bold #6cb6ff", box=None,
                           padding=(0, 1), expand=True)
            for col in ["Diskgroup", "Disk", "Path", "State", "Failgroup",
                        "Total MB", "Free MB", "Used%", "R-ms", "W-ms"]:
                disk_t.add_column(col)
            for dgname in sorted(by_dg):
                for d in by_dg[dgname]:
                    state    = str(d.get("state", ""))
                    sc       = "green" if state in ("NORMAL", "MEMBER") else "red"
                    used_pct = float(d.get("used_pct", 0) or 0)
                    disk_t.add_row(
                        f"[bold]{dgname}[/]",
                        str(d.get("disk_name", "")),
                        f"[dim]{str(d.get('path', ''))[-32:]}[/]",
                        f"[{sc}]{state}[/]",
                        str(d.get("failgroup", "")),
                        f"{int(d.get('total_mb', 0) or 0):,}",
                        f"{int(d.get('free_mb',  0) or 0):,}",
                        pct_bar(used_pct, width=8, show_pct=True),
                        fmt(d.get("avg_read_ms"),  2),
                        fmt(d.get("avg_write_ms"), 2),
                    )
            disk_render: RenderableType = disk_t
        else:
            disk_render = Text("  No ASM disk data available (requires +ASM or privileged connection).",
                               style="dim")

        self.query_one("#asm-disks", Static).update(
            Panel(disk_render, title="[bold #6cb6ff]ASM Disks per Diskgroup[/]",
                  border_style="#384c7a", padding=(0, 1))
        )

        # ── FRA ───────────────────────────────────────────────────────
        fra_text = Text()
        if fra:
            used_mb  = float(fra.get("used_mb", 0) or 0)
            total_mb = float(fra.get("total_mb", 1) or 1)
            pct      = float(fra.get("used_pct", used_mb / total_mb * 100 if total_mb else 0) or 0)
            fra_text.append(f"  Total:        {total_mb / 1024:.1f} GB\n", style="white")
            fra_text.append(f"  Used:         {used_mb / 1024:.1f} GB\n", style="white")
            fra_text.append("  Usage:        ")
            fra_text.append_text(pct_bar(pct, width=24, show_pct=True))
            fra_text.append(f"\n  Archive Rate: {arch_rate:.2f} MB/s", style="dim")
            if arch_rate > 0:
                daily_gb  = arch_rate * 86400 / 1024
                free_gb   = (total_mb - used_mb) / 1024
                days_left = free_gb / daily_gb if daily_gb > 0 else 9999
                dc        = "red" if days_left < 3 else ("yellow" if days_left < 7 else "green")
                fra_text.append(f"  ({daily_gb:.1f} GB/day — full in ", style="dim")
                fra_text.append(f"{days_left:.0f}d", style=dc)
                fra_text.append(")\n", style="dim")
            else:
                fra_text.append("\n")
            if fra_files:
                fra_text.append("\n")
                for ff in fra_files:
                    fra_text.append(
                        f"  {ff.get('file_type', ''):24s}  "
                        f"used={ff.get('percent_space_used', 0):.1f}%  "
                        f"reclaimable={ff.get('percent_space_reclaimable', 0):.1f}%  "
                        f"files={ff.get('number_of_files', 0)}\n",
                        style="dim",
                    )
        else:
            fra_text.append("  No FRA data available.", style="dim")

        self.query_one("#asm-fra", Static).update(
            Panel(fra_text, title="[bold yellow]Fast Recovery Area (FRA)[/]", border_style="yellow", padding=(0, 1))
        )

        # ── Large Objects ──────────────────────────────────────────────
        lt = Table(show_header=True, header_style="bold #bbc8e8", box=None, padding=(0, 2))
        lt.add_column("Owner",      width=14)
        lt.add_column("Segment",    ratio=3)
        lt.add_column("Type",       width=18)
        lt.add_column("Tablespace", width=16)
        lt.add_column("Size",       width=12, justify="right")
        lt.add_column("Relative",   width=20)

        if large_segs:
            max_mb = max((float(s.get("mb", 0) or 0) for s in large_segs), default=1) or 1
            for seg in large_segs:
                mb  = float(seg.get("mb", 0) or 0)
                rel = mb / max_mb * 100
                size_str = f"{mb / 1024:.1f} GB" if mb >= 1024 else f"{mb:,.0f} MB"
                lt.add_row(
                    str(seg.get("owner", "")),
                    f"[bold]{seg.get('segment_name', '')}[/]",
                    f"[dim]{seg.get('segment_type', '')}[/]",
                    str(seg.get("tablespace_name", "")),
                    f"[bold]{size_str}[/]",
                    pct_bar(rel, width=18, show_pct=False),
                )
        else:
            lt.add_row("[dim]No data available[/]", "", "", "", "", "")

        self.query_one("#asm-large", Static).update(
            Panel(lt, title="[bold #bbc8e8]Top Database Objects by Size[/]", border_style="blue", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 9. RMAN
# ---------------------------------------------------------------------------

class RMANPanel(BasePanel):
    REFRESH_RATE = 5

    def compose(self) -> ComposeResult:
        yield Static(id="rman-monitor")
        yield Static(id="rman-chart")
        yield DataTable(id="rman-history")

    @staticmethod
    def _elapsed_str(secs: int) -> str:
        h, r = divmod(int(secs or 0), 3600)
        m, s = divmod(r, 60)
        return f"{h:02d}:{m:02d}:{s:02d}"

    def _rman_section(
        self, title: str, color: str, rows: list[dict], cols: list[str],
        row_fn, empty_msg: str,
    ) -> Panel:
        if rows:
            t = Table(show_header=True, header_style=f"bold {color}", box=None, padding=(0, 2))
            for col in cols:
                t.add_column(col)
            for r in rows:
                t.add_row(*row_fn(r))
            body: RenderableType = t
        else:
            body = Text(f"  {empty_msg}", style="dim")
        return Panel(body, title=f"[bold {color}]{title}[/]", border_style=color, padding=(0, 1))

    async def refresh_data(self) -> None:
        sessions     = self.cache.get("rman.sessions",     []) or []
        longops      = self.cache.get("rman.longops",      []) or []
        wait_events  = self.cache.get("rman.wait_events",  []) or []
        disk_io      = self.cache.get("rman.disk_io",      []) or []
        tape_io      = self.cache.get("rman.tape_io",      []) or []
        perf_summary = self.cache.get("rman.perf_summary", {}) or {}
        history      = self.cache.get("rman.history",      []) or []

        if not sessions:
            monitor_render: RenderableType = Panel(
                Text("  No RMAN sessions detected.", style="dim"),
                title="[bold green]RMAN Active Monitor — Doc ID 1487262.1[/]",
                border_style="green",
            )
        else:
            # ── Section 1: Active Sessions ─────────────────────────────
            def s1_row(s: dict):
                mins = int(s.get("session_mins", 0) or 0)
                mc   = "red" if mins > 120 else ("yellow" if mins > 30 else "white")
                return (
                    str(s.get("inst_id",    "")),
                    str(s.get("sid",        "")),
                    str(s.get("serial_num", "")),
                    str(s.get("os_pid",     "")),
                    str(s.get("username",   "") or ""),
                    str(s.get("program",    ""))[:30],
                    str(s.get("client_info","") or ""),
                    Text.from_markup(f"[{mc}]{mins}[/]"),
                )
            p1 = self._rman_section(
                "1. ACTIVE RMAN SESSIONS", "green", sessions,
                ["Inst","SID","Serial","PID","Username","Program","Client Info","Elapsed(min)"],
                s1_row, "",
            )

            # ── Section 2: Channel Progress ───────────────────────────
            def s2_row(op: dict):
                pct = float(op.get("pct_complete", 0) or 0)
                pc  = "green" if pct >= 80 else ("yellow" if pct >= 40 else "white")
                return (
                    str(op.get("inst_id", "")),
                    str(op.get("sid",     "")),
                    str(op.get("channel", "") or ""),
                    str(op.get("operation","") or ""),
                    Text.from_markup(
                        f"[{pc}]{pct:.1f}%[/] "
                        f"{int(op.get('sofar',0) or 0):,}/"
                        f"{int(op.get('totalwork',0) or 0):,} MB"
                    ),
                    fmt(op.get("mb_per_sec"), 2),
                    self._elapsed_str(int(op.get("elapsed_secs", 0) or 0)),
                    str(op.get("time_remaining","") or "—"),
                )
            p2 = self._rman_section(
                "2. CHANNEL PROGRESS (RMAN LONGOPS)", "cyan", longops,
                ["Inst","SID","Channel","Operation","Progress","MB/s","Elapsed","ETA(s)"],
                s2_row, "No channel progress data.",
            )

            # ── Section 3: Wait Events ────────────────────────────────
            def s3_row(w: dict):
                wait_s = float(w.get("wait_secs", 0) or 0)
                wc     = "red" if wait_s > 5 else "yellow"
                return (
                    str(w.get("inst_id", "")),
                    str(w.get("sid",     "")),
                    str(w.get("channel", "") or ""),
                    str(w.get("seq_num", "")),
                    str(w.get("event",   "")),
                    str(w.get("state",   "")),
                    Text.from_markup(f"[{wc}]{wait_s:.2f}[/]"),
                    f"{str(w.get('p1text',''))[:14]}={w.get('p1','')}",
                    f"{str(w.get('p2text',''))[:14]}={w.get('p2','')}",
                )
            p3 = self._rman_section(
                "3. WAIT EVENTS", "yellow", wait_events,
                ["Inst","SID","Channel","Seq#","Event","State","Wait(s)","P1","P2"],
                s3_row, "No active waits.",
            )

            # ── Section 4: Disk I/O ───────────────────────────────────
            def s4_row(io: dict):
                pct = float(io.get("pct_complete", 0) or 0)
                pc  = "green" if pct >= 80 else ("yellow" if pct >= 40 else "white")
                return (
                    str(io.get("inst_id", "")),
                    str(io.get("sid",     "")),
                    str(io.get("channel", "") or ""),
                    str(io.get("type",    "")),
                    str(io.get("status",  "")),
                    Text.from_markup(
                        f"[{pc}]{pct:.1f}%[/] "
                        f"({fmt(io.get('sofar_mb'),1)}/{fmt(io.get('total_mb'),1)} MB)"
                    ),
                    str(io.get("io_count", "")),
                    str(io.get("filename", "") or "")[-38:],
                )
            p4 = self._rman_section(
                "4. DISK I/O (ASYNC — GV$BACKUP_ASYNC_IO)", "blue", disk_io,
                ["Inst","SID","Channel","Type","Status","Progress","I/O Count","File"],
                s4_row, "No disk I/O activity.",
            )

            # ── Section 5: Tape I/O ───────────────────────────────────
            def s5_row(io: dict):
                return (
                    str(io.get("inst_id",     "")),
                    str(io.get("sid",         "")),
                    str(io.get("channel",     "") or ""),
                    str(io.get("type",        "")),
                    str(io.get("status",      "")),
                    fmt(io.get("sofar_mb"),   1),
                    fmt(io.get("total_mb"),   1),
                    str(io.get("buffer_size", "")),
                    str(io.get("buffer_count","")),
                )
            p5 = self._rman_section(
                "5. TAPE I/O (SYNC — GV$BACKUP_SYNC_IO)", "#a5d6ff", tape_io,
                ["Inst","SID","Channel","Type","Status","Sofar MB","Total MB","Buf Size","Buf Count"],
                s5_row, "No tape I/O activity.",
            )

            # ── Section 6: Performance Summary ───────────────────────
            if perf_summary:
                avg_pct = float(perf_summary.get("avg_pct_complete", 0) or 0)
                eta     = int(perf_summary.get("max_eta_secs", 0) or 0)
                ps = Table.grid(padding=(0, 3))
                ps.add_column(width=24, style="dim")
                ps.add_column()
                ps.add_column(width=24, style="dim")
                ps.add_column()
                ps.add_row(
                    "Active Channels:", str(perf_summary.get("active_channels", 0)),
                    "Working Channels:", str(perf_summary.get("working_channels", 0)),
                )
                ps.add_row(
                    "Processed (GB):",
                    f"{fmt(perf_summary.get('total_processed_gb'), 2)} / "
                    f"{fmt(perf_summary.get('total_work_gb'), 2)}",
                    "Avg MB/s:", fmt(perf_summary.get("avg_mb_per_sec"), 2),
                )
                ps.add_row(
                    "Avg Progress:",
                    Text.from_markup(f"[{'green' if avg_pct >= 80 else 'yellow'}]{avg_pct:.1f}%[/]"),
                    "Max ETA:", self._elapsed_str(eta) if eta else "—",
                )
                p6: RenderableType = Panel(ps, title="[bold #3fb950]6. OVERALL PERFORMANCE SUMMARY[/]",
                                           border_style="#3fb950", padding=(0, 1))
            else:
                p6 = Panel(Text("  No summary data.", style="dim"),
                            title="[bold #3fb950]6. OVERALL PERFORMANCE SUMMARY[/]",
                            border_style="#3fb950")

            monitor_render = Group(p1, Text(""), p2, Text(""), p3, Text(""), p4, Text(""), p5, Text(""), p6)

        self.query_one("#rman-monitor", Static).update(monitor_render)

        # Backup growth chart — horizontal bar chart of input_mb per job
        completed = [r for r in history if r.get("status") in ("COMPLETED", "FAILED")]
        chart_text = Text()
        if completed:
            max_mb = max((float(r.get("input_mb", 0) or 0) for r in completed), default=1) or 1
            chart_text.append("  Backup Size History (Input MB)\n\n", style="bold #bbc8e8")
            bar_width = 32
            for r in completed[-10:]:
                status   = str(r.get("status", ""))
                inp_mb   = float(r.get("input_mb", 0) or 0)
                out_mb   = float(r.get("output_mb", 0) or 0)
                btype    = str(r.get("input_type", "")[:14]).ljust(14)
                rel      = inp_mb / max_mb
                filled   = int(bar_width * rel)
                sc       = "green" if status == "COMPLETED" else "red"
                bar_str  = "▓" * filled + "░" * (bar_width - filled)
                stime    = r.get("start_time")
                stime_s  = stime.strftime("%m-%d %H:%M") if hasattr(stime, "strftime") else str(stime or "")[:11]
                ratio    = float(r.get("compression_ratio", 0) or 0)
                size_s   = f"{inp_mb:>8,.0f} MB"
                ratio_s  = f"  {ratio:.1f}x" if ratio else ""
                chart_text.append(f"  {stime_s} {btype} ", style="dim")
                chart_text.append(bar_str, style=sc)
                chart_text.append(f" {size_s}{ratio_s}\n", style="dim")
        else:
            chart_text.append("  No backup history available.", style="dim")

        self.query_one("#rman-chart", Static).update(
            Panel(chart_text, title="[bold cyan]Backup Growth Chart[/]", border_style="cyan", padding=(0, 1))
        )

        # History DataTable
        dt: DataTable = self.query_one("#rman-history")
        if not dt.columns:
            dt.add_columns(
                "Operation", "Type", "Status", "Start Time", "Duration",
                "Input MB", "Output MB", "Ratio",
            )
        dt.clear()
        for r in history:
            status = str(r.get("status", ""))
            color  = "green" if status == "COMPLETED" else ("red" if status == "FAILED" else "yellow")
            ratio  = float(r.get("compression_ratio", 0) or 0)
            dt.add_row(
                str(r.get("operation", "")),
                str(r.get("input_type", "")),
                Text.from_markup(f"[{color}]{status}[/]"),
                str(r.get("start_time", "")),
                str(r.get("time_taken_display", "") or r.get("elapsed_seconds", "")),
                fmt(r.get("input_mb"), 1),
                fmt(r.get("output_mb"), 1),
                f"{ratio:.2f}x" if ratio else "—",
            )


# ---------------------------------------------------------------------------
# 10. AWR / TABLESPACES
# ---------------------------------------------------------------------------

class AWRPanel(BasePanel):
    REFRESH_RATE = 5

    def compose(self) -> ComposeResult:
        yield Static(id="awr-ts")
        yield Static(id="awr-top-sql")
        yield Static(id="awr-top-waits")
        yield Static(id="awr-sysstat")
        yield Static(id="awr-snaps")
        yield Static(id="awr-addm")

    async def refresh_data(self) -> None:
        ts_list   = self.cache.get("awr.tablespaces", []) or []
        findings  = self.cache.get("awr.addm_findings", []) or []
        snaps     = self.cache.get("awr.snapshots", []) or []
        top_sql   = self.cache.get("awr.top_sql", []) or []
        top_waits = self.cache.get("awr.top_waits", []) or []
        sysstat   = self.cache.get("awr.sysstat", {}) or {}

        # ── Tablespaces ───────────────────────────────────────────────────
        t = Table(show_header=True, header_style="bold", box=None, padding=(0, 1), expand=True)
        for col in ["Tablespace", "Total MB", "Used MB", "Free MB", "Used%", "AutoExt", "Status"]:
            t.add_column(col)
        for ts in ts_list:
            pct    = float(ts.get("pct_used", 0) or ts.get("used_pct", 0) or 0)
            autoxt = str(ts.get("autoextensible", ts.get("autoext", "NO")) or "NO")
            status = str(ts.get("status", "ONLINE"))
            st_c   = "green" if status == "ONLINE" else "red"
            t.add_row(
                f"[bold]{ts.get('tablespace_name', '')}[/]",
                fmt(ts.get("total_mb"), 0), fmt(ts.get("used_mb"), 0), fmt(ts.get("free_mb"), 0),
                pct_bar(pct, width=14, show_pct=True),
                f"[green]{autoxt}[/]" if autoxt == "YES" else f"[yellow]{autoxt}[/]",
                f"[{st_c}]{status}[/]",
            )
        self.query_one("#awr-ts", Static).update(
            Panel(t, title="[bold blue]Tablespaces[/]", border_style="blue", padding=(0, 1))
        )

        # ── AWR Top SQL ───────────────────────────────────────────────────
        sq_t = Table(show_header=True, header_style="bold #bbc8e8", box=None, padding=(0, 1), expand=True)
        sq_t.add_column("SQL ID",       width=14)
        sq_t.add_column("Elapsed (s)",  width=12, justify="right")
        sq_t.add_column("CPU (s)",      width=10, justify="right")
        sq_t.add_column("Execs",        width=10, justify="right")
        sq_t.add_column("Buf Gets",     width=12, justify="right")
        sq_t.add_column("Disk Reads",   width=12, justify="right")
        sq_t.add_column("Clus Wait(s)", width=12, justify="right")
        sq_t.add_column("SQL Text",     ratio=1)
        for r in top_sql:
            el    = float(r.get("elapsed_secs", 0) or 0)
            cpu   = float(r.get("cpu_secs", 0) or 0)
            cpu_pct = (cpu / el * 100) if el else 0
            c_col = "green" if cpu_pct > 70 else ("yellow" if cpu_pct > 40 else "red")
            sq_t.add_row(
                r.get("sql_id", ""),
                f"[bold]{el:,.1f}[/]",
                f"[{c_col}]{cpu:,.1f}[/]",
                f"{int(r.get('executions', 0) or 0):,}",
                f"{int(r.get('buffer_gets', 0) or 0):,}",
                f"{int(r.get('disk_reads', 0) or 0):,}",
                f"{float(r.get('cluster_wait_secs', 0) or 0):.1f}",
                (r.get("sql_text") or "")[:60],
            )
        if not top_sql:
            sq_t.add_row("[dim]No AWR SQL data (requires Diagnostics Pack)[/]", "", "", "", "", "", "", "")
        self.query_one("#awr-top-sql", Static).update(
            Panel(sq_t, title="[bold white]AWR Top SQL by Elapsed Time (last 1h)[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── AWR Top Wait Events ───────────────────────────────────────────
        wt_t = Table(show_header=True, header_style="bold #bbc8e8", box=None, padding=(0, 1), expand=True)
        wt_t.add_column("Event",         ratio=3)
        wt_t.add_column("Total Waits",   width=14, justify="right")
        wt_t.add_column("Time (s)",      width=12, justify="right")
        wt_t.add_column("Avg Wait (ms)", width=14, justify="right")
        wt_t.add_column("Class",         width=14)
        for r in top_waits:
            avg  = float(r.get("avg_wait_ms", 0) or 0)
            col  = "green" if avg < 2 else ("yellow" if avg < 10 else "red")
            wt_t.add_row(
                r.get("event_name", r.get("event", "")),
                f"{int(r.get('total_waits', 0) or 0):,}",
                f"{float(r.get('time_waited_secs', 0) or 0):.1f}",
                f"[{col}]{avg:.2f}[/]",
                r.get("wait_class", ""),
            )
        if not top_waits:
            wt_t.add_row("[dim]No AWR wait data (requires Diagnostics Pack)[/]", "", "", "", "")
        self.query_one("#awr-top-waits", Static).update(
            Panel(wt_t, title="[bold white]AWR Top Wait Events (last 1h)[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── Instance Activity (sysstat) ───────────────────────────────────
        if sysstat:
            ss_t = Table.grid(padding=(0, 3), expand=True)
            ss_t.add_column(ratio=1)
            ss_t.add_column(ratio=1)
            ss_t.add_column(ratio=1)
            stat_labels = {
                "DB time":                     ("DB Time (s)",       1e6),
                "CPU used by this session":    ("CPU Time (s)",      1e6),
                "physical read total bytes":   ("Phys Reads (GB)",   1073741824),
                "physical write total bytes":  ("Phys Writes (GB)",  1073741824),
                "redo size":                   ("Redo (MB)",         1048576),
                "user calls":                  ("User Calls",        1),
                "execute count":               ("Executes",          1),
                "hard parses":                 ("Hard Parses",       1),
                "sorts (disk)":                ("Disk Sorts",        1),
                "table scans (long tables)":   ("Full Scans",        1),
            }
            items = []
            for key, (label, div) in stat_labels.items():
                val = float(sysstat.get(key, 0) or 0) / div
                items.append(f"[dim]{label}:[/]  [bold]{val:,.1f}[/]")
            # 3 columns
            for i in range(0, len(items), 3):
                chunk = items[i:i+3]
                while len(chunk) < 3:
                    chunk.append("")
                ss_t.add_row(*chunk)
            self.query_one("#awr-sysstat", Static).update(
                Panel(ss_t, title="[bold white]Instance Activity Metrics (last 1h)[/]", border_style="#1b233a", padding=(0, 1))
            )
        else:
            self.query_one("#awr-sysstat", Static).update(Text(""))

        # ── Recent snapshots ───────────────────────────────────────────────
        if snaps:
            recent = snaps[-8:]
            snaps_text = Text()
            # Mini AAS sparkline
            aas_vals = []
            for snap in snaps[-24:]:
                db_s  = float(snap.get("dbtime_secs", 0) or 0)
                el_s  = float(snap.get("elapsed_secs", 1) or 1)
                aas_vals.append(db_s / el_s if el_s else 0)
            from widgets.charts import sparkline as sp
            if aas_vals:
                snaps_text.append("  AAS trend (24h): ", style="dim")
                snaps_text.append_text(sp(aas_vals, width=48))
                snaps_text.append("\n\n")
            for snap in recent:
                begin = snap.get("begin_time", snap.get("begin_interval_time", "?"))
                end   = snap.get("end_time",   snap.get("end_interval_time", "?"))
                db_s  = float(snap.get("dbtime_secs", 0) or 0)
                el_s  = float(snap.get("elapsed_secs", 1) or 1)
                aas   = db_s / el_s if el_s else 0
                aas_c = "red" if aas > 8 else ("yellow" if aas > 4 else "green")
                s_id  = snap.get("snap_id", snap.get("end_snap_id", "?"))
                snaps_text.append(
                    f"  Snap {s_id:>6}  {str(begin)[:16]} → {str(end)[:16]}  AAS: "
                )
                snaps_text.append(f"{aas:.2f}", style=aas_c)
                snaps_text.append("\n")
            self.query_one("#awr-snaps", Static).update(
                Panel(snaps_text, title="[bold cyan]AWR Snapshots & AAS Trend[/]", border_style="cyan", padding=(0, 1))
            )
        else:
            self.query_one("#awr-snaps", Static).update(
                Panel(Text("  No AWR snapshot data.", style="dim"), title="[bold cyan]AWR Snapshots[/]", border_style="dim")
            )

        # ── ADDM findings ──────────────────────────────────────────────────
        addm_t = Table(show_header=True, header_style="bold #bbc8e8", box=None,
                       padding=(0, 2), expand=True)
        addm_t.add_column("Type",    width=16)
        addm_t.add_column("Finding", ratio=2)
        addm_t.add_column("Impact",  width=10, justify="right")
        addm_t.add_column("Message", ratio=3)
        for f in findings[:10]:
            impact = float(f.get("impact_absolute", 0) or 0)
            ic     = "red" if impact > 30 else ("yellow" if impact > 10 else "cyan")
            addm_t.add_row(
                f"[dim]{f.get('type', '')}[/]",
                f"[bold]{f.get('finding_name', '')}[/]",
                f"[{ic}]{impact:.0f}[/]",
                (f.get("message") or "")[:80],
            )
        if not findings:
            addm_t.add_row("[dim]No ADDM findings (requires Diagnostics Pack)[/]", "", "", "")
        self.query_one("#awr-addm", Static).update(
            Panel(addm_t, title="[bold yellow]ADDM Findings[/]", border_style="yellow", padding=(0, 1))
        )

    _SQL_AWR_REPORT = """
        SELECT output
        FROM TABLE(
            DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_TEXT(
                :dbid, :inst_num, :begin_snap, :end_snap
            )
        )
    """

    async def action_generate(self) -> None:
        snaps = self.cache.get("awr.snapshots", []) or []
        if len(snaps) < 2:
            self.app.notify("Not enough AWR snapshots to generate report.", severity="warning")
            return

        db_info    = self.cache.get("health.db_info", {}) or {}
        dbid       = db_info.get("dbid")
        inst_num   = db_info.get("instance_number", 1)
        if not dbid:
            self.app.notify("DBID not available yet — wait for health collector.", severity="warning")
            return

        end_snap   = snaps[-1].get("snap_id") or snaps[-1].get("end_snap_id")
        begin_snap = snaps[-2].get("snap_id") or snaps[-2].get("end_snap_id")
        self.app.notify(f"Generating AWR report: snap {begin_snap} → {end_snap}…", timeout=5)

        rows = await self.conn.execute_query(
            self._SQL_AWR_REPORT,
            {"dbid": int(dbid), "inst_num": int(inst_num),
             "begin_snap": int(begin_snap), "end_snap": int(end_snap)},
        )
        if rows:
            report_text = "\n".join(str(r.get("output", "")) for r in rows)
            from widgets.text_view_screen import TextViewScreen
            self.app.push_screen(TextViewScreen(
                title=f"AWR Report — snap {begin_snap} → {end_snap}",
                content=report_text,
            ))
        else:
            self.app.notify(
                "AWR report returned no rows — check Diagnostics Pack license.", severity="warning"
            )


# ---------------------------------------------------------------------------
# 11. ASH
# ---------------------------------------------------------------------------

class ASHPanel(BasePanel):

    def compose(self) -> ComposeResult:
        yield Static(id="ash-summary")
        yield DataTable(id="ash-table")

    async def refresh_data(self) -> None:
        ash = self.cache.get("ash.samples", []) or []

        # Activity summary by event
        event_counts: dict[str, int] = {}
        for s in ash:
            ev = str(s.get("event", "CPU") or "CPU")
            event_counts[ev] = event_counts.get(ev, 0) + 1

        total      = len(ash) or 1
        top_events = sorted(event_counts.items(), key=lambda x: x[1], reverse=True)[:6]

        # Dolphie-style: split into two columns
        left_t = Table.grid(padding=(0, 1))
        left_t.add_column(width=36)
        left_t.add_column(width=20)
        left_t.add_column(width=12, justify="right")
        right_t = Table.grid(padding=(0, 1))
        right_t.add_column(width=36)
        right_t.add_column(width=20)
        right_t.add_column(width=12, justify="right")

        for i, (ev, cnt) in enumerate(top_events):
            pct = cnt / total * 100
            row_args = (
                f"[dim]{ev[:34]}[/]",
                pct_bar(pct, width=16, show_pct=False),
                f"[dim]{pct:5.1f}%[/]",
            )
            if i < 3:
                left_t.add_row(*row_args)
            else:
                right_t.add_row(*row_args)

        outer = Table.grid(expand=True, padding=(0, 1))
        outer.add_column(ratio=1)
        outer.add_column(ratio=1)
        outer.add_row(left_t, right_t)

        self.query_one("#ash-summary", Static).update(
            Panel(outer, title=f"[bold cyan]ASH Activity Summary ({total} samples)[/]",
                  border_style="cyan", padding=(0, 1))
        )

        # Detail table
        dt: DataTable = self.query_one("#ash-table")
        if not dt.columns:
            dt.add_columns(
                "Sample Time", "Inst", "SID", "SQL_ID",
                "Event", "Wait Class", "State", "Module",
            )
        cursor = dt.cursor_row
        dt.clear()
        for r in ash[:200]:
            state = str(r.get("session_state", "") or "")
            sc = "green" if state == "ON CPU" else "yellow"
            dt.add_row(
                str(r.get("sample_time", "")),
                str(r.get("inst_id", "")),
                str(r.get("session_id", "")),
                str(r.get("sql_id", "") or ""),
                str(r.get("event", "") or ""),
                str(r.get("wait_class", "") or ""),
                f"[{sc}]{state}[/]",
                str(r.get("module", "") or ""),
            )
        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))


# ---------------------------------------------------------------------------
# 12. ADVISOR
# ---------------------------------------------------------------------------

class AdvisorPanel(BasePanel):
    REFRESH_RATE = 5

    BINDINGS = [
        Binding("enter", "show_sql_detail", "SQL Plan", show=True),
        Binding("s",     "input_sql_id",    "SQL ID…",  show=True),
    ]

    def compose(self) -> ComposeResult:
        yield Static(id="advisor-header")
        yield Static(id="advisor-content")
        yield Static(id="advisor-advisors")
        yield Static(id="advisor-oracle-findings")
        yield Static(id="advisor-sql-label")
        yield DataTable(id="advisor-sql-dt", show_cursor=True, zebra_stripes=True)
        yield Static(id="advisor-sql-plan")
        yield Static(id="advisor-exa")

    async def refresh_data(self) -> None:
        findings        = self.cache.get("advisor.findings", []) or []
        oracle_advisors = self.cache.get("advisor.oracle_advisors", []) or []
        oracle_findings = self.cache.get("advisor.oracle_findings", []) or []
        sql_monitor     = self.cache.get("advisor.sql_monitor", []) or []
        sql_plan        = self.cache.get("advisor.sql_plan", []) or []
        is_exa          = self.cache.get("exa.detected", False)

        # ── Header ─────────────────────────────────────────────────────────
        critical = sum(1 for f in findings if f.get("severity") == "CRITICAL")
        warnings = sum(1 for f in findings if f.get("severity") == "WARNING")
        infos    = sum(1 for f in findings if f.get("severity") == "INFO")
        hdr = Table.grid(padding=(0, 3))
        hdr.add_column(); hdr.add_column(); hdr.add_column()
        hdr.add_row(
            Text.from_markup(f"[bold red]CRITICAL: {critical}[/]"),
            Text.from_markup(f"[bold yellow]WARNING: {warnings}[/]"),
            Text.from_markup(f"[cyan]INFO: {infos}[/]"),
        )
        self.query_one("#advisor-header", Static).update(
            Panel(hdr, title="[bold white]ORA BRABO Advisor[/]",
                  border_style="red", padding=(0, 1))
        )

        # ── ORA BRABO findings ─────────────────────────────────────────────
        t = Table(show_header=True, header_style="bold", box=None,
                  padding=(0, 1), expand=True)
        t.add_column("Severity", width=10)
        t.add_column("Category", width=14)
        t.add_column("Finding",  ratio=2)
        t.add_column("Suggestion", ratio=3)
        for f in findings:
            sev   = f.get("severity", "INFO")
            color = SEVERITY_COLORS.get(str(sev), "white")
            detail = f.get("detail", "")
            t.add_row(
                f"[{color}]{sev}[/]",
                f.get("category", ""),
                f"[bold]{f.get('title', '')}[/]\n[dim]{detail}[/]" if detail else f"[bold]{f.get('title', '')}[/]",
                f.get("suggestion", ""),
            )
        if not findings:
            t.add_row("[green]INFO[/]", "System", "No issues detected.", "Keep monitoring.")
        self.query_one("#advisor-content", Static).update(
            Panel(t, title="[bold white]Continuous Recommendations[/]",
                  border_style="yellow", padding=(0, 1))
        )

        # ── Oracle Advisor Framework ───────────────────────────────────────
        adv_t = Table(show_header=True, header_style="bold #bbc8e8",
                      box=None, padding=(0, 1), expand=True)
        adv_t.add_column("Advisor",   ratio=2)
        adv_t.add_column("Tasks",     width=7,  justify="right")
        adv_t.add_column("Completed", width=11, justify="right")
        adv_t.add_column("Errors",    width=8,  justify="right")
        adv_t.add_column("Last Run",  width=18)
        adv_t.add_column("Status",    width=12)
        for adv in oracle_advisors:
            errors = int(adv.get("errors", 0) or 0)
            status = str(adv.get("last_status", ""))
            sc     = "green" if status == "COMPLETED" and errors == 0 else ("red" if errors > 0 else "yellow")
            adv_t.add_row(
                f"[bold]{adv.get('advisor_name', '')}[/]",
                str(adv.get("task_count", 0)),
                str(adv.get("completed", 0)),
                f"[red]{errors}[/]" if errors else "[dim]0[/]",
                str(adv.get("last_run", "") or "—"),
                f"[{sc}]{status}[/]",
            )
        if not oracle_advisors:
            adv_t.add_row("[dim]No advisor data[/]", "", "", "", "", "")
        self.query_one("#advisor-advisors", Static).update(
            Panel(adv_t, title="[bold white]Oracle Advisor Framework[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

        # ── Oracle Advisor findings ────────────────────────────────────────
        of_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=None, padding=(0, 1), expand=True)
        of_t.add_column("Advisor",  width=22)
        of_t.add_column("Finding",  ratio=2)
        of_t.add_column("Type",     width=12)
        of_t.add_column("Impact %", width=10, justify="right")
        of_t.add_column("Message",  ratio=3)
        for f in oracle_findings:
            impact = float(f.get("impact", 0) or 0)
            ic     = "red" if impact > 30 else ("yellow" if impact > 10 else "green")
            of_t.add_row(
                f"[dim]{f.get('advisor_name', '')}[/]",
                f"[bold]{f.get('finding_name', '')}[/]",
                str(f.get("type", "")),
                f"[{ic}]{impact:.1f}[/]",
                (f.get("message") or "")[:80],
            )
        if not oracle_findings:
            of_t.add_row("[dim]No oracle advisor findings[/]", "", "", "", "")
        self.query_one("#advisor-oracle-findings", Static).update(
            Panel(of_t, title="[bold white]Advisor Findings & Recommendations[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

        # ── SQL Monitor DataTable (interactive) ───────────────────────────
        self.query_one("#advisor-sql-label", Static).update(
            Text.from_markup(
                f"[bold]{len(sql_monitor)}[/] monitored SQL(s)  "
                f"[dim]Enter=Execution Plan  S=Enter SQL ID[/]"
            )
        )
        dt: DataTable = self.query_one("#advisor-sql-dt")
        if not dt.columns:
            dt.add_columns(
                "SQL ID", "Status", "User", "Elapsed(s)", "CPU(s)",
                "Buf Gets", "Disk Reads", "Rows", "Inst", "SQL Text",
            )
        dt.clear()
        for r in sql_monitor:
            status   = str(r.get("status", ""))
            sc       = "green" if status == "EXECUTING" else "dim"
            elapsed  = float(r.get("elapsed_secs", 0) or 0)
            cpu      = float(r.get("cpu_secs", 0) or 0)
            cpu_pct  = (cpu / elapsed * 100) if elapsed else 0
            c_col    = "green" if cpu_pct > 70 else ("yellow" if cpu_pct > 40 else "red")
            dt.add_row(
                str(r.get("sql_id", "")),
                Text.from_markup(f"[{sc}]{status}[/]"),
                str(r.get("username", "") or ""),
                f"{elapsed:,.1f}",
                Text.from_markup(f"[{c_col}]{cpu:,.1f}[/]"),
                f"{int(r.get('buffer_gets', 0) or 0):,}",
                f"{int(r.get('disk_reads', 0) or 0):,}",
                f"{int(r.get('rows_processed', 0) or 0):,}",
                str(r.get("inst_id", "") or ""),
                (r.get("sql_text") or "")[:50],
                key=str(r.get("sql_id", "")),
            )

        # ── Execution plan (from cache — top SQL from monitor) ─────────────
        if sql_plan:
            plan_sql = sql_plan[0].get("sql_id", "")
            plan_t = Table(show_header=True, header_style="bold #bbc8e8",
                           box=None, padding=(0, 1), expand=True)
            plan_t.add_column("#",      width=4,  justify="right")
            plan_t.add_column("Operation", ratio=2)
            plan_t.add_column("Object",    width=20)
            plan_t.add_column("Rows Est",  width=10, justify="right")
            plan_t.add_column("Rows Act",  width=10, justify="right")
            plan_t.add_column("Starts",    width=8,  justify="right")
            plan_t.add_column("Elapsed(s)",width=11, justify="right")
            plan_t.add_column("Disk Rd",   width=9,  justify="right")
            plan_t.add_column("Status",    width=12)
            for r in sql_plan:
                pid    = r.get("plan_line_id", 0)
                indent = "  " * min(int(pid or 0), 8)
                status = str(r.get("status", "") or "")
                sc     = "green" if status == "EXECUTING" else "dim"
                plan_t.add_row(
                    str(pid),
                    f"{indent}{r.get('operation', '')}",
                    str(r.get("object_name", "") or ""),
                    f"{int(r.get('cardinality', 0) or 0):,}" if r.get("cardinality") else "—",
                    f"{int(r.get('actual_rows', 0) or 0):,}" if r.get("actual_rows") else "—",
                    f"{int(r.get('starts', 0) or 0):,}" if r.get("starts") else "—",
                    f"{float(r.get('elapsed_secs', 0) or 0):.1f}" if r.get("elapsed_secs") else "—",
                    f"{int(r.get('disk_reads', 0) or 0):,}" if r.get("disk_reads") else "—",
                    f"[{sc}]{status}[/]" if status else "",
                )
            self.query_one("#advisor-sql-plan", Static).update(
                Panel(plan_t, title=f"[bold white]Execution Plan — SQL {plan_sql}[/]",
                      border_style="#1b233a", padding=(0, 1))
            )
        else:
            self.query_one("#advisor-sql-plan", Static).update(
                Panel(Text("  No SQL execution plan available.\n  Select a SQL in the monitor above and press Enter.", style="dim"),
                      title="[bold white]SQL Execution Plan[/]", border_style="dim")
            )

        # ── Exadata ─────────────────────────────────────────────────────────
        if is_exa:
            smart = self.cache.get("exa.smart_scan", {}) or {}
            flash = self.cache.get("exa.flash_cache", {}) or {}
            exa_t = Table.grid(padding=(0, 2))
            exa_t.add_column(width=28); exa_t.add_column()
            exa_t.add_row("[dim]Smart Scan %[/]",          pct_bar(smart.get("smart_scan_pct", 0), width=16))
            exa_t.add_row("[dim]Offload Efficiency %[/]",  pct_bar(smart.get("offload_efficiency_pct", 0), width=16))
            exa_t.add_row("[dim]Storage Index Savings %[/]",pct_bar(smart.get("storage_index_pct", 0), width=16))
            exa_t.add_row("[dim]Flash Cache Hit %[/]",     pct_bar(flash.get("hit_pct", 0), width=16))
            self.query_one("#advisor-exa", Static).update(
                Panel(exa_t, title="[bold yellow]Exadata Performance[/]",
                      border_style="yellow", padding=(0, 1))
            )
        else:
            self.query_one("#advisor-exa", Static).update(Text(""))

    def _get_selected_sql(self) -> tuple[str, str, list[dict]] | None:
        dt: DataTable = self.query_one("#advisor-sql-dt")
        sql_monitor = self.cache.get("advisor.sql_monitor", []) or []
        row_idx = dt.cursor_row
        if 0 <= row_idx < len(sql_monitor):
            r      = sql_monitor[row_idx]
            sql_id = str(r.get("sql_id", ""))
            sql_txt= str(r.get("sql_text", "") or "")
            plan   = self.cache.get("advisor.sql_plan", []) or []
            plan   = [p for p in plan if p.get("sql_id") == sql_id] or plan
            return sql_id, sql_txt, plan
        return None

    def action_show_sql_detail(self) -> None:
        from widgets.explain_screen import ExplainScreen
        result = self._get_selected_sql()
        if result:
            self.app.push_screen(ExplainScreen(*result))
        else:
            self.app.notify("No SQL selected", severity="warning")

    def action_input_sql_id(self) -> None:
        from widgets.sql_input_screen import SQLInputScreen
        def on_result(sql_id: str | None) -> None:
            if not sql_id:
                return
            from widgets.explain_screen import ExplainScreen
            sql_monitor = self.cache.get("advisor.sql_monitor", []) or []
            matching = next((r for r in sql_monitor if r.get("sql_id") == sql_id), None)
            sql_txt  = str(matching.get("sql_text", "")) if matching else ""
            plan     = self.cache.get("advisor.sql_plan", []) or []
            plan     = [p for p in plan if p.get("sql_id") == sql_id] or plan
            self.app.push_screen(ExplainScreen(sql_id, sql_txt, plan))
        self.app.push_screen(SQLInputScreen(), on_result)


# ---------------------------------------------------------------------------
# 13. EXADATA
# ---------------------------------------------------------------------------

class ExadataPanel(BasePanel):
    """Exadata monitoring panel — no rack diagram, pure metrics tables."""
    REFRESH_RATE = 10

    def compose(self) -> ComposeResult:
        yield Static(id="exa-overview")
        yield Static(id="exa-metrics")
        yield Static(id="exa-cells")
        yield Static(id="exa-sql-offload")
        yield Static(id="exa-cell-waits")
        yield Static(id="exa-hcc")
        yield Static(id="exa-params")

    async def refresh_data(self) -> None:
        detected: bool = self.cache.get("exa.detected", False) or False
        self._render_overview(detected)
        if not detected:
            return
        self._render_metrics()
        self._render_cells()
        self._render_sql_offload()
        self._render_cell_waits()
        self._render_hcc()
        self._render_params()

    def _render_overview(self, detected: bool) -> None:
        cells:  list[dict] = self.cache.get("exa.cells", []) or []
        inst:   list[dict] = self.cache.get("rac.instances", []) or []
        smart:  dict       = self.cache.get("exa.smart_scan", {}) or {}
        flash:  dict       = self.cache.get("exa.flash_cache", {}) or {}

        if not detected:
            msg = Text()
            msg.append("\n  ✗  ", style="bold #f85149")
            msg.append("This database is NOT running on Exadata.\n\n", style="bold #e6edf3")
            msg.append(
                "  Detection: v$sysstat › 'cell physical IO bytes eligible for predicate offload'\n"
                "  was not found — no Exadata Cell Servers are connected.\n\n",
                style="#8b949e",
            )
            msg.append("  →  Press ", style="#8b949e")
            msg.append("F1", style="bold #58a6ff")
            msg.append(" to return to Dashboard.", style="#8b949e")
            self.query_one("#exa-overview", Static).update(
                Panel(msg, title="[bold yellow]Exadata[/]",
                      border_style="yellow", padding=(1, 2))
            )
            return

        ov_t = Table(show_header=False, box=None, padding=(0, 3), expand=True)
        ov_t.add_column(width=24, style="dim")
        ov_t.add_column(ratio=1)
        ov_t.add_column(width=24, style="dim")
        ov_t.add_column(ratio=1)

        nc = len(cells)
        nn = len(inst)
        smart_pct   = float(smart.get("smart_scan_pct", 0) or 0)
        offload_pct = float(smart.get("offload_efficiency_pct", 0) or 0)
        storidx_pct = float(smart.get("storage_index_pct", 0) or 0)
        flash_pct   = float(flash.get("hit_pct", 0) or 0)
        elig_gb     = float(smart.get("eligible_gb", 0) or 0)
        ret_gb      = float(smart.get("returned_gb", 0) or 0)
        saved_gb    = float(smart.get("saved_by_storage_index_gb", 0) or 0)

        sp_c  = "green" if smart_pct >= 70 else ("yellow" if smart_pct >= 40 else "red")
        op_c  = "green" if offload_pct >= 80 else ("yellow" if offload_pct >= 50 else "red")
        si_c  = "green" if storidx_pct >= 40 else "yellow"
        fl_c  = "green" if flash_pct >= 80 else ("yellow" if flash_pct >= 50 else "red")

        node_str = ", ".join(i.get("host_name", "?") for i in inst) if inst else "—"
        cell_str = ", ".join(c.get("cell_name", c.get("ip_address", "?")) for c in cells) if cells else "—"
        ov_t.add_row("DB Nodes",          Text.from_markup(f"[bold]{nn}[/] ({node_str})"),
                     "Storage Cells",     Text.from_markup(f"[bold cyan]{nc}[/] ({cell_str})"))
        ov_t.add_row("Smart Scan %",      Text.from_markup(f"[{sp_c}]{smart_pct:.1f}%[/]"),
                     "Offload Efficiency",Text.from_markup(f"[{op_c}]{offload_pct:.1f}%[/]"))
        ov_t.add_row("Storage Index %",   Text.from_markup(f"[{si_c}]{storidx_pct:.1f}%[/]"),
                     "Flash Cache Hit %", Text.from_markup(f"[{fl_c}]{flash_pct:.1f}%[/]"))
        ov_t.add_row("Eligible GB",       f"{elig_gb:.1f}",
                     "Returned via IB",   f"{ret_gb:.1f} GB")
        ov_t.add_row("Saved (Stor.Idx)",  f"{saved_gb:.1f} GB",
                     "Flash Hits",        f"{flash.get('hits', 0):,}")

        self.query_one("#exa-overview", Static).update(
            Panel(ov_t, title="[bold yellow]Exadata Overview[/]",
                  border_style="yellow", padding=(0, 1))
        )

    def _render_metrics(self) -> None:
        smart = self.cache.get("exa.smart_scan", {}) or {}
        flash = self.cache.get("exa.flash_cache", {}) or {}

        smart_pct   = smart.get("smart_scan_pct", 0)
        offload_pct = smart.get("offload_efficiency_pct", 0)
        storidx_pct = smart.get("storage_index_pct", 0)
        flash_pct   = flash.get("hit_pct", 0)

        elig_gb = smart.get("eligible_gb", 0)
        ret_gb  = smart.get("returned_gb", 0)
        saved_gb = smart.get("saved_by_storage_index_gb", 0)

        t = Table.grid(padding=(0, 3), expand=True)
        t.add_column(ratio=1)
        t.add_column(ratio=1)

        # Left column — Smart Scan
        left = Table.grid(padding=(0, 1))
        left.add_column(width=26)
        left.add_column()
        left.add_row("[bold #bbc8e8]Smart Scan %[/]",          pct_bar(smart_pct,   24, show_pct=True))
        left.add_row("[bold #bbc8e8]Offload Efficiency %[/]",  pct_bar(offload_pct, 24, show_pct=True))
        left.add_row("[bold #bbc8e8]Storage Index Savings %[/]", pct_bar(storidx_pct, 24, show_pct=True))
        left.add_row("[bold #bbc8e8]Flash Cache Hit %[/]",     pct_bar(flash_pct,   24, show_pct=True))

        # Right column — Throughput
        right = Table.grid(padding=(0, 1))
        right.add_column(width=26)
        right.add_column()
        right.add_row("[dim]Eligible for Offload[/]",  f"[bold]{elig_gb:.1f} GB[/]")
        right.add_row("[dim]Returned via IB[/]",       f"[cyan]{ret_gb:.1f} GB[/]")
        right.add_row("[dim]Saved by Stor. Index[/]",  f"[green]{saved_gb:.1f} GB[/]")
        right.add_row("[dim]Flash Cache Hits[/]",      f"[yellow]{flash.get('hits', 0):,}[/]")

        t.add_row(
            Panel(left,  title="[bold white]Performance[/]", border_style="#1b233a", padding=(0, 1)),
            Panel(right, title="[bold white]I/O Stats[/]",   border_style="#1b233a", padding=(0, 1)),
        )

        self.query_one("#exa-metrics", Static).update(
            Panel(t, title="[bold white]Exadata Performance Metrics[/]",
                  border_style="yellow", padding=(0, 1))
        )

    def _render_cells(self) -> None:
        cells: list[dict] = self.cache.get("exa.cells", []) or []

        t = Table(show_header=True, header_style="bold #bbc8e8",
                  box=None, padding=(0, 2), expand=True)
        t.add_column("Cell Name", ratio=2)
        t.add_column("IP Address", ratio=2)
        t.add_column("Interconnect IP", ratio=2)
        t.add_column("Status", width=10)
        t.add_column("Version", ratio=2)

        for c in cells:
            status = c.get("cell_status", "?")
            color  = "green" if status == "online" else "red"
            t.add_row(
                c.get("cell_name", "?"),
                c.get("ip_address", "N/A"),
                c.get("interconnect_ip", "N/A"),
                f"[{color}]{status}[/]",
                c.get("cell_version", "N/A"),
            )

        if not cells:
            t.add_row("[dim]No cell data[/]", "", "", "", "")

        self.query_one("#exa-cells", Static).update(
            Panel(t, title="[bold white]Cell Servers[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

    def _render_sql_offload(self) -> None:
        rows: list[dict] = self.cache.get("exa.sql_offload", []) or []

        t = Table(show_header=True, header_style="bold #bbc8e8",
                  box=None, padding=(0, 2), expand=True)
        t.add_column("SQL ID",       width=14)
        t.add_column("Schema",       width=14)
        t.add_column("Execs",        width=9,  justify="right")
        t.add_column("Eligible GB",  width=12, justify="right")
        t.add_column("IB GB",        width=10, justify="right")
        t.add_column("Offload %",    width=10, justify="right")
        t.add_column("SQL Text",     ratio=1)

        for r in rows:
            offpct  = float(r.get("offload_pct", 0) or 0)
            off_col = "green" if offpct >= 80 else ("yellow" if offpct >= 50 else "red")
            t.add_row(
                r.get("sql_id", ""),
                r.get("schema_name", ""),
                f"{int(r.get('executions', 0)):,}",
                f"{float(r.get('eligible_gb', 0)):.1f}",
                f"{float(r.get('ib_gb', 0)):.1f}",
                f"[{off_col}]{offpct:.1f}%[/]",
                (r.get("sql_text") or "")[:60],
            )

        if not rows:
            t.add_row("[dim]No offload data — Exadata SQL stats populate after workload[/]",
                      "", "", "", "", "", "")

        self.query_one("#exa-sql-offload", Static).update(
            Panel(t, title="[bold white]Top SQLs by Exadata Offload Efficiency[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

    def _render_cell_waits(self) -> None:
        rows: list[dict] = self.cache.get("exa.cell_waits", []) or []

        t = Table(show_header=True, header_style="bold #bbc8e8",
                  box=None, padding=(0, 2), expand=True)
        t.add_column("Event",           ratio=3)
        t.add_column("Total Waits",     width=14, justify="right")
        t.add_column("Time (s)",        width=12, justify="right")
        t.add_column("Avg Wait (ms)",   width=14, justify="right")
        t.add_column("Class",           width=12)

        for r in rows:
            avg_ms = float(r.get("avg_wait_ms", 0) or 0)
            color  = "green" if avg_ms < 2 else ("yellow" if avg_ms < 10 else "red")
            t.add_row(
                r.get("event", ""),
                f"{int(r.get('total_waits', 0)):,}",
                f"{float(r.get('time_waited_secs', 0)):.1f}",
                f"[{color}]{avg_ms:.2f}[/]",
                r.get("wait_class", ""),
            )

        if not rows:
            t.add_row("[dim]No cell wait events found[/]", "", "", "", "")

        self.query_one("#exa-cell-waits", Static).update(
            Panel(t, title="[bold white]Cell Wait Events[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

    def _render_hcc(self) -> None:
        rows: list[dict] = self.cache.get("exa.hcc_objects", []) or []

        t = Table(show_header=True, header_style="bold #bbc8e8",
                  box=None, padding=(0, 2), expand=True)
        t.add_column("Owner",         width=16)
        t.add_column("Table",         ratio=2)
        t.add_column("Compression",   width=16)
        t.add_column("Rows",          width=16, justify="right")
        t.add_column("Size MB",       width=12, justify="right")
        t.add_column("Last Analyzed", width=14)

        for r in rows:
            compress = r.get("compress_for", "")
            c_color  = "green" if "HIGH" in compress else "yellow"
            analyzed = r.get("last_analyzed")
            analyzed_s = analyzed.strftime("%Y-%m-%d") if hasattr(analyzed, "strftime") else str(analyzed or "N/A")
            num_rows = r.get("num_rows")
            rows_s   = f"{int(num_rows):,}" if num_rows else "N/A"
            t.add_row(
                r.get("owner", ""),
                r.get("table_name", ""),
                f"[{c_color}]{compress}[/]",
                rows_s,
                f"{float(r.get('size_mb', 0)):.0f}",
                analyzed_s,
            )

        if not rows:
            t.add_row("[dim]No HCC-compressed objects found[/]", "", "", "", "", "")

        self.query_one("#exa-hcc", Static).update(
            Panel(t, title="[bold white]HCC Compressed Objects (Hybrid Columnar Compression)[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

    def _render_params(self) -> None:
        rows: list[dict] = self.cache.get("exa.params", []) or []

        t = Table(show_header=True, header_style="bold #bbc8e8",
                  box=None, padding=(0, 2), expand=True)
        t.add_column("Parameter",   ratio=2)
        t.add_column("Value",       width=20)
        t.add_column("Description", ratio=3)

        for r in rows:
            name  = r.get("name", "")
            val   = str(r.get("value", "") or "")
            desc  = (r.get("description") or "")[:80]
            # Highlight key Exadata params
            n_col = "#58a6ff" if name.startswith("cell") else "#e6edf3"
            t.add_row(f"[{n_col}]{name}[/]", f"[bold]{val}[/]", f"[dim]{desc}[/]")

        if not rows:
            t.add_row("[dim]No Exadata parameters found[/]", "", "")

        self.query_one("#exa-params", Static).update(
            Panel(t, title="[bold white]Exadata Database Parameters[/]",
                  border_style="#1b233a", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 14. PDB MONITOR
# ---------------------------------------------------------------------------

class PDBPanel(BasePanel):
    """Pluggable Database monitor — only active when connected to a CDB."""

    def compose(self) -> ComposeResult:
        yield Static(id="pdb-overview")
        yield Static(id="pdb-ts")

    async def refresh_data(self) -> None:
        detected = self.cache.get("pdb.detected", False)
        pdbs     = self.cache.get("pdb.list", []) or []
        ts_list  = self.cache.get("pdb.tablespaces", []) or []

        if not detected:
            self.query_one("#pdb-overview", Static).update(
                Panel(
                    Text("  CDB not detected — this is a non-container database.\n\n"
                         "  PDB monitoring requires Oracle 12c+ in CDB mode.", style="dim"),
                    title="[bold cyan]PDB Monitor[/]",
                    border_style="dim",
                    padding=(1, 2),
                )
            )
            self.query_one("#pdb-ts", Static).update(Text(""))
            return

        # ── PDB overview table ────────────────────────────────────────────
        t = Table(show_header=True, header_style="bold cyan",
                  box=None, padding=(0, 2), expand=True)
        t.add_column("Con ID",     width=7)
        t.add_column("PDB Name",   ratio=2)
        t.add_column("Open Mode",  width=14)
        t.add_column("Restricted", width=11)
        t.add_column("Recovery",   width=12)
        t.add_column("Size MB",    width=12, justify="right")
        t.add_column("Sessions",   width=16)
        t.add_column("Created",    width=12)

        for p in pdbs:
            mode  = str(p.get("open_mode", ""))
            mc    = "green" if mode == "READ WRITE" else ("yellow" if mode == "READ ONLY" else "red")
            restr = str(p.get("restricted", "NO"))
            rc    = "yellow" if restr == "YES" else "dim"
            recv  = str(p.get("recovery_status", ""))
            rvc   = "yellow" if recv == "ENABLED" else "dim"
            asess = p.get("active_sessions", 0)
            tsess = p.get("total_sessions", 0)
            ctime = p.get("creation_time")
            ctime_s = ctime.strftime("%Y-%m-%d") if hasattr(ctime, "strftime") else str(ctime or "—")
            t.add_row(
                str(p.get("con_id", "")),
                f"[bold]{p.get('name', '')}[/]",
                f"[{mc}]{mode}[/]",
                f"[{rc}]{restr}[/]",
                f"[{rvc}]{recv}[/]",
                fmt(p.get("total_mb"), 1),
                f"[green]{asess}[/] act / {tsess} tot",
                f"[dim]{ctime_s}[/]",
            )
        if not pdbs:
            t.add_row("[dim]No PDB data[/]", "", "", "", "", "", "", "")

        self.query_one("#pdb-overview", Static).update(
            Panel(t,
                  title=f"[bold cyan]Pluggable Databases — {len(pdbs)} PDB(s)[/]",
                  border_style="cyan", padding=(0, 1))
        )

        # ── PDB tablespaces grouped by PDB ─────────────────────────────────
        pdb_name = {p.get("con_id"): p.get("name", str(p.get("con_id", ""))) for p in pdbs}
        ts_by_pdb: dict[int, list[dict]] = {}
        for ts in ts_list:
            cid = int(ts.get("con_id", 0))
            ts_by_pdb.setdefault(cid, []).append(ts)

        ts_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=None, padding=(0, 1), expand=True)
        ts_t.add_column("PDB",        width=16)
        ts_t.add_column("Tablespace", ratio=2)
        ts_t.add_column("Total MB",   width=12, justify="right")
        ts_t.add_column("Used MB",    width=12, justify="right")
        ts_t.add_column("Used %",     width=22)

        for cid, rows in sorted(ts_by_pdb.items()):
            name = pdb_name.get(cid, str(cid))
            for ts in rows:
                pct = float(ts.get("used_pct", 0) or 0)
                ts_t.add_row(
                    f"[cyan]{name}[/]",
                    f"[bold]{ts.get('tablespace_name', '')}[/]",
                    fmt(ts.get("total_mb"), 1),
                    fmt(ts.get("used_mb"), 1),
                    pct_bar(pct, width=16, show_pct=True),
                )

        if not ts_list:
            ts_t.add_row("[dim]No tablespace data[/]", "", "", "", "")

        self.query_one("#pdb-ts", Static).update(
            Panel(ts_t,
                  title="[bold #bbc8e8]PDB Tablespaces[/]",
                  border_style="#1b233a", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 15. I/O ACTIVITY
# ---------------------------------------------------------------------------

class IOActivityPanel(BasePanel):
    """I/O by datafile, by function, load profile, redo logs, undo stats."""
    REFRESH_RATE = 5

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    def compose(self) -> ComposeResult:
        yield Static(id="io-header")
        yield Static(id="io-file-table")
        yield Static(id="io-func-table")
        yield Static(id="io-load-profile")
        yield Static(id="io-redo-logs")
        yield Static(id="io-redo-switches")
        yield Static(id="io-undo")

    async def refresh_data(self) -> None:
        file_stats   = self.cache.get("io.file_stats",           []) or []
        func_stats   = self.cache.get("io.function_stats",       []) or []
        load_profile = self.cache.get("io.load_profile",         []) or []
        redo_logs    = self.cache.get("io.redo_logs",            []) or []
        redo_files   = self.cache.get("io.redo_log_files",       []) or []
        switches     = self.cache.get("io.redo_switches_per_hour",[]) or []
        undo_stats   = self.cache.get("io.undo_stats",           []) or []
        undo_extents = self.cache.get("io.undo_extents",         []) or []

        # ── Header summary ─────────────────────────────────────────────
        total_read_mb  = sum(float(r.get("read_mb",  0) or 0) for r in file_stats)
        total_write_mb = sum(float(r.get("write_mb", 0) or 0) for r in file_stats)
        top_file       = file_stats[0].get("name", "—")[:40] if file_stats else "—"
        top_func       = func_stats[0].get("function_name", "—") if func_stats else "—"

        h = Table.grid(expand=True, padding=(0, 3))
        h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Total Read MB:[/] [bold cyan]{total_read_mb:,.1f}[/]",
            f"[dim]Total Write MB:[/] [bold yellow]{total_write_mb:,.1f}[/]",
            f"[dim]Top File:[/] [dim]{top_file}[/]",
            f"[dim]Top Function:[/] [dim]{top_func}[/]",
        )
        self.query_one("#io-header", Static).update(
            Panel(h, title="[bold blue]I/O Activity[/]", border_style="blue", padding=(0, 1))
        )

        # ── File I/O table ─────────────────────────────────────────────
        ft = Table(show_header=True, header_style="bold #bbc8e8",
                   box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        ft.add_column("File", ratio=2)
        ft.add_column("Tablespace", width=14)
        ft.add_column("Reads", width=10, justify="right")
        ft.add_column("Writes", width=10, justify="right")
        ft.add_column("Read MB", width=10, justify="right")
        ft.add_column("Write MB", width=10, justify="right")
        ft.add_column("Avg R(ms)", width=11, justify="right")
        ft.add_column("Avg W(ms)", width=11, justify="right")
        for r in file_stats[:20]:
            avg_r = float(r.get("avg_read_ms",  0) or 0)
            avg_w = float(r.get("avg_write_ms", 0) or 0)
            rc = "red" if avg_r > 20 else ("yellow" if avg_r > 5 else "green")
            wc = "red" if avg_w > 20 else ("yellow" if avg_w > 5 else "green")
            ft.add_row(
                str(r.get("name", ""))[-40:],
                str(r.get("tablespace_name", "")),
                f"{int(r.get('phyrds', 0) or 0):,}",
                f"{int(r.get('phywrts', 0) or 0):,}",
                fmt(r.get("read_mb"), 1),
                fmt(r.get("write_mb"), 1),
                f"[{rc}]{avg_r:.2f}[/]",
                f"[{wc}]{avg_w:.2f}[/]",
            )
        if not file_stats:
            ft.add_row("[dim]No file I/O data[/]", "", "", "", "", "", "", "")
        self.query_one("#io-file-table", Static).update(
            Panel(ft, title="[bold white]I/O by Datafile[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── Function I/O table ─────────────────────────────────────────
        fn_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        fn_t.add_column("Function", ratio=2)
        fn_t.add_column("Lg Reads", width=10, justify="right")
        fn_t.add_column("Sm Reads", width=10, justify="right")
        fn_t.add_column("Lg Writes", width=10, justify="right")
        fn_t.add_column("Sm Writes", width=10, justify="right")
        fn_t.add_column("Total R MB", width=12, justify="right")
        fn_t.add_column("Total W MB", width=12, justify="right")
        fn_t.add_column("Avg Lg R(ms)", width=13, justify="right")
        for r in func_stats[:10]:
            fn_t.add_row(
                str(r.get("function_name", "")),
                f"{int(r.get('large_read_reqs', 0) or 0):,}",
                f"{int(r.get('small_read_reqs', 0) or 0):,}",
                f"{int(r.get('large_write_reqs', 0) or 0):,}",
                f"{int(r.get('small_write_reqs', 0) or 0):,}",
                fmt(r.get("total_read_mb"), 1),
                fmt(r.get("total_write_mb"), 1),
                fmt(r.get("avg_large_read_ms"), 2),
            )
        if not func_stats:
            fn_t.add_row("[dim]No function I/O data[/]", "", "", "", "", "", "", "")
        self.query_one("#io-func-table", Static).update(
            Panel(fn_t, title="[bold white]I/O by Function[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── Load Profile ───────────────────────────────────────────────
        lp_map = {r.get("metric_name", ""): float(r.get("value", 0) or 0) for r in load_profile}
        lp_t = Table.grid(padding=(0, 3), expand=True)
        lp_t.add_column(ratio=1); lp_t.add_column(ratio=1)
        lp_t.add_column(ratio=1); lp_t.add_column(ratio=1)
        metrics = [
            ("DB Time/s",        "DB Time Per Sec",          "red"),
            ("CPU/s",            "CPU Usage Per Sec",         "yellow"),
            ("Redo/s",           "Redo Generated Per Sec",    "cyan"),
            ("Log Reads/s",      "Logical Reads Per Sec",     "white"),
            ("Phys Reads/s",     "Physical Reads Per Sec",    "blue"),
            ("Phys Writes/s",    "Physical Writes Per Sec",   "blue"),
            ("Hard Parses/s",    "Hard Parses Per Sec",       "magenta"),
            ("Executes/s",       "Executions Per Sec",        "green"),
            ("Transactions/s",   "Transactions Per Sec",      "cyan"),
            ("User Commits/s",   "User Commits Per Sec",      "green"),
            ("User Calls/s",     "User Calls Per Sec",        "dim"),
            ("Rollbacks/s",      "User Rollbacks Per Sec",    "yellow"),
        ]
        items = [f"[dim]{lbl}[/] [{clr}]{lp_map.get(key, 0):,.2f}[/]"
                 for lbl, key, clr in metrics]
        for i in range(0, len(items), 4):
            chunk = items[i:i+4]
            while len(chunk) < 4:
                chunk.append("")
            lp_t.add_row(*chunk)
        self.query_one("#io-load-profile", Static).update(
            Panel(lp_t, title="[bold white]Load Profile (last 60s — v$sysmetric)[/]",
                  border_style="cyan", padding=(0, 1))
        )

        # ── Redo log groups ────────────────────────────────────────────
        rl_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        rl_t.add_column("Group#", width=7, justify="right")
        rl_t.add_column("Members", width=8, justify="right")
        rl_t.add_column("Size MB", width=9, justify="right")
        rl_t.add_column("Status", width=10)
        rl_t.add_column("Archived", width=9)
        rl_t.add_column("Sequence#", width=11, justify="right")
        rl_t.add_column("First Time", width=20)
        rl_t.add_column("Members", ratio=1)

        # collect member paths per group
        members_by_group: dict = {}
        for lf in redo_files:
            g = lf.get("group#")
            members_by_group.setdefault(g, []).append(str(lf.get("member", "")))

        for r in redo_logs:
            status = str(r.get("status", ""))
            if status == "CURRENT":
                sc = "bold green"
            elif status == "ACTIVE":
                sc = "yellow"
            else:
                sc = "dim"
            grp = r.get("group#")
            member_str = ", ".join(members_by_group.get(grp, []))
            ft_str = str(r.get("first_time", ""))
            rl_t.add_row(
                str(grp),
                str(r.get("members", "")),
                fmt(r.get("size_mb"), 0),
                f"[{sc}]{status}[/]",
                str(r.get("archived", "")),
                str(r.get("sequence#", r.get("sequence", ""))),
                ft_str[:19] if ft_str else "—",
                f"[dim]{member_str[:60]}[/]",
            )
        if not redo_logs:
            rl_t.add_row("[dim]No redo log data[/]", "", "", "", "", "", "", "")
        self.query_one("#io-redo-logs", Static).update(
            Panel(rl_t, title="[bold yellow]Redo Log Groups[/]", border_style="yellow", padding=(0, 1))
        )

        # ── Redo switches table ────────────────────────────────────────
        sw_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        sw_t.add_column("Hour", width=18)
        sw_t.add_column("Switches", width=10, justify="right")
        for r in switches[:12]:
            cnt = int(r.get("switches", 0) or 0)
            cc  = "red" if cnt > 4 else ("yellow" if cnt > 2 else "green")
            sw_t.add_row(str(r.get("hour_slot", "")), f"[{cc}]{cnt}[/]")
        if not switches:
            sw_t.add_row("[dim]No switch history[/]", "")
        self.query_one("#io-redo-switches", Static).update(
            Panel(sw_t, title="[bold white]Redo Switches per Hour (last 24h)[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

        # ── Undo stats ─────────────────────────────────────────────────
        undo_t = Table(show_header=True, header_style="bold #bbc8e8",
                       box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        undo_t.add_column("Begin",       width=20)
        undo_t.add_column("End",         width=20)
        undo_t.add_column("Undo Blks",   width=11, justify="right")
        undo_t.add_column("Txns",        width=8,  justify="right")
        undo_t.add_column("Max Q Len",   width=10, justify="right")
        undo_t.add_column("MaxConcur",   width=10, justify="right")
        undo_t.add_column("ORA-01555",   width=10, justify="right")
        undo_t.add_column("No Space",    width=10, justify="right")
        for r in undo_stats[:5]:
            ss_err = int(r.get("ssolderrcnt", 0) or 0)
            ns_err = int(r.get("nospaceerrcnt", 0) or 0)
            undo_t.add_row(
                str(r.get("begin_time", ""))[:19],
                str(r.get("end_time",   ""))[:19],
                f"{int(r.get('undoblks', 0) or 0):,}",
                f"{int(r.get('txncount', 0) or 0):,}",
                f"{int(r.get('maxquerylen', 0) or 0):,}",
                f"{int(r.get('maxconcurrency', 0) or 0):,}",
                f"[{'red' if ss_err else 'dim'}]{ss_err}[/]",
                f"[{'red' if ns_err else 'dim'}]{ns_err}[/]",
            )
        # Undo extents summary
        ext_parts = []
        for e in undo_extents:
            ext_parts.append(f"[dim]{e.get('status','')}:[/] {e.get('ext_count',0)} exts / {fmt(e.get('total_mb'),1)} MB")
        ext_str = "  ".join(ext_parts) if ext_parts else "[dim]No extent data[/]"
        undo_body: RenderableType = Group(undo_t, Text.from_markup(f"\n  Extents: {ext_str}"))
        if not undo_stats:
            undo_body = Text("  No undo stats data.", style="dim")
        self.query_one("#io-undo", Static).update(
            Panel(undo_body, title="[bold white]Undo Stats (v$undostat)[/]",
                  border_style="#1b233a", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 16. MEMORY ADVISOR
# ---------------------------------------------------------------------------

class MemoryAdvisorPanel(BasePanel):
    """SGA/PGA advisory, buffer pool, resize ops, latches, mutex."""
    REFRESH_RATE = 10

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    def compose(self) -> ComposeResult:
        yield Static(id="mem-header")
        yield Static(id="mem-sga-advice")
        yield Static(id="mem-pga-advice")
        yield Static(id="mem-buffer-pool")
        yield Static(id="mem-resize-ops")
        yield Static(id="mem-latches")
        yield Static(id="mem-mutex")

    async def refresh_data(self) -> None:
        sga_advice   = self.cache.get("mem.sga_advice",    []) or []
        pga_advice   = self.cache.get("mem.pga_advice",    []) or []
        pga_stats    = self.cache.get("mem.pga_stats",     []) or []
        buffer_pool  = self.cache.get("mem.buffer_pool",   []) or []
        db_cache_adv = self.cache.get("mem.db_cache_advice",[]) or []
        resize_ops   = self.cache.get("mem.resize_ops",    []) or []
        latches      = self.cache.get("mem.latches",       []) or []
        mutex_sleep  = self.cache.get("mem.mutex_sleep",   []) or []

        # Build pga_stats dict
        pga_map = {r.get("name", ""): r.get("value", 0) for r in pga_stats}
        sga_mb  = self.cache.get("health.sga_mb", 0) or 0
        pga_mb  = self.cache.get("health.pga_mb", 0) or 0

        buf_hit = max((float(b.get("hit_pct", 0) or 0) for b in buffer_pool), default=0)
        pga_hit = float(pga_map.get("cache hit percentage", 0) or 0)

        h = Table.grid(padding=(0, 3), expand=True)
        h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]SGA Size:[/] [bold]{sga_mb:,.0f} MB[/]",
            f"[dim]PGA Target:[/] [bold]{pga_mb:,.0f} MB[/]",
            f"[dim]Buffer Cache Hit%:[/] [{color_for_pct(buf_hit)}]{buf_hit:.2f}%[/]",
            f"[dim]PGA Cache Hit%:[/] [{color_for_pct(pga_hit)}]{pga_hit:.2f}%[/]",
        )
        self.query_one("#mem-header", Static).update(
            Panel(h, title="[bold magenta]Memory Advisor[/]", border_style="magenta", padding=(0, 1))
        )

        # ── SGA target advice ──────────────────────────────────────────
        sg_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        sg_t.add_column("SGA MB",    width=10, justify="right")
        sg_t.add_column("Factor",    width=8,  justify="right")
        sg_t.add_column("DB Time",   width=12, justify="right")
        sg_t.add_column("Time Factor", width=13, justify="right")
        sg_t.add_column("Est Phys Reads", width=15, justify="right")
        for r in sga_advice:
            factor = float(r.get("sga_size_factor", 1) or 1)
            is_current = abs(factor - 1.0) < 0.05
            row_style = "bold green" if is_current else ""
            sg_t.add_row(
                Text(fmt(r.get("sga_size"), 0), style=row_style, justify="right"),
                Text(f"{factor:.2f}", style=row_style, justify="right"),
                Text(fmt(r.get("estd_db_time"), 1), style=row_style, justify="right"),
                Text(fmt(r.get("estd_db_time_factor"), 4), style=row_style, justify="right"),
                Text(f"{int(r.get('estd_physical_reads', 0) or 0):,}", style=row_style, justify="right"),
            )
        if not sga_advice:
            sg_t.add_row("[dim]No SGA advice (check AMM/ASMM config)[/]", "", "", "", "")
        self.query_one("#mem-sga-advice", Static).update(
            Panel(sg_t, title="[bold white]SGA Target Advice[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── PGA target advice ──────────────────────────────────────────
        pg_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        pg_t.add_column("PGA MB",      width=10, justify="right")
        pg_t.add_column("Factor",      width=8,  justify="right")
        pg_t.add_column("Est Hit%",    width=10, justify="right")
        pg_t.add_column("Overalloc",   width=10, justify="right")
        for r in pga_advice:
            factor  = float(r.get("pga_target_factor", 1) or 1)
            hit_pct = float(r.get("estd_hit_pct", 0) or 0)
            is_current = abs(factor - 1.0) < 0.05
            row_style = "bold green" if is_current else ""
            hc = color_for_pct(hit_pct)
            pg_t.add_row(
                Text(fmt(r.get("pga_target_mb"), 0), style=row_style, justify="right"),
                Text(f"{factor:.2f}", style=row_style, justify="right"),
                Text.from_markup(f"[{hc}]{hit_pct:.2f}%[/]"),
                Text(str(int(r.get("estd_overalloc_count", 0) or 0)), justify="right"),
            )
        if not pga_advice:
            pg_t.add_row("[dim]No PGA advice data[/]", "", "", "")
        self.query_one("#mem-pga-advice", Static).update(
            Panel(pg_t, title="[bold white]PGA Target Advice[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── Buffer pool stats ──────────────────────────────────────────
        bp_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        bp_t.add_column("Pool",       width=10)
        bp_t.add_column("Hit%",       width=10, justify="right")
        bp_t.add_column("Logical Reads", width=16, justify="right")
        bp_t.add_column("Phys R MB",  width=12, justify="right")
        bp_t.add_column("Phys W MB",  width=12, justify="right")
        bp_t.add_column("Free Buf Wait", width=14, justify="right")
        for r in buffer_pool:
            hit = float(r.get("hit_pct", 0) or 0)
            hc  = color_for_pct(hit)
            bp_t.add_row(
                str(r.get("name", "")),
                f"[{hc}]{hit:.2f}%[/]",
                f"{int(r.get('logical_reads', 0) or 0):,}",
                fmt(r.get("phys_read_mb"), 1),
                fmt(r.get("phys_write_mb"), 1),
                str(int(r.get("free_buffer_wait", 0) or 0)),
            )
        if not buffer_pool:
            bp_t.add_row("[dim]No buffer pool data[/]", "", "", "", "", "")
        self.query_one("#mem-buffer-pool", Static).update(
            Panel(bp_t, title="[bold white]Buffer Pool Statistics[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── Recent resize ops ──────────────────────────────────────────
        ro_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        ro_t.add_column("Component", width=22)
        ro_t.add_column("Type",      width=10)
        ro_t.add_column("Mode",      width=8)
        ro_t.add_column("Initial MB", width=11, justify="right")
        ro_t.add_column("Target MB",  width=10, justify="right")
        ro_t.add_column("Final MB",   width=10, justify="right")
        ro_t.add_column("Status",    width=10)
        ro_t.add_column("Duration(s)", width=11, justify="right")
        for r in resize_ops[:10]:
            status = str(r.get("status", ""))
            sc     = "green" if status == "COMPLETE" else ("red" if "ERROR" in status else "yellow")
            ro_t.add_row(
                str(r.get("component", "")),
                str(r.get("oper_type", "")),
                str(r.get("oper_mode", "")),
                fmt(r.get("initial_mb"), 1),
                fmt(r.get("target_mb"),  1),
                fmt(r.get("final_mb"),   1),
                f"[{sc}]{status}[/]",
                fmt(r.get("duration_sec"), 1),
            )
        if not resize_ops:
            ro_t.add_row("[dim]No recent resize operations[/]", "", "", "", "", "", "", "")
        self.query_one("#mem-resize-ops", Static).update(
            Panel(ro_t, title="[bold white]Recent SGA/PGA Resize Operations[/]",
                  border_style="#1b233a", padding=(0, 1))
        )

        # ── Latches ────────────────────────────────────────────────────
        lt_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        lt_t.add_column("Latch Name", ratio=2)
        lt_t.add_column("Gets",       width=12, justify="right")
        lt_t.add_column("Misses",     width=10, justify="right")
        lt_t.add_column("Miss%",      width=9,  justify="right")
        lt_t.add_column("Sleeps",     width=10, justify="right")
        lt_t.add_column("Wait ms",    width=10, justify="right")
        for r in latches[:10]:
            miss_pct = float(r.get("miss_pct", 0) or 0)
            mc  = "red" if miss_pct > 0.1 else ("yellow" if miss_pct > 0.01 else "dim")
            lt_t.add_row(
                str(r.get("name", "")),
                f"{int(r.get('gets', 0) or 0):,}",
                f"{int(r.get('misses', 0) or 0):,}",
                f"[{mc}]{miss_pct:.4f}%[/]",
                f"{int(r.get('sleeps', 0) or 0):,}",
                fmt(r.get("wait_ms"), 2),
            )
        if not latches:
            lt_t.add_row("[dim]No latch data[/]", "", "", "", "", "")
        self.query_one("#mem-latches", Static).update(
            Panel(lt_t, title="[bold white]Top Latches by Sleeps[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── Mutex sleep ────────────────────────────────────────────────
        mu_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        mu_t.add_column("Mutex Type", width=20)
        mu_t.add_column("Location",   ratio=2)
        mu_t.add_column("Sleeps",     width=10, justify="right")
        mu_t.add_column("Wait ms",    width=10, justify="right")
        for r in mutex_sleep[:10]:
            mu_t.add_row(
                str(r.get("mutex_type", "")),
                str(r.get("location", "")),
                f"{int(r.get('sleeps', 0) or 0):,}",
                fmt(r.get("wait_ms"), 2),
            )
        if not mutex_sleep:
            mu_t.add_row("[dim]No mutex sleep data[/]", "", "", "")
        self.query_one("#mem-mutex", Static).update(
            Panel(mu_t, title="[bold white]Mutex Sleep (top 10)[/]", border_style="#1b233a", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 17. SEGMENTS
# ---------------------------------------------------------------------------

class SegmentsPanel(BasePanel):
    """Top segments, stale stats, scheduler jobs, plan baselines."""
    REFRESH_RATE = 10

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    # current statistic filter (0=logical reads, 1=physical reads, etc.)
    _filter_idx: int = 0
    _STAT_FILTERS = [
        "logical reads", "physical reads", "row lock waits",
        "buffer busy waits", "ITL waits",
    ]

    def compose(self) -> ComposeResult:
        yield Static(id="seg-header")
        yield DataTable(id="seg-segments")
        yield Static(id="seg-stale")
        yield Static(id="seg-jobs")
        yield Static(id="seg-failed-history")

    BINDINGS = [
        Binding("1", "filter_stat('logical reads')",    "Logical Reads",    show=True),
        Binding("2", "filter_stat('physical reads')",   "Physical Reads",   show=True),
        Binding("3", "filter_stat('row lock waits')",   "Row Locks",        show=True),
        Binding("4", "filter_stat('buffer busy waits')", "Buf Busy",        show=True),
        Binding("5", "filter_stat('ITL waits')",        "ITL Waits",        show=True),
    ]

    def action_filter_stat(self, stat: str) -> None:
        self._filter_idx = self._STAT_FILTERS.index(stat) if stat in self._STAT_FILTERS else 0

    async def refresh_data(self) -> None:
        top_segments = self.cache.get("obj.top_segments",   []) or []
        stale_stats  = self.cache.get("obj.stale_stats",    []) or []
        jobs         = self.cache.get("obj.scheduler_jobs", []) or []
        history      = self.cache.get("obj.scheduler_history", []) or []

        stale_count    = len(stale_stats)
        fail_count     = sum(1 for j in jobs if int(j.get("failure_count", 0) or 0) > 0)
        px_count       = len(self.cache.get("obj.px_sessions", []) or [])
        current_filter = self._STAT_FILTERS[self._filter_idx % len(self._STAT_FILTERS)]

        h = Table.grid(padding=(0, 3), expand=True)
        h.add_column(ratio=1); h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Stale Stats:[/] [{'red' if stale_count > 0 else 'green'}]{stale_count}[/]",
            f"[dim]Sched Failures:[/] [{'red' if fail_count > 0 else 'green'}]{fail_count}[/]",
            f"[dim]PX Sessions:[/] [cyan]{px_count}[/]",
        )
        h.add_row(
            Text.from_markup(f"[dim]Filter: [bold cyan]{current_filter}[/] (keys 1-5)[/]"),
            "", "",
        )
        self.query_one("#seg-header", Static).update(
            Panel(h, title="[bold cyan]Segments & Objects[/]", border_style="cyan", padding=(0, 1))
        )

        # ── Top segments DataTable ─────────────────────────────────────
        filtered = [r for r in top_segments
                    if str(r.get("statistic_name", "")).lower() == current_filter.lower()]
        dt: DataTable = self.query_one("#seg-segments")
        if not dt.columns:
            dt.add_columns("Owner", "Object Name", "Type", "Tablespace", "Statistic", "Value")
        dt.border_title = (
            f"Top Segments — {current_filter}  [{len(filtered)} rows]  Keys 1-5 to filter"
        )
        cursor = dt.cursor_row
        dt.clear()
        for r in filtered[:30]:
            val = int(r.get("value", 0) or 0)
            dt.add_row(
                str(r.get("owner", "")),
                str(r.get("object_name", "")),
                str(r.get("object_type", "")),
                str(r.get("tablespace_name", "")),
                str(r.get("statistic_name", "")),
                f"{val:,}",
            )
        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))

        # ── Stale stats table ──────────────────────────────────────────
        ss_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        ss_t.add_column("Owner",   width=16)
        ss_t.add_column("Table",   ratio=2)
        ss_t.add_column("Rows",    width=12, justify="right")
        ss_t.add_column("Last Analyzed", width=20)
        ss_t.add_column("Days Old", width=10, justify="right")
        ss_t.add_column("DML Since", width=12, justify="right")
        ss_t.add_column("Stale",   width=8)
        for r in stale_stats[:15]:
            days = float(r.get("days_since_analyze", 0) or 0)
            dc   = "red" if days > 7 else ("yellow" if days > 3 else "dim")
            dml  = int(r.get("dml_since_analyze", 0) or 0)
            ss_t.add_row(
                str(r.get("owner", "")),
                str(r.get("table_name", "")),
                f"{int(r.get('num_rows', 0) or 0):,}",
                str(r.get("last_analyzed", "") or "never"),
                f"[{dc}]{days:.1f}[/]",
                f"{dml:,}",
                str(r.get("stale_stats", "") or ""),
            )
        if not stale_stats:
            ss_t.add_row("[dim]No stale statistics detected[/]", "", "", "", "", "", "")
        self.query_one("#seg-stale", Static).update(
            Panel(ss_t, title="[bold yellow]Stale / Missing Object Statistics[/]",
                  border_style="yellow", padding=(0, 1))
        )

        # ── Scheduler jobs ─────────────────────────────────────────────
        jb_t = Table(show_header=True, header_style="bold #bbc8e8",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        jb_t.add_column("Job Name",    ratio=2)
        jb_t.add_column("Owner",       width=12)
        jb_t.add_column("State",       width=10)
        jb_t.add_column("Next Run",    width=22)
        jb_t.add_column("Run Count",   width=10, justify="right")
        jb_t.add_column("Failures",    width=10, justify="right")
        jb_t.add_column("Last Duration", width=14)
        for r in jobs[:20]:
            state = str(r.get("state", ""))
            if state == "RUNNING":
                sc = "bold green"
            elif state == "FAILED" or int(r.get("failure_count", 0) or 0) > 0:
                sc = "red"
            else:
                sc = "dim"
            fails = int(r.get("failure_count", 0) or 0)
            jb_t.add_row(
                str(r.get("job_name", "")),
                str(r.get("owner", "")),
                f"[{sc}]{state}[/]",
                str(r.get("next_run_date", "") or "—")[:22],
                str(int(r.get("run_count", 0) or 0)),
                f"[{'red' if fails else 'dim'}]{fails}[/]",
                str(r.get("last_run_duration", "") or "—"),
            )
        if not jobs:
            jb_t.add_row("[dim]No scheduler jobs found[/]", "", "", "", "", "", "")
        self.query_one("#seg-jobs", Static).update(
            Panel(jb_t, title="[bold white]Scheduler Jobs[/]", border_style="#1b233a", padding=(0, 1))
        )

        # ── Failed job history ─────────────────────────────────────────
        failed_hist = [r for r in history if str(r.get("status", "")).upper() == "FAILED"][:10]
        fh_t = Table(show_header=True, header_style="bold red",
                     box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        fh_t.add_column("Job Name",    ratio=2)
        fh_t.add_column("Owner",       width=12)
        fh_t.add_column("Error#",      width=9, justify="right")
        fh_t.add_column("Start",       width=24)
        fh_t.add_column("Duration",    width=14)
        fh_t.add_column("Info",        ratio=2)
        for r in failed_hist:
            fh_t.add_row(
                str(r.get("job_name", "")),
                str(r.get("owner", "")),
                f"[red]{r.get('error#', '')}[/]",
                str(r.get("actual_start_date", ""))[:24],
                str(r.get("run_duration", "") or "—"),
                str(r.get("additional_info", "") or "")[:60],
            )
        if not failed_hist:
            fh_t.add_row("[dim]No failed job runs in history[/]", "", "", "", "", "")
        self.query_one("#seg-failed-history", Static).update(
            Panel(fh_t, title="[bold red]Failed Job Run History (last 10)[/]",
                  border_style="red", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 18. SQL MONITOR
# ---------------------------------------------------------------------------

class SQLMonitorPanel(BasePanel):
    """Real-Time SQL Monitor — GV$SQL_MONITOR."""
    REFRESH_RATE = 3

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    _rows: list[dict] = []

    BINDINGS = [
        Binding("enter", "show_sql_text", "Full SQL", show=True),
    ]

    def compose(self) -> ComposeResult:
        yield Static(id="sqlmon-header")
        yield DataTable(id="sqlmon-table")
        yield Static(id="sqlmon-sql-preview")

    def on_data_table_row_highlighted(self, event: DataTable.RowHighlighted) -> None:
        rows = self._rows
        idx  = event.cursor_row
        if not rows or idx < 0 or idx >= len(rows):
            return
        r       = rows[idx]
        sql_txt = str(r.get("sql_text", "") or "")
        sql_id  = str(r.get("sql_id", "") or "")
        prev = Text()
        prev.append(f"  SQL ID: ", style="dim")
        prev.append(f"{sql_id}\n  ", style="bold cyan")
        prev.append(sql_txt[:400], style="dim")
        self.query_one("#sqlmon-sql-preview", Static).update(
            Panel(prev, title="[bold #bbc8e8]SQL Text Preview[/]",
                  border_style="#384c7a", padding=(0, 1))
        )

    async def refresh_data(self) -> None:
        active = self.cache.get("sqlmon.active", []) or []
        recent = self.cache.get("sqlmon.recent", []) or []
        all_rows = active + recent
        self._rows = all_rows

        exec_count = len(active)
        total_count = len(all_rows)

        h = Table.grid(padding=(0, 3), expand=True)
        h.add_column(ratio=1); h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Total monitored:[/] [bold]{total_count}[/]",
            f"[dim]Executing:[/] [bold green]{exec_count}[/]",
            Text.from_markup("[dim]Enter=Full SQL text[/]"),
        )
        self.query_one("#sqlmon-header", Static).update(
            Panel(h, title="[bold white]Real-Time SQL Monitor (GV$SQL_MONITOR)[/]",
                  border_style="blue", padding=(0, 1))
        )

        dt: DataTable = self.query_one("#sqlmon-table")
        if not dt.columns:
            dt.add_columns(
                "Inst", "SID", "SQL ID", "Status",
                "User", "Elapsed(s)", "CPU(s)", "Buf Gets",
                "Disk Reads", "PX Req", "PX Alloc", "SQL Text",
            )
        cursor = dt.cursor_row
        dt.clear()
        for r in all_rows:
            status  = str(r.get("status", ""))
            if status == "EXECUTING":
                sc = "bold green"
            elif "ERROR" in status:
                sc = "red"
            else:
                sc = "dim"
            elapsed = float(r.get("elapsed_sec", 0) or 0)
            cpu     = float(r.get("cpu_sec", 0) or 0)
            dt.add_row(
                str(r.get("inst_id", "") or ""),
                str(r.get("sid", "") or ""),
                str(r.get("sql_id", "") or ""),
                Text.from_markup(f"[{sc}]{status}[/]"),
                str(r.get("username", "") or ""),
                f"{elapsed:,.1f}",
                f"{cpu:,.1f}",
                f"{int(r.get('buffer_gets', 0) or 0):,}",
                f"{int(r.get('disk_reads', 0) or 0):,}",
                str(r.get("px_servers_requested", "") or ""),
                str(r.get("px_servers_allocated", "") or ""),
                str(r.get("sql_text", "") or "")[:50],
                key=str(r.get("key", "") or r.get("sql_id", "")),
            )
        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))

    def action_show_sql_text(self) -> None:
        rows = self._rows
        dt: DataTable = self.query_one("#sqlmon-table")
        idx = dt.cursor_row
        if not rows or idx < 0 or idx >= len(rows):
            return
        from widgets.text_view_screen import TextViewScreen
        r   = rows[idx]
        sql = str(r.get("sql_text", "") or "(no SQL text)")
        self.app.push_screen(TextViewScreen(
            title=f"SQL Monitor — {r.get('sql_id', '')}",
            content=sql,
        ))


# ---------------------------------------------------------------------------
# 19. ALERT LOG
# ---------------------------------------------------------------------------

class AlertLogPanel(BasePanel):
    """Alert log entries and incident summary."""
    REFRESH_RATE = 10

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    def compose(self) -> ComposeResult:
        yield Static(id="alert-header")
        yield DataTable(id="alert-table")
        yield Static(id="alert-incidents")

    async def refresh_data(self) -> None:
        recent    = self.cache.get("alertlog.recent",    []) or []
        incidents = self.cache.get("alertlog.incidents", []) or []

        last_ora_time = "—"
        if recent:
            last_ora_time = str(recent[0].get("originating_timestamp", ""))[:19]

        h = Table.grid(padding=(0, 3), expand=True)
        h.add_column(ratio=1); h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Incidents:[/] [{'red' if incidents else 'green'}]{len(incidents)}[/]",
            f"[dim]Alert entries:[/] [bold]{len(recent)}[/]",
            f"[dim]Last ORA-:[/] [yellow]{last_ora_time}[/]",
        )
        self.query_one("#alert-header", Static).update(
            Panel(h, title="[bold red]Alert Log Monitor[/]", border_style="red", padding=(0, 1))
        )

        dt: DataTable = self.query_one("#alert-table")
        if not dt.columns:
            dt.add_columns("Timestamp", "Level", "Component", "Host", "Instance", "Message")
        cursor = dt.cursor_row
        dt.clear()
        for r in recent[:100]:
            lvl   = int(r.get("message_level", 3) or 3)
            if lvl <= 1:
                lc = "bold red"
                lbl = "CRITICAL"
            elif lvl == 2:
                lc = "yellow"
                lbl = "ERROR"
            else:
                lc = "dim"
                lbl = "WARNING"
            msg = str(r.get("message_text", "") or "")
            dt.add_row(
                str(r.get("originating_timestamp", ""))[:19],
                Text.from_markup(f"[{lc}]{lbl}[/]"),
                str(r.get("component_id", "") or ""),
                str(r.get("host_id", "") or ""),
                str(r.get("instance_id", "") or ""),
                msg[:80],
            )
        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))

        # ── Incidents/problems summary ─────────────────────────────────
        inc_t = Table(show_header=True, header_style="bold red",
                      box=rich_box.SIMPLE_HEAD, padding=(0, 1), expand=True)
        inc_t.add_column("Problem Key",  ratio=2)
        inc_t.add_column("Incident ID",  width=12, justify="right")
        inc_t.add_column("Count",        width=8,  justify="right")
        inc_t.add_column("Last Time",    width=22)
        for r in incidents:
            cnt = int(r.get("incident_count", 0) or 0)
            inc_t.add_row(
                str(r.get("problem_key", "")),
                str(r.get("last_incident_id", "")),
                f"[red]{cnt}[/]",
                str(r.get("last_time", ""))[:22],
            )
        if not incidents:
            inc_t.add_row("[dim green]No open incidents[/]", "", "", "")
        self.query_one("#alert-incidents", Static).update(
            Panel(inc_t, title="[bold red]Incidents / Problems Summary[/]",
                  border_style="red", padding=(0, 1))
        )


# ---------------------------------------------------------------------------
# 20. WAIT CHAINS
# ---------------------------------------------------------------------------

class WaitChainPanel(BasePanel):
    """Visual wait chain tree from V$WAIT_CHAINS."""
    REFRESH_RATE = 5

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    def compose(self) -> ComposeResult:
        yield Static(id="chain-header")
        yield Static(id="chain-tree")

    async def refresh_data(self) -> None:
        chains_raw = self.cache.get("obj.wait_chains", []) or []

        # Group by chain_id
        by_chain: dict[int, list[dict]] = {}
        for r in chains_raw:
            cid = int(r.get("chain_id", 0) or 0)
            by_chain.setdefault(cid, []).append(r)

        has_cycle = any(str(r.get("chain_is_cycle", "N")).upper() == "Y"
                        for r in chains_raw)
        cycle_str = "[bold red]YES — deadlock cycle detected![/]" if has_cycle else "[green]No[/]"

        h = Table.grid(padding=(0, 3), expand=True)
        h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Chains:[/] [bold]{len(by_chain)}[/]",
            f"[dim]Cycles (deadlocks):[/] {cycle_str}",
        )
        self.query_one("#chain-header", Static).update(
            Panel(h, title="[bold yellow]Wait Chains (V$WAIT_CHAINS)[/]",
                  border_style="yellow", padding=(0, 1))
        )

        if not by_chain:
            self.query_one("#chain-tree", Static).update(
                Panel(Text("  No wait chains detected.", style="dim green"),
                      border_style="dim")
            )
            return

        chain_panels: list[RenderableType] = []
        for cid, rows in sorted(by_chain.items()):
            is_cycle = any(str(r.get("chain_is_cycle", "N")).upper() == "Y"
                           for r in rows)
            # Sort by wait_id
            rows_sorted = sorted(rows, key=lambda r: int(r.get("wait_id", 0) or 0))
            # Build tree
            tree = Tree(
                f"[bold yellow]Chain #{cid}[/]"
                + (" [bold red][CYCLE][/]" if is_cycle else ""),
                guide_style="dim",
            )
            node_by_wait: dict = {None: tree}
            for r in rows_sorted:
                wait_id    = r.get("wait_id")
                blocker_id = r.get("blocker_wait_id")
                sid        = r.get("sid", "?")
                os_pid     = r.get("osid", r.get("pid", "?"))
                wait_secs  = int(r.get("in_wait_secs", 0) or 0)
                wait_evt   = str(r.get("wait_event_text", "unknown") or "unknown")
                sc = "red" if wait_secs > 10 else ("yellow" if wait_secs > 2 else "white")
                label = (
                    f"[cyan]SID {sid}[/]  [dim]PID {os_pid}[/]"
                    f"  [{sc}]{wait_secs}s[/]  [dim]{wait_evt[:50]}[/]"
                )
                parent_node = node_by_wait.get(blocker_id, tree)
                node = parent_node.add(label)
                node_by_wait[wait_id] = node

            chain_panels.append(
                Panel(tree,
                      title=f"[bold {'red' if is_cycle else 'yellow'}]Chain {cid}[/]",
                      border_style="red" if is_cycle else "yellow",
                      padding=(0, 1))
            )

        self.query_one("#chain-tree", Static).update(Group(*chain_panels))


# ---------------------------------------------------------------------------
# 21. PLAN BASELINES
# ---------------------------------------------------------------------------

class PlanBaselinesPanel(BasePanel):
    """SQL Plan Management — DBA_SQL_PLAN_BASELINES."""
    REFRESH_RATE = 30

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    def compose(self) -> ComposeResult:
        yield Static(id="spm-header")
        yield DataTable(id="spm-table")

    async def refresh_data(self) -> None:
        baselines = self.cache.get("obj.plan_baselines", []) or []

        total_count    = len(baselines)
        fixed_count    = sum(1 for b in baselines if str(b.get("fixed", "NO")).upper() == "YES")
        no_repro_count = sum(1 for b in baselines if str(b.get("reproduced", "YES")).upper() == "NO")

        h = Table.grid(padding=(0, 3), expand=True)
        h.add_column(ratio=1); h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Total Baselines:[/] [bold]{total_count}[/]",
            f"[dim]Fixed:[/] [{'red' if fixed_count else 'green'}]{fixed_count}[/]",
            f"[dim]Not Reproduced:[/] [{'red' if no_repro_count else 'green'}]{no_repro_count}[/]",
        )
        self.query_one("#spm-header", Static).update(
            Panel(h, title="[bold white]SQL Plan Management (DBA_SQL_PLAN_BASELINES)[/]",
                  border_style="blue", padding=(0, 1))
        )

        dt: DataTable = self.query_one("#spm-table")
        if not dt.columns:
            dt.add_columns(
                "SQL Handle", "Plan Name", "Schema",
                "Accepted", "Fixed", "Enabled", "Reproduced",
                "Executions", "Elapsed(s)", "Last Executed",
            )
        cursor = dt.cursor_row
        dt.clear()
        for r in baselines:
            accepted   = str(r.get("accepted",   "NO")).upper() == "YES"
            fixed      = str(r.get("fixed",      "NO")).upper() == "YES"
            enabled    = str(r.get("enabled",    "NO")).upper() == "YES"
            reproduced = str(r.get("reproduced", "YES")).upper() == "YES"
            dt.add_row(
                str(r.get("sql_handle", ""))[:20],
                str(r.get("plan_name",  ""))[:22],
                str(r.get("parsing_schema_name", "") or ""),
                Text.from_markup("[green]Y[/]" if accepted   else "[dim]N[/]"),
                Text.from_markup("[red]Y[/]"   if fixed      else "[dim]N[/]"),
                Text.from_markup("[green]Y[/]" if enabled    else "[dim]N[/]"),
                Text.from_markup("[dim]Y[/]"   if reproduced else "[red]N[/]"),
                f"{int(r.get('executions', 0) or 0):,}",
                fmt(r.get("elapsed_sec"), 1),
                str(r.get("last_executed", "") or "—")[:22],
            )
        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))


# ---------------------------------------------------------------------------
# 22. PARALLEL QUERY
# ---------------------------------------------------------------------------

class ParallelQueryPanel(BasePanel):
    """Parallel query sessions from GV$PX_SESSION."""
    REFRESH_RATE = 5

    DEFAULT_CSS = BasePanel.DEFAULT_CSS

    def compose(self) -> ComposeResult:
        yield Static(id="px-header")
        yield DataTable(id="px-table")

    async def refresh_data(self) -> None:
        px_sessions = self.cache.get("obj.px_sessions", []) or []

        total_px   = len(px_sessions)
        active_qcs = len({r.get("sql_id") for r in px_sessions
                          if int(r.get("requested_dop", 0) or 0) > 0})
        total_slaves = sum(1 for r in px_sessions
                           if int(r.get("actual_dop", 0) or 0) > 0)

        h = Table.grid(padding=(0, 3), expand=True)
        h.add_column(ratio=1); h.add_column(ratio=1); h.add_column(ratio=1)
        h.add_row(
            f"[dim]Total PX Sessions:[/] [bold]{total_px}[/]",
            f"[dim]Active Coordinators:[/] [bold cyan]{active_qcs}[/]",
            f"[dim]Total Slaves:[/] [bold]{total_slaves}[/]",
        )
        self.query_one("#px-header", Static).update(
            Panel(h, title="[bold cyan]Parallel Query Monitor (GV$PX_SESSION)[/]",
                  border_style="cyan", padding=(0, 1))
        )

        dt: DataTable = self.query_one("#px-table")
        if not dt.columns:
            dt.add_columns(
                "Inst", "SID", "Serial#", "Username", "Status",
                "Req DOP", "Act DOP", "Slave Sets",
                "PX Req", "PX Alloc", "SQL ID", "Event", "Wait(s)",
            )
        cursor = dt.cursor_row
        dt.clear()
        for r in px_sessions:
            req_dop = int(r.get("requested_dop", 0) or 0)
            act_dop = int(r.get("actual_dop",    0) or 0)
            # DOP degraded = actual < requested
            dop_color = "red" if (req_dop > 0 and act_dop < req_dop) else "green"
            dt.add_row(
                str(r.get("inst_id", "") or ""),
                str(r.get("sid", "") or ""),
                str(r.get("serial#", r.get("serial", "")) or ""),
                str(r.get("username", "") or ""),
                str(r.get("status", "") or ""),
                str(req_dop),
                Text.from_markup(f"[{dop_color}]{act_dop}[/]"),
                str(r.get("slave_sets", "") or ""),
                str(r.get("px_servers_requested", "") or ""),
                str(r.get("px_servers_allocated", "") or ""),
                str(r.get("sql_id", "") or ""),
                str(r.get("event", "") or "")[:30],
                str(r.get("seconds_in_wait", "") or ""),
            )
        if not px_sessions:
            self.query_one("#px-table", DataTable).add_row(
                "", "", "", "[dim]No parallel query sessions[/]", "", "", "", "", "", "", "", "", ""
            )
        if dt.row_count and cursor > 0:
            dt.move_cursor(row=min(cursor, dt.row_count - 1))

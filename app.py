"""
ORA BRABO Monitoring Tool
=========================
Oracle Database TUI Monitor — inspired by Dolphie, powered by Textual.
Author : DBA BRABO | Acacio Lima Rocha
Version: 1.3.3 — Advisor findings render fix + thin-mode timestamp/CLOB fixes (scheduler, alertlog)
"""

from __future__ import annotations

import asyncio
import logging
import sys
from pathlib import Path

from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Vertical
from textual.widgets import ContentSwitcher, Footer, Header, Tab, Tabs

from core.config import AppConfig
from core.connection_session import ConnectionSession
from core.version import __version__, BANNER_ART
from widgets.connection_pane import ConnectionPane
from widgets.add_connection_modal import AddConnectionModal

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[logging.FileHandler("/tmp/ora_brabo.log")],
)
log = logging.getLogger("ora_brabo")


class OraBraboApp(App):
    """
    Main TUI application.

    Each open Oracle connection lives in its own tab (ConnectionPane).
    F1–F12 navigate panels within the active tab.
    Ctrl+N opens a new connection; Ctrl+W closes the current one.
    """

    CSS_PATH = Path(__file__).parent / "ora_brabo.tcss"

    BINDINGS = [
        # ── Panel navigation (forwarded to the active ConnectionPane) ──
        Binding("f1",  "show_panel('dashboard')",  "Dashboard",  show=True),
        Binding("f2",  "show_panel('sessions')",   "Sessions",   show=True),
        Binding("f3",  "show_panel('topsql')",     "Top SQL",    show=True),
        Binding("f4",  "show_panel('waits')",      "Waits",      show=True),
        Binding("f5",  "show_panel('locks')",      "Locks",      show=True),
        Binding("f6",  "show_panel('rac')",        "RAC",        show=True),
        Binding("f7",  "show_panel('dataguard')",  "Data Guard", show=True),
        Binding("f8",  "show_panel('asm')",        "ASM",        show=True),
        Binding("f9",  "show_panel('rman')",       "RMAN",       show=True),
        Binding("f10", "show_panel('awr')",        "AWR",        show=True),
        Binding("f11", "show_panel('ash')",        "ASH",        show=True),
        Binding("f12", "show_panel('advisor')",    "Advisor",    show=True),
        Binding("x",      "show_panel('exadata')",      "Exadata",      show=False),
        Binding("p",      "show_panel('pdb')",         "PDB",          show=False),
        # ── Extended panels (Ctrl+1 – Ctrl+8) ──────────────────────────
        Binding("ctrl+1", "show_panel('io')",           "I/O",          show=True),
        Binding("ctrl+2", "show_panel('memory')",       "Memory",       show=True),
        Binding("ctrl+3", "show_panel('segments')",     "Segments",     show=True),
        Binding("ctrl+4", "show_panel('sqlmonitor')",   "SQL Monitor",  show=True),
        Binding("ctrl+5", "show_panel('alertlog')",     "Alert Log",    show=True),
        Binding("ctrl+6", "show_panel('waitchains')",   "Wait Chains",  show=True),
        Binding("ctrl+7", "show_panel('planbaselines')", "Plan Baselines", show=True),
        Binding("ctrl+8", "show_panel('parallelquery')", "Parallel Query", show=True),
        Binding("ctrl+9", "show_panel('report')",        "Report",         show=True),
        Binding("ctrl+0", "show_panel('planhist')",      "Plan Hist",      show=True),
        Binding("h",      "show_panel('planhist')",      "Plan Hist",      show=False),
        Binding("j",      "show_panel('jobs')",          "Jobs",           show=True),
        # ── Tab / connection management ─────────────────────────────────
        # "+" opens the connection screen (new tab). Many terminals/RDM
        # swallow Ctrl+N/Ctrl+O, but a plain "+" is always delivered.
        Binding("plus",   "new_connection", "New Conn.", show=True),
        Binding("ctrl+n", "new_connection", "New Conn.", show=False),
        Binding("ctrl+o", "new_connection", "New Conn.", show=False),
        Binding("ctrl+w", "close_tab",      "Close Tab", show=True),
        # ── In-panel actions ───────────────────────────────────────────
        Binding("k", "kill_session",  "Kill",       show=False),
        Binding("t", "trace_session", "Trace",      show=False),
        Binding("e", "explain_plan",  "Explain",    show=False),
        Binding("r", "generate_awr",  "AWR Report", show=False),
        Binding("g", "generate_report", "PDF Report", show=True),
        # ── App ────────────────────────────────────────────────────────
        Binding("?", "help",  "Help", show=False),
        Binding("q", "quit",  "Quit", show=True),
    ]

    TITLE     = f"ORA BRABO Monitoring Tool v{__version__}"
    SUB_TITLE = "Oracle Database TUI Monitor | DBA BRABO"

    def __init__(
        self,
        initial_configs: list[AppConfig] | None = None,
        initial_config: AppConfig | None = None,
    ) -> None:
        super().__init__()
        # Accept a single config (back-compat) or a list (multi-tab startup).
        if initial_config is not None and not initial_configs:
            initial_configs = [initial_config]
        self._initial_configs: list[AppConfig] = initial_configs or []
        self._sessions: dict[str, ConnectionSession] = {}   # session.id → session
        self._active_id: str | None = None
        # Thin vs Thick is process-wide and irreversible; the first successful
        # connection locks it and no conflicting mode can be opened afterwards.
        self._active_mode: str | None = None

    # ──────────────────────────────────────────────────────────────────
    # Layout
    # ──────────────────────────────────────────────────────────────────

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        with Vertical(id="main-vertical"):
            yield Tabs(id="connection-tabs")
            yield ContentSwitcher(id="pane-switcher")
        yield Footer()

    # ──────────────────────────────────────────────────────────────────
    # Lifecycle
    # ──────────────────────────────────────────────────────────────────

    async def on_mount(self) -> None:
        log.info("ORA BRABO v%s starting (multi-tab, thick mode, cache priming).", __version__)
        self.set_interval(0.5, self._tick_refresh)

        if self._initial_configs:
            for cfg in self._initial_configs:
                await self._add_connection_tab(cfg)
        else:
            # No CLI args → open modal after first render
            self.call_after_refresh(self.action_new_connection)

    async def on_unmount(self) -> None:
        for session in list(self._sessions.values()):
            await session.close()
        log.info("ORA BRABO shut down cleanly.")

    # ──────────────────────────────────────────────────────────────────
    # Tab events
    # ──────────────────────────────────────────────────────────────────

    def on_tabs_tab_activated(self, event: Tabs.TabActivated) -> None:
        if event.tab is None:
            return
        session_id = event.tab.id.removeprefix("tab-")
        self._active_id = session_id
        try:
            self.query_one(ContentSwitcher).current = f"pane-{session_id}"
        except Exception as exc:
            log.warning("ContentSwitcher switch error: %s", exc)

    # ──────────────────────────────────────────────────────────────────
    # Actions — panel navigation
    # ──────────────────────────────────────────────────────────────────

    def action_show_panel(self, panel: str) -> None:
        pane = self._active_pane()
        if pane:
            pane.show_panel(panel)

    # ──────────────────────────────────────────────────────────────────
    # Actions — tab management
    # ──────────────────────────────────────────────────────────────────

    def action_new_connection(self) -> None:
        """Open the 'Add Connection' modal and connect if confirmed."""
        def on_dismiss(config: AppConfig | None) -> None:
            if config:
                asyncio.create_task(self._add_connection_tab(config))
        self.push_screen(AddConnectionModal(), callback=on_dismiss)

    async def action_close_tab(self) -> None:
        """Close the currently active connection tab."""
        if not self._active_id:
            return
        session_id = self._active_id
        session = self._sessions.pop(session_id, None)
        if session:
            await session.close()

        tabs = self.query_one(Tabs)
        tabs.remove_tab(f"tab-{session_id}")

        try:
            pane = self.query_one(f"#pane-{session_id}")
            await pane.remove()
        except Exception:
            pass

        if not self._sessions:
            self._active_id = None
            # No tabs left → offer a new connection
            self.set_timer(0.1, self._prompt_if_empty)

    # ──────────────────────────────────────────────────────────────────
    # Actions — in-panel forwards
    # ──────────────────────────────────────────────────────────────────

    async def action_kill_session(self) -> None:
        pane = self._active_pane()
        if pane:
            await pane.forward_kill()

    async def action_trace_session(self) -> None:
        pane = self._active_pane()
        if pane:
            await pane.forward_trace()

    async def action_explain_plan(self) -> None:
        pane = self._active_pane()
        if pane:
            await pane.forward_explain()

    async def action_generate_awr(self) -> None:
        pane = self._active_pane()
        if pane:
            await pane.forward_awr()

    async def action_generate_report(self) -> None:
        pane = self._active_pane()
        if pane:
            await pane.forward_generate_report()

    def action_help(self) -> None:
        from widgets.help_screen import HelpScreen
        self.push_screen(HelpScreen())

    # ──────────────────────────────────────────────────────────────────
    # Internal helpers
    # ──────────────────────────────────────────────────────────────────

    async def _add_connection_tab(self, config: AppConfig) -> None:
        """Create session, connect, mount pane, add tab."""
        # Thin and Thick can't coexist in one process (oracledb.init_oracle_client
        # is global and irreversible). Block a conflicting mode with a clear
        # message instead of a cryptic driver error.
        if not config.demo:
            wanted = "Thick" if config.thick_mode else "Thin"
            if self._active_mode and wanted != self._active_mode:
                self.notify(
                    f"Não é possível abrir '{config.label or config.service}' em modo "
                    f"{wanted}: esta sessão já está em {self._active_mode}. Thin e Thick "
                    f"não se misturam no mesmo processo — abra outra instância do ora-brabo "
                    f"para o outro modo.",
                    severity="error", timeout=15)
                return

        session = ConnectionSession(config)
        self.notify(f"Connecting to {config.service}@{config.host}…")

        try:
            await session.connect()
        except Exception as exc:
            log.error("Connection failed: %s", exc)
            msg = str(exc)
            if "DPY-3010" in msg:
                # Thin mode reaches only 12.1+. 11g needs Thick mode.
                msg = (
                    "Banco Oracle 11.2 ou anterior não conecta em modo Thin.\n"
                    "Ative o 'Thick mode (11g / Native Encryption)' na tela de "
                    "conexão. Requer Oracle Instant Client instalado."
                )
            elif "DPY-3001" in msg:
                # Native Network Encryption required — thin unsupported.
                msg = (
                    "Este banco exige Native Network Encryption, não suportada "
                    "em modo Thin.\nAtive o 'Thick mode' na tela de conexão "
                    "(requer Oracle Instant Client)."
                )
            elif "DPI-1047" in msg:
                # Thick requested but Instant Client not found.
                msg = (
                    "Oracle Instant Client não encontrado para o Thick mode.\n"
                    "Instale o Instant Client e/ou informe o diretório dele no "
                    "campo 'Instant Client dir' da tela de conexão.\n"
                    f"Detalhe: {exc}"
                )
            self.notify(f"Connection failed: {msg}", severity="error", timeout=15)
            return

        # Lock the process-wide connection mode on first successful connect.
        if not config.demo:
            self._active_mode = "Thick" if config.thick_mode else "Thin"

        self._sessions[session.id] = session

        tab_id  = f"tab-{session.id}"
        pane_id = f"pane-{session.id}"

        # Mount the ConnectionPane inside the ContentSwitcher
        pane = ConnectionPane(session, id=pane_id)
        switcher = self.query_one(ContentSwitcher)
        await switcher.mount(pane)

        # Add the tab (this fires TabActivated which switches the switcher)
        tabs = self.query_one(Tabs)
        tabs.add_tab(Tab(session.label, id=tab_id))

        # After a few seconds update the tab label (db_name from health collector)
        self.set_timer(6.0, lambda s=session: self._refresh_tab_label(s))

        log.info("Tab added for session %s", session.id)
        self.notify(f"Connected: {session.label}", severity="information")

    def _refresh_tab_label(self, session: ConnectionSession) -> None:
        """Update the tab label once db_info is available in cache."""
        tab_id = f"tab-{session.id}"
        new_label = session.label
        try:
            tab = self.query_one(f"#{tab_id}", Tab)
            tab.label = new_label  # type: ignore[assignment]
        except Exception:
            pass

    async def _tick_refresh(self) -> None:
        """Global 1-second tick: refresh active panel + update tab health indicators."""
        pane = self._active_pane()
        if pane:
            await pane.refresh_active_panel()
        for session_id, session in self._sessions.items():
            tab_id = f"tab-{session_id}"
            try:
                tab = self.query_one(f"#{tab_id}", Tab)
                label = session.label
                if not session.is_healthy:
                    label = f"⚠ {label}"
                if str(tab.label) != label:
                    tab.label = label  # type: ignore[assignment]
            except Exception:
                pass

        # Header sub-title: freshness indicator for the ACTIVE session so the
        # user knows when collection has stalled (cache is stale-tolerant, so
        # panels keep showing the last values — this flags that they're old).
        self._update_freshness_subtitle()

    def _update_freshness_subtitle(self) -> None:
        if not self._active_id or self._active_id not in self._sessions:
            return
        sess = self._sessions[self._active_id]
        pane = self._active_pane()
        # Freshness of the data shown on the *current* panel — recomputed on
        # every tick, so the counter tracks the active panel live.
        key = pane.active_primary_key() if pane else "health.total_sessions"
        try:
            cache = sess.cache
            if cache.is_fresh(key):
                self.sub_title = sess.label
            else:
                age = cache.age(key)
                if age is None:
                    self.sub_title = f"{sess.label} — aguardando coleta…"
                else:
                    self.sub_title = f"{sess.label} — ⚠ dados defasados há {age:.0f}s"
        except Exception:
            pass

    def _active_pane(self) -> ConnectionPane | None:
        if not self._active_id:
            return None
        try:
            return self.query_one(f"#pane-{self._active_id}", ConnectionPane)
        except Exception:
            return None

    def _prompt_if_empty(self) -> None:
        if not self._sessions:
            self.action_new_connection()


# ──────────────────────────────────────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────────────────────────────────────

def _print_version_banner() -> None:
    """Print a colored ASCII banner with the ORA BRABO version."""
    import platform
    from rich.console import Console

    try:
        odb = __import__("oracledb").__version__
    except Exception:
        odb = "?"

    c = Console()
    c.print(BANNER_ART, style="bold #58a6ff")
    c.print(f"  ORA BRABO Monitoring Tool   ·   v{__version__}", style="bold #e6edf3")
    c.print("  Oracle Database TUI Monitor — inspired by Dolphie", style="#8b949e")
    c.print("  DBA BRABO · Acacio Lima Rocha", style="#8b949e")
    c.print(
        f"  Python {platform.python_version()}  ·  oracledb {odb} (thin)",
        style="#484f58",
    )
    c.print("")


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(
        description="ORA BRABO — Oracle Database TUI Monitor",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  ora_brabo --host db01 --service ORCL --user system --password secret\n"
            "  ora_brabo --host db01 --service ORCL --user sys --password secret --sysdba\n"
            "  ora_brabo --host db01 --service ORCL --user sys --password secret --thick\n"
            "  ora_brabo --start-saved PROD,DW    # open saved connections as tabs\n"
            "  ora_brabo --start-saved all        # open every saved connection\n"
            "  ora_brabo --list-saved             # list saved connection labels\n"
            "  ora_brabo                          # opens connection dialog"
        ),
    )
    parser.add_argument("--host",           default=None, help="Oracle host")
    parser.add_argument("--port",           default=1521, type=int)
    parser.add_argument("--service",        default=None, help="Service name, SID, or TNS alias")
    parser.add_argument("--user",           default="system")
    parser.add_argument("--password",       default=None)
    parser.add_argument("--refresh",        default=5,    type=int,
                        help="Refresh interval in seconds (default: 5)")
    parser.add_argument("--sysdba",         action="store_true")
    parser.add_argument("--label",          default=None, help="Tab label")
    # Wallet / ADB / OCI
    parser.add_argument("--wallet-zip",     default=None,
                        help="Path to Oracle Wallet .zip (ADB/OCI)")
    parser.add_argument("--wallet-password", default=None,
                        help="Wallet password for ewallet.p12 (omit for cwallet.sso auto-login)")
    parser.add_argument("--demo",            action="store_true",
                        help="Run in demo mode with simulated Oracle data (no database required)")
    parser.add_argument("--thick",           action="store_true",
                        help="Connect in Thick mode (Oracle Instant Client) — needed for 11g "
                             "or Native Network Encryption")
    parser.add_argument("--client-dir",      default=None,
                        help="Oracle Instant Client directory for --thick (omit to use PATH/default)")
    parser.add_argument("--start-saved",     default=None, metavar="LABELS",
                        help="Open tabs already connected from saved connections — comma-separated "
                             "labels (as saved), or 'all'. Ex: --start-saved BANCO1,BANCO2")
    parser.add_argument("--list-saved",      action="store_true",
                        help="List saved connection labels and exit")
    parser.add_argument("--version", "-v",   action="store_true",
                        help="Show version banner and exit")
    args = parser.parse_args()

    if args.version:
        _print_version_banner()
        sys.exit(0)

    if args.list_saved:
        from core.connections_store import load_connections
        conns = load_connections()
        if not conns:
            print("Nenhuma saved connection encontrada (~/.ora_brabo/connections.json).")
        else:
            print("Saved connections:")
            for c in conns:
                mode = "wallet" if c.wallet_zip else ("thick" if c.thick_mode else "thin")
                print(f"  {(c.label or c.service):24s} [{mode:6s}] {c.service}")
        sys.exit(0)

    # Build the list of connections to open on startup
    initial_configs: list[AppConfig] = []
    wallet_zip = args.wallet_zip

    if args.demo:
        # Demo mode — no real DB connection
        initial_configs = [AppConfig(
            label="DEMO — ORCL_PRIMARY", service="DEMO", username="demo",
            password="demo", demo=True, refresh_interval=args.refresh,
        )]
    elif args.start_saved:
        # Open one tab per saved connection referenced by its label.
        from core.connections_store import load_connections
        saved = load_connections()
        if args.start_saved.strip().lower() == "all":
            chosen, missing = saved, []
        else:
            chosen, missing = [], []
            for w in (s.strip() for s in args.start_saved.split(",") if s.strip()):
                match = (next((c for c in saved if (c.label or "").lower() == w.lower()), None)
                         or next((c for c in saved if c.service.lower() == w.lower()), None))
                (chosen.append(match) if match else missing.append(w))
        if missing:
            print(f"Aviso: saved connection(s) não encontrada(s): {', '.join(missing)}")
        initial_configs = [c.to_app_config() for c in chosen]
        if not initial_configs:
            print("Nenhuma saved connection válida em --start-saved — abrindo a tela de conexão.")
    elif wallet_zip and args.service and args.password:
        # Wallet-based connection (ADB / OCI)
        initial_configs = [AppConfig(
            label=args.label, service=args.service, username=args.user,
            password=args.password, wallet_zip=wallet_zip,
            wallet_password=args.wallet_password, refresh_interval=args.refresh,
            sysdba=args.sysdba, thick_mode=args.thick,
            oracle_client_lib_dir=args.client_dir,
        )]
    elif args.host and args.service and args.password:
        # Standard TCP connection
        initial_configs = [AppConfig(
            label=args.label, host=args.host, port=args.port, service=args.service,
            username=args.user, password=args.password, refresh_interval=args.refresh,
            sysdba=args.sysdba, thick_mode=args.thick,
            oracle_client_lib_dir=args.client_dir,
        )]

    OraBraboApp(initial_configs=initial_configs or None).run()


if __name__ == "__main__":
    main()

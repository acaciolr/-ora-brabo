"""
ORA BRABO Monitoring Tool
=========================
Oracle Database TUI Monitor — inspired by Dolphie, powered by Textual.
Author : DBA BRABO | Acacio Lima Rocha
Version: 1.1.0 — multi-tab support
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
        # ── Tab management ──────────────────────────────────────────────
        Binding("ctrl+n", "new_connection", "New Tab",   show=True),
        Binding("ctrl+w", "close_tab",      "Close Tab", show=True),
        # ── In-panel actions ───────────────────────────────────────────
        Binding("k", "kill_session",  "Kill",       show=False),
        Binding("t", "trace_session", "Trace",      show=False),
        Binding("e", "explain_plan",  "Explain",    show=False),
        Binding("r", "generate_awr",  "AWR Report", show=False),
        # ── App ────────────────────────────────────────────────────────
        Binding("?", "help",  "Help", show=False),
        Binding("q", "quit",  "Quit", show=True),
    ]

    TITLE     = "ORA BRABO Monitoring Tool"
    SUB_TITLE = "Oracle Database TUI Monitor | DBA BRABO"

    def __init__(self, initial_config: AppConfig | None = None) -> None:
        super().__init__()
        self._initial_config = initial_config
        self._sessions: dict[str, ConnectionSession] = {}   # session.id → session
        self._active_id: str | None = None

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
        log.info("ORA BRABO v1.1.0 starting (multi-tab).")
        self.set_interval(1.0, self._tick_refresh)

        if self._initial_config:
            await self._add_connection_tab(self._initial_config)
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

    def action_help(self) -> None:
        from widgets.help_screen import HelpScreen
        self.push_screen(HelpScreen())

    # ──────────────────────────────────────────────────────────────────
    # Internal helpers
    # ──────────────────────────────────────────────────────────────────

    async def _add_connection_tab(self, config: AppConfig) -> None:
        """Create session, connect, mount pane, add tab."""
        session = ConnectionSession(config)
        self.notify(f"Connecting to {config.service}@{config.host}…")

        try:
            await session.connect()
        except Exception as exc:
            log.error("Connection failed: %s", exc)
            self.notify(f"Connection failed: {exc}", severity="error", timeout=12)
            return

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

def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(
        description="ORA BRABO — Oracle Database TUI Monitor",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  ora_brabo --host db01 --service ORCL --user system --password secret\n"
            "  ora_brabo --host db01 --service ORCL --user sys --password secret --sysdba\n"
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
    args = parser.parse_args()

    # Build initial config only when the essential args are present
    initial_config: AppConfig | None = None
    wallet_zip = args.wallet_zip

    if args.demo:
        # Demo mode — no real DB connection
        initial_config = AppConfig(
            label="DEMO — ORCL_PRIMARY",
            service="DEMO",
            username="demo",
            password="demo",
            demo=True,
            refresh_interval=args.refresh,
        )
    elif wallet_zip and args.service and args.password:
        # Wallet-based connection (ADB / OCI)
        initial_config = AppConfig(
            label=args.label,
            service=args.service,
            username=args.user,
            password=args.password,
            wallet_zip=wallet_zip,
            wallet_password=args.wallet_password,
            refresh_interval=args.refresh,
            sysdba=args.sysdba,
        )
    elif args.host and args.service and args.password:
        # Standard TCP connection
        initial_config = AppConfig(
            label=args.label,
            host=args.host,
            port=args.port,
            service=args.service,
            username=args.user,
            password=args.password,
            refresh_interval=args.refresh,
            sysdba=args.sysdba,
        )

    OraBraboApp(initial_config=initial_config).run()


if __name__ == "__main__":
    main()

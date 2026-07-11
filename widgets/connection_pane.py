"""
widgets/connection_pane.py
Container widget that hosts all 12 monitoring panels for one ConnectionSession.
One ConnectionPane exists per open tab.
"""
from __future__ import annotations

import logging

from textual.app import ComposeResult
from textual.widget import Widget

from core.connection_session import ConnectionSession
from widgets.panels import (
    DashboardPanel,
    SessionsPanel,
    TopSQLPanel,
    WaitsPanel,
    LocksPanel,
    RACPanel,
    DataGuardPanel,
    ASMPanel,
    RMANPanel,
    AWRPanel,
    ASHPanel,
    AdvisorPanel,
    ExadataPanel,
    PDBPanel,
    IOActivityPanel,
    MemoryAdvisorPanel,
    SegmentsPanel,
    SQLMonitorPanel,
    AlertLogPanel,
    WaitChainPanel,
    PlanBaselinesPanel,
    ParallelQueryPanel,
)

log = logging.getLogger(__name__)

# Ordered list — index 0 is the default (F1)
_PANELS: list[tuple[str, type]] = [
    ("dashboard", DashboardPanel),
    ("sessions",  SessionsPanel),
    ("topsql",    TopSQLPanel),
    ("waits",     WaitsPanel),
    ("locks",     LocksPanel),
    ("rac",       RACPanel),
    ("dataguard", DataGuardPanel),
    ("asm",       ASMPanel),
    ("rman",      RMANPanel),
    ("awr",       AWRPanel),
    ("ash",       ASHPanel),
    ("advisor",   AdvisorPanel),
    ("exadata",      ExadataPanel),
    ("pdb",          PDBPanel),
    ("io",           IOActivityPanel),
    ("memory",       MemoryAdvisorPanel),
    ("segments",     SegmentsPanel),
    ("sqlmonitor",   SQLMonitorPanel),
    ("alertlog",     AlertLogPanel),
    ("waitchains",   WaitChainPanel),
    ("planbaselines",PlanBaselinesPanel),
    ("parallelquery",ParallelQueryPanel),
]


class ConnectionPane(Widget):
    """
    Hosts all 12 panels for one Oracle connection.
    Panel switching (F1–F12) is delegated here by OraBraboApp.
    """

    DEFAULT_CSS = """
    ConnectionPane {
        height: 1fr;
        width: 1fr;
    }
    """

    def __init__(self, session: ConnectionSession, **kwargs) -> None:
        super().__init__(**kwargs)
        self.session = session
        self._active_panel: str = "dashboard"

    def compose(self) -> ComposeResult:
        cm    = self.session.conn_manager
        cache = self.session.cache
        sid   = self.session.id

        for idx, (name, cls) in enumerate(_PANELS):
            classes = "" if idx == 0 else "hidden"
            yield cls(
                id=f"panel-{name}-{sid}",
                conn_manager=cm,
                cache=cache,
                classes=classes,
            )

    # ------------------------------------------------------------------
    # Panel navigation
    # ------------------------------------------------------------------

    def show_panel(self, panel: str) -> None:
        """Switch the visible panel within this connection pane."""
        sid = self.session.id
        old_id = f"#panel-{self._active_panel}-{sid}"
        new_id = f"#panel-{panel}-{sid}"
        try:
            self.query_one(old_id).add_class("hidden")
            self.query_one(new_id).remove_class("hidden")
            self._active_panel = panel
        except Exception as exc:
            log.warning("Panel switch error [session=%s]: %s", sid, exc)

    async def refresh_active_panel(self) -> None:
        """Call tick() on the active panel (respects each panel's REFRESH_RATE)."""
        sid = self.session.id
        panel_id = f"#panel-{self._active_panel}-{sid}"
        try:
            panel = self.query_one(panel_id)
            if hasattr(panel, "tick"):
                await panel.tick()
            elif hasattr(panel, "refresh_data"):
                await panel.refresh_data()
        except Exception as exc:
            log.warning("Refresh error [session=%s]: %s", sid, exc)

    # ------------------------------------------------------------------
    # Action targets (called from app.py)
    # ------------------------------------------------------------------

    async def forward_kill(self) -> None:
        sid = self.session.id
        # Try active panel first (e.g. LocksPanel has its own kill)
        try:
            panel = self.query_one(f"#panel-{self._active_panel}-{sid}")
            if hasattr(panel, "action_kill"):
                await panel.action_kill()
                return
        except Exception:
            pass
        # Fall back to SessionsPanel
        try:
            panel = self.query_one(f"#panel-sessions-{sid}")
            if hasattr(panel, "action_kill"):
                await panel.action_kill()
        except Exception:
            pass

    async def forward_trace(self) -> None:
        sid = self.session.id
        try:
            panel = self.query_one(f"#panel-sessions-{sid}")
            if hasattr(panel, "action_trace"):
                await panel.action_trace()
        except Exception:
            pass

    async def forward_explain(self) -> None:
        sid = self.session.id
        try:
            panel = self.query_one(f"#panel-topsql-{sid}")
            if hasattr(panel, "action_explain"):
                await panel.action_explain()
        except Exception:
            pass

    async def forward_awr(self) -> None:
        sid = self.session.id
        try:
            panel = self.query_one(f"#panel-awr-{sid}")
            if hasattr(panel, "action_generate"):
                await panel.action_generate()
        except Exception:
            pass

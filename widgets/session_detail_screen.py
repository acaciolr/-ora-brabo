"""
widgets/session_detail_screen.py
Session detail modal — all fields from GV$SESSION for a selected session.
"""
from __future__ import annotations

from datetime import datetime

from rich.table import Table
from rich.text import Text
from rich.panel import Panel
from textual.app import ComposeResult
from textual.binding import Binding
from textual.screen import ModalScreen
from textual.widgets import Static, Footer


class SessionDetailScreen(ModalScreen):
    """Shows all available fields for one Oracle session."""

    BINDINGS = [
        Binding("escape", "dismiss", "Close"),
        Binding("q",      "dismiss", "Close", show=False),
        Binding("d",      "dismiss", "Close", show=False),
    ]

    DEFAULT_CSS = """
    SessionDetailScreen {
        align: center middle;
    }
    SessionDetailScreen > Static {
        width: 90;
        max-height: 92vh;
        background: #161b22;
        border: solid #384c7a;
        padding: 0 1;
    }
    """

    _FIELD_LABELS: list[tuple[str, str]] = [
        ("inst_id",           "Instance"),
        ("sid",               "SID"),
        ("serial",            "Serial#"),
        ("username",          "Username"),
        ("status",            "Status"),
        ("event",             "Wait Event"),
        ("wait_class",        "Wait Class"),
        ("sql_id",            "SQL ID"),
        ("machine",           "Machine"),
        ("program",           "Program"),
        ("module",            "Module"),
        ("action",            "Action"),
        ("client_identifier", "Client ID"),
        ("service_name",      "Service"),
        ("blocking_session",  "Blocking SID"),
        ("last_call_et",      "Last Call ET (s)"),
        ("logon_time",        "Logon Time"),
        ("sql_exec_start",    "SQL Exec Start"),
        ("row_wait_obj",      "Row Wait Object"),
        ("type",              "Session Type"),
        ("state",             "Wait State"),
        ("seconds_in_wait",   "Seconds in Wait"),
    ]

    def __init__(self, session_data: dict, **kwargs) -> None:
        super().__init__(**kwargs)
        self.session_data = session_data

    def compose(self) -> ComposeResult:
        yield Static(id="sess-detail-body")

    def on_mount(self) -> None:
        s = self.session_data
        sid = s.get("sid", "?")
        user = s.get("username", "?") or "?"

        # Status color
        status = str(s.get("status", "") or "")
        blocking = s.get("blocking_session")
        if blocking:
            status_style = "bold red"
        elif status == "ACTIVE":
            status_style = "bold green"
        else:
            status_style = "dim"

        t = Table(show_header=False, box=None, padding=(0, 2), expand=True)
        t.add_column("Field", width=20, style="dim")
        t.add_column("Value", ratio=1)

        for key, label in self._FIELD_LABELS:
            val = s.get(key)
            if val is None:
                continue
            val_str = val.strftime("%Y-%m-%d %H:%M:%S") if isinstance(val, datetime) else str(val)
            if not val_str or val_str in ("", "None"):
                continue

            # Apply colors to specific fields
            if key == "status":
                val_text = Text(val_str, style=status_style)
            elif key == "blocking_session" and val:
                val_text = Text(val_str, style="bold red")
            elif key == "wait_class":
                CLASS_COLORS = {
                    "User I/O": "cyan", "Commit": "yellow", "Concurrency": "magenta",
                    "Application": "red", "System I/O": "blue", "Idle": "dim",
                }
                val_text = Text(val_str, style=CLASS_COLORS.get(val_str, "white"))
            elif key == "sql_id" and val_str:
                val_text = Text(val_str, style="bold #58a6ff")
            else:
                val_text = Text(val_str)

            t.add_row(label, val_text)

        # Extra: show full SQL text if available
        sql_text = str(s.get("sql_text", "") or s.get("sql_fulltext", "") or "")
        if sql_text:
            t.add_row("", "")
            t.add_row("SQL Text", Text(sql_text[:400], style="#e6edf3"))

        self.query_one("#sess-detail-body", Static).update(
            Panel(
                t,
                title=f"[bold cyan]Session Detail — SID {sid} ({user})[/]",
                subtitle="[dim]Esc / Q to close[/]",
                border_style="cyan",
                padding=(0, 1),
            )
        )

    def action_dismiss(self) -> None:
        self.dismiss()

"""
widgets/help_screen.py
Keyboard bindings help overlay — press ? from anywhere.
"""
from __future__ import annotations

from rich.table import Table
from rich.text import Text
from textual.app import ComposeResult
from textual.binding import Binding
from textual.screen import ModalScreen
from textual.widgets import Static, Footer


class HelpScreen(ModalScreen):
    """Full help overlay listing all keyboard shortcuts."""

    BINDINGS = [
        Binding("escape", "dismiss", "Close"),
        Binding("q",      "dismiss", "Close", show=False),
        Binding("?",      "dismiss", "Close", show=False),
    ]

    DEFAULT_CSS = """
    HelpScreen {
        align: center middle;
    }
    HelpScreen > Static {
        width: 80;
        max-height: 90vh;
        background: #161b22;
        border: solid #384c7a;
        padding: 1 2;
    }
    """

    _BINDINGS_TABLE = [
        # (key, description, category)
        ("F1",       "Dashboard — health, graphs, DB info",         "Panels"),
        ("F2",       "Sessions — active/blocked sessions",           "Panels"),
        ("F3",       "Top SQL — CPU/elapsed/buffer leaders",         "Panels"),
        ("F4",       "Waits — system wait events",                   "Panels"),
        ("F5",       "Locks — blocking sessions & wait chains",      "Panels"),
        ("F6",       "RAC — instances, GC stats, interconnect",      "Panels"),
        ("F7",       "Data Guard — replication, lag, processes",     "Panels"),
        ("F8",       "ASM — disk groups, FRA, archive rate",         "Panels"),
        ("F9",       "RMAN — backup jobs, history, sets",            "Panels"),
        ("F10",      "AWR — tablespaces, ADDM, top SQL/waits",       "Panels"),
        ("F11",      "ASH — active session history samples",         "Panels"),
        ("F12",      "Advisor — rule-based + Oracle Advisor",        "Panels"),
        ("X",        "Exadata — cells, Smart Scan, Flash Cache",     "Panels"),
        ("P",        "PDB Monitor — pluggable databases",            "Panels"),
        ("Ctrl+N",   "Open new connection tab",                      "Tabs"),
        ("Ctrl+W",   "Close current tab",                            "Tabs"),
        ("K",        "Kill session (with confirmation)",             "Actions"),
        ("T",        "Enable SQL Trace on session",                  "Actions"),
        ("E / Enter","Explain Plan for selected SQL",                "Actions"),
        ("S",        "Enter SQL ID manually for Explain Plan",       "Actions"),
        ("D",        "Session detail (on F2 Sessions panel)",        "Actions"),
        ("/",        "Filter sessions (on F2 Sessions panel)",       "Actions"),
        ("Esc",      "Close filter / modal / screen",                "Actions"),
        ("R",        "Generate AWR Report (on F10 AWR panel)",       "Actions"),
        ("?",        "This help screen",                             "App"),
        ("Q",        "Quit ORA BRABO",                               "App"),
    ]

    def compose(self) -> ComposeResult:
        yield Static(id="help-body")

    def on_mount(self) -> None:
        t = Table(
            show_header=True,
            header_style="bold cyan",
            box=None,
            padding=(0, 2),
            expand=True,
        )
        t.add_column("Key",         width=12)
        t.add_column("Action",      ratio=3)
        t.add_column("Category",    width=10)

        prev_cat = ""
        for key, desc, cat in self._BINDINGS_TABLE:
            if cat != prev_cat and prev_cat:
                t.add_row("", "", "")
            cat_label = f"[dim]{cat}[/]" if cat == prev_cat else f"[bold #58a6ff]{cat}[/]"
            t.add_row(
                f"[bold yellow]{key}[/]",
                desc,
                cat_label,
            )
            prev_cat = cat

        header = Text("  ORA BRABO — Keyboard Reference\n", style="bold white")
        header.append("  Press Esc or Q to close\n", style="dim")

        self.query_one("#help-body", Static).update(
            Text.assemble(header, "\n") if False else self._render(t, header)
        )

    def _render(self, table: Table, header: Text) -> Table:
        from rich.console import Group
        # We can't easily compose Text + Table in a Static, so just show the table
        # with a title row at the top
        return table

    def action_dismiss(self) -> None:
        self.dismiss()

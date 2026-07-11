"""
widgets/sql_input_screen.py
Simple modal to enter a SQL ID manually.
"""
from __future__ import annotations

from textual.app import ComposeResult
from textual.screen import ModalScreen
from textual.widgets import Button, Input, Label
from textual.containers import Vertical, Horizontal
from textual.binding import Binding


class SQLInputScreen(ModalScreen[str | None]):
    """Ask user for a SQL ID, return it or None on cancel."""

    BINDINGS = [Binding("escape", "dismiss_none", "Cancel", show=True)]

    DEFAULT_CSS = """
    SQLInputScreen {
        align: center middle;
    }
    SQLInputScreen > Vertical {
        width: 60;
        height: auto;
        background: #161b22;
        border: heavy #58a6ff;
        padding: 1 2;
    }
    SQLInputScreen Label {
        margin-bottom: 1;
        color: #8b949e;
    }
    SQLInputScreen Input {
        margin-bottom: 1;
    }
    SQLInputScreen Horizontal {
        height: auto;
        align: right middle;
    }
    SQLInputScreen Button {
        margin-left: 1;
    }
    """

    def compose(self) -> ComposeResult:
        with Vertical():
            yield Label("Enter SQL ID to inspect:")
            yield Input(placeholder="e.g. 3yru4fqvqpzwm", id="sql-id-input")
            with Horizontal():
                yield Button("Cancel", variant="default", id="btn-cancel")
                yield Button("Show Plan", variant="primary", id="btn-ok")

    def on_mount(self) -> None:
        self.query_one("#sql-id-input", Input).focus()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn-ok":
            val = self.query_one("#sql-id-input", Input).value.strip()
            self.dismiss(val if val else None)
        else:
            self.dismiss(None)

    def on_input_submitted(self, event: Input.Submitted) -> None:
        val = event.value.strip()
        self.dismiss(val if val else None)

    def action_dismiss_none(self) -> None:
        self.dismiss(None)

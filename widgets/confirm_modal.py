"""
widgets/confirm_modal.py
Simple yes/no confirmation dialog for destructive Oracle actions.
"""
from __future__ import annotations

from textual.app import ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal, Vertical
from textual.screen import ModalScreen
from textual.widgets import Button, Label


class ConfirmModal(ModalScreen[bool]):
    """Ask the user to confirm a destructive action. Returns True on confirm."""

    BINDINGS = [
        Binding("escape", "dismiss_false", "Cancel"),
        Binding("n",      "dismiss_false", "No"),
        Binding("y",      "dismiss_true",  "Yes"),
    ]

    DEFAULT_CSS = """
    ConfirmModal {
        align: center middle;
    }
    ConfirmModal > Vertical {
        width: 68;
        height: auto;
        background: #161b22;
        border: heavy #f85149;
        padding: 1 2;
    }
    ConfirmModal #confirm-title {
        text-style: bold;
        color: #f85149;
        height: 1;
        margin-bottom: 1;
    }
    ConfirmModal #confirm-body {
        color: #e6edf3;
        margin-bottom: 0;
    }
    ConfirmModal #confirm-cmd {
        color: #e3b341;
        margin-top: 1;
        margin-bottom: 1;
    }
    ConfirmModal #confirm-hint {
        color: #8b949e;
        height: 1;
        margin-bottom: 1;
    }
    ConfirmModal Horizontal {
        height: auto;
        align: right middle;
        margin-top: 1;
    }
    ConfirmModal Button {
        margin-left: 1;
    }
    """

    def __init__(self, title: str, body: str, command: str = "", **kwargs) -> None:
        super().__init__(**kwargs)
        self._title   = title
        self._body    = body
        self._command = command

    def compose(self) -> ComposeResult:
        with Vertical():
            yield Label(self._title,   id="confirm-title")
            yield Label(self._body,    id="confirm-body")
            if self._command:
                yield Label(self._command, id="confirm-cmd")
            yield Label("[dim]Y / Enter = confirm   N / Esc = cancel[/]", id="confirm-hint")
            with Horizontal():
                yield Button("Cancel",  variant="default", id="btn-no")
                yield Button("Confirm", variant="error",   id="btn-yes")

    def on_mount(self) -> None:
        self.query_one("#btn-no", Button).focus()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        self.dismiss(event.button.id == "btn-yes")

    def action_dismiss_false(self) -> None:
        self.dismiss(False)

    def action_dismiss_true(self) -> None:
        self.dismiss(True)

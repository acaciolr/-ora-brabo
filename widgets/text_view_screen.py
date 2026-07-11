"""
widgets/text_view_screen.py
Full-screen text viewer — used for AWR reports and other large text output.
"""
from __future__ import annotations

from textual.app import ComposeResult
from textual.binding import Binding
from textual.screen import Screen
from textual.widgets import Footer, Header, Static
from textual.containers import ScrollableContainer


class TextViewScreen(Screen):
    """Full-screen scrollable text viewer."""

    BINDINGS = [
        Binding("q",      "dismiss", "Close", show=True),
        Binding("escape", "dismiss", "Close", show=False),
    ]

    def __init__(self, title: str, content: str, **kwargs) -> None:
        super().__init__(**kwargs)
        self._view_title   = title
        self._view_content = content

    def compose(self) -> ComposeResult:
        yield Header(show_clock=False)
        with ScrollableContainer():
            yield Static(id="textview-body")
        yield Footer()

    def on_mount(self) -> None:
        self.title     = self._view_title
        self.sub_title = "q to close"
        self.query_one("#textview-body", Static).update(self._view_content)

    def action_dismiss(self) -> None:
        self.dismiss()

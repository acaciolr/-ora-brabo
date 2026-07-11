"""
widgets/add_connection_modal.py
Two-panel connection modal:
  Left  — saved connections list (arrow keys to navigate, Enter to load)
  Right — connection form with wallet toggle and "Save" option
"""
from __future__ import annotations

from textual.app import ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal, Vertical
from textual.screen import ModalScreen
from textual.widgets import Button, Input, Label, ListItem, ListView, Switch

from core.config import AppConfig
from core.connections_store import (
    SavedConnection,
    load_connections,
    remove_connection,
    save_connection,
)


class AddConnectionModal(ModalScreen[AppConfig | None]):
    """Two-panel Oracle connection dialog with saved-connections list."""

    BINDINGS = [
        Binding("escape", "cancel", "Cancel"),
    ]

    DEFAULT_CSS = """
    AddConnectionModal {
        align: center middle;
        background: rgba(0,0,0,0.82);
    }

    /* ── outer dialog ─────────────────────────────────────────────── */
    #dialog {
        background: #161b22;
        border: solid #58a6ff;
        width: 88;
        height: auto;
        max-height: 90vh;
    }

    #dialog-title {
        color: #58a6ff;
        text-style: bold;
        height: 1;
        padding: 0 1;
        background: #1c2128;
        border-bottom: solid #30363d;
    }

    /* ── two-column layout ────────────────────────────────────────── */
    #two-col {
        height: auto;
    }

    /* ── left panel (saved connections) ──────────────────────────── */
    #left-panel {
        width: 22;
        border-right: solid #30363d;
        padding: 1 1;
        height: auto;
        min-height: 20;
    }

    #left-panel Label.panel-hdr {
        color: #8b949e;
        text-style: bold;
        height: 1;
        margin-bottom: 1;
    }

    #saved-list {
        height: auto;
        min-height: 8;
        max-height: 20;
        background: #0d1117;
        border: solid #30363d;
    }

    #saved-list > ListItem {
        background: #0d1117;
        color: #c9d1d9;
        padding: 0 1;
    }

    #saved-list > ListItem:hover {
        background: #1c2128;
    }

    #saved-list > ListItem.--highlight {
        background: #1f6feb;
        color: #ffffff;
    }

    #no-saved {
        color: #484f58;
        padding: 1;
        height: 3;
    }

    #btn-delete {
        margin-top: 1;
        background: #3d1c1c;
        color: #f85149;
        width: 100%;
        height: 3;
    }

    #btn-delete:hover {
        background: #5a2020;
    }

    /* ── right panel (form) ───────────────────────────────────────── */
    #right-panel {
        width: 1fr;
        padding: 1 2;
        height: auto;
    }

    #right-panel Label {
        color: #8b949e;
        height: 1;
        margin: 0;
    }

    #right-panel Input {
        margin-bottom: 1;
        border: solid #30363d;
        background: #0d1117;
        color: #e6edf3;
        height: 3;
    }

    #right-panel Input:focus {
        border: solid #58a6ff;
    }

    .section-hdr {
        color: #3fb950;
        text-style: bold;
        height: 1;
        margin-top: 1;
        margin-bottom: 0;
    }

    .section-hdr-wallet {
        color: #e3b341;
        text-style: bold;
        height: 1;
        margin-top: 1;
        margin-bottom: 0;
    }

    #wallet-toggle-row {
        height: 3;
        align: left middle;
        margin-bottom: 1;
    }

    #wallet-toggle-row Label {
        color: #e3b341;
        text-style: bold;
        width: 26;
    }

    #sysdba-save-row {
        height: 3;
        align: left middle;
        margin-bottom: 1;
    }

    #sysdba-save-row Label {
        width: 10;
    }

    #save-row {
        height: 3;
        align: left middle;
        margin-bottom: 1;
    }

    #save-row Label {
        width: 26;
        color: #3fb950;
    }

    #port-refresh-row {
        height: auto;
    }

    #port-refresh-row Vertical {
        width: 1fr;
        margin-right: 1;
    }

    #btn-row {
        height: auto;
        margin-top: 1;
        align: right middle;
    }

    #btn-demo {
        background: #3d2b00;
        color: #e3b341;
        margin-right: 1;
    }

    #btn-demo:hover { background: #5a4000; }

    #btn-connect {
        background: #1f6feb;
        color: #ffffff;
        margin-right: 1;
    }

    #btn-connect:hover { background: #388bfd; }

    #btn-cancel {
        background: #21262d;
        color: #8b949e;
    }

    .hidden { display: none; }
    """

    def __init__(self) -> None:
        super().__init__()
        self._saved: list[SavedConnection] = []
        self._highlighted_idx: int = -1

    # ─────────────────────────────────────────────────────────────────
    # Layout
    # ─────────────────────────────────────────────────────────────────

    def compose(self) -> ComposeResult:
        with Vertical(id="dialog"):
            yield Label("  New Oracle Connection", id="dialog-title")

            with Horizontal(id="two-col"):

                # ── Left: saved connections ──────────────────────────
                with Vertical(id="left-panel"):
                    yield Label("Saved", classes="panel-hdr")
                    yield ListView(id="saved-list")
                    yield Label("(none saved)", id="no-saved")
                    yield Button("Delete", id="btn-delete", variant="error")

                # ── Right: form ──────────────────────────────────────
                with Vertical(id="right-panel"):

                    yield Label("Label  (optional)")
                    yield Input(
                        placeholder="PROD / DW / ADB-DEV",
                        id="inp-label",
                    )

                    # Wallet toggle
                    with Horizontal(id="wallet-toggle-row"):
                        yield Label("Use Wallet  (ADB / OCI)")
                        yield Switch(value=False, id="sw-wallet")

                    # Standard TCP section
                    with Vertical(id="section-standard"):
                        yield Label("── Standard TCP ──", classes="section-hdr")
                        yield Label("Host *")
                        yield Input(
                            placeholder="hostname or IP",
                            id="inp-host",
                        )
                        with Horizontal(id="port-refresh-row"):
                            with Vertical():
                                yield Label("Port")
                                yield Input(
                                    placeholder="1521",
                                    value="1521",
                                    id="inp-port",
                                )
                            with Vertical():
                                yield Label("Refresh (sec)")
                                yield Input(
                                    placeholder="5",
                                    value="5",
                                    id="inp-refresh",
                                )

                    # Wallet section
                    with Vertical(id="section-wallet", classes="hidden"):
                        yield Label("── Oracle Wallet ──", classes="section-hdr-wallet")
                        yield Label("Wallet ZIP path *")
                        yield Input(
                            placeholder="/path/to/Wallet_mydb.zip",
                            id="inp-wallet-zip",
                        )
                        yield Label("Wallet Password  (blank = cwallet.sso auto-login)")
                        yield Input(
                            placeholder="optional",
                            password=True,
                            id="inp-wallet-password",
                        )
                        yield Label("Refresh (sec)")
                        yield Input(
                            placeholder="5",
                            value="5",
                            id="inp-refresh-wallet",
                        )

                    # Common fields
                    yield Label("Service / DSN *")
                    yield Input(
                        placeholder="ORCL  or  mydb_high",
                        id="inp-service",
                    )
                    yield Label("Username")
                    yield Input(
                        placeholder="system  or  admin",
                        value="system",
                        id="inp-user",
                    )
                    yield Label("Password *")
                    yield Input(
                        placeholder="••••••••",
                        password=True,
                        id="inp-password",
                    )

                    with Horizontal(id="sysdba-save-row"):
                        yield Label("SYSDBA")
                        yield Switch(value=False, id="sw-sysdba")

                    with Horizontal(id="save-row"):
                        yield Label("Save this connection")
                        yield Switch(value=False, id="sw-save")

                    with Horizontal(id="btn-row"):
                        yield Button("Live Demo", variant="warning", id="btn-demo")
                        yield Button("Connect",   variant="primary", id="btn-connect")
                        yield Button("Cancel",    variant="default", id="btn-cancel")

    # ─────────────────────────────────────────────────────────────────
    # Lifecycle
    # ─────────────────────────────────────────────────────────────────

    def on_mount(self) -> None:
        self._reload_saved_list()

    def _reload_saved_list(self) -> None:
        self._saved = load_connections()
        lv = self.query_one("#saved-list", ListView)
        lv.clear()

        if self._saved:
            for i, conn in enumerate(self._saved):
                lv.append(ListItem(Label(conn.display_label), id=f"saved-{i}"))
            self.query_one("#saved-list").remove_class("hidden")
            self.query_one("#no-saved").add_class("hidden")
            self.query_one("#btn-delete").remove_class("hidden")
        else:
            self.query_one("#saved-list").add_class("hidden")
            self.query_one("#no-saved").remove_class("hidden")
            self.query_one("#btn-delete").add_class("hidden")

    # ─────────────────────────────────────────────────────────────────
    # ListView events
    # ─────────────────────────────────────────────────────────────────

    def on_list_view_highlighted(self, event: ListView.Highlighted) -> None:
        """Populate form when arrow key moves highlight."""
        if event.item is None:
            self._highlighted_idx = -1
            return
        try:
            idx = int(event.item.id.removeprefix("saved-"))
        except (AttributeError, ValueError):
            return
        self._highlighted_idx = idx
        self._populate_form(self._saved[idx])

    def on_list_view_selected(self, event: ListView.Selected) -> None:
        """Enter on a list item → populate form and focus Connect."""
        if event.item is None:
            return
        try:
            idx = int(event.item.id.removeprefix("saved-"))
        except (AttributeError, ValueError):
            return
        self._highlighted_idx = idx
        self._populate_form(self._saved[idx])
        self.query_one("#btn-connect", Button).focus()

    def _populate_form(self, conn: SavedConnection) -> None:
        """Fill the right-panel form with values from a SavedConnection."""
        use_wallet = bool(conn.wallet_zip)
        self.query_one("#sw-wallet",  Switch).value = use_wallet
        self._toggle_wallet_sections(use_wallet)

        self.query_one("#inp-label",   Input).value = conn.label or ""
        self.query_one("#inp-service", Input).value = conn.service
        self.query_one("#inp-user",    Input).value = conn.username
        self.query_one("#inp-password",Input).value = conn.password
        self.query_one("#sw-sysdba",   Switch).value = conn.sysdba
        self.query_one("#sw-save",     Switch).value = True  # already saved

        if use_wallet:
            self.query_one("#inp-wallet-zip",      Input).value = conn.wallet_zip or ""
            self.query_one("#inp-wallet-password", Input).value = conn.wallet_password or ""
            self.query_one("#inp-refresh-wallet",  Input).value = str(conn.refresh_interval)
        else:
            self.query_one("#inp-host",    Input).value = conn.host
            self.query_one("#inp-port",    Input).value = str(conn.port)
            self.query_one("#inp-refresh", Input).value = str(conn.refresh_interval)

    # ─────────────────────────────────────────────────────────────────
    # Wallet toggle
    # ─────────────────────────────────────────────────────────────────

    def on_switch_changed(self, event: Switch.Changed) -> None:
        if event.switch.id == "sw-wallet":
            self._toggle_wallet_sections(event.value)

    def _toggle_wallet_sections(self, use_wallet: bool) -> None:
        self.query_one("#section-standard").set_class(use_wallet,      "hidden")
        self.query_one("#section-wallet").set_class(not use_wallet,    "hidden")

    # ─────────────────────────────────────────────────────────────────
    # Buttons
    # ─────────────────────────────────────────────────────────────────

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn-cancel":
            self.dismiss(None)
        elif event.button.id == "btn-connect":
            self._submit()
        elif event.button.id == "btn-delete":
            self._delete_highlighted()
        elif event.button.id == "btn-demo":
            self._launch_demo()

    def on_input_submitted(self, _: Input.Submitted) -> None:
        self._submit()

    # ─────────────────────────────────────────────────────────────────
    # Delete saved connection
    # ─────────────────────────────────────────────────────────────────

    def _delete_highlighted(self) -> None:
        if self._highlighted_idx < 0 or self._highlighted_idx >= len(self._saved):
            self.app.notify("Select a connection to delete.", severity="warning")
            return
        conn = self._saved[self._highlighted_idx]
        remove_connection(conn.label, conn.host, conn.service)
        self._highlighted_idx = -1
        self._reload_saved_list()
        self.app.notify(f"Removed: {conn.display_label}")

    # ─────────────────────────────────────────────────────────────────
    # Cancel
    # ─────────────────────────────────────────────────────────────────

    def action_cancel(self) -> None:
        self.dismiss(None)

    def _launch_demo(self) -> None:
        """Dismiss with a demo AppConfig — no real DB needed."""
        from core.config import AppConfig
        self.dismiss(AppConfig(demo=True, label="DEMO — ORCL@oraserver01"))

    # ─────────────────────────────────────────────────────────────────
    # Submit / validate
    # ─────────────────────────────────────────────────────────────────

    def _submit(self) -> None:
        use_wallet = self.query_one("#sw-wallet", Switch).value

        service  = self.query_one("#inp-service",  Input).value.strip()
        password = self.query_one("#inp-password", Input).value
        username = self.query_one("#inp-user",     Input).value.strip() or "system"
        label    = self.query_one("#inp-label",    Input).value.strip()
        sysdba   = self.query_one("#sw-sysdba",    Switch).value
        do_save  = self.query_one("#sw-save",      Switch).value

        if not service or not password:
            self.app.notify("Service/DSN and Password are required.", severity="error")
            return

        if use_wallet:
            config = self._build_wallet_config(
                service, password, username, label, sysdba)
        else:
            config = self._build_standard_config(
                service, password, username, label, sysdba)

        if config is None:
            return

        if do_save:
            _persist(config)

        self.dismiss(config)

    # ─────────────────────────────────────────────────────────────────
    # Config builders
    # ─────────────────────────────────────────────────────────────────

    def _build_standard_config(
        self,
        service: str,
        password: str,
        username: str,
        label: str,
        sysdba: bool,
    ) -> AppConfig | None:
        host = self.query_one("#inp-host", Input).value.strip()
        if not host:
            self.app.notify("Host is required for standard connection.", severity="error")
            return None
        try:
            port    = int(self.query_one("#inp-port",    Input).value or "1521")
            refresh = int(self.query_one("#inp-refresh", Input).value or "5")
        except ValueError:
            self.app.notify("Port and Refresh must be integers.", severity="error")
            return None

        return AppConfig(
            label=label or None,
            host=host,
            port=port,
            service=service,
            username=username,
            password=password,
            refresh_interval=max(1, refresh),
            sysdba=sysdba,
        )

    def _build_wallet_config(
        self,
        service: str,
        password: str,
        username: str,
        label: str,
        sysdba: bool,
    ) -> AppConfig | None:
        from pathlib import Path

        wallet_zip = self.query_one("#inp-wallet-zip", Input).value.strip()
        if not wallet_zip:
            self.app.notify("Wallet ZIP path is required.", severity="error")
            return None
        if not Path(wallet_zip).expanduser().exists():
            self.app.notify(f"File not found: {wallet_zip}", severity="error")
            return None
        try:
            refresh = int(self.query_one("#inp-refresh-wallet", Input).value or "5")
        except ValueError:
            refresh = 5

        wallet_pw = self.query_one("#inp-wallet-password", Input).value or None

        return AppConfig(
            label=label or None,
            host="",
            port=1521,
            service=service,
            username=username,
            password=password,
            wallet_zip=wallet_zip,
            wallet_password=wallet_pw,
            refresh_interval=max(1, refresh),
            sysdba=sysdba,
        )


# ─────────────────────────────────────────────────────────────────────
# Helper — persist without coupling to the form
# ─────────────────────────────────────────────────────────────────────

def _persist(config: AppConfig) -> None:
    conn = SavedConnection(
        label=config.label or "",
        host=config.host,
        port=config.port,
        service=config.service,
        username=config.username,
        password=config.password,
        wallet_zip=config.wallet_zip,
        wallet_password=config.wallet_password,
        sysdba=config.sysdba,
        refresh_interval=config.refresh_interval,
    )
    save_connection(conn)

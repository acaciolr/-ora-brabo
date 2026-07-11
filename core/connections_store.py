"""
core/connections_store.py
Persists saved Oracle connections to ~/.ora_brabo/connections.json.
Passwords are stored in the system keychain (keyring) when available;
otherwise fall back to plaintext in JSON for backward compatibility.
"""
from __future__ import annotations

import json
import logging
from dataclasses import asdict, dataclass, field
from pathlib import Path

from core.config import AppConfig

log = logging.getLogger(__name__)

_STORE_DIR  = Path.home() / ".ora_brabo"
_STORE_FILE = _STORE_DIR / "connections.json"
_KEYRING_SERVICE = "ora_brabo"

# Graceful import — keyring may not be installed
try:
    import keyring as _keyring
    _HAS_KEYRING = True
except ImportError:
    _HAS_KEYRING = False
    log.debug("keyring not installed; passwords stored in plaintext JSON")


def _keyring_key(label: str, host: str, service: str) -> str:
    return f"{label}|{host}|{service}"


def _store_password(label: str, host: str, service: str, password: str) -> bool:
    if _HAS_KEYRING and password:
        try:
            _keyring.set_password(_KEYRING_SERVICE, _keyring_key(label, host, service), password)
            return True
        except Exception as exc:
            log.warning("keyring store failed: %s", exc)
    return False


def _retrieve_password(label: str, host: str, service: str) -> str | None:
    if _HAS_KEYRING:
        try:
            return _keyring.get_password(_KEYRING_SERVICE, _keyring_key(label, host, service))
        except Exception as exc:
            log.warning("keyring retrieve failed: %s", exc)
    return None


@dataclass
class SavedConnection:
    label: str
    host: str
    port: int
    service: str
    username: str
    password: str          # empty when stored in keychain
    wallet_zip: str | None = None
    wallet_password: str | None = None
    sysdba: bool = False
    refresh_interval: int = 5

    @property
    def display_label(self) -> str:
        if self.wallet_zip:
            return f"[W] {self.label or self.service}"
        host_short = self.host.split(".")[0] if self.host else ""
        return self.label or f"{self.service}@{host_short}"

    def resolved_password(self) -> str:
        """Return the actual password — from keyring if JSON field is empty."""
        if self.password:
            return self.password
        pw = _retrieve_password(self.label, self.host, self.service)
        return pw or ""

    def to_app_config(self) -> AppConfig:
        return AppConfig(
            label=self.label or None,
            host=self.host,
            port=self.port,
            service=self.service,
            username=self.username,
            password=self.resolved_password(),
            wallet_zip=self.wallet_zip or None,
            wallet_password=self.wallet_password or None,
            sysdba=self.sysdba,
            refresh_interval=self.refresh_interval,
        )


# ─────────────────────────────────────────────────────────────────────
# Storage helpers
# ─────────────────────────────────────────────────────────────────────

def load_connections() -> list[SavedConnection]:
    """Return saved connections. Empty list if file missing."""
    if not _STORE_FILE.exists():
        return []
    try:
        data = json.loads(_STORE_FILE.read_text(encoding="utf-8"))
        return [SavedConnection(**item) for item in data]
    except Exception as exc:
        log.warning("Failed to load connections: %s", exc)
        return []


def _write(connections: list[SavedConnection]) -> None:
    _STORE_DIR.mkdir(parents=True, exist_ok=True)
    _STORE_FILE.write_text(
        json.dumps([asdict(c) for c in connections], indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def save_connection(conn: SavedConnection) -> None:
    """Add or update a connection. Stores password in keyring when available."""
    password_to_json = conn.password

    if _store_password(conn.label, conn.host, conn.service, conn.password):
        # Password saved to keychain — clear from JSON
        password_to_json = ""
        log.info("Password stored in system keychain for: %s", conn.display_label)

    conn_to_save = SavedConnection(
        label=conn.label,
        host=conn.host,
        port=conn.port,
        service=conn.service,
        username=conn.username,
        password=password_to_json,
        wallet_zip=conn.wallet_zip,
        wallet_password=conn.wallet_password,
        sysdba=conn.sysdba,
        refresh_interval=conn.refresh_interval,
    )

    connections = load_connections()
    key = (conn.label, conn.host, conn.service)
    for i, existing in enumerate(connections):
        if (existing.label, existing.host, existing.service) == key:
            connections[i] = conn_to_save
            _write(connections)
            return
    connections.insert(0, conn_to_save)
    _write(connections)
    log.info("Saved connection: %s", conn.display_label)


def remove_connection(label: str, host: str, service: str) -> None:
    """Remove a saved connection and its keychain entry."""
    connections = load_connections()
    key = (label, host, service)
    connections = [c for c in connections if (c.label, c.host, c.service) != key]
    _write(connections)
    if _HAS_KEYRING:
        try:
            _keyring.delete_password(_KEYRING_SERVICE, _keyring_key(label, host, service))
        except Exception:
            pass
    log.info("Removed connection: %s", label)


def from_app_config(config: AppConfig) -> SavedConnection:
    """Build a SavedConnection from an AppConfig (for saving after connect)."""
    return SavedConnection(
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

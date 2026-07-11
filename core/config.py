"""
core/config.py
Application configuration — loaded from CLI args or config file.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class AppConfig:
    # ── Standard connection ────────────────────────────────────────────
    host: str = ""
    port: int = 1521
    service: str = ""
    username: str = "system"
    password: str = ""

    # ── Wallet / mTLS (Oracle ADB / OCI) ──────────────────────────────
    wallet_zip: str | None = None       # path to the downloaded wallet .zip
    wallet_password: str | None = None  # ewallet.p12 password (optional for cwallet.sso)

    # ── Display ────────────────────────────────────────────────────────
    label: str | None = None            # tab label (auto-set from db_name if None)

    # ── Demo mode ──────────────────────────────────────────────────────
    demo: bool = False                  # populate cache with fake data, no real DB needed

    # ── Behaviour ─────────────────────────────────────────────────────
    refresh_interval: int = 5
    sysdba: bool = False
    pool_min: int = 1
    pool_max: int = 4
    pool_increment: int = 1
    connection_timeout: int = 10
    query_timeout: int = 30
    log_level: str = "INFO"
    awr_snap_interval_min: int = 60
    ash_sample_interval_sec: int = 10
    advisor_eval_interval_sec: int = 30
    exadata_detection: bool = True
    rac_detection: bool = True
    dg_detection: bool = True

    @property
    def uses_wallet(self) -> bool:
        return bool(self.wallet_zip)

    @property
    def dsn(self) -> str:
        """DSN for standard (non-wallet) connections."""
        return f"{self.host}:{self.port}/{self.service}"

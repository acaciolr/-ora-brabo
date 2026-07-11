"""
core/connection_manager.py
Manages Oracle connection pool (oracledb Thin Mode).
Supports Single Instance, RAC, Data Guard, SYSDBA, and Oracle Wallet (ADB/OCI).
"""

from __future__ import annotations

import hashlib
import logging
import zipfile
from pathlib import Path

import oracledb

from core.config import AppConfig

log = logging.getLogger(__name__)

# Wallets are extracted once to ~/.ora_brabo/wallets/<hash>/
_WALLET_BASE = Path.home() / ".ora_brabo" / "wallets"


def _extract_wallet(zip_path: str) -> Path:
    """
    Extract the wallet zip to a stable directory keyed by the zip's absolute path.
    Re-extracts only when the zip file is newer than the last extraction.
    Returns the directory containing cwallet.sso / tnsnames.ora.
    """
    zip_path_obj = Path(zip_path).expanduser().resolve()
    key = hashlib.md5(str(zip_path_obj).encode()).hexdigest()[:12]
    wallet_dir = _WALLET_BASE / key

    # Re-extract if directory missing or zip is newer
    if not wallet_dir.exists() or (
        zip_path_obj.stat().st_mtime > (wallet_dir / ".extracted_mtime").stat().st_mtime
        if (wallet_dir / ".extracted_mtime").exists() else True
    ):
        wallet_dir.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(zip_path_obj) as zf:
            zf.extractall(wallet_dir)
        (wallet_dir / ".extracted_mtime").touch()
        log.info("Wallet extracted to %s", wallet_dir)
    else:
        log.info("Wallet already extracted at %s", wallet_dir)

    return wallet_dir


class ConnectionManager:
    """
    Async-friendly Oracle connection pool wrapper.
    Uses oracledb Thin Mode — no Oracle Client required.
    Supports wallet-based mTLS connections (ADB / OCI).
    """

    def __init__(self, config: AppConfig) -> None:
        self.config = config
        self._pool: oracledb.AsyncConnectionPool | None = None
        self.db_info: dict = {}
        self._wallet_dir: Path | None = None

    # ------------------------------------------------------------------
    # Lifecycle
    # ------------------------------------------------------------------

    async def connect(self) -> None:
        """Create async connection pool (standard or wallet-based)."""
        mode = oracledb.AUTH_MODE_SYSDBA if self.config.sysdba else oracledb.AUTH_MODE_DEFAULT

        if self.config.uses_wallet:
            await self._connect_wallet(mode)
        else:
            await self._connect_standard(mode)

        # Validate and collect db info
        async with self.acquire() as conn:
            self.db_info = await self._collect_db_info(conn)
            log.info("Connected: %s %s", self.db_info.get("db_name"), self.db_info.get("version"))

    async def _connect_standard(self, mode: int) -> None:
        log.info("Connecting to %s as %s (sysdba=%s)",
                 self.config.dsn, self.config.username, self.config.sysdba)
        self._pool = oracledb.create_pool_async(
            user=self.config.username,
            password=self.config.password,
            dsn=self.config.dsn,
            min=self.config.pool_min,
            max=self.config.pool_max,
            increment=self.config.pool_increment,
            mode=mode,
            timeout=self.config.connection_timeout,
        )

    async def _connect_wallet(self, mode: int) -> None:
        """Connect using Oracle Wallet (ADB / OCI mTLS)."""
        self._wallet_dir = _extract_wallet(self.config.wallet_zip)
        log.info("Connecting with wallet: service=%s wallet_dir=%s",
                 self.config.service, self._wallet_dir)

        kwargs: dict = dict(
            user=self.config.username,
            password=self.config.password,
            dsn=self.config.service,          # service name as in tnsnames.ora
            config_dir=str(self._wallet_dir), # tnsnames.ora location
            wallet_location=str(self._wallet_dir),
            min=self.config.pool_min,
            max=self.config.pool_max,
            increment=self.config.pool_increment,
            mode=mode,
            timeout=self.config.connection_timeout,
        )
        if self.config.wallet_password:
            kwargs["wallet_password"] = self.config.wallet_password

        self._pool = oracledb.create_pool_async(**kwargs)

    async def close(self) -> None:
        if self._pool:
            await self._pool.close(force=False)
            log.info("Connection pool closed.")

    # ------------------------------------------------------------------
    # Pool access
    # ------------------------------------------------------------------

    def acquire(self) -> oracledb.AsyncConnection:
        """Context manager — acquire a connection from the pool."""
        if self._pool is None:
            raise RuntimeError("ConnectionManager not connected. Call connect() first.")
        return self._pool.acquire()

    async def execute_query(self, sql: str, params: dict | None = None) -> list[dict]:
        """Execute a SELECT and return list of dicts."""
        params = params or {}
        try:
            async with self.acquire() as conn:
                async with conn.cursor() as cur:
                    await cur.execute(sql, params)
                    cols = [c[0].lower() for c in cur.description]
                    rows = await cur.fetchall()
                    return [dict(zip(cols, row)) for row in rows]
        except oracledb.DatabaseError as exc:
            log.error("Query error: %s | SQL: %.200s", exc, sql)
            return []

    async def execute_ddl(self, sql: str) -> bool:
        """Execute DDL/DML without result set."""
        try:
            async with self.acquire() as conn:
                async with conn.cursor() as cur:
                    await cur.execute(sql)
                await conn.commit()
            return True
        except oracledb.DatabaseError as exc:
            log.error("DDL error: %s | SQL: %.200s", exc, sql)
            return False

    async def fetch_one(self, sql: str, params: dict | None = None) -> dict | None:
        rows = await self.execute_query(sql, params)
        return rows[0] if rows else None

    # ------------------------------------------------------------------
    # Database introspection
    # ------------------------------------------------------------------

    async def _collect_db_info(self, conn: oracledb.AsyncConnection) -> dict:
        sql = """
            SELECT
                d.dbid,
                d.name            AS db_name,
                d.db_unique_name,
                d.open_mode,
                d.database_role,
                d.flashback_on,
                d.log_mode,
                d.cdb,
                i.version,
                i.host_name,
                i.instance_name,
                i.startup_time,
                i.status          AS inst_status
            FROM v$database d, v$instance i
        """
        async with conn.cursor() as cur:
            await cur.execute(sql)
            cols = [c[0].lower() for c in cur.description]
            row = await cur.fetchone()
            return dict(zip(cols, row)) if row else {}

    @property
    def is_rac(self) -> bool:
        return self.db_info.get("cluster_database", "FALSE").upper() == "TRUE"

    @property
    def is_cdb(self) -> bool:
        return self.db_info.get("cdb", "NO") == "YES"

    @property
    def db_name(self) -> str:
        return self.db_info.get("db_name", "UNKNOWN")

    @property
    def version(self) -> str:
        return self.db_info.get("version", "?")

"""
core/connection_manager.py
Manages Oracle connection pool (oracledb Thin + Thick modes).

Thin mode (default): pure-Python asyncio pool, no Oracle Client, reaches
    Oracle Database 12.1+ and TLS/mTLS wallets (ADB / OCI).
Thick mode (opt-in): uses Oracle Instant Client, required for Oracle 11g and
    for servers with Native Network Encryption (NNE). Thick has no asyncio
    API, so its calls run synchronously inside asyncio.to_thread() to preserve
    the async interface used by every collector.

Supports Single Instance, RAC, Data Guard, SYSDBA, and Oracle Wallet (ADB/OCI).
"""

from __future__ import annotations

import asyncio
import hashlib
import logging
import zipfile
from pathlib import Path

import oracledb

from core.config import AppConfig

log = logging.getLogger(__name__)

# Wallets are extracted once to ~/.ora_brabo/wallets/<hash>/
_WALLET_BASE = Path.home() / ".ora_brabo" / "wallets"

# init_oracle_client() is process-global and may only be called once. Guard it.
_thick_client_initialized = False


def _ensure_thick_client(lib_dir: str | None) -> None:
    """Initialize Oracle Client (Thick mode) once per process.

    Raises oracledb.DatabaseError (e.g. DPI-1047) if the Instant Client
    libraries cannot be located — the caller surfaces a friendly message.
    """
    global _thick_client_initialized
    if _thick_client_initialized:
        return
    kwargs: dict = {}
    if lib_dir:
        kwargs["lib_dir"] = lib_dir
    oracledb.init_oracle_client(**kwargs)
    _thick_client_initialized = True
    log.info("Oracle Client initialized (thick mode). lib_dir=%s",
             lib_dir or "<PATH/default>")


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
        self._pool: oracledb.AsyncConnectionPool | None = None      # thin
        self._sync_pool: oracledb.ConnectionPool | None = None      # thick
        self.db_info: dict = {}
        self._wallet_dir: Path | None = None

    # ------------------------------------------------------------------
    # Lifecycle
    # ------------------------------------------------------------------

    async def connect(self) -> None:
        """Create connection pool (thin async, or thick sync-in-thread)."""
        mode = oracledb.AUTH_MODE_SYSDBA if self.config.sysdba else oracledb.AUTH_MODE_DEFAULT

        # ---- Thick mode (Oracle 11g / Native Network Encryption) ----
        if self.config.thick_mode:
            await self._connect_thick(mode)
            self.db_info = await asyncio.to_thread(self._collect_db_info_sync)
            log.info("Connected (thick): %s %s",
                     self.db_info.get("db_name"), self.db_info.get("version"))
            return

        # ---- Thin mode (default, unchanged) ----
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
        # Thin mode decrypts ewallet.pem with wallet_password. We must ALWAYS
        # pass it — otherwise Python's ssl layer drops to an interactive
        # "Enter PEM pass phrase:" prompt on the tty and hangs the TUI.
        # If no dedicated wallet password was given, reuse the connection
        # password so the user only ever supplies one credential.
        kwargs["wallet_password"] = (
            self.config.wallet_password or self.config.password or ""
        )

        self._pool = oracledb.create_pool_async(**kwargs)

    async def _connect_thick(self, mode: int) -> None:
        """Connect in Thick mode (Instant Client). Builds a synchronous pool
        off-thread so the event loop is never blocked."""
        _ensure_thick_client(self.config.oracle_client_lib_dir)

        if self.config.uses_wallet:
            self._wallet_dir = _extract_wallet(self.config.wallet_zip)
            log.info("Connecting (thick) with wallet: service=%s wallet_dir=%s",
                     self.config.service, self._wallet_dir)
            kwargs: dict = dict(
                user=self.config.username,
                password=self.config.password,
                dsn=self.config.service,
                config_dir=str(self._wallet_dir),
                wallet_location=str(self._wallet_dir),
                min=self.config.pool_min,
                max=self.config.pool_max,
                increment=self.config.pool_increment,
                mode=mode,
            )
            # Thick uses cwallet.sso auto-login; only pass a password if one
            # was explicitly provided (for a PKCS#12 wallet).
            if self.config.wallet_password:
                kwargs["wallet_password"] = self.config.wallet_password
        else:
            log.info("Connecting (thick) to %s as %s (sysdba=%s)",
                     self.config.dsn, self.config.username, self.config.sysdba)
            kwargs = dict(
                user=self.config.username,
                password=self.config.password,
                dsn=self.config.dsn,
                min=self.config.pool_min,
                max=self.config.pool_max,
                increment=self.config.pool_increment,
                mode=mode,
            )

        self._sync_pool = await asyncio.to_thread(
            lambda: oracledb.create_pool(**kwargs)
        )

    async def close(self) -> None:
        if self._pool:
            await self._pool.close(force=False)
            log.info("Connection pool closed.")
        if self._sync_pool:
            await asyncio.to_thread(self._sync_pool.close, force=True)
            log.info("Connection pool closed (thick).")

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
        if self.config.thick_mode:
            return await asyncio.to_thread(self._execute_query_sync, sql, params)
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
        if self.config.thick_mode:
            return await asyncio.to_thread(self._execute_ddl_sync, sql)
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
    # Thick-mode synchronous workers (run inside asyncio.to_thread)
    # ------------------------------------------------------------------

    def _execute_query_sync(self, sql: str, params: dict) -> list[dict]:
        try:
            with self._sync_pool.acquire() as conn:
                with conn.cursor() as cur:
                    cur.execute(sql, params)
                    cols = [c[0].lower() for c in cur.description]
                    rows = cur.fetchall()
                    return [dict(zip(cols, row)) for row in rows]
        except oracledb.DatabaseError as exc:
            log.error("Query error (thick): %s | SQL: %.200s", exc, sql)
            return []

    def _execute_ddl_sync(self, sql: str) -> bool:
        try:
            with self._sync_pool.acquire() as conn:
                with conn.cursor() as cur:
                    cur.execute(sql)
                conn.commit()
            return True
        except oracledb.DatabaseError as exc:
            log.error("DDL error (thick): %s | SQL: %.200s", exc, sql)
            return False

    def _collect_db_info_sync(self) -> dict:
        # v$database.cdb only exists on 12.1+. On 11g it raises ORA-00904, so
        # fall back to a query without it (cdb defaults to 'NO').
        sql_full = """
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
        sql_11g = """
            SELECT
                d.dbid,
                d.name            AS db_name,
                d.db_unique_name,
                d.open_mode,
                d.database_role,
                d.flashback_on,
                d.log_mode,
                'NO'              AS cdb,
                i.version,
                i.host_name,
                i.instance_name,
                i.startup_time,
                i.status          AS inst_status
            FROM v$database d, v$instance i
        """
        with self._sync_pool.acquire() as conn:
            with conn.cursor() as cur:
                try:
                    cur.execute(sql_full)
                except oracledb.DatabaseError:
                    cur.execute(sql_11g)
                cols = [c[0].lower() for c in cur.description]
                row = cur.fetchone()
                return dict(zip(cols, row)) if row else {}

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

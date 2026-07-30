#!/usr/bin/env python3
"""
tools/validate_queries.py
Query linter for ORA BRABO — validates EVERY SQL used by the collectors
against a live Oracle database WITHOUT fetching data.

Each query is wrapped as `SELECT * FROM ( <query> ) WHERE ROWNUM = 0`, so the
server parses and name-resolves every column but returns no rows. Any
ORA-00904 (invalid identifier), ORA-00942 (table/view not found), missing
privilege, etc. is reported per query — so we find broken columns at build
time instead of "só saber depois" in production.

Usage (mirrors app.py connection flags):

  # Standard TCP
  python tools/validate_queries.py --host 10.0.0.10 --port 1521 \
         --service ORCLPDB1 --user system --password ****

  # Wallet (ADB / OCI), thin mode
  python tools/validate_queries.py --wallet-zip ~/Wallet_ABATP.zip \
         --service abatp_high --user admin --password ****

  # Thick mode (11g / Native Network Encryption)
  python tools/validate_queries.py --host ... --service ... --user ... \
         --password **** --thick [--lib-dir /opt/oracle/instantclient_21_13]

Exit code is 0 when every query passes, 1 when any query fails.
"""
from __future__ import annotations

import argparse
import glob
import os
import re
import sys

# Make the project root importable (so we can reuse the wallet extractor).
_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _ROOT)

import oracledb  # noqa: E402

# Files whose triple-quoted SQL blocks we validate.
_SCAN_GLOBS = ["collectors/*.py", "advisor/*.py", "core/connection_manager.py"]

# Extract triple-quoted blocks that look like SQL SELECTs.
_TRIPLE = re.compile(r'"""(.*?)"""', re.DOTALL)
_BIND = re.compile(r":(\w+)")


def _looks_like_select(sql: str) -> bool:
    body = "\n".join(
        ln for ln in sql.splitlines() if not ln.strip().startswith("--")
    ).strip()
    return body[:6].upper() == "SELECT"


def _collect_queries() -> list[tuple[str, int, str]]:
    """Return (file, line_no, sql) for every SELECT block found."""
    out: list[tuple[str, int, str]] = []
    for pattern in _SCAN_GLOBS:
        for path in glob.glob(os.path.join(_ROOT, pattern)):
            # Skip iCloud conflict copies ("collectors/objects 2.py").
            if re.search(r" \d+\.py$", os.path.basename(path)):
                continue
            src = open(path, encoding="utf-8").read()
            for m in _TRIPLE.finditer(src):
                block = m.group(1)
                if not _looks_like_select(block):
                    continue
                line_no = src.count("\n", 0, m.start()) + 1
                rel = os.path.relpath(path, _ROOT)
                out.append((rel, line_no, block.strip()))
    return out


def _connect(args) -> oracledb.Connection:
    if args.thick:
        kw = {}
        if args.lib_dir:
            kw["lib_dir"] = args.lib_dir
        oracledb.init_oracle_client(**kw)

    mode = oracledb.AUTH_MODE_SYSDBA if args.sysdba else oracledb.AUTH_MODE_DEFAULT
    kwargs = dict(user=args.user, password=args.password, mode=mode)

    if args.wallet_zip:
        from core.connection_manager import _extract_wallet
        wdir = _extract_wallet(args.wallet_zip)
        kwargs.update(
            dsn=args.service,
            config_dir=str(wdir),
            wallet_location=str(wdir),
            wallet_password=args.wallet_password or args.password or "",
        )
    else:
        kwargs["dsn"] = args.dsn or f"{args.host}:{args.port}/{args.service}"

    return oracledb.connect(**kwargs)


def main() -> int:
    ap = argparse.ArgumentParser(description="Validate all ORA BRABO SQL against a live DB.")
    ap.add_argument("--host")
    ap.add_argument("--port", type=int, default=1521)
    ap.add_argument("--service")
    ap.add_argument("--dsn", help="Full DSN (overrides host/port/service)")
    ap.add_argument("--user", required=True)
    ap.add_argument("--password", required=True)
    ap.add_argument("--sysdba", action="store_true")
    ap.add_argument("--wallet-zip", dest="wallet_zip")
    ap.add_argument("--wallet-password", dest="wallet_password")
    ap.add_argument("--thick", action="store_true")
    ap.add_argument("--lib-dir", dest="lib_dir")
    args = ap.parse_args()

    queries = _collect_queries()
    print(f"Discovered {len(queries)} SQL blocks to validate.\n")

    conn = _connect(args)
    cur = conn.cursor()

    passed = failed = 0
    failures: list[str] = []

    for rel, line_no, sql in queries:
        binds = {name: None for name in set(_BIND.findall(sql))}
        snippet = " ".join(sql.split())[:70]
        try:
            # execute() parses and name-resolves every column (this is where
            # ORA-00904 surfaces). We fetch a single row cap and never iterate,
            # so no meaningful data is transferred. Avoids the column-name
            # uniqueness requirement of a SELECT * wrapper (no ORA-00918 false
            # positives on JOINs).
            cur.execute(sql, binds)
            cur.fetchmany(0)
            passed += 1
            print(f"  \033[92mOK\033[0m   {rel}:{line_no}  {snippet}…")
        except oracledb.DatabaseError as exc:
            failed += 1
            err = str(exc).splitlines()[0]
            print(f"  \033[91mFAIL\033[0m {rel}:{line_no}  {snippet}…")
            print(f"        -> {err}")
            failures.append(f"{rel}:{line_no}  {err}")

    cur.close()
    conn.close()

    print(f"\n{'='*70}\nPassed: {passed}   Failed: {failed}")
    if failures:
        print("\nFAILURES:")
        for f in failures:
            print(f"  - {f}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

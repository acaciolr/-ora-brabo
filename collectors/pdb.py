"""
collectors/pdb.py
PDB (Pluggable Database) monitoring — CDB only.
Cache keys: pdb.detected, pdb.list, pdb.tablespaces, pdb.dg_status
"""
from __future__ import annotations

from collectors.base import BaseCollector

_SQL_DETECT = """
SELECT cdb FROM v$database
"""

_SQL_PDBS = """
SELECT
    p.con_id,
    p.name,
    p.open_mode,
    p.restricted,
    p.recovery_status,
    p.total_size / 1048576        AS total_mb,
    NVL(s.active_sess, 0)         AS active_sessions,
    NVL(s.total_sess,  0)         AS total_sessions,
    p.creation_time
FROM v$pdbs p
LEFT JOIN (
    SELECT con_id,
           COUNT(*)                                            AS total_sess,
           SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_sess
    FROM v$session
    WHERE type = 'USER'
    GROUP BY con_id
) s ON s.con_id = p.con_id
ORDER BY p.con_id
"""

_SQL_PDB_DG = """
SELECT p.con_id, p.name AS pdb_name, p.open_mode, p.restricted,
    p.recovery_status, p.logging, p.application_root,
    s.protection_mode, s.database_role,
    ds.name AS dg_stat_name, ds.value AS dg_stat_value, ds.unit
FROM v$pdbs p
CROSS JOIN v$database s
LEFT JOIN v$dataguard_stats ds ON 1=1
ORDER BY p.con_id, ds.name
"""

_SQL_PDB_TS = """
SELECT * FROM (
    SELECT
        t.con_id,
        t.tablespace_name,
        ROUND(NVL(d.bytes_alloc, 0) / 1048576, 1)                        AS total_mb,
        ROUND(NVL(d.bytes_alloc - NVL(f.bytes_free, 0), 0) / 1048576, 1) AS used_mb,
        ROUND((NVL(d.bytes_alloc - NVL(f.bytes_free, 0), 0)) /
              NULLIF(d.bytes_alloc, 0) * 100, 1)                         AS used_pct
    FROM cdb_tablespaces t
    LEFT JOIN (
        SELECT con_id, tablespace_name, SUM(bytes) AS bytes_alloc
        FROM cdb_data_files
        GROUP BY con_id, tablespace_name
    ) d ON d.con_id = t.con_id AND d.tablespace_name = t.tablespace_name
    LEFT JOIN (
        SELECT con_id, tablespace_name, SUM(bytes) AS bytes_free
        FROM cdb_free_space
        GROUP BY con_id, tablespace_name
    ) f ON f.con_id = t.con_id AND f.tablespace_name = t.tablespace_name
    WHERE t.con_id > 2
    ORDER BY t.con_id, used_pct DESC NULLS LAST
)
WHERE ROWNUM <= 100
"""


class PDBCollector(BaseCollector):

    _is_cdb: bool | None = None

    async def collect(self) -> None:
        if self._is_cdb is None:
            row = await self.conn.fetch_one(_SQL_DETECT)
            self._is_cdb = (row or {}).get("cdb", "NO") == "YES"
            self.cache.set("pdb.detected", self._is_cdb, ttl=300)

        if not self._is_cdb:
            return

        pdbs = await self.conn.execute_query(_SQL_PDBS)
        self.cache.set("pdb.list", pdbs or [], ttl=self.interval + 2)

        ts = await self.conn.execute_query(_SQL_PDB_TS)
        self.cache.set("pdb.tablespaces", ts or [], ttl=60)

        dg_status = await self.conn.execute_query(_SQL_PDB_DG)
        self.cache.set("pdb.dg_status", dg_status or [], ttl=60)

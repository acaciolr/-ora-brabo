"""
collectors/plan_hist.py
Plan History — detects SQL with plan instability (more than one plan_hash_value),
plus the current adaptive-plan optimizer parameters and whether AWR (Diagnostics
Pack) is reachable. Per-sql_id plan history and plan trees are fetched on demand
by the panel; this collector only feeds the top-level list + header.

Cache keys:
    planhist.unstable   list[dict]  — SQLs with >1 plan (from GV$SQL, no license)
    planhist.adaptive   dict|None   — adaptive optimizer params (12c+); None if <12c
    planhist.awr_ok     bool        — True when DBA_HIST_* is readable (Diagnostics Pack)
"""
from __future__ import annotations

from collectors.base import BaseCollector

# SQLs with more than one plan currently in the shared pool. GV$SQL needs no
# Diagnostics Pack licence, so the top-level list always works. current_phv is
# the plan of the most recently active child cursor.
_SQL_UNSTABLE = """
SELECT * FROM (
    SELECT sql_id,
           MAX(parsing_schema_name)                    AS schema_name,
           COUNT(DISTINCT plan_hash_value)             AS plans,
           SUM(executions)                             AS execs,
           MAX(plan_hash_value) KEEP (DENSE_RANK LAST
               ORDER BY last_active_time)              AS current_phv,
           MAX(is_resolved_adaptive_plan)              AS adaptive,
           SUBSTR(MAX(sql_text), 1, 140)               AS sql_text
    FROM gv$sql
    WHERE plan_hash_value > 0
      AND parsing_schema_name NOT IN
          ('SYS','SYSTEM','DBSNMP','SYSMAN','XDB','OUTLN','ORACLE_OCM','GSMADMIN_INTERNAL')
    GROUP BY sql_id
    HAVING COUNT(DISTINCT plan_hash_value) > 1
    ORDER BY SUM(executions) DESC
) WHERE ROWNUM <= 50
"""

# Adaptive-plan optimizer parameters. On 11g the optimizer_adaptive_* names do
# not exist, so only optimizer_features_enable comes back — that is fine.
_SQL_ADAPTIVE = """
SELECT LOWER(name) AS name, value
FROM v$parameter
WHERE name IN ('optimizer_adaptive_plans',
               'optimizer_adaptive_statistics',
               'optimizer_adaptive_reporting_only',
               'optimizer_adaptive_features',
               'optimizer_features_enable')
"""

# Cheap probe for Diagnostics Pack / AWR availability.
_SQL_AWR_PROBE = "SELECT 1 AS ok FROM dba_hist_sqlstat WHERE ROWNUM = 1"


class PlanHistCollector(BaseCollector):

    async def collect(self) -> None:
        ttl = self.interval + 5

        rows = await self.conn.execute_query(_SQL_UNSTABLE)
        self.cache.set("planhist.unstable", rows, ttl=ttl)

        params = await self.conn.execute_query(_SQL_ADAPTIVE)
        adaptive = {r.get("name"): r.get("value") for r in (params or [])}
        # If none of the adaptive-specific params exist, the DB is < 12c.
        has_adaptive = any(k.startswith("optimizer_adaptive") for k in adaptive)
        self.cache.set("planhist.adaptive", adaptive if has_adaptive else None, ttl=86400)

        # AWR reachable? execute_query returns [] on ORA- (e.g. no licence).
        probe = await self.conn.execute_query(_SQL_AWR_PROBE)
        self.cache.set("planhist.awr_ok", bool(probe), ttl=300)

"""
collectors/jobs.py
Oracle jobs monitor — DBMS_SCHEDULER + legacy DBMS_JOB, business/DBA jobs only
(Oracle-maintained schemas are excluded). Feeds counts, a per-day success/fail
history for charts, the job list, currently-running jobs and upcoming runs.
Per-job run history is fetched on demand by the panel.

Cache keys:
    jobs.summary   dict        — totals (jobs, running, failed_24h, disabled, dbms_job)
    jobs.list      list[dict]  — unified scheduler + dbms_job list
    jobs.running   list[dict]  — running now
    jobs.upcoming  list[dict]  — next runs by next_run_date
    jobs.daily     list[dict]  — per day: ok / failed / avg_dur_s (last 14 days)
"""
from __future__ import annotations

from collectors.base import BaseCollector

# Oracle-maintained schemas to exclude — we only want business / DBA jobs.
_EXCL = (
    "'SYS','SYSTEM','DBSNMP','SYSMAN','ORACLE_OCM','XDB','WMSYS','CTXSYS','MDSYS',"
    "'EXFSYS','OLAPSYS','ORDDATA','ORDSYS','GSMADMIN_INTERNAL','AUDSYS','DVSYS',"
    "'LBACSYS','OJVMSYS','APEX_PUBLIC_USER','FLOWS_FILES','APPQOSSYS','DBSFWUSER',"
    "'REMOTE_SCHEDULER_AGENT','GGSYS','ANONYMOUS','OUTLN','SI_INFORMTN_SCHEMA'"
)

_SQL_SCHED = f"""
SELECT owner, job_name, job_style, state, enabled,
       CAST(last_start_date AS TIMESTAMP) AS last_start_date,
       run_count, failure_count,
       CAST(next_run_date AS TIMESTAMP)  AS next_run_date,
       schedule_type, SUBSTR(comments,1,60) AS comments
FROM dba_scheduler_jobs
WHERE owner NOT IN ({_EXCL})
  AND job_name NOT LIKE 'ORA$%'
ORDER BY failure_count DESC, next_run_date
"""

_SQL_DBMS_JOB = f"""
SELECT schema_user AS owner, job AS job_no,
       CAST(last_date AS TIMESTAMP) AS last_date,
       CAST(next_date AS TIMESTAMP) AS next_date,
       failures, broken, SUBSTR(what,1,60) AS what
FROM dba_jobs
WHERE schema_user NOT IN ({_EXCL})
"""

_SQL_RUNNING = f"""
SELECT owner, job_name, CAST(start_date AS TIMESTAMP) AS start_date,
       elapsed_time, session_id, running_instance
FROM dba_scheduler_running_jobs
WHERE owner NOT IN ({_EXCL})
ORDER BY start_date
"""

_SQL_UPCOMING = f"""
SELECT * FROM (
    SELECT owner, job_name, CAST(next_run_date AS TIMESTAMP) AS next_run_date,
           schedule_type, state
    FROM dba_scheduler_jobs
    WHERE owner NOT IN ({_EXCL}) AND job_name NOT LIKE 'ORA$%'
      AND enabled = 'TRUE' AND next_run_date IS NOT NULL
    ORDER BY next_run_date
) WHERE ROWNUM <= 20
"""

_DUR_SECS = ("EXTRACT(DAY FROM run_duration)*86400 + EXTRACT(HOUR FROM run_duration)*3600 "
             "+ EXTRACT(MINUTE FROM run_duration)*60 + EXTRACT(SECOND FROM run_duration)")

_SQL_DAILY = f"""
SELECT TO_CHAR(TRUNC(actual_start_date),'DD/MM') AS day,
       SUM(CASE WHEN status='SUCCEEDED' THEN 1 ELSE 0 END) AS ok,
       SUM(CASE WHEN status<>'SUCCEEDED' THEN 1 ELSE 0 END) AS failed,
       COUNT(*) AS total,
       ROUND(AVG({_DUR_SECS})) AS avg_dur_s
FROM dba_scheduler_job_run_details
WHERE actual_start_date >= TRUNC(SYSDATE) - 14
  AND owner NOT IN ({_EXCL})
GROUP BY TRUNC(actual_start_date)
ORDER BY TRUNC(actual_start_date)
"""

_SQL_FAILED_24H = f"""
SELECT COUNT(*) AS c FROM dba_scheduler_job_run_details
WHERE actual_start_date >= SYSDATE - 1 AND status <> 'SUCCEEDED'
  AND owner NOT IN ({_EXCL})
"""


class JobsCollector(BaseCollector):

    async def collect(self) -> None:
        ttl = self.interval + 5

        sched = await self.conn.execute_query(_SQL_SCHED)
        legacy = await self.conn.execute_query(_SQL_DBMS_JOB)

        # Unified list: scheduler jobs + legacy dbms_job in one shape.
        unified: list[dict] = []
        for j in sched:
            unified.append({
                "type": "SCHEDULER", "owner": j.get("owner"), "name": j.get("job_name"),
                "state": j.get("state"), "enabled": j.get("enabled"),
                "last_start": j.get("last_start_date"), "run_count": j.get("run_count"),
                "failures": j.get("failure_count"), "next_run": j.get("next_run_date"),
                "detail": j.get("comments") or j.get("schedule_type"),
            })
        for j in legacy:
            unified.append({
                "type": "DBMS_JOB", "owner": j.get("owner"), "name": f"JOB#{j.get('job_no')}",
                "state": "BROKEN" if str(j.get("broken")) == "Y" else "SCHEDULED",
                "enabled": "FALSE" if str(j.get("broken")) == "Y" else "TRUE",
                "last_start": j.get("last_date"), "run_count": None,
                "failures": j.get("failures"), "next_run": j.get("next_date"),
                "detail": j.get("what"),
            })
        self.cache.set("jobs.list", unified, ttl=ttl)

        running = await self.conn.execute_query(_SQL_RUNNING)
        self.cache.set("jobs.running", running, ttl=ttl)
        self.cache.set("jobs.upcoming", await self.conn.execute_query(_SQL_UPCOMING), ttl=ttl)
        self.cache.set("jobs.daily", await self.conn.execute_query(_SQL_DAILY), ttl=ttl)

        f24 = await self.conn.fetch_one(_SQL_FAILED_24H)
        disabled = sum(1 for j in unified if str(j.get("enabled")).upper() == "FALSE")
        self.cache.set("jobs.summary", {
            "total": len(unified),
            "scheduler": len(sched),
            "dbms_job": len(legacy),
            "running": len(running),
            "failed_24h": int((f24 or {}).get("c", 0) or 0),
            "disabled": disabled,
        }, ttl=ttl)

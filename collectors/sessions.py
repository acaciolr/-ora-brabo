"""
collectors/sessions.py
Active and all user sessions from GV$SESSION.
Cache key: sessions.list
"""

from __future__ import annotations

from collectors.base import BaseCollector

_SQL_LOCK_BLOCKERS = """
SELECT
    l1.sid,
    l1.id1,
    l1.id2,
    l1.type                                             AS lock_type,
    MAX(l2.ctime)                                       AS ctime_secs,
    MAX(s.username)                                     AS username,
    MAX(s.status)                                       AS status,
    MAX(s.osuser)                                       AS osuser,
    MAX(s.machine)                                      AS machine,
    MAX(s.program)                                      AS program,
    MAX(s.serial#)                                      AS serial_num,
    MAX(i.instance_name)                                AS instance_name,
    MAX(i.host_name)                                    AS host_name,
    MAX(s.sql_id)                                       AS sql_id,
    MAX(s.inst_id)                                      AS inst_id,
    MAX(s.sql_hash_value)                               AS sql_hash_value,
    MAX(p.spid)                                         AS os_pid
FROM gv$lock l1
JOIN gv$lock l2    ON l1.id1 = l2.id1 AND l1.id2 = l2.id2 AND l2.block = 0
JOIN gv$session s  ON l1.sid = s.sid AND l1.inst_id = s.inst_id
JOIN gv$instance i ON s.inst_id = i.inst_id
LEFT JOIN gv$process p ON s.paddr = p.addr AND s.inst_id = p.inst_id
WHERE l1.block > 0
  AND s.username IS NOT NULL
GROUP BY l1.sid, l1.id1, l1.id2, l1.type
ORDER BY MAX(l2.ctime) ASC
"""

_SQL_LOCK_WAITERS = """
SELECT
    s.inst_id,
    s.sid          AS waiter_sid,
    s.serial#      AS waiter_serial,
    s.sql_id       AS waiter_sql_id,
    l.type         AS lock_type,
    s.username     AS waiter_username,
    s.osuser       AS waiter_osuser,
    l.id1,
    l.id2
FROM gv$session s
JOIN gv$lock l ON s.sid = l.sid AND s.inst_id = l.inst_id
WHERE l.request > 0
ORDER BY l.id1, l.id2, s.sid
"""

_SQL_LOCK_OBJECTS = """
SELECT
    l.session_id AS sid,
    l.inst_id,
    o.object_name,
    o.owner,
    o.object_type,
    DECODE(l.locked_mode,
           0, 'None',
           1, 'Null (NULL)',
           2, 'Row-S (SS)',
           3, 'Row-X (SX)',
           4, 'Share (S)',
           5, 'S/Row-X (SSX)',
           6, 'Exclusive (X)',
           TO_CHAR(l.locked_mode)) AS lock_mode_desc,
    l.locked_mode
FROM gv$locked_object l
JOIN dba_objects o ON l.object_id = o.object_id
ORDER BY l.session_id, o.object_type, o.object_name
"""

_SQL = """
SELECT
    s.inst_id,
    s.sid,
    s.serial#           AS serial,
    s.username,
    s.machine,
    s.module,
    s.action,
    s.event,
    s.wait_class,
    s.sql_id,
    s.status,
    s.blocking_session,
    s.blocking_instance,
    s.seconds_in_wait,
    s.state,
    s.program,
    s.osuser,
    s.logon_time,
    s.last_call_et,
    s.row_wait_obj#     AS row_wait_obj,
    s.p1text,
    s.p1,
    s.p2text,
    s.p2
FROM gv$session s
WHERE s.type = 'USER'
  AND s.username IS NOT NULL
ORDER BY
    s.status DESC,
    s.last_call_et DESC
"""


class SessionsCollector(BaseCollector):

    async def collect(self) -> None:
        rows = await self.conn.execute_query(_SQL)
        self.cache.set("sessions.list", rows, ttl=self.interval + 2)
        self.cache.set(
            "sessions.active_count",
            sum(1 for r in rows if r["status"] == "ACTIVE"),
            ttl=self.interval + 2,
        )
        self.cache.set("sessions.total_count", len(rows), ttl=self.interval + 2)

        # Lock detail queries (for LocksPanel redesign)
        blockers = await self.conn.execute_query(_SQL_LOCK_BLOCKERS)
        self.cache.set("locks.blockers", blockers, ttl=self.interval + 2)

        waiters = await self.conn.execute_query(_SQL_LOCK_WAITERS)
        self.cache.set("locks.waiters", waiters, ttl=self.interval + 2)

        lock_objs = await self.conn.execute_query(_SQL_LOCK_OBJECTS)
        self.cache.set("locks.objects", lock_objs, ttl=self.interval + 2)

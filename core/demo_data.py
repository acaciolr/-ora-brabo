"""
core/demo_data.py
Live demo mode: populates MetricsCache with realistic fake Oracle data.
Values fluctuate every tick to simulate real monitoring activity.
No Oracle database required.
"""
from __future__ import annotations

import asyncio
import logging
import math
import random
from datetime import datetime, timedelta

from core.cache import MetricsCache

log = logging.getLogger(__name__)

# ── Stable reference data (doesn't change between ticks) ─────────────

_DB_INFO = {
    "db_name":        "ORCL",
    "dbid":           "1423756891",
    "db_unique_name": "ORCL_PRIMARY",
    "version":        "19.19.0.0.0",
    "host_name":      "oraserver01.brabolab.local",
    "instance_name":  "ORCL1",
    "open_mode":      "READ WRITE",
    "database_role":  "PRIMARY",
    "cdb":            "YES",
    "flashback_on":   "YES",
    "log_mode":       "ARCHIVELOG",
    "startup_time":   datetime.now() - timedelta(days=14, hours=3, minutes=22),
    "inst_status":    "ACTIVE",
}

_TABLESPACES = [
    {"tablespace_name": "SYSTEM",   "total_mb": 1024,  "used_mb": 876,  "free_mb": 148,  "pct_used": 85.5, "status": "ONLINE", "autoextensible": "YES"},
    {"tablespace_name": "SYSAUX",   "total_mb": 2048,  "used_mb": 1432, "free_mb": 616,  "pct_used": 69.9, "status": "ONLINE", "autoextensible": "YES"},
    {"tablespace_name": "USERS",    "total_mb": 8192,  "used_mb": 5120, "free_mb": 3072, "pct_used": 62.5, "status": "ONLINE", "autoextensible": "YES"},
    {"tablespace_name": "UNDOTBS1", "total_mb": 4096,  "used_mb": 1280, "free_mb": 2816, "pct_used": 31.3, "status": "ONLINE", "autoextensible": "YES"},
    {"tablespace_name": "TEMP",     "total_mb": 2048,  "used_mb": 512,  "free_mb": 1536, "pct_used": 25.0, "status": "ONLINE", "autoextensible": "YES"},
    {"tablespace_name": "APP_DATA", "total_mb": 51200, "used_mb": 44032,"free_mb": 7168, "pct_used": 86.0, "status": "ONLINE", "autoextensible": "NO"},
    {"tablespace_name": "APP_IDX",  "total_mb": 20480, "used_mb": 15360,"free_mb": 5120, "pct_used": 75.0, "status": "ONLINE", "autoextensible": "NO"},
    {"tablespace_name": "ARCHIVE",  "total_mb": 10240, "used_mb": 9830, "free_mb": 410,  "pct_used": 96.0, "status": "ONLINE", "autoextensible": "NO"},
]

_RAC_INSTANCES = [
    {"inst_id": 1, "instance_name": "ORCL1", "host_name": "oraserver01", "status": "OPEN",
     "total_sessions": 0, "active_sessions": 0},
    {"inst_id": 2, "instance_name": "ORCL2", "host_name": "oraserver02", "status": "OPEN",
     "total_sessions": 0, "active_sessions": 0},
]

_DG_PROCESSES = [
    {"process": "MRP0",  "status": "APPLYING_LOG", "sequence": 8841, "block": 512,  "delay_mins": 0},
    {"process": "RFS",   "status": "RECEIVING",    "sequence": 8842, "block": 0,    "delay_mins": 0},
    {"process": "ARCH",  "status": "CONNECTED",    "sequence": 8840, "block": 1024, "delay_mins": 0},
]

_ASM_DISKGROUPS = [
    {"name": "DATA",    "state": "MOUNTED", "type": "NORMAL", "total_mb": 204800, "free_mb": 81920,
     "usable_file_mb": 40960, "pct_used": 60.0, "num_disks": 6},
    {"name": "FRA",     "state": "MOUNTED", "type": "NORMAL", "total_mb": 102400, "free_mb": 18432,
     "usable_file_mb": 9216,  "pct_used": 82.0, "num_disks": 4},
    {"name": "RECO",    "state": "MOUNTED", "type": "EXTERNAL","total_mb": 51200,  "free_mb": 25600,
     "usable_file_mb": 25600, "pct_used": 50.0, "num_disks": 2},
]

_RMAN_HISTORY = [
    {"operation": "BACKUP",         "status": "COMPLETED", "input_type": "DB FULL",       "start_time": datetime.now()-timedelta(hours=8),   "end_time": datetime.now()-timedelta(hours=5,minutes=12), "elapsed_seconds": 10680, "input_mb": 44800.0, "output_mb": 18200.0, "time_taken_display": "02:58:00", "compression_ratio": 2.46},
    {"operation": "BACKUP",         "status": "COMPLETED", "input_type": "ARCHIVELOG",     "start_time": datetime.now()-timedelta(hours=2),   "end_time": datetime.now()-timedelta(hours=1,minutes=48), "elapsed_seconds":   720, "input_mb":  1240.0, "output_mb":   610.0, "time_taken_display": "00:12:00", "compression_ratio": 2.03},
    {"operation": "BACKUP",         "status": "COMPLETED", "input_type": "DB INCR LEVEL 1","start_time": datetime.now()-timedelta(days=1),    "end_time": datetime.now()-timedelta(hours=22),           "elapsed_seconds":  3600, "input_mb":  8192.0, "output_mb":  3200.0, "time_taken_display": "01:00:00", "compression_ratio": 2.56},
    {"operation": "VALIDATE",       "status": "COMPLETED", "input_type": "DB FULL",        "start_time": datetime.now()-timedelta(days=2),    "end_time": datetime.now()-timedelta(days=1,hours=21),    "elapsed_seconds":  9000, "input_mb": 44800.0, "output_mb":     0.0, "time_taken_display": "02:30:00", "compression_ratio": 0},
    {"operation": "BACKUP",         "status": "FAILED",    "input_type": "ARCHIVELOG",     "start_time": datetime.now()-timedelta(days=3),    "end_time": datetime.now()-timedelta(days=2,hours=23,minutes=55), "elapsed_seconds": 300, "input_mb": 0.0, "output_mb": 0.0, "time_taken_display": "00:05:00", "compression_ratio": 0},
]

_TOP_SQL = [
    {"sql_id": "3yru4fqvqpzwm", "executions": 18420, "elapsed_secs": 4821.3, "cpu_secs": 4610.2,
     "buffer_gets": 92840000, "disk_reads": 18400, "rows_processed": 1842000,
     "avg_elapsed_ms": 261.7, "cpu_pct": 41.2,
     "sql_text": "SELECT C.CUSTOMER_ID, C.NAME, SUM(O.AMOUNT) FROM CUSTOMERS C JOIN ORDERS O ON C.ID = O.CUST_ID WHERE O.STATUS = 'PENDING' GROUP BY C.CUSTOMER_ID, C.NAME ORDER BY 3 DESC"},
    {"sql_id": "8fkg2hzmdq1wx", "executions": 284100, "elapsed_secs": 1923.7, "cpu_secs": 1812.4,
     "buffer_gets": 56820000, "disk_reads": 2100, "rows_processed": 28410000,
     "avg_elapsed_ms": 6.8, "cpu_pct": 16.3,
     "sql_text": "UPDATE ORDERS SET STATUS = :1, UPDATED_AT = SYSDATE WHERE ORDER_ID = :2"},
    {"sql_id": "g7z1nkpq9r4ty", "executions": 92300, "elapsed_secs": 1654.1, "cpu_secs": 512.3,
     "buffer_gets": 34100000, "disk_reads": 98400, "rows_processed": 923000,
     "avg_elapsed_ms": 17.9, "cpu_pct": 14.8,
     "sql_text": "SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME > :1 AND DBID = :2"},
    {"sql_id": "2mx8vbwqc5pla", "executions": 1240, "elapsed_secs": 987.2, "cpu_secs": 880.1,
     "buffer_gets": 12480000, "disk_reads": 48200, "rows_processed": 124000,
     "avg_elapsed_ms": 796.1, "cpu_pct": 8.9,
     "sql_text": "SELECT /*+ FULL(T) PARALLEL(T,8) */ COUNT(*), SUM(AMOUNT) FROM TRANSACTIONS T WHERE TXN_DATE BETWEEN :1 AND :2"},
    {"sql_id": "5hnqzxpj7m2wv", "executions": 48200, "elapsed_secs": 722.4, "cpu_secs": 698.3,
     "buffer_gets": 9640000, "disk_reads": 420, "rows_processed": 4820000,
     "avg_elapsed_ms": 15.0, "cpu_pct": 6.5,
     "sql_text": "INSERT INTO AUDIT_LOG (USER_ID, ACTION, TS, DETAIL) VALUES (:1,:2,SYSTIMESTAMP,:3)"},
]

_WAITS_TOP = [
    {"event": "db file sequential read",   "total_waits": 0, "time_waited_secs": 0, "avg_wait_ms": 3.2,  "wait_class": "User I/O"},
    {"event": "log file sync",             "total_waits": 0, "time_waited_secs": 0, "avg_wait_ms": 1.8,  "wait_class": "Commit"},
    {"event": "buffer busy waits",         "total_waits": 0, "time_waited_secs": 0, "avg_wait_ms": 12.4, "wait_class": "Concurrency"},
    {"event": "db file parallel read",     "total_waits": 0, "time_waited_secs": 0, "avg_wait_ms": 8.1,  "wait_class": "User I/O"},
    {"event": "latch: shared pool",        "total_waits": 0, "time_waited_secs": 0, "avg_wait_ms": 0.9,  "wait_class": "Concurrency"},
    {"event": "gc buffer busy acquire",    "total_waits": 0, "time_waited_secs": 0, "avg_wait_ms": 5.2,  "wait_class": "Cluster"},
    {"event": "enq: TX - row lock contention","total_waits":0,"time_waited_secs":0, "avg_wait_ms": 420.0,"wait_class": "Application"},
    {"event": "SQL*Net message from client","total_waits": 0, "time_waited_secs": 0, "avg_wait_ms": 0.3,  "wait_class": "Idle"},
]

_SESSIONS_BASE = [
    {"sid": 112, "serial": 4821, "username": "APP_USER",   "status": "ACTIVE",  "osuser": "appsvr01", "machine": "appserver01", "program": "JDBC Thin Client", "sql_id": "3yru4fqvqpzwm", "wait_event": "db file sequential read", "wait_class": "User I/O",    "blocking_session": None, "logon_time": datetime.now()-timedelta(hours=2),  "last_call_et": 0},
    {"sid": 234, "serial": 1293, "username": "APP_USER",   "status": "ACTIVE",  "osuser": "appsvr02", "machine": "appserver02", "program": "JDBC Thin Client", "sql_id": "8fkg2hzmdq1wx", "wait_event": "log file sync",             "wait_class": "Commit",       "blocking_session": None, "logon_time": datetime.now()-timedelta(hours=1),  "last_call_et": 0},
    {"sid": 89,  "serial": 7712, "username": "BATCH_USR",  "status": "ACTIVE",  "osuser": "oracle",   "machine": "oraserver01", "program": "python@batch01",   "sql_id": "2mx8vbwqc5pla", "wait_event": "db file parallel read",     "wait_class": "User I/O",    "blocking_session": None, "logon_time": datetime.now()-timedelta(hours=6),  "last_call_et": 0},
    {"sid": 341, "serial": 9921, "username": "APP_USER",   "status": "ACTIVE",  "osuser": "appsvr01", "machine": "appserver01", "program": "JDBC Thin Client", "sql_id": "8fkg2hzmdq1wx", "wait_event": "enq: TX - row lock contention","wait_class":"Application","blocking_session": 112,  "logon_time": datetime.now()-timedelta(minutes=30),"last_call_et": 0},
    {"sid": 156, "serial": 3344, "username": "DBA_MONITOR","status": "ACTIVE",  "osuser": "acaciolr", "machine": "MacBook-Pro",  "program": "ORA BRABO",        "sql_id": "g7z1nkpq9r4ty", "wait_event": "SQL*Net message from client","wait_class": "Idle",        "blocking_session": None, "logon_time": datetime.now()-timedelta(minutes=5),  "last_call_et": 0},
    {"sid": 44,  "serial": 182,  "username": "SYS",        "status": "ACTIVE",  "osuser": "oracle",   "machine": "oraserver01", "program": "oracle@oraserver01","sql_id": None,            "wait_event": "pmon timer",                "wait_class": "Idle",        "blocking_session": None, "logon_time": datetime.now()-timedelta(days=14),    "last_call_et": 0},
    {"sid": 55,  "serial": 290,  "username": "SYS",        "status": "ACTIVE",  "osuser": "oracle",   "machine": "oraserver01", "program": "oracle@oraserver01","sql_id": None,            "wait_event": "smon timer",                "wait_class": "Idle",        "blocking_session": None, "logon_time": datetime.now()-timedelta(days=14),    "last_call_et": 0},
]

_EXA_CELLS = [
    {"cell_name": "exa-cell-01.brabolab.local", "ip_address": "192.168.10.11",
     "interconnect_ip": "192.168.20.11", "cell_status": "online", "cell_version": "19.3.0.0.0"},
    {"cell_name": "exa-cell-02.brabolab.local", "ip_address": "192.168.10.12",
     "interconnect_ip": "192.168.20.12", "cell_status": "online", "cell_version": "19.3.0.0.0"},
    {"cell_name": "exa-cell-03.brabolab.local", "ip_address": "192.168.10.13",
     "interconnect_ip": "192.168.20.13", "cell_status": "online", "cell_version": "19.3.0.0.0"},
]

_RAC_INTERCONNECT = [
    {"inst_id": 1, "name": "ens3", "ip_address": "192.168.10.11", "is_public": "NO"},
    {"inst_id": 2, "name": "ens3", "ip_address": "192.168.10.12", "is_public": "NO"},
]

_ASM_LARGE_SEGMENTS = [
    {"owner": "APP_SCHEMA", "segment_name": "TRANSACTIONS",     "segment_type": "TABLE",          "tablespace_name": "APP_DATA", "mb": 18432.0},
    {"owner": "APP_SCHEMA", "segment_name": "ORDERS",           "segment_type": "TABLE",          "tablespace_name": "APP_DATA", "mb": 8192.0},
    {"owner": "APP_SCHEMA", "segment_name": "TRANSACTIONS_IDX", "segment_type": "INDEX",          "tablespace_name": "APP_IDX",  "mb": 4096.0},
    {"owner": "APP_SCHEMA", "segment_name": "ORDERS_PK",        "segment_type": "INDEX",          "tablespace_name": "APP_IDX",  "mb": 2048.0},
    {"owner": "APP_SCHEMA", "segment_name": "AUDIT_LOG",        "segment_type": "TABLE",          "tablespace_name": "APP_DATA", "mb": 1024.0},
    {"owner": "SYS",        "segment_name": "SYSAUX01",         "segment_type": "LOBSEGMENT",     "tablespace_name": "SYSAUX",   "mb": 820.0},
    {"owner": "APP_SCHEMA", "segment_name": "CUSTOMERS",        "segment_type": "TABLE",          "tablespace_name": "APP_DATA", "mb": 614.0},
    {"owner": "APP_SCHEMA", "segment_name": "ITEMS_LOB",        "segment_type": "LOBSEGMENT",     "tablespace_name": "APP_DATA", "mb": 512.0},
    {"owner": "APP_SCHEMA", "segment_name": "REPORT_CACHE",     "segment_type": "TABLE PARTITION","tablespace_name": "APP_DATA", "mb": 409.0},
    {"owner": "SYSTEM",     "segment_name": "AUD$",             "segment_type": "TABLE",          "tablespace_name": "SYSTEM",   "mb": 256.0},
]

_EXA_SQL_OFFLOAD = [
    {"sql_id": "3yru4fqvqpzwm", "sql_text": "SELECT C.CUSTOMER_ID, C.NAME, SUM(O.AMOUNT) FROM CUSTOMERS C JOIN ORDERS O",
     "executions": 18420, "eligible_gb": 42.8, "ib_gb": 3.8, "offload_pct": 91.2, "uncompressed_gb": 38.4, "schema_name": "APP_SCHEMA"},
    {"sql_id": "2mx8vbwqc5pla", "sql_text": "SELECT /*+ FULL(T) PARALLEL(T,8) */ COUNT(*), SUM(AMOUNT) FROM TRANSACTIONS T",
     "executions": 1240, "eligible_gb": 28.3, "ib_gb": 4.6, "offload_pct": 83.7, "uncompressed_gb": 24.1, "schema_name": "APP_SCHEMA"},
    {"sql_id": "g7z1nkpq9r4ty", "sql_text": "SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME > :1",
     "executions": 92300, "eligible_gb": 12.1, "ib_gb": 3.2, "offload_pct": 73.5, "uncompressed_gb": 10.8, "schema_name": "APP_SCHEMA"},
    {"sql_id": "8fkg2hzmdq1wx", "sql_text": "UPDATE ORDERS SET STATUS = :1, UPDATED_AT = SYSDATE WHERE ORDER_ID = :2",
     "executions": 284100, "eligible_gb": 6.4, "ib_gb": 2.1, "offload_pct": 67.2, "uncompressed_gb": 5.9, "schema_name": "APP_SCHEMA"},
    {"sql_id": "5hnqzxpj7m2wv", "sql_text": "INSERT INTO AUDIT_LOG (USER_ID, ACTION, TS, DETAIL) VALUES (:1,:2,SYSTIMESTAMP,:3)",
     "executions": 48200, "eligible_gb": 2.8, "ib_gb": 1.4, "offload_pct": 50.0, "uncompressed_gb": 2.5, "schema_name": "APP_SCHEMA"},
]

_EXA_CELL_WAITS = [
    {"event": "cell smart table scan",          "total_waits": 182400, "time_waited_secs": 312.4, "avg_wait_ms": 1.71, "wait_class": "User I/O"},
    {"event": "cell single block physical read","total_waits":  98300, "time_waited_secs": 187.2, "avg_wait_ms": 1.90, "wait_class": "User I/O"},
    {"event": "cell multiblock physical read",  "total_waits":  42100, "time_waited_secs":  98.4, "avg_wait_ms": 2.34, "wait_class": "User I/O"},
    {"event": "cell flash cache read hits",     "total_waits":  38400, "time_waited_secs":  21.8, "avg_wait_ms": 0.57, "wait_class": "User I/O"},
    {"event": "cell list of blocks physical read","total_waits": 12800, "time_waited_secs":  43.2, "avg_wait_ms": 3.38, "wait_class": "User I/O"},
    {"event": "cell physical IO interconnect bytes", "total_waits": 9200, "time_waited_secs": 31.6, "avg_wait_ms": 3.43, "wait_class": "User I/O"},
    {"event": "cell index scan",                "total_waits":  7400, "time_waited_secs":  12.8, "avg_wait_ms": 1.73, "wait_class": "User I/O"},
    {"event": "cell statistics gather",         "total_waits":  1240, "time_waited_secs":   4.2, "avg_wait_ms": 3.39, "wait_class": "User I/O"},
]

_EXA_HCC_OBJECTS = [
    {"owner": "APP_SCHEMA", "table_name": "TRANSACTIONS_ARCH", "compress_for": "ARCHIVE HIGH",  "num_rows": 4820000000, "size_mb": 12288.0, "last_analyzed": datetime.now()-timedelta(days=3)},
    {"owner": "APP_SCHEMA", "table_name": "ORDERS_HIST",       "compress_for": "QUERY HIGH",    "num_rows":  980000000, "size_mb":  4096.0, "last_analyzed": datetime.now()-timedelta(days=1)},
    {"owner": "APP_SCHEMA", "table_name": "AUDIT_LOG_ARCH",    "compress_for": "ARCHIVE LOW",   "num_rows": 2100000000, "size_mb":  3072.0, "last_analyzed": datetime.now()-timedelta(days=7)},
    {"owner": "APP_SCHEMA", "table_name": "CUSTOMERS_SNAP",    "compress_for": "QUERY LOW",     "num_rows":   84000000, "size_mb":  1024.0, "last_analyzed": datetime.now()-timedelta(days=2)},
    {"owner": "DWH",        "table_name": "FACT_SALES",        "compress_for": "QUERY HIGH",    "num_rows": 1480000000, "size_mb":  8192.0, "last_analyzed": datetime.now()-timedelta(days=1)},
    {"owner": "DWH",        "table_name": "FACT_EVENTS",       "compress_for": "ARCHIVE HIGH",  "num_rows":  620000000, "size_mb":  2560.0, "last_analyzed": datetime.now()-timedelta(days=4)},
]

_EXA_PARAMS = [
    {"name": "cell_offload_processing",           "value": "TRUE",    "description": "enable Exadata predicate offload processing"},
    {"name": "cell_offload_compaction",           "value": "ADAPTIVE","description": "compaction offload policy"},
    {"name": "cell_offload_decryption",           "value": "TRUE",    "description": "enable decryption in storage cells"},
    {"name": "cell_offload_parameters",           "value": "",        "description": "additional cell offload parameters"},
    {"name": "db_file_multiblock_read_count",     "value": "128",     "description": "db block to be read each IO"},
    {"name": "parallel_degree_policy",            "value": "AUTO",    "description": "policy used to compute the degree of parallelism"},
    {"name": "heat_map",                          "value": "ON",      "description": "enable heat map"},
    {"name": "inmemory_size",                     "value": "4294967296", "description": "size bytes of in-memory area"},
    {"name": "db_big_table_cache_percent_target", "value": "60",      "description": "cache percent target for big table"},
]

_PDBS = [
    {"con_id": 2, "name": "PDB$SEED",  "open_mode": "READ ONLY",  "restricted": "NO",
     "recovery_status": "DISABLED", "total_mb": 1024.0,  "active_sessions": 0, "total_sessions": 0,
     "creation_time": datetime(2022, 1, 15)},
    {"con_id": 3, "name": "APPDB",     "open_mode": "READ WRITE", "restricted": "NO",
     "recovery_status": "DISABLED", "total_mb": 51200.0, "active_sessions": 0, "total_sessions": 0,
     "creation_time": datetime(2022, 3, 1)},
    {"con_id": 4, "name": "REPORTDB",  "open_mode": "READ WRITE", "restricted": "NO",
     "recovery_status": "DISABLED", "total_mb": 20480.0, "active_sessions": 0, "total_sessions": 0,
     "creation_time": datetime(2022, 6, 15)},
    {"con_id": 5, "name": "DEVDB",     "open_mode": "MOUNTED",    "restricted": "NO",
     "recovery_status": "DISABLED", "total_mb": 8192.0,  "active_sessions": 0, "total_sessions": 0,
     "creation_time": datetime(2023, 1, 10)},
]

_PDB_TABLESPACES = [
    {"con_id": 3, "tablespace_name": "USERS",      "total_mb": 8192.0,  "used_mb": 5120.0,  "used_pct": 62.5},
    {"con_id": 3, "tablespace_name": "APP_DATA",   "total_mb": 30720.0, "used_mb": 26419.2, "used_pct": 86.0},
    {"con_id": 3, "tablespace_name": "APP_IDX",    "total_mb": 10240.0, "used_mb": 7168.0,  "used_pct": 70.0},
    {"con_id": 3, "tablespace_name": "TEMP",       "total_mb": 2048.0,  "used_mb": 512.0,   "used_pct": 25.0},
    {"con_id": 4, "tablespace_name": "USERS",      "total_mb": 4096.0,  "used_mb": 1024.0,  "used_pct": 25.0},
    {"con_id": 4, "tablespace_name": "REPORT_DATA","total_mb": 15360.0, "used_mb": 12288.0, "used_pct": 80.0},
    {"con_id": 5, "tablespace_name": "USERS",      "total_mb": 4096.0,  "used_mb": 2048.0,  "used_pct": 50.0},
    {"con_id": 5, "tablespace_name": "DEV_DATA",   "total_mb": 4096.0,  "used_mb": 3276.8,  "used_pct": 80.0},
]

_RAC_SERVICES = [
    {"name": "APP_SVC",      "network_name": "APP_SVC.brabolab.local",   "enabled": "YES", "goal": "LONG",  "clb_goal": "LONG",  "svc_status": "RUNNING", "inst_id": 1},
    {"name": "REPORT_SVC",   "network_name": "REPORT_SVC.brabolab.local","enabled": "YES", "goal": "SHORT", "clb_goal": "SHORT", "svc_status": "RUNNING", "inst_id": 2},
    {"name": "BATCH_SVC",    "network_name": "BATCH_SVC.brabolab.local", "enabled": "YES", "goal": "LONG",  "clb_goal": "LONG",  "svc_status": "STOPPED", "inst_id": None},
    {"name": "DWH_SVC",      "network_name": "DWH_SVC.brabolab.local",   "enabled": "YES", "goal": "LONG",  "clb_goal": "LONG",  "svc_status": "RUNNING", "inst_id": 1},
    {"name": "BACKUP_SVC",   "network_name": "BACKUP_SVC.brabolab.local","enabled": "NO",  "goal": "NONE",  "clb_goal": "NONE",  "svc_status": "STOPPED", "inst_id": None},
]

_AWR_TOP_SQL = [
    {"sql_id": "3yru4fqvqpzwm", "elapsed_secs": 4821.3, "cpu_secs": 4610.2, "executions": 18420, "buffer_gets": 92840000, "disk_reads": 18400, "cluster_wait_secs": 124.1, "sql_text": "SELECT C.CUSTOMER_ID, C.NAME, SUM(O.AMOUNT) FROM CUSTOMERS C JOIN ORDERS O ON C.ID=O.CUST_ID"},
    {"sql_id": "8fkg2hzmdq1wx", "elapsed_secs": 1923.7, "cpu_secs": 1812.4, "executions": 284100,"buffer_gets": 56820000, "disk_reads": 2100,  "cluster_wait_secs": 312.8, "sql_text": "UPDATE ORDERS SET STATUS = :1, UPDATED_AT = SYSDATE WHERE ORDER_ID = :2"},
    {"sql_id": "g7z1nkpq9r4ty", "elapsed_secs": 1654.1, "cpu_secs": 512.3,  "executions": 92300, "buffer_gets": 34100000, "disk_reads": 98400, "cluster_wait_secs": 18.4, "sql_text": "SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME > :1 AND DBID = :2"},
    {"sql_id": "2mx8vbwqc5pla", "elapsed_secs": 987.2,  "cpu_secs": 880.1,  "executions": 1240,  "buffer_gets": 12480000, "disk_reads": 48200, "cluster_wait_secs": 8.2,  "sql_text": "SELECT /*+ FULL(T) PARALLEL(T,8) */ COUNT(*), SUM(AMOUNT) FROM TRANSACTIONS T"},
    {"sql_id": "5hnqzxpj7m2wv", "elapsed_secs": 722.4,  "cpu_secs": 698.3,  "executions": 48200, "buffer_gets": 9640000,  "disk_reads": 420,   "cluster_wait_secs": 2.1,  "sql_text": "INSERT INTO AUDIT_LOG (USER_ID, ACTION, TS, DETAIL) VALUES (:1,:2,SYSTIMESTAMP,:3)"},
]

_AWR_TOP_WAITS = [
    {"event_name": "db file sequential read",      "total_waits": 182400, "time_waited_secs": 583.2, "avg_wait_ms": 3.20, "wait_class": "User I/O"},
    {"event_name": "log file sync",                "total_waits": 98300,  "time_waited_secs": 177.0, "avg_wait_ms": 1.80, "wait_class": "Commit"},
    {"event_name": "buffer busy waits",            "total_waits": 12400,  "time_waited_secs": 153.8, "avg_wait_ms": 12.4, "wait_class": "Concurrency"},
    {"event_name": "db file parallel read",        "total_waits": 7820,   "time_waited_secs": 63.4,  "avg_wait_ms": 8.10, "wait_class": "User I/O"},
    {"event_name": "enq: TX - row lock contention","total_waits": 340,    "time_waited_secs": 142.8, "avg_wait_ms": 420.0,"wait_class": "Application"},
    {"event_name": "gc buffer busy acquire",       "total_waits": 2180,   "time_waited_secs": 11.4,  "avg_wait_ms": 5.20, "wait_class": "Cluster"},
    {"event_name": "latch: shared pool",           "total_waits": 4210,   "time_waited_secs": 3.8,   "avg_wait_ms": 0.90, "wait_class": "Concurrency"},
]

_AWR_SYSSTAT = {
    "DB time":                      18432000000,
    "CPU used by this session":     15840000000,
    "physical read total bytes":    48234000000,
    "physical write total bytes":   12840000000,
    "redo size":                    21480000000,
    "user calls":                   3248000,
    "execute count":                18420000,
    "hard parses":                  4820,
    "parse time elapsed":           148000000,
    "sorts (disk)":                 240,
    "table scans (long tables)":    1842,
}

_ASM_DISKS = [
    # DATA diskgroup — 6 disks in 2 failgroups
    {"group_number": 1, "diskgroup_name": "DATA", "disk_number": 0, "disk_name": "DATA_0000",
     "path": "/dev/oracleasm/data01", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 35000, "free_mb": 14000, "used_pct": 60.0,
     "reads": 8421340, "writes": 4102983, "avg_read_ms": 1.12, "avg_write_ms": 0.98,
     "failgroup": "FG_A", "label": "DATA01"},
    {"group_number": 1, "diskgroup_name": "DATA", "disk_number": 1, "disk_name": "DATA_0001",
     "path": "/dev/oracleasm/data02", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 35000, "free_mb": 13800, "used_pct": 60.6,
     "reads": 8300120, "writes": 4050123, "avg_read_ms": 1.08, "avg_write_ms": 1.01,
     "failgroup": "FG_A", "label": "DATA02"},
    {"group_number": 1, "diskgroup_name": "DATA", "disk_number": 2, "disk_name": "DATA_0002",
     "path": "/dev/oracleasm/data03", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 35000, "free_mb": 14200, "used_pct": 59.4,
     "reads": 8150000, "writes": 3980000, "avg_read_ms": 1.15, "avg_write_ms": 0.95,
     "failgroup": "FG_B", "label": "DATA03"},
    {"group_number": 1, "diskgroup_name": "DATA", "disk_number": 3, "disk_name": "DATA_0003",
     "path": "/dev/oracleasm/data04", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 35000, "free_mb": 13600, "used_pct": 61.1,
     "reads": 7900000, "writes": 3850000, "avg_read_ms": 1.19, "avg_write_ms": 1.05,
     "failgroup": "FG_B", "label": "DATA04"},
    {"group_number": 1, "diskgroup_name": "DATA", "disk_number": 4, "disk_name": "DATA_0004",
     "path": "/dev/oracleasm/data05", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 32500, "free_mb": 13060, "used_pct": 59.8,
     "reads": 7650000, "writes": 3700000, "avg_read_ms": 1.10, "avg_write_ms": 0.92,
     "failgroup": "FG_A", "label": "DATA05"},
    {"group_number": 1, "diskgroup_name": "DATA", "disk_number": 5, "disk_name": "DATA_0005",
     "path": "/dev/oracleasm/data06", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 32300, "free_mb": 13260, "used_pct": 58.9,
     "reads": 7400000, "writes": 3600000, "avg_read_ms": 1.22, "avg_write_ms": 1.00,
     "failgroup": "FG_B", "label": "DATA06"},
    # FRA diskgroup — 4 disks
    {"group_number": 2, "diskgroup_name": "FRA", "disk_number": 0, "disk_name": "FRA_0000",
     "path": "/dev/oracleasm/fra01", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 26000, "free_mb": 4680, "used_pct": 82.0,
     "reads": 2100000, "writes": 9800000, "avg_read_ms": 0.88, "avg_write_ms": 1.20,
     "failgroup": "FG_A", "label": "FRA01"},
    {"group_number": 2, "diskgroup_name": "FRA", "disk_number": 1, "disk_name": "FRA_0001",
     "path": "/dev/oracleasm/fra02", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 26000, "free_mb": 4680, "used_pct": 82.0,
     "reads": 2050000, "writes": 9600000, "avg_read_ms": 0.91, "avg_write_ms": 1.18,
     "failgroup": "FG_B", "label": "FRA02"},
    {"group_number": 2, "diskgroup_name": "FRA", "disk_number": 2, "disk_name": "FRA_0002",
     "path": "/dev/oracleasm/fra03", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 25200, "free_mb": 4536, "used_pct": 82.0,
     "reads": 1980000, "writes": 9200000, "avg_read_ms": 0.92, "avg_write_ms": 1.22,
     "failgroup": "FG_A", "label": "FRA03"},
    {"group_number": 2, "diskgroup_name": "FRA", "disk_number": 3, "disk_name": "FRA_0003",
     "path": "/dev/oracleasm/fra04", "mode_status": "ONLINE", "state": "NORMAL",
     "header_status": "MEMBER", "total_mb": 25200, "free_mb": 4536, "used_pct": 82.0,
     "reads": 1900000, "writes": 8900000, "avg_read_ms": 0.90, "avg_write_ms": 1.19,
     "failgroup": "FG_B", "label": "FRA04"},
]

_DG_RAC_PROCESSES = [
    {"inst_id": 1, "process": "MRP0", "status": "APPLYING_LOG", "thread": 1, "sequence": 8841,
     "block": 512, "blocks": 1024, "delay_mins": 0},
    {"inst_id": 1, "process": "RFS",  "status": "RECEIVING",    "thread": 1, "sequence": 8842,
     "block": 0, "blocks": 0, "delay_mins": 0},
    {"inst_id": 1, "process": "ARCH", "status": "CONNECTED",    "thread": 1, "sequence": 8840,
     "block": 1024, "blocks": 2048, "delay_mins": 0},
    {"inst_id": 2, "process": "RFS",  "status": "RECEIVING",    "thread": 2, "sequence": 4421,
     "block": 0, "blocks": 0, "delay_mins": 0},
    {"inst_id": 2, "process": "ARCH", "status": "CONNECTED",    "thread": 2, "sequence": 4419,
     "block": 512, "blocks": 1024, "delay_mins": 0},
]

_LOCK_BLOCKERS = [
    {"sid": 112, "id1": 589723, "id2": 1, "lock_type": "TX",
     "ctime_secs": 187,
     "username": "APP_USER", "status": "ACTIVE",
     "osuser": "appsvr01", "machine": "appserver01.brabolab.local",
     "program": "JDBC Thin Client", "serial_num": 4821,
     "instance_name": "ORCL1", "host_name": "oraserver01",
     "sql_id": "3yru4fqvqpzwm", "inst_id": 1,
     "sql_hash_value": 3847291023, "os_pid": "18342"},
]

_LOCK_WAITERS = [
    {"inst_id": 1, "waiter_sid": 341, "waiter_serial": 9921, "waiter_sql_id": "8fkg2hzmdq1wx",
     "lock_type": "TX", "waiter_username": "APP_USER", "waiter_osuser": "appsvr01",
     "id1": 589723, "id2": 1},
    {"inst_id": 2, "waiter_sid": 502, "waiter_serial": 6112, "waiter_sql_id": "5hnqzxpj7m2wv",
     "lock_type": "TX", "waiter_username": "BATCH_USR", "waiter_osuser": "oracle",
     "id1": 589723, "id2": 1},
]

_LOCK_OBJECTS = [
    {"sid": 112, "inst_id": 1, "object_name": "ORDERS",        "owner": "APP_SCHEMA",
     "object_type": "TABLE", "lock_mode_desc": "Exclusive (X)", "locked_mode": 6},
    {"sid": 112, "inst_id": 1, "object_name": "ORDERS_IDX_PK", "owner": "APP_SCHEMA",
     "object_type": "INDEX", "lock_mode_desc": "Row-X (SX)",   "locked_mode": 3},
]

_IO_FILE_STATS = [
    {"file#": 1, "name": "/oradata/ORCL/datafile/system01.dbf",    "ts#": 0, "tablespace_name": "SYSTEM",   "phyrds": 482930, "phywrts": 84210,  "avg_read_ms": 1.82, "avg_write_ms": 0.94, "read_mb": 3772.9, "write_mb": 657.9},
    {"file#": 4, "name": "/oradata/ORCL/datafile/app_data01.dbf",  "ts#": 5, "tablespace_name": "APP_DATA",  "phyrds": 921840, "phywrts": 312400, "avg_read_ms": 2.41, "avg_write_ms": 1.12, "read_mb": 7202.0, "write_mb": 2440.6},
    {"file#": 5, "name": "/oradata/ORCL/datafile/app_data02.dbf",  "ts#": 5, "tablespace_name": "APP_DATA",  "phyrds": 874320, "phywrts": 298100, "avg_read_ms": 2.38, "avg_write_ms": 1.08, "read_mb": 6830.6, "write_mb": 2329.7},
    {"file#": 6, "name": "/oradata/ORCL/datafile/app_idx01.dbf",   "ts#": 6, "tablespace_name": "APP_IDX",   "phyrds": 643100, "phywrts": 121040, "avg_read_ms": 1.91, "avg_write_ms": 0.88, "read_mb": 5024.2, "write_mb": 945.6},
    {"file#": 2, "name": "/oradata/ORCL/datafile/sysaux01.dbf",    "ts#": 1, "tablespace_name": "SYSAUX",    "phyrds": 184200, "phywrts":  42100, "avg_read_ms": 1.44, "avg_write_ms": 0.72, "read_mb": 1439.1, "write_mb": 328.9},
]

_IO_FUNCTION_STATS = [
    {"function_name": "DBWR",          "large_read_reqs": 0,      "large_write_reqs": 724120, "small_read_reqs": 0,      "small_write_reqs": 0,      "avg_large_read_ms": None, "avg_small_read_ms": None, "total_read_mb": 0.0,    "total_write_mb": 5656.4},
    {"function_name": "LGWR",          "large_read_reqs": 0,      "large_write_reqs": 0,      "small_read_reqs": 0,      "small_write_reqs": 984210, "avg_large_read_ms": None, "avg_small_read_ms": None, "total_read_mb": 0.0,    "total_write_mb": 7688.4},
    {"function_name": "Archiver",      "large_read_reqs": 184200, "large_write_reqs": 0,      "small_read_reqs": 0,      "small_write_reqs": 0,      "avg_large_read_ms": 1.82, "avg_small_read_ms": None, "total_read_mb": 1439.1, "total_write_mb": 0.0},
    {"function_name": "Direct Read",   "large_read_reqs": 312840, "large_write_reqs": 0,      "small_read_reqs": 48200,  "small_write_reqs": 0,      "avg_large_read_ms": 8.42, "avg_small_read_ms": 2.11, "total_read_mb": 4879.4, "total_write_mb": 0.0},
    {"function_name": "SQL",           "large_read_reqs": 428100, "large_write_reqs": 98430,  "small_read_reqs": 924000, "small_write_reqs": 312000, "avg_large_read_ms": 3.21, "avg_small_read_ms": 1.42, "total_read_mb": 10504.7,"total_write_mb": 3209.6},
    {"function_name": "Buffer Cache Reads","large_read_reqs": 921840,"large_write_reqs": 0,   "small_read_reqs": 182400, "small_write_reqs": 0,      "avg_large_read_ms": 2.41, "avg_small_read_ms": 1.18, "total_read_mb": 8695.5, "total_write_mb": 0.0},
]

_IO_LOAD_PROFILE = [
    {"metric_name": "DB Time Per Sec",          "value": 2.31,    "metric_unit": "CentiSeconds Per Second"},
    {"metric_name": "CPU Usage Per Sec",        "value": 1.84,    "metric_unit": "CentiSeconds Per Second"},
    {"metric_name": "Redo Generated Per Sec",   "value": 536821.4,"metric_unit": "Bytes Per Second"},
    {"metric_name": "Logical Reads Per Sec",    "value": 45182.3, "metric_unit": "Reads Per Second"},
    {"metric_name": "Physical Reads Per Sec",   "value": 1842.6,  "metric_unit": "Reads Per Second"},
    {"metric_name": "Physical Writes Per Sec",  "value": 724.1,   "metric_unit": "Writes Per Second"},
    {"metric_name": "Hard Parses Per Sec",      "value": 12.4,    "metric_unit": "Parses Per Second"},
    {"metric_name": "Executions Per Sec",       "value": 3241.8,  "metric_unit": "Executions Per Second"},
    {"metric_name": "User Calls Per Sec",       "value": 8420.3,  "metric_unit": "Calls Per Second"},
    {"metric_name": "Transactions Per Sec",     "value": 284.1,   "metric_unit": "Transactions Per Second"},
    {"metric_name": "User Rollbacks Per Sec",   "value": 2.1,     "metric_unit": "Rollbacks Per Second"},
    {"metric_name": "DB Block Gets Per Sec",    "value": 12840.2, "metric_unit": "Block Gets Per Second"},
    {"metric_name": "Consistent Gets Per Sec",  "value": 32342.1, "metric_unit": "Block Gets Per Second"},
    {"metric_name": "User Commits Per Sec",     "value": 281.9,   "metric_unit": "Commits Per Second"},
]

_IO_REDO_LOGS = [
    {"group#": 1, "members": 2, "size_mb": 512.0, "status": "INACTIVE", "archived": "YES", "sequence#": 8840, "first_time": datetime.now() - timedelta(hours=4)},
    {"group#": 2, "members": 2, "size_mb": 512.0, "status": "ACTIVE",   "archived": "NO",  "sequence#": 8841, "first_time": datetime.now() - timedelta(hours=1)},
    {"group#": 3, "members": 2, "size_mb": 512.0, "status": "CURRENT",  "archived": "NO",  "sequence#": 8842, "first_time": datetime.now() - timedelta(minutes=12)},
]

_IO_REDO_LOG_FILES = [
    {"group#": 1, "member": "/oradata/ORCL/redo/redo01a.log", "status": None, "type": "ONLINE"},
    {"group#": 1, "member": "/oradata/ORCL_REDO2/redo01b.log", "status": None, "type": "ONLINE"},
    {"group#": 2, "member": "/oradata/ORCL/redo/redo02a.log", "status": None, "type": "ONLINE"},
    {"group#": 2, "member": "/oradata/ORCL_REDO2/redo02b.log", "status": None, "type": "ONLINE"},
    {"group#": 3, "member": "/oradata/ORCL/redo/redo03a.log", "status": None, "type": "ONLINE"},
    {"group#": 3, "member": "/oradata/ORCL_REDO2/redo03b.log", "status": None, "type": "ONLINE"},
]

_IO_REDO_SWITCHES = [
    {"hour_slot": (datetime.now() - timedelta(hours=i)).strftime("%Y-%m-%d %H"),
     "switches": [2, 1, 3, 2, 1, 2, 3, 5, 2, 1, 2, 1][i]}
    for i in range(12)
]

_IO_UNDO_STATS = [
    {"begin_time": datetime.now()-timedelta(minutes=30), "end_time": datetime.now()-timedelta(minutes=20), "undoblks": 4821, "txncount": 8420, "maxquerylen": 124, "maxconcurrency": 42, "ssolderrcnt": 0, "nospaceerrcnt": 0, "activeblks": 1240, "unexpiredblks": 3200},
    {"begin_time": datetime.now()-timedelta(minutes=40), "end_time": datetime.now()-timedelta(minutes=30), "undoblks": 3912, "txncount": 7820, "maxquerylen": 98,  "maxconcurrency": 38, "ssolderrcnt": 0, "nospaceerrcnt": 0, "activeblks": 980,  "unexpiredblks": 2840},
    {"begin_time": datetime.now()-timedelta(minutes=50), "end_time": datetime.now()-timedelta(minutes=40), "undoblks": 5241, "txncount": 9120, "maxquerylen": 156, "maxconcurrency": 51, "ssolderrcnt": 1, "nospaceerrcnt": 0, "activeblks": 1480, "unexpiredblks": 3580},
]

_IO_UNDO_EXTENTS = [
    {"status": "ACTIVE",    "ext_count": 284,  "total_mb": 1124.8},
    {"status": "EXPIRED",   "ext_count": 1842, "total_mb": 2048.0},
    {"status": "UNEXPIRED", "ext_count": 98,   "total_mb": 392.0},
]

_MEM_SGA_ADVICE = [
    {"sga_size": 8192,  "sga_size_factor": 0.5,  "estd_db_time": 18420.0, "estd_db_time_factor": 1.92, "estd_physical_reads": 98400},
    {"sga_size": 10240, "sga_size_factor": 0.625, "estd_db_time": 16100.0, "estd_db_time_factor": 1.68, "estd_physical_reads": 72800},
    {"sga_size": 12288, "sga_size_factor": 0.75,  "estd_db_time": 13200.0, "estd_db_time_factor": 1.38, "estd_physical_reads": 52400},
    {"sga_size": 14336, "sga_size_factor": 0.875, "estd_db_time": 11800.0, "estd_db_time_factor": 1.23, "estd_physical_reads": 38200},
    {"sga_size": 16384, "sga_size_factor": 1.0,   "estd_db_time":  9584.0, "estd_db_time_factor": 1.00, "estd_physical_reads": 24800},
    {"sga_size": 18432, "sga_size_factor": 1.125, "estd_db_time":  8920.0, "estd_db_time_factor": 0.93, "estd_physical_reads": 19400},
    {"sga_size": 20480, "sga_size_factor": 1.25,  "estd_db_time":  8640.0, "estd_db_time_factor": 0.90, "estd_physical_reads": 17200},
    {"sga_size": 24576, "sga_size_factor": 1.5,   "estd_db_time":  8480.0, "estd_db_time_factor": 0.88, "estd_physical_reads": 16100},
]

_MEM_PGA_ADVICE = [
    {"pga_target_mb": 1024,  "pga_target_factor": 0.25, "estd_hit_pct": 72.4, "estd_overalloc_count": 842},
    {"pga_target_mb": 2048,  "pga_target_factor": 0.5,  "estd_hit_pct": 84.2, "estd_overalloc_count": 312},
    {"pga_target_mb": 3072,  "pga_target_factor": 0.75, "estd_hit_pct": 90.8, "estd_overalloc_count": 84},
    {"pga_target_mb": 4096,  "pga_target_factor": 1.0,  "estd_hit_pct": 94.2, "estd_overalloc_count": 12},
    {"pga_target_mb": 6144,  "pga_target_factor": 1.5,  "estd_hit_pct": 97.1, "estd_overalloc_count": 0},
    {"pga_target_mb": 8192,  "pga_target_factor": 2.0,  "estd_hit_pct": 98.4, "estd_overalloc_count": 0},
    {"pga_target_mb": 12288, "pga_target_factor": 3.0,  "estd_hit_pct": 99.1, "estd_overalloc_count": 0},
    {"pga_target_mb": 16384, "pga_target_factor": 4.0,  "estd_hit_pct": 99.5, "estd_overalloc_count": 0},
]

_MEM_PGA_STATS = [
    {"name": "aggregate PGA target parameter",       "value": 4294967296},
    {"name": "aggregate PGA auto target",            "value": 3489660928},
    {"name": "global memory bound",                  "value": 107374182},
    {"name": "total PGA inuse",                      "value": 1842000000},
    {"name": "total PGA allocated",                  "value": 2148000000},
    {"name": "maximum PGA allocated",                "value": 3210000000},
    {"name": "total freeable PGA memory",            "value": 128000000},
    {"name": "PGA memory freed back to OS",          "value": 48000000},
    {"name": "total PGA used for auto workareas",    "value": 984000000},
    {"name": "over allocation count",                "value": 12},
    {"name": "bytes processed",                      "value": 184200000000},
    {"name": "extra bytes read/written",             "value": 0},
    {"name": "cache hit percentage",                 "value": 94.2},
    {"name": "recompute count (total)",              "value": 8420},
]

_MEM_BUFFER_POOL = [
    {"name": "DEFAULT", "block_size": 8192, "phys_read_mb": 1842.4, "phys_write_mb": 724.8,
     "logical_reads": 45182000, "hit_pct": 95.92, "free_buffer_wait": 0, "write_complete_wait": 0, "buffer_busy_wait": 124},
]

_MEM_DB_CACHE_ADVICE = [
    {"cache_size_mb": 2048,  "size_factor": 0.25, "estd_phys_read_factor": 2.84, "estd_physical_reads": 18420000},
    {"cache_size_mb": 4096,  "size_factor": 0.5,  "estd_phys_read_factor": 1.82, "estd_physical_reads": 11840000},
    {"cache_size_mb": 6144,  "size_factor": 0.75, "estd_phys_read_factor": 1.24, "estd_physical_reads": 8042000},
    {"cache_size_mb": 8192,  "size_factor": 1.0,  "estd_phys_read_factor": 1.00, "estd_physical_reads": 6490000},
    {"cache_size_mb": 10240, "size_factor": 1.25, "estd_phys_read_factor": 0.84, "estd_physical_reads": 5451000},
    {"cache_size_mb": 12288, "size_factor": 1.5,  "estd_phys_read_factor": 0.72, "estd_physical_reads": 4673000},
    {"cache_size_mb": 16384, "size_factor": 2.0,  "estd_phys_read_factor": 0.61, "estd_physical_reads": 3959000},
    {"cache_size_mb": 24576, "size_factor": 3.0,  "estd_phys_read_factor": 0.53, "estd_physical_reads": 3440000},
]

_MEM_RESIZE_OPS = [
    {"component": "DB Cache",       "oper_type": "GROW",   "oper_mode": "DEFERRED", "initial_mb": 6144.0, "target_mb": 8192.0, "final_mb": 8192.0, "status": "COMPLETE", "start_time": datetime.now()-timedelta(hours=2), "end_time": datetime.now()-timedelta(hours=2,minutes=-3), "duration_sec": 180.0},
    {"component": "Shared Pool",    "oper_type": "SHRINK", "oper_mode": "IMMEDIATE","initial_mb": 4096.0, "target_mb": 2048.0, "final_mb": 2048.0, "status": "COMPLETE", "start_time": datetime.now()-timedelta(hours=2), "end_time": datetime.now()-timedelta(hours=2,minutes=-1), "duration_sec": 62.4},
    {"component": "Large Pool",     "oper_type": "GROW",   "oper_mode": "DEFERRED", "initial_mb": 128.0,  "target_mb": 256.0,  "final_mb": 256.0,  "status": "COMPLETE", "start_time": datetime.now()-timedelta(hours=1), "end_time": datetime.now()-timedelta(hours=1,minutes=-1), "duration_sec": 42.1},
]

_MEM_LATCHES = [
    {"name": "cache buffers chains",       "gets": 924810000, "misses": 18420, "miss_pct": 0.0020, "sleeps": 4821, "spin_gets": 18240, "wait_ms": 142.4},
    {"name": "shared pool",               "gets": 184200000,  "misses": 4210,  "miss_pct": 0.0023, "sleeps": 1242, "spin_gets": 4198,  "wait_ms": 38.4},
    {"name": "library cache",             "gets": 248100000,  "misses": 2840,  "miss_pct": 0.0011, "sleeps": 842,  "spin_gets": 2831,  "wait_ms": 24.8},
    {"name": "row cache objects",         "gets": 82400000,   "misses": 1240,  "miss_pct": 0.0015, "sleeps": 312,  "spin_gets": 1232,  "wait_ms": 9.8},
    {"name": "undo global data",          "gets": 48200000,   "misses": 984,   "miss_pct": 0.0020, "sleeps": 284,  "spin_gets": 980,   "wait_ms": 8.4},
    {"name": "cache buffers lru chain",   "gets": 62400000,   "misses": 421,   "miss_pct": 0.0007, "sleeps": 124,  "spin_gets": 420,   "wait_ms": 3.8},
    {"name": "library cache lock",        "gets": 12480000,   "misses": 240,   "miss_pct": 0.0019, "sleeps": 84,   "spin_gets": 238,   "wait_ms": 2.4},
    {"name": "object queue header operation","gets": 9840000, "misses": 184,   "miss_pct": 0.0019, "sleeps": 52,   "spin_gets": 182,   "wait_ms": 1.6},
    {"name": "checkpoint queue latch",    "gets": 7420000,    "misses": 120,   "miss_pct": 0.0016, "sleeps": 38,   "spin_gets": 119,   "wait_ms": 1.1},
    {"name": "session allocation",        "gets": 3240000,    "misses": 84,    "miss_pct": 0.0026, "sleeps": 24,   "spin_gets": 83,    "wait_ms": 0.8},
]

_MEM_MUTEX_SLEEP = [
    {"mutex_type": "Cursor Pin",        "location": "kksLockDelete [KKSCHLPIN6]", "sleeps": 4821, "wait_ms": 142.4},
    {"mutex_type": "Library Cache",     "location": "kksfbc [KKSCHLFSP2]",        "sleeps": 1840, "wait_ms": 54.8},
    {"mutex_type": "Cursor Stat",       "location": "kkocsStoreBinds [KKOCSSTOREBI]", "sleeps": 924, "wait_ms": 28.2},
    {"mutex_type": "Cursor Parent",     "location": "kksCheckCursor [KKSCHLPIN1]","sleeps": 484,  "wait_ms": 14.8},
    {"mutex_type": "Session Pin",       "location": "kksHashTableLookup [KKSCHLPIN8]","sleeps": 284, "wait_ms": 8.4},
]

_OBJ_TOP_SEGMENTS = [
    {"owner": "APP_SCHEMA", "object_name": "ORDERS",           "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "logical reads",   "value": 92840000},
    {"owner": "APP_SCHEMA", "object_name": "TRANSACTIONS",     "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "logical reads",   "value": 56820000},
    {"owner": "APP_SCHEMA", "object_name": "ORDERS_PK",        "object_type": "INDEX",  "tablespace_name": "APP_IDX",  "statistic_name": "logical reads",   "value": 34100000},
    {"owner": "APP_SCHEMA", "object_name": "CUSTOMERS",        "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "logical reads",   "value": 12480000},
    {"owner": "APP_SCHEMA", "object_name": "AUDIT_LOG",        "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "logical reads",   "value": 9640000},
    {"owner": "APP_SCHEMA", "object_name": "TRANSACTIONS",     "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "physical reads",  "value": 98400},
    {"owner": "APP_SCHEMA", "object_name": "ORDERS",           "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "physical reads",  "value": 18400},
    {"owner": "APP_SCHEMA", "object_name": "REPORT_CACHE",     "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "physical reads",  "value": 48200},
    {"owner": "APP_SCHEMA", "object_name": "ORDERS",           "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "row lock waits",  "value": 341},
    {"owner": "APP_SCHEMA", "object_name": "TRANSACTIONS",     "object_type": "TABLE",  "tablespace_name": "APP_DATA", "statistic_name": "buffer busy waits","value": 124},
]

_OBJ_STALE_STATS = [
    {"owner": "APP_SCHEMA", "table_name": "TRANSACTIONS",   "num_rows": 4821000000, "last_analyzed": datetime.now()-timedelta(days=12), "stale_stats": "YES", "stattype_locked": None, "days_since_analyze": 12.0, "dml_since_analyze": 8420000},
    {"owner": "APP_SCHEMA", "table_name": "AUDIT_LOG",      "num_rows": 184200000,  "last_analyzed": datetime.now()-timedelta(days=8),  "stale_stats": "YES", "stattype_locked": None, "days_since_analyze": 8.0,  "dml_since_analyze": 4820000},
    {"owner": "APP_SCHEMA", "table_name": "ORDER_ITEMS",    "num_rows": 9840000,    "last_analyzed": datetime.now()-timedelta(days=5),  "stale_stats": "YES", "stattype_locked": None, "days_since_analyze": 5.0,  "dml_since_analyze": 1242000},
    {"owner": "DWH",        "table_name": "FACT_SALES",     "num_rows": 1480000000, "last_analyzed": datetime.now()-timedelta(days=14), "stale_stats": "YES", "stattype_locked": None, "days_since_analyze": 14.0, "dml_since_analyze": 0},
    {"owner": "APP_SCHEMA", "table_name": "CUSTOMERS_TEMP", "num_rows": None,       "last_analyzed": None, "stale_stats": "YES",        "stattype_locked": None, "days_since_analyze": None, "dml_since_analyze": 0},
]

_OBJ_SCHEDULER_JOBS = [
    {"owner": "APP_SCHEMA", "job_name": "GATHER_STATS_NIGHTLY",  "job_type": "PLSQL_BLOCK", "state": "SCHEDULED", "enabled": "TRUE", "last_start_date": datetime.now()-timedelta(hours=8),  "last_run_duration": "00:00:42.3", "next_run_date": datetime.now()+timedelta(hours=16), "run_count": 482, "failure_count": 0,  "max_failures": None, "comments": "Nightly stats gather"},
    {"owner": "APP_SCHEMA", "job_name": "PURGE_AUDIT_LOG",        "job_type": "PLSQL_BLOCK", "state": "RUNNING",   "enabled": "TRUE", "last_start_date": datetime.now()-timedelta(minutes=8), "last_run_duration": None,         "next_run_date": None,                             "run_count": 120, "failure_count": 0,  "max_failures": None, "comments": "Purge old audit entries"},
    {"owner": "APP_SCHEMA", "job_name": "REFRESH_MV_ORDERS",      "job_type": "PLSQL_BLOCK", "state": "SCHEDULED", "enabled": "TRUE", "last_start_date": datetime.now()-timedelta(hours=1),  "last_run_duration": "00:00:08.1", "next_run_date": datetime.now()+timedelta(hours=1),  "run_count": 2184,"failure_count": 0,  "max_failures": None, "comments": "Refresh orders materialized view"},
    {"owner": "DWH",        "job_name": "LOAD_DWH_DAILY",         "job_type": "PLSQL_BLOCK", "state": "FAILED",    "enabled": "TRUE", "last_start_date": datetime.now()-timedelta(hours=3),  "last_run_duration": "00:02:18.4", "next_run_date": None,                             "run_count": 98,  "failure_count": 3,  "max_failures": 5,    "comments": "Daily DWH load — FAILED"},
]

_OBJ_SCHEDULER_HISTORY = [
    {"owner": "APP_SCHEMA", "job_name": "GATHER_STATS_NIGHTLY", "status": "SUCCEEDED", "error#": 0,     "actual_start_date": datetime.now()-timedelta(hours=8),  "run_duration": "00:00:42.3", "cpu_used": "00:00:38.1", "additional_info": None},
    {"owner": "APP_SCHEMA", "job_name": "PURGE_AUDIT_LOG",       "status": "SUCCEEDED", "error#": 0,     "actual_start_date": datetime.now()-timedelta(hours=9),  "run_duration": "00:00:12.4", "cpu_used": "00:00:10.8", "additional_info": None},
    {"owner": "DWH",        "job_name": "LOAD_DWH_DAILY",        "status": "FAILED",    "error#": 20003, "actual_start_date": datetime.now()-timedelta(hours=3),  "run_duration": "00:02:18.4", "cpu_used": "00:01:42.1", "additional_info": "ORA-20003: Source table not available"},
    {"owner": "DWH",        "job_name": "LOAD_DWH_DAILY",        "status": "FAILED",    "error#": 20003, "actual_start_date": datetime.now()-timedelta(days=1),   "run_duration": "00:01:52.8", "cpu_used": "00:01:28.4", "additional_info": "ORA-20003: Source table not available"},
    {"owner": "APP_SCHEMA", "job_name": "REFRESH_MV_ORDERS",     "status": "SUCCEEDED", "error#": 0,     "actual_start_date": datetime.now()-timedelta(hours=1),  "run_duration": "00:00:08.1", "cpu_used": "00:00:07.2", "additional_info": None},
    {"owner": "APP_SCHEMA", "job_name": "GATHER_STATS_NIGHTLY",  "status": "SUCCEEDED", "error#": 0,     "actual_start_date": datetime.now()-timedelta(days=1),   "run_duration": "00:00:44.8", "cpu_used": "00:00:39.2", "additional_info": None},
    {"owner": "APP_SCHEMA", "job_name": "PURGE_AUDIT_LOG",        "status": "SUCCEEDED", "error#": 0,     "actual_start_date": datetime.now()-timedelta(days=1),   "run_duration": "00:00:11.8", "cpu_used": "00:00:10.1", "additional_info": None},
    {"owner": "DWH",        "job_name": "LOAD_DWH_DAILY",        "status": "FAILED",    "error#": 20003, "actual_start_date": datetime.now()-timedelta(days=2),   "run_duration": "00:02:04.1", "cpu_used": "00:01:38.9", "additional_info": "ORA-20003: Source table not available"},
]

_OBJ_WAIT_CHAINS = [
    {"chain_id": 1, "chain_is_cycle": "N", "chain_attribute": None, "num_waiters": 2, "instance_id": 1, "osid": "18342", "pid": 84, "sid": 112, "sess_serial#": 4821, "wait_id": 0, "blocker_wait_id": None, "in_wait_secs": 187, "time_since_last_wait_secs": 0, "wait_event_text": "enq: TX - row lock contention"},
    {"chain_id": 1, "chain_is_cycle": "N", "chain_attribute": None, "num_waiters": 0, "instance_id": 1, "osid": "21840", "pid": 92, "sid": 341, "sess_serial#": 9921, "wait_id": 1, "blocker_wait_id": 0, "in_wait_secs": 187, "time_since_last_wait_secs": 0, "wait_event_text": "enq: TX - row lock contention"},
    {"chain_id": 1, "chain_is_cycle": "N", "chain_attribute": None, "num_waiters": 0, "instance_id": 2, "osid": "31284", "pid": 112,"sid": 502, "sess_serial#": 6112, "wait_id": 2, "blocker_wait_id": 0, "in_wait_secs": 184, "time_since_last_wait_secs": 0, "wait_event_text": "enq: TX - row lock contention"},
]

_OBJ_PLAN_BASELINES = [
    {"sql_handle": "SQL_abc123def456", "plan_name": "SQL_PLAN_abc123_1", "sql_text": "SELECT C.CUSTOMER_ID, C.NAME, SUM(O.AMOUNT) FROM CUSTOMERS C JOIN ORDERS O ON C.ID = O.CUST_ID", "creator": "SYS", "origin": "MANUAL-LOAD", "parsing_schema_name": "APP_SCHEMA", "enabled": "YES", "accepted": "YES", "fixed": "NO", "reproduced": "YES", "autopurge": "YES", "last_executed": datetime.now()-timedelta(hours=1), "last_modified": datetime.now()-timedelta(days=5), "created": datetime.now()-timedelta(days=30), "executions": 18420, "elapsed_sec": 4821.3, "cpu_sec": 4610.2, "buffer_gets": 92840000},
    {"sql_handle": "SQL_def789abc012", "plan_name": "SQL_PLAN_def789_1", "sql_text": "UPDATE ORDERS SET STATUS = :1, UPDATED_AT = SYSDATE WHERE ORDER_ID = :2", "creator": "APP_USER", "origin": "AUTO-CAPTURE", "parsing_schema_name": "APP_SCHEMA", "enabled": "YES", "accepted": "YES", "fixed": "NO", "reproduced": "YES", "autopurge": "YES", "last_executed": datetime.now()-timedelta(minutes=2), "last_modified": datetime.now()-timedelta(days=3), "created": datetime.now()-timedelta(days=60), "executions": 284100, "elapsed_sec": 1923.7, "cpu_sec": 1812.4, "buffer_gets": 56820000},
    {"sql_handle": "SQL_ghi345jkl678", "plan_name": "SQL_PLAN_ghi345_1", "sql_text": "SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME > :1 AND DBID = :2", "creator": "SYS", "origin": "MANUAL-LOAD", "parsing_schema_name": "APP_SCHEMA", "enabled": "YES", "accepted": "YES", "fixed": "YES", "reproduced": "YES", "autopurge": "NO", "last_executed": datetime.now()-timedelta(hours=2), "last_modified": datetime.now()-timedelta(days=1), "created": datetime.now()-timedelta(days=45), "executions": 92300, "elapsed_sec": 1654.1, "cpu_sec": 512.3, "buffer_gets": 34100000},
    {"sql_handle": "SQL_mno901pqr234", "plan_name": "SQL_PLAN_mno901_1", "sql_text": "SELECT /*+ FULL(T) PARALLEL(T,8) */ COUNT(*), SUM(AMOUNT) FROM TRANSACTIONS T", "creator": "DBA_MONITOR", "origin": "AUTO-CAPTURE", "parsing_schema_name": "APP_SCHEMA", "enabled": "NO", "accepted": "NO", "fixed": "NO", "reproduced": "NO", "autopurge": "YES", "last_executed": datetime.now()-timedelta(hours=4), "last_modified": datetime.now()-timedelta(days=10), "created": datetime.now()-timedelta(days=90), "executions": 1240, "elapsed_sec": 987.2, "cpu_sec": 880.1, "buffer_gets": 12480000},
    {"sql_handle": "SQL_stu567vwx890", "plan_name": "SQL_PLAN_stu567_1", "sql_text": "INSERT INTO AUDIT_LOG (USER_ID, ACTION, TS, DETAIL) VALUES (:1,:2,SYSTIMESTAMP,:3)", "creator": "APP_USER", "origin": "AUTO-CAPTURE", "parsing_schema_name": "APP_SCHEMA", "enabled": "YES", "accepted": "YES", "fixed": "NO", "reproduced": "YES", "autopurge": "YES", "last_executed": datetime.now()-timedelta(minutes=1), "last_modified": datetime.now()-timedelta(days=2), "created": datetime.now()-timedelta(days=120), "executions": 48200, "elapsed_sec": 722.4, "cpu_sec": 698.3, "buffer_gets": 9640000},
]

_OBJ_PX_SESSIONS = [
    {"inst_id": 1, "sid": 89, "serial#": 7712, "username": "BATCH_USR", "status": "ACTIVE", "requested_dop": 8, "actual_dop": 8, "slave_sets": 1, "px_servers_requested": 8, "px_servers_allocated": 8, "sql_id": "2mx8vbwqc5pla", "event": "PX Deq: Execute Reply", "seconds_in_wait": 0},
    {"inst_id": 1, "sid": 401, "serial#": 1234, "username": "BATCH_USR", "status": "ACTIVE", "requested_dop": 8, "actual_dop": 4, "slave_sets": 1, "px_servers_requested": 8, "px_servers_allocated": 4, "sql_id": "2mx8vbwqc5pla", "event": "PX Deq: Parse Reply", "seconds_in_wait": 0},
    {"inst_id": 2, "sid": 512, "serial#": 5678, "username": "BATCH_USR", "status": "ACTIVE", "requested_dop": 8, "actual_dop": 4, "slave_sets": 1, "px_servers_requested": 8, "px_servers_allocated": 4, "sql_id": "2mx8vbwqc5pla", "event": "PX Deq: Slave Session Stats", "seconds_in_wait": 0},
    {"inst_id": 1, "sid": 402, "serial#": 1240, "username": "DWH",       "status": "ACTIVE", "requested_dop": 4, "actual_dop": 4, "slave_sets": 1, "px_servers_requested": 4, "px_servers_allocated": 4, "sql_id": "3yru4fqvqpzwm", "event": "PX Deq Credit: send blkd", "seconds_in_wait": 2},
]

_SQLMON_ACTIVE = [
    {"inst_id": 1, "key": 101, "sid": 112, "sql_id": "3yru4fqvqpzwm", "sql_exec_id": 16777216, "status": "EXECUTING", "username": "APP_USER",  "module": "JDBC Thin Client", "program": "JDBC Thin Client", "elapsed_sec": 312.4, "cpu_sec": 298.1, "buffer_gets": 4820000, "disk_reads": 18400, "phys_write_mb": 0.0, "fetches": 0,      "executions": 1, "px_servers_requested": 0, "px_servers_allocated": 0, "interconnect_mb": 0.0, "sql_text": "SELECT C.CUSTOMER_ID, C.NAME, SUM(O.AMOUNT) FROM CUSTOMERS C JOIN ORDERS O ON C.ID = O.CUST_ID WHERE O.STATUS = 'PENDING' GROUP BY C.CUSTOMER_ID, C.NAME ORDER BY 3 DESC"},
    {"inst_id": 1, "key": 102, "sid": 89,  "sql_id": "2mx8vbwqc5pla", "sql_exec_id": 16777217, "status": "EXECUTING", "username": "BATCH_USR", "module": "python@batch01",   "program": "python@batch01",   "elapsed_sec": 187.2, "cpu_sec": 164.8, "buffer_gets": 8240000, "disk_reads": 48200, "phys_write_mb": 0.0, "fetches": 0,      "executions": 1, "px_servers_requested": 8, "px_servers_allocated": 8, "interconnect_mb": 42.3,"sql_text": "SELECT /*+ FULL(T) PARALLEL(T,8) */ COUNT(*), SUM(AMOUNT) FROM TRANSACTIONS T WHERE TXN_DATE BETWEEN :1 AND :2"},
]

_SQLMON_RECENT = [
    {"inst_id": 1, "key": 98, "sid": 234, "sql_id": "8fkg2hzmdq1wx", "sql_exec_id": 16777210, "status": "DONE", "username": "APP_USER", "module": "JDBC Thin Client", "program": "JDBC Thin Client", "elapsed_sec": 42.8, "cpu_sec": 38.2, "buffer_gets": 1248000, "disk_reads": 2100, "phys_write_mb": 0.0, "fetches": 284100, "executions": 1, "px_servers_requested": 0, "px_servers_allocated": 0, "interconnect_mb": 0.0, "sql_text": "UPDATE ORDERS SET STATUS = :1, UPDATED_AT = SYSDATE WHERE ORDER_ID = :2"},
    {"inst_id": 2, "key": 99, "sid": 412, "sql_id": "g7z1nkpq9r4ty", "sql_exec_id": 16777211, "status": "DONE", "username": "APP_USER", "module": "JDBC Thin Client", "program": "JDBC Thin Client", "elapsed_sec": 18.4, "cpu_sec": 14.2, "buffer_gets": 482000,  "disk_reads": 4820, "phys_write_mb": 0.0, "fetches": 9230,  "executions": 1, "px_servers_requested": 0, "px_servers_allocated": 0, "interconnect_mb": 0.0, "sql_text": "SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY WHERE SAMPLE_TIME > :1 AND DBID = :2"},
    {"inst_id": 1, "key": 97, "sid": 341, "sql_id": "5hnqzxpj7m2wv", "sql_exec_id": 16777209, "status": "DONE (ERROR)", "username": "APP_USER", "module": "JDBC Thin Client", "program": "JDBC Thin Client", "elapsed_sec": 0.4, "cpu_sec": 0.2, "buffer_gets": 8400, "disk_reads": 0, "phys_write_mb": 0.0, "fetches": 0, "executions": 1, "px_servers_requested": 0, "px_servers_allocated": 0, "interconnect_mb": 0.0, "sql_text": "INSERT INTO AUDIT_LOG (USER_ID, ACTION, TS, DETAIL) VALUES (:1,:2,SYSTIMESTAMP,:3)"},
]

_ALERTLOG_RECENT = [
    {"originating_timestamp": datetime.now()-timedelta(minutes=2),  "message_text": "ORA-00060: deadlock detected while waiting for resource", "message_level": 2, "component_id": "rdbms",    "host_id": "oraserver01", "instance_id": "ORCL1"},
    {"originating_timestamp": datetime.now()-timedelta(minutes=8),  "message_text": "ORA-04031: unable to allocate 65536 bytes of shared memory (shared pool,unknown object,sga heap(1,0),permanent memory)", "message_level": 2, "component_id": "rdbms", "host_id": "oraserver01", "instance_id": "ORCL1"},
    {"originating_timestamp": datetime.now()-timedelta(minutes=12), "message_text": "ORA-00060: deadlock detected while waiting for resource", "message_level": 2, "component_id": "rdbms",    "host_id": "oraserver01", "instance_id": "ORCL1"},
    {"originating_timestamp": datetime.now()-timedelta(hours=1),    "message_text": "ORA-01555: snapshot too old: rollback segment number 8 with name \"_SYSSMU8_804554510$\" too small", "message_level": 2, "component_id": "rdbms", "host_id": "oraserver01", "instance_id": "ORCL1"},
    {"originating_timestamp": datetime.now()-timedelta(hours=2),    "message_text": "ORA-04031: unable to allocate 32768 bytes of shared memory (large pool)", "message_level": 2, "component_id": "rdbms", "host_id": "oraserver01", "instance_id": "ORCL2"},
    {"originating_timestamp": datetime.now()-timedelta(hours=3),    "message_text": "ORA-00600: internal error code, arguments: [kclchkblk_3]", "message_level": 1, "component_id": "rdbms", "host_id": "oraserver01", "instance_id": "ORCL1"},
    {"originating_timestamp": datetime.now()-timedelta(hours=4),    "message_text": "ORA-00060: deadlock detected while waiting for resource", "message_level": 2, "component_id": "rdbms",    "host_id": "oraserver02", "instance_id": "ORCL2"},
    {"originating_timestamp": datetime.now()-timedelta(hours=6),    "message_text": "ORA-01536: space quota exceeded for tablespace 'APP_DATA'", "message_level": 2, "component_id": "rdbms",   "host_id": "oraserver01", "instance_id": "ORCL1"},
    {"originating_timestamp": datetime.now()-timedelta(hours=8),    "message_text": "ORA-04031: unable to allocate 262144 bytes of shared memory (shared pool)", "message_level": 2, "component_id": "rdbms", "host_id": "oraserver02", "instance_id": "ORCL2"},
    {"originating_timestamp": datetime.now()-timedelta(hours=12),   "message_text": "ORA-07445: exception encountered: core dump [kgllin()+1248] [SIGSEGV]", "message_level": 1, "component_id": "rdbms", "host_id": "oraserver01", "instance_id": "ORCL1"},
]

_ALERTLOG_INCIDENTS = [
    {"problem_id": 1, "problem_key": "ORA 600 [kclchkblk_3]",       "last_incident_id": 8421, "incident_count": 3, "last_time": datetime.now()-timedelta(hours=3)},
    {"problem_id": 2, "problem_key": "ORA 7445 [kgllin()+1248]",     "last_incident_id": 8418, "incident_count": 1, "last_time": datetime.now()-timedelta(hours=12)},
    {"problem_id": 3, "problem_key": "ORA 4031 [shared pool]",       "last_incident_id": 8415, "incident_count": 5, "last_time": datetime.now()-timedelta(minutes=8)},
]

_PDB_DG_STATUS = [
    {"con_id": 3, "pdb_name": "APPDB",    "open_mode": "READ WRITE", "restricted": "NO", "recovery_status": "DISABLED", "logging": "LOGGING", "application_root": "NO", "protection_mode": "MAXIMUM PERFORMANCE", "database_role": "PRIMARY", "dg_stat_name": "Apply Lag",     "dg_stat_value": "+00 00:00:02.0", "unit": "day(s) hour(s) minute(s) second(s)"},
    {"con_id": 3, "pdb_name": "APPDB",    "open_mode": "READ WRITE", "restricted": "NO", "recovery_status": "DISABLED", "logging": "LOGGING", "application_root": "NO", "protection_mode": "MAXIMUM PERFORMANCE", "database_role": "PRIMARY", "dg_stat_name": "Transport Lag", "dg_stat_value": "+00 00:00:01.0", "unit": "day(s) hour(s) minute(s) second(s)"},
    {"con_id": 4, "pdb_name": "REPORTDB", "open_mode": "READ WRITE", "restricted": "NO", "recovery_status": "DISABLED", "logging": "LOGGING", "application_root": "NO", "protection_mode": "MAXIMUM PERFORMANCE", "database_role": "PRIMARY", "dg_stat_name": "Apply Lag",     "dg_stat_value": "+00 00:00:02.0", "unit": "day(s) hour(s) minute(s) second(s)"},
    {"con_id": 5, "pdb_name": "DEVDB",    "open_mode": "MOUNTED",    "restricted": "NO", "recovery_status": "DISABLED", "logging": "LOGGING", "application_root": "NO", "protection_mode": "MAXIMUM PERFORMANCE", "database_role": "PRIMARY", "dg_stat_name": None,            "dg_stat_value": None,              "unit": None},
]

_RMAN_SESSIONS = [
    {"inst_id": 1, "sid": 288, "serial_num": 7412, "os_pid": "19823",
     "username": "SYS", "client_info": "rman channel=ch1",
     "status": "ACTIVE", "program": "rman@oraserver01",
     "session_mins": 42},
    {"inst_id": 1, "sid": 290, "serial_num": 7418, "os_pid": "19831",
     "username": "SYS", "client_info": "rman channel=ch2",
     "status": "ACTIVE", "program": "rman@oraserver01",
     "session_mins": 42},
    {"inst_id": 1, "sid": 32,  "serial_num": 9182, "os_pid": "19800",
     "username": "SYS", "client_info": "rman target connection",
     "status": "ACTIVE", "program": "rman@oraserver01",
     "session_mins": 42},
]

_RMAN_LONGOPS = [
    {"inst_id": 1, "sid": 288, "serial_num": 7412, "channel": "rman channel=ch1",
     "operation": "RMAN: full datafile backup", "context": 1,
     "sofar": 18432, "totalwork": 44800, "pct_complete": 41.1,
     "time_remaining": 3720, "elapsed_secs": 2520, "mb_per_sec": 7.32},
    {"inst_id": 1, "sid": 290, "serial_num": 7418, "channel": "rman channel=ch2",
     "operation": "RMAN: full datafile backup", "context": 1,
     "sofar": 19200, "totalwork": 44800, "pct_complete": 42.9,
     "time_remaining": 3580, "elapsed_secs": 2520, "mb_per_sec": 7.62},
]

_RMAN_WAIT_EVENTS = [
    {"inst_id": 1, "sid": 288, "serial_num": 7412, "channel": "rman channel=ch1",
     "seq_num": 1248, "event": "backup: sbtbackup", "state": "WAITING",
     "wait_secs": 0.12, "p1text": "buffer#", "p1": 4, "p2text": "size", "p2": 262144},
    {"inst_id": 1, "sid": 290, "serial_num": 7418, "channel": "rman channel=ch2",
     "seq_num": 1312, "event": "backup: sbtbackup", "state": "WAITING",
     "wait_secs": 0.09, "p1text": "buffer#", "p1": 3, "p2text": "size", "p2": 262144},
]

_RMAN_DISK_IO = [
    {"inst_id": 1, "sid": 288, "serial_num": 7412, "channel": "rman channel=ch1",
     "status": "IN PROGRESS", "open_time": datetime.now()-timedelta(minutes=42),
     "sofar_mb": 18432, "total_mb": 44800, "pct_complete": 41.1,
     "io_count": 147456, "type": "DATAFILE",
     "filename": "/oradata/APP_DATA/datafile/o1_mf_app_data_1.dbf"},
    {"inst_id": 1, "sid": 290, "serial_num": 7418, "channel": "rman channel=ch2",
     "status": "IN PROGRESS", "open_time": datetime.now()-timedelta(minutes=42),
     "sofar_mb": 19200, "total_mb": 44800, "pct_complete": 42.9,
     "io_count": 153600, "type": "DATAFILE",
     "filename": "/oradata/APP_DATA/datafile/o1_mf_app_data_2.dbf"},
]

_RMAN_PERF_SUMMARY = {
    "active_channels": 3, "working_channels": 2,
    "total_processed_gb": 36.75, "total_work_gb": 87.50,
    "avg_pct_complete": 42.0, "max_eta_secs": 3720, "avg_mb_per_sec": 7.47,
}

_ORACLE_ADVISORS = [
    {"advisor_name": "ADDM",                   "task_count": 48, "completed": 48, "errors": 0, "last_run": "2026-06-29 08:00", "last_status": "COMPLETED"},
    {"advisor_name": "SQL Tuning Advisor",      "task_count": 12, "completed": 11, "errors": 1, "last_run": "2026-06-29 06:00", "last_status": "COMPLETED"},
    {"advisor_name": "SQL Access Advisor",      "task_count": 3,  "completed": 3,  "errors": 0, "last_run": "2026-06-28 23:00", "last_status": "COMPLETED"},
    {"advisor_name": "Segment Advisor",         "task_count": 7,  "completed": 7,  "errors": 0, "last_run": "2026-06-29 02:00", "last_status": "COMPLETED"},
    {"advisor_name": "Undo Advisor",            "task_count": 48, "completed": 48, "errors": 0, "last_run": "2026-06-29 08:00", "last_status": "COMPLETED"},
    {"advisor_name": "SGA Advisor",             "task_count": 48, "completed": 48, "errors": 0, "last_run": "2026-06-29 08:00", "last_status": "COMPLETED"},
    {"advisor_name": "PGA Advisor",             "task_count": 48, "completed": 48, "errors": 0, "last_run": "2026-06-29 08:00", "last_status": "COMPLETED"},
    {"advisor_name": "Buffer Cache Advisor",    "task_count": 48, "completed": 48, "errors": 0, "last_run": "2026-06-29 08:00", "last_status": "COMPLETED"},
    {"advisor_name": "Shared Pool Advisor",     "task_count": 48, "completed": 47, "errors": 1, "last_run": "2026-06-29 07:00", "last_status": "COMPLETED"},
    {"advisor_name": "MTTR Advisor",            "task_count": 48, "completed": 48, "errors": 0, "last_run": "2026-06-29 08:00", "last_status": "COMPLETED"},
    {"advisor_name": "SQL Performance Analyzer","task_count": 2,  "completed": 2,  "errors": 0, "last_run": "2026-06-27 14:00", "last_status": "COMPLETED"},
    {"advisor_name": "Compression Advisor",     "task_count": 1,  "completed": 1,  "errors": 0, "last_run": "2026-06-25 10:00", "last_status": "COMPLETED"},
    {"advisor_name": "Tablespace Advisor",      "task_count": 48, "completed": 48, "errors": 0, "last_run": "2026-06-29 08:00", "last_status": "COMPLETED"},
]

_ORACLE_ADVISOR_FINDINGS = [
    {"advisor_name": "ADDM",              "finding_name": "Top SQL by DB Time", "type": "PROBLEM", "impact": 41.2, "message": "SQL 3yru4fqvqpzwm responsible for 41.2% of DB time. Consider index on ORDERS(STATUS,CUST_ID)."},
    {"advisor_name": "ADDM",              "finding_name": "Hard Parse",         "type": "PROBLEM", "impact": 8.4,  "message": "Hard parse rate 12.4/s. Increase cursor_sharing or add bind variables."},
    {"advisor_name": "SGA Advisor",       "finding_name": "Buffer Cache",       "type": "RECOMMEND","impact": 6.1, "message": "Increasing DB_CACHE_SIZE by 2 GB would reduce physical reads by ~12%."},
    {"advisor_name": "Segment Advisor",   "finding_name": "Reclaimable Space",  "type": "RECOMMEND","impact": 3.8, "message": "Table AUDIT_LOG has 35% reclaimable space. Consider shrink or move operation."},
    {"advisor_name": "Undo Advisor",      "finding_name": "Undo Retention",     "type": "RECOMMEND","impact": 2.1, "message": "Undo retention of 900s insufficient for peak workload. Recommend 1800s."},
    {"advisor_name": "SQL Tuning Advisor","finding_name": "Index Recommendation","type": "RECOMMEND","impact": 18.4,"message": "Create index APP_SCHEMA.ORDERS(STATUS,CUST_ID) — estimated 18.4% CPU reduction."},
]

_SQL_MONITOR_DATA = [
    {"sql_id": "3yru4fqvqpzwm", "sql_text": "SELECT C.CUSTOMER_ID, C.NAME, SUM(O.AMOUNT) FROM CUSTOMERS C JOIN ORDERS O", "status": "EXECUTING", "username": "APP_USER",  "last_active": "08:42:11", "elapsed_secs": 312.4, "cpu_secs": 298.1, "buffer_gets": 4820000, "disk_reads": 18400, "rows_processed": 0,      "sid": 112, "inst_id": 1, "sql_plan_hash_value": 3847291023},
    {"sql_id": "2mx8vbwqc5pla", "sql_text": "SELECT /*+ FULL(T) PARALLEL(T,8) */ COUNT(*), SUM(AMOUNT) FROM TRANSACTIONS T", "status": "DONE",      "username": "BATCH_USR","last_active": "08:40:33", "elapsed_secs": 187.2, "cpu_secs": 164.8, "buffer_gets": 8240000, "disk_reads": 48200, "rows_processed": 1842000, "sid": 89,  "inst_id": 1, "sql_plan_hash_value": 2918473621},
    {"sql_id": "8fkg2hzmdq1wx", "sql_text": "UPDATE ORDERS SET STATUS = :1, UPDATED_AT = SYSDATE WHERE ORDER_ID = :2",     "status": "DONE",      "username": "APP_USER",  "last_active": "08:41:58", "elapsed_secs": 42.8,  "cpu_secs": 38.2,  "buffer_gets": 1248000, "disk_reads": 2100,  "rows_processed": 284100, "sid": 234, "inst_id": 2, "sql_plan_hash_value": 1729384756},
]

_SQL_PLAN_DATA = [
    {"sql_id": "3yru4fqvqpzwm", "plan_line_id": 0, "operation": "SELECT STATEMENT",    "object_name": None,         "cardinality": None, "output_rows": 0,      "starts": 1,   "actual_rows": 0,      "elapsed_secs": 312.4, "cpu_secs": 298.1, "disk_reads": 18400, "disk_writes": 0, "status": "EXECUTING"},
    {"sql_id": "3yru4fqvqpzwm", "plan_line_id": 1, "operation": "SORT GROUP BY",       "object_name": None,         "cardinality": 18420,"output_rows": 0,      "starts": 1,   "actual_rows": 0,      "elapsed_secs": 312.3, "cpu_secs": 297.8, "disk_reads": 18400, "disk_writes": 0, "status": "EXECUTING"},
    {"sql_id": "3yru4fqvqpzwm", "plan_line_id": 2, "operation": "HASH JOIN",            "object_name": None,         "cardinality": 920000,"output_rows": 0,     "starts": 1,   "actual_rows": 0,      "elapsed_secs": 311.8, "cpu_secs": 297.2, "disk_reads": 18400, "disk_writes": 2100,"status": "EXECUTING"},
    {"sql_id": "3yru4fqvqpzwm", "plan_line_id": 3, "operation": "TABLE ACCESS FULL",   "object_name": "CUSTOMERS",  "cardinality": 84000, "output_rows": 84000, "starts": 1,   "actual_rows": 84120,  "elapsed_secs": 12.4,  "cpu_secs": 11.8,  "disk_reads": 4820,  "disk_writes": 0, "status": "DONE"},
    {"sql_id": "3yru4fqvqpzwm", "plan_line_id": 4, "operation": "TABLE ACCESS FULL",   "object_name": "ORDERS",     "cardinality": 4820000,"output_rows": 920000,"starts": 1,  "actual_rows": 4821847,"elapsed_secs": 298.2, "cpu_secs": 284.1, "disk_reads": 13580, "disk_writes": 0, "status": "EXECUTING"},
]

_ADVISOR_FINDINGS = [
    {"severity": "CRITICAL", "category": "SQL",         "title": "High CPU SQL detected",
     "detail": "SQL 3yru4fqvqpzwm consuming 41.2% of DB CPU. 18,420 executions with avg 261ms.",
     "suggestion": "Add index on ORDERS(STATUS, CUST_ID) or review execution plan.", "sql_id": "3yru4fqvqpzwm"},
    {"severity": "CRITICAL", "category": "Tablespace",  "title": "ARCHIVE tablespace at 96%",
     "detail": "APP_DATA at 86%, ARCHIVE at 96% — AUTOEXTEND disabled.",
     "suggestion": "Add datafile or purge old archive logs immediately.", "sql_id": ""},
    {"severity": "WARNING",  "category": "Waits",       "title": "Row lock contention",
     "detail": "SID 341 blocked by SID 112 on enq: TX — row lock contention (420ms avg).",
     "suggestion": "Review application transaction logic; commit more frequently.", "sql_id": ""},
    {"severity": "WARNING",  "category": "RMAN",        "title": "RMAN archive backup failed 3 days ago",
     "detail": "ARCHIVELOG backup failed 2026-06-26. No retry observed.",
     "suggestion": "Investigate RMAN error log; run backup archivelog all delete input.", "sql_id": ""},
    {"severity": "INFO",     "category": "Memory",      "title": "PGA usage elevated",
     "detail": "PGA aggregate target at 78% — batch workload causing sort spills.",
     "suggestion": "Increase PGA_AGGREGATE_TARGET or schedule batch off-peak.", "sql_id": ""},
]


# ─────────────────────────────────────────────────────────────────────
# Live demo runner
# ─────────────────────────────────────────────────────────────────────

class DemoRunner:
    """
    Populates MetricsCache with fake but realistic Oracle data.
    Runs as a background async task — values fluctuate to simulate live monitoring.
    """

    def __init__(self, cache: MetricsCache, interval: int = 3) -> None:
        self.cache    = cache
        self.interval = interval
        self._running = False
        self._tick    = 0

    async def run(self) -> None:
        self._running = True
        log.info("Demo runner started.")
        # Seed static data immediately
        self._populate_static()
        while self._running:
            try:
                self._populate_dynamic()
                self._tick += 1
            except Exception as exc:
                log.warning("Demo tick error: %s", exc)
            await asyncio.sleep(self.interval)

    def stop(self) -> None:
        self._running = False

    # ── Static (set once) ────────────────────────────────────────────

    def _populate_static(self) -> None:
        c = self.cache
        c.set("health.db_info",      _DB_INFO,        ttl=86400)
        c.set("rac.detected",        True,             ttl=86400)
        c.set("dg.role",             "PRIMARY",        ttl=86400)
        c.set("dg.protection_mode",  "MAXIMUM PERFORMANCE", ttl=86400)
        c.set("dg.standby_processes", _DG_PROCESSES,   ttl=86400)
        c.set("dg.archive_gap",      0,                ttl=86400)
        c.set("asm.diskgroups",      _ASM_DISKGROUPS,  ttl=86400)
        c.set("asm.fra",             {"used_pct": 82.0, "used_mb": 83968, "total_mb": 102400}, ttl=86400)
        c.set("asm.archive_rate_mb", 4.8,              ttl=86400)
        c.set("awr.tablespaces",     _TABLESPACES,     ttl=86400)
        c.set("rman.history",        _RMAN_HISTORY,    ttl=86400)
        c.set("rman.sessions",       _RMAN_SESSIONS,   ttl=86400)
        c.set("rman.longops",        _RMAN_LONGOPS,    ttl=86400)
        c.set("rman.wait_events",    _RMAN_WAIT_EVENTS,ttl=86400)
        c.set("rman.disk_io",        _RMAN_DISK_IO,    ttl=86400)
        c.set("rman.tape_io",        [],               ttl=86400)
        c.set("rman.perf_summary",   _RMAN_PERF_SUMMARY, ttl=86400)
        c.set("sql.top",             _TOP_SQL,         ttl=86400)
        c.set("advisor.findings",    _ADVISOR_FINDINGS, ttl=86400)
        c.set("ash.samples",         self._fake_ash(), ttl=86400)
        c.set("awr.snapshots",       self._fake_snapshots(), ttl=86400)
        # Exadata (simulated)
        c.set("exa.detected",        True,          ttl=86400)
        c.set("exa.cells",           _EXA_CELLS,    ttl=86400)
        c.set("rac.interconnect",    _RAC_INTERCONNECT,    ttl=86400)
        c.set("asm.large_segments",  _ASM_LARGE_SEGMENTS,  ttl=86400)
        c.set("dg.standby_host",     "orastandby01.brabolab.local", ttl=86400)
        c.set("dg.standby_unique_name", "ORCL_STANDBY",    ttl=86400)
        c.set("dg.rac_processes",   _DG_RAC_PROCESSES, ttl=86400)
        c.set("asm.disks",          _ASM_DISKS,        ttl=86400)
        c.set("locks.blockers",     _LOCK_BLOCKERS,    ttl=86400)
        c.set("locks.waiters",      _LOCK_WAITERS,     ttl=86400)
        c.set("locks.objects",      _LOCK_OBJECTS,     ttl=86400)
        c.set("exa.sql_offload",     _EXA_SQL_OFFLOAD,     ttl=86400)
        c.set("exa.cell_waits",      _EXA_CELL_WAITS,      ttl=86400)
        c.set("exa.hcc_objects",     _EXA_HCC_OBJECTS,     ttl=86400)
        c.set("exa.params",          _EXA_PARAMS,          ttl=86400)
        c.set("rac.services",             _RAC_SERVICES,           ttl=86400)
        c.set("awr.top_sql",              _AWR_TOP_SQL,            ttl=86400)
        c.set("awr.top_waits",            _AWR_TOP_WAITS,          ttl=86400)
        c.set("awr.sysstat",              _AWR_SYSSTAT,            ttl=86400)
        c.set("advisor.oracle_advisors",  _ORACLE_ADVISORS,        ttl=86400)
        c.set("advisor.oracle_findings",  _ORACLE_ADVISOR_FINDINGS,ttl=86400)
        c.set("advisor.sql_monitor",      _SQL_MONITOR_DATA,       ttl=86400)
        c.set("advisor.sql_plan",         _SQL_PLAN_DATA,          ttl=86400)
        # PDB
        c.set("pdb.detected",     True,           ttl=86400)
        c.set("pdb.list",         _PDBS,          ttl=86400)
        c.set("pdb.tablespaces",  _PDB_TABLESPACES, ttl=86400)
        c.set("pdb.dg_status",    _PDB_DG_STATUS,   ttl=86400)
        # I/O Activity
        c.set("io.file_stats",              _IO_FILE_STATS,         ttl=86400)
        c.set("io.function_stats",          _IO_FUNCTION_STATS,     ttl=86400)
        c.set("io.load_profile",            _IO_LOAD_PROFILE,       ttl=86400)
        c.set("io.redo_logs",               _IO_REDO_LOGS,          ttl=86400)
        c.set("io.redo_log_files",          _IO_REDO_LOG_FILES,     ttl=86400)
        c.set("io.redo_switches_per_hour",  _IO_REDO_SWITCHES,      ttl=86400)
        c.set("io.undo_stats",              _IO_UNDO_STATS,         ttl=86400)
        c.set("io.undo_extents",            _IO_UNDO_EXTENTS,       ttl=86400)
        # Memory Advisor
        c.set("mem.sga_advice",     _MEM_SGA_ADVICE,     ttl=86400)
        c.set("mem.pga_advice",     _MEM_PGA_ADVICE,     ttl=86400)
        c.set("mem.pga_stats",      _MEM_PGA_STATS,      ttl=86400)
        c.set("mem.buffer_pool",    _MEM_BUFFER_POOL,    ttl=86400)
        c.set("mem.db_cache_advice",_MEM_DB_CACHE_ADVICE,ttl=86400)
        c.set("mem.resize_ops",     _MEM_RESIZE_OPS,     ttl=86400)
        c.set("mem.latches",        _MEM_LATCHES,        ttl=86400)
        c.set("mem.mutex_sleep",    _MEM_MUTEX_SLEEP,    ttl=86400)
        # Objects / Segments
        c.set("obj.top_segments",     _OBJ_TOP_SEGMENTS,      ttl=86400)
        c.set("obj.stale_stats",      _OBJ_STALE_STATS,       ttl=86400)
        c.set("obj.scheduler_jobs",   _OBJ_SCHEDULER_JOBS,    ttl=86400)
        c.set("obj.scheduler_history",_OBJ_SCHEDULER_HISTORY, ttl=86400)
        c.set("obj.wait_chains",      _OBJ_WAIT_CHAINS,       ttl=86400)
        c.set("obj.plan_baselines",   _OBJ_PLAN_BASELINES,    ttl=86400)
        c.set("obj.px_sessions",      _OBJ_PX_SESSIONS,       ttl=86400)
        # SQL Monitor
        c.set("sqlmon.active", _SQLMON_ACTIVE, ttl=86400)
        c.set("sqlmon.recent", _SQLMON_RECENT, ttl=86400)
        # Alert Log
        c.set("alertlog.recent",    _ALERTLOG_RECENT,    ttl=86400)
        c.set("alertlog.incidents", _ALERTLOG_INCIDENTS, ttl=86400)

    # ── Dynamic (updated every tick) ─────────────────────────────────

    def _populate_dynamic(self) -> None:
        t  = self._tick
        c  = self.cache

        # CPU — sine wave 1.2–5.8 with noise
        cpu = 3.5 + 2.3 * math.sin(t * 0.4) + random.uniform(-0.3, 0.3)
        cpu = max(0.8, min(7.9, cpu))

        # Sessions — drifts around 127 total, 8-28 active
        total_sessions  = int(127 + random.randint(-5, 5))
        active_sessions = int(18  + 10 * abs(math.sin(t * 0.3)) + random.randint(-3, 3))
        active_sessions = min(active_sessions, total_sessions)

        # SGA / PGA
        sga_mb = round(16384 + random.uniform(-128, 128), 0)
        pga_mb = round(4096  + random.uniform(-256, 256), 0)

        # Memory
        total_mem_mb = 65536
        free_mem_mb  = round(18432 + random.uniform(-512, 512), 0)

        # Rates
        rates = {
            "redo_mb_per_sec":      round(abs(4.2  + 2.1  * math.sin(t * 0.5) + random.uniform(-0.5, 0.5)), 3),
            "logons_per_sec":       round(abs(1.8  + random.uniform(-0.5, 0.5)), 2),
            "executes_per_sec":     round(abs(3240 + 800  * math.sin(t * 0.3) + random.uniform(-100, 100)), 0),
            "hard_parses_per_sec":  round(abs(12.4 + random.uniform(-3, 3)), 1),
            "commits_per_sec":      round(abs(284  + 60   * math.sin(t * 0.4) + random.uniform(-20, 20)), 1),
            "rollbacks_per_sec":    round(abs(2.1  + random.uniform(-0.5, 0.5)), 2),
        }

        c.set("health.cpu_load",       cpu,              ttl=10)
        c.set("health.total_sessions", total_sessions,   ttl=10)
        c.set("health.active_sessions",active_sessions,  ttl=10)
        c.set("health.sga_mb",         sga_mb,           ttl=10)
        c.set("health.pga_mb",         pga_mb,           ttl=10)
        c.set("health.rates",          rates,            ttl=10)
        c.set("health.memory",         {"total_mb": total_mem_mb, "free_mb": free_mem_mb}, ttl=10)

        # RAC instances with fluctuating sessions
        inst = _RAC_INSTANCES.copy()
        half = total_sessions // 2
        inst[0] = {**inst[0], "total_sessions": half + random.randint(-3,3),
                               "active_sessions": active_sessions // 2 + random.randint(0,3)}
        inst[1] = {**inst[1], "total_sessions": total_sessions - half,
                               "active_sessions": active_sessions - active_sessions // 2}
        c.set("rac.instances",    inst,   ttl=10)
        c.set("rac.gc_stats",     self._fake_gc_stats(), ttl=10)

        # DataGuard lag — oscillates 0–4s
        lag_s = abs(math.sin(t * 0.15)) * 4
        lag   = f"+00 00:00:{int(lag_s):02d}.0"
        c.set("dg.stats", {
            "Apply Lag":      {"value": lag,  "unit": "day(s) hour(s) minute(s) second(s)"},
            "Transport Lag":  {"value": "+00 00:00:01.0", "unit": "day(s) hour(s) minute(s) second(s)"},
            "Redo Generated": {"value": "5.2 MByte/sec",  "unit": "MByte/sec"},
        }, ttl=10)

        # Waits — fluctuating counts
        base_waits = [182400, 98300, 12400, 7820, 4210, 2180, 340, 2840000]
        base_time  = [583.2,  177.0, 153.8, 63.4, 3.8,  11.4, 142.8, 852.0]
        waits = []
        for i, w in enumerate(_WAITS_TOP):
            waits.append({
                **w,
                "total_waits":      int(base_waits[i] * (1 + random.uniform(-0.05, 0.05))),
                "time_waited_secs": round(base_time[i] * (1 + random.uniform(-0.05, 0.05)), 1),
            })
        c.set("waits.system_top", waits, ttl=10)

        # Scalar aggregates for graph ring-buffers (Waits)
        non_idle_waits = [w for w in waits if w.get("wait_class", "") != "Idle"]
        c.set("waits.top_wait_sec",       float(non_idle_waits[0]["time_waited_secs"]) if non_idle_waits else 0.0, ttl=10)
        c.set("waits.non_idle_total_sec", sum(float(w["time_waited_secs"]) for w in non_idle_waits), ttl=10)
        c.set("waits.active_count",       float(active_sessions), ttl=10)

        # Scalar aggregates for graph ring-buffers (Top SQL)
        total_cpu_sec  = sum(float(r.get("cpu_secs",  r.get("cpu_sec",  0)) or 0) for r in _TOP_SQL)
        total_ela_sec  = sum(float(r.get("elapsed_secs", r.get("elapsed_sec", 0)) or 0) for r in _TOP_SQL)
        total_buf_k    = sum(int(r.get("buffer_gets", 0) or 0)                          for r in _TOP_SQL) / 1000.0
        # Add slight noise per tick
        c.set("sql.total_cpu_sec",     total_cpu_sec  * (1 + random.uniform(-0.03, 0.03)), ttl=10)
        c.set("sql.total_elapsed_sec", total_ela_sec  * (1 + random.uniform(-0.03, 0.03)), ttl=10)
        c.set("sql.total_buffer_gets", total_buf_k    * (1 + random.uniform(-0.03, 0.03)), ttl=10)

        # Sessions list — vary last_call_et
        sessions = []
        for s in _SESSIONS_BASE:
            sessions.append({
                **s,
                "last_call_et": s["last_call_et"] + t * self.interval + random.randint(0, 5),
            })
        # Occasionally add a temp session
        if t % 5 == 0:
            sessions.append({
                "sid": 400 + t % 10, "serial": random.randint(1000, 9999),
                "username": "APP_USER", "status": "ACTIVE",
                "osuser": "appsvr03", "machine": "appserver03",
                "program": "JDBC Thin Client", "sql_id": "5hnqzxpj7m2wv",
                "wait_event": "log file sync", "wait_class": "Commit",
                "blocking_session": None,
                "logon_time": datetime.now() - timedelta(seconds=t * self.interval),
                "last_call_et": random.randint(0, 30),
            })

        c.set("sessions.list",         sessions, ttl=10)
        c.set("sessions.active_count", active_sessions, ttl=10)
        c.set("sessions.total_count",  total_sessions,  ttl=10)

        # Lock demo — vary ctime each tick to simulate growing lock time
        blockers = [
            {**_LOCK_BLOCKERS[0], "ctime_secs": 187 + t * self.interval}
        ]
        c.set("locks.blockers", blockers, ttl=10)
        c.set("locks.waiters",  _LOCK_WAITERS,  ttl=10)
        c.set("locks.objects",  _LOCK_OBJECTS,  ttl=10)

        # PDB sessions — distribute active sessions across APPDB and REPORTDB
        pdb_list = []
        for p in _PDBS:
            cid = p["con_id"]
            if cid == 3:   # APPDB
                asess = active_sessions * 2 // 3 + random.randint(0, 3)
                tsess = total_sessions * 2 // 3
            elif cid == 4:  # REPORTDB
                asess = active_sessions // 3
                tsess = total_sessions // 3
            else:
                asess = 0
                tsess = 0
            pdb_list.append({**p, "active_sessions": asess, "total_sessions": tsess})
        c.set("pdb.list", pdb_list, ttl=10)

        # Exadata — fluctuating Smart Scan / Flash Cache metrics
        smart_pct   = max(10, min(98, 82 + 8 * math.sin(t * 0.2) + random.uniform(-3, 3)))
        offload_pct = max(10, min(99, 91 + 5 * math.sin(t * 0.3) + random.uniform(-2, 2)))
        storidx_pct = max(10, min(80, 46 + 12 * math.sin(t * 0.25) + random.uniform(-4, 4)))
        flash_pct   = max(10, min(99, 88 + 6 * math.sin(t * 0.18) + random.uniform(-2, 2)))
        elig_gb     = max(10, 840 + 60 * math.sin(t * 0.1) + random.uniform(-20, 20))
        ret_gb      = elig_gb * (1 - offload_pct / 100)
        saved_gb    = elig_gb * storidx_pct / 100
        flash_hits  = int(abs(1842000 * (1 + random.uniform(-0.05, 0.05))))
        c.set("exa.smart_scan", {
            "smart_scan_pct":         round(smart_pct, 1),
            "offload_efficiency_pct": round(offload_pct, 1),
            "storage_index_pct":      round(storidx_pct, 1),
            "eligible_gb":            round(elig_gb, 1),
            "returned_gb":            round(ret_gb, 1),
            "saved_by_storage_index_gb": round(saved_gb, 1),
        }, ttl=10)
        c.set("exa.flash_cache", {
            "hit_pct": round(flash_pct, 1),
            "hits":    flash_hits,
            "reads":   int(flash_hits / max(flash_pct / 100, 0.01)),
        }, ttl=10)

        # RMAN active monitor — progress advances each tick
        rman_pct = min(99.0, 41.0 + t * self.interval * 0.05)
        sofar_mb = round(44800 * rman_pct / 100, 0)
        eta_secs = max(0, int((44800 - sofar_mb) / 7.5))
        rman_sessions = _RMAN_SESSIONS   # sessions don't change
        rman_longops  = [
            {**_RMAN_LONGOPS[0], "sofar": sofar_mb,          "pct_complete": rman_pct,
             "time_remaining": eta_secs, "elapsed_secs": 2520 + t * self.interval},
            {**_RMAN_LONGOPS[1], "sofar": sofar_mb + 768,    "pct_complete": min(99, rman_pct + 1.7),
             "time_remaining": max(0, eta_secs - 90), "elapsed_secs": 2520 + t * self.interval},
        ]
        rman_disk_io = [
            {**_RMAN_DISK_IO[0], "sofar_mb": sofar_mb,       "pct_complete": rman_pct},
            {**_RMAN_DISK_IO[1], "sofar_mb": sofar_mb + 768, "pct_complete": min(99, rman_pct + 1.7)},
        ]
        rman_summary = {
            **_RMAN_PERF_SUMMARY,
            "avg_pct_complete": rman_pct,
            "total_processed_gb": round(sofar_mb * 2 / 1024, 2),
            "max_eta_secs": eta_secs,
        }
        c.set("rman.sessions",     rman_sessions, ttl=10)
        c.set("rman.longops",      rman_longops,  ttl=10)
        c.set("rman.disk_io",      rman_disk_io,  ttl=10)
        c.set("rman.wait_events",  _RMAN_WAIT_EVENTS, ttl=10)
        c.set("rman.tape_io",      [],            ttl=10)
        c.set("rman.perf_summary", rman_summary,  ttl=10)

        # Cell waits — fluctuate total_waits slightly
        cw = []
        for i, w in enumerate(_EXA_CELL_WAITS):
            cw.append({
                **w,
                "total_waits":      int(w["total_waits"] * (1 + random.uniform(-0.03, 0.03))),
                "time_waited_secs": round(w["time_waited_secs"] * (1 + random.uniform(-0.03, 0.03)), 2),
            })
        c.set("exa.cell_waits", cw, ttl=10)

    # ── Helpers ───────────────────────────────────────────────────────

    @staticmethod
    def _fake_gc_stats() -> list[dict]:
        return [
            {"inst_id": 1, "gc_cr_blocks_received": random.randint(12000, 15000),
             "gc_current_blocks_received": random.randint(8000, 10000),
             "gc_latency_ms": round(random.uniform(0.8, 2.4), 2)},
            {"inst_id": 2, "gc_cr_blocks_received": random.randint(11000, 14000),
             "gc_current_blocks_received": random.randint(7500, 9500),
             "gc_latency_ms": round(random.uniform(0.9, 2.6), 2)},
        ]

    @staticmethod
    def _fake_ash() -> list[dict]:
        events = [
            "db file sequential read", "log file sync", "CPU",
            "buffer busy waits", "db file parallel read",
        ]
        samples = []
        base = datetime.now() - timedelta(minutes=30)
        for i in range(120):
            samples.append({
                "sample_time":     base + timedelta(seconds=i * 15),
                "session_id":      random.randint(50, 400),
                "sql_id":          random.choice(["3yru4fqvqpzwm", "8fkg2hzmdq1wx", "2mx8vbwqc5pla", None]),
                "event":           random.choice(events),
                "wait_class":      "User I/O" if "file" in random.choice(events) else "Commit",
                "session_state":   random.choice(["WAITING", "ON CPU"]),
                "inst_id":         random.choice([1, 2]),
            })
        return samples

    @staticmethod
    def _fake_snapshots() -> list[dict]:
        snaps = []
        base = datetime.now() - timedelta(hours=24)
        for i in range(25):
            snaps.append({
                "snap_id":       1000 + i,
                "begin_snap_id": 999 + i,
                "begin_time":    base + timedelta(hours=i),
                "end_time":      base + timedelta(hours=i + 1),
                "elapsed_secs":  3600,
                "dbtime_secs":   round(random.uniform(800, 3200), 0),
            })
        return snaps

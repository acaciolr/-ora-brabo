select inst_id,
       sql_id,
	   sql_profile,
       child_number child,
       plan_hash_value plan_hash,
       executions execs,
       (elapsed_time / 1000000) /
       decode(nvl(executions, 0), 0, 1, executions) /
       decode(px_servers_executions,
              0,
              1,
              px_servers_executions /
              decode(nvl(executions, 0), 0, 1, executions)) avg_etime,
       px_servers_executions / decode(nvl(executions, 0), 0, 1, executions) avg_px,
       decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES, 0, 'No', 'Yes') Offload,
       decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,
              0,
              0,
              100 * (IO_CELL_OFFLOAD_ELIGIBLE_BYTES - IO_INTERCONNECT_BYTES) /
              decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,
                     0,
                     1,
                     IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%",
       first_load_time,
       last_load_time,
       last_active_time
  from gv$sql s
 where sql_text not like 'BEGIN :sql_text := %'
   and sql_text not like '%IO_CELL_OFFLOAD_ELIGIBLE_BYTES%'
   and sql_text not like '/* SQL Analyze(%'
   and sql_id = '&SQLID'
 order by 1, 2, 3;
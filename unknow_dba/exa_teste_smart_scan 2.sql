create table sh.big_t tablespace sh_data as select * from all_objects;

insert into sh.big_t select * from sh.big_t;
insert into sh.big_t select * from sh.big_t;
insert into sh.big_t select * from sh.big_t;
insert into sh.big_t select * from sh.big_t;
insert into sh.big_t select * from sh.big_t;
insert into sh.big_t select * from sh.big_t;
insert into sh.big_t select * from sh.big_t;


select /*+ OPT_PARAM('cell_offload_processing' 'false') */ max(created) from sh.big_t;

select s.name, m.value/1024/1024 mb from v$mystat m, v$sysstat s where m.statistic#=s.statistic# and s.name like '%physical IO%';

select owner, segment_name, segment_type, bytes/1024/1024 mb from dba_segments where segment_name='BIG_T';

alter session set "_serial_direct_read" = always;

select /*+ OPT_PARAM('cell_offload_processing' 'true') */ max(created) from sh.big_t;

select  max(created) from sh.big_t;

select 'alter index '|| owner ||'.'||index_name||' unusable;' from dba_indexes where owner ='SH';

----------------------------------------------------------------------------------------------------------------------------------------


select /* single-col */ avg(prod_id) from sh.sales;

select /* multi-col */ avg(prod_id), sum(cust_id), sum(channel_id) from sh.sales;

col sql_text for a90
select sql_id, sql_text from v$sql where regexp_like(sql_text,'(single|multi)-col');


@fsx4.sql
set verify off
set pagesize 999
set lines 190
col sql_text format a40 trunc
col child format 99999 heading CHILD
col execs format 9,999,999
col avg_etime format 99,999.99
col avg_cpu  format 9,999,999.99
col avg_lio format 999,999,999
col avg_pio format 999,999,999
col "IO_SAVED_%" format 999.99
col avg_px format 999
col offload for a7

select sql_id, child_number child, 
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,
100*(IO_CELL_OFFLOAD_ELIGIBLE_BYTES-IO_INTERCONNECT_BYTES)
/decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%",
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, 
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,buffer_gets/decode(nvl(executions,0),0,1,executions),null) avg_lio,
decode(IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,disk_reads/decode(nvl(executions,0),0,1,executions),null) avg_pio,
sql_text 
from v$sql s
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like 'BEGIN :sql_text := %'
and sql_text not like '%IO_CELL_OFFLOAD_ELIGIBLE_BYTES%'
and sql_id like nvl('&sql_id',sql_id)
order by 1, 2, 3
/
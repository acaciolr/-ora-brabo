col base         new_value banco    noprint
col ndate        new_value datevar  noprint
col ndate2       new_value datevar2 noprint
col sid          new_value nombase  noprint
col server       new_value host     noprint

select substr(host_name,1,14) server from v$instance;
select to_char(sysdate,'dd/mm/yyyy hh24miss') ndate from dual;
select to_char(sysdate,'RRMM') ndate2 from dual;
select name sid from v$database;

col "Tamanho em Gb." format 999,999,999,999.99 heading "Tamanho em Gb."
set termout off lines 80 feed off
spool /home/oracle/exttable/rel_tamanho_base_&host._&nombase._&datevar2..inf

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') Dia from dual;
select name Banco from v$database;
select
( select sum(bytes)/1024/1024/1024 data_size from dba_data_files ) +
( select nvl(sum(bytes),0)/1024/1024/1024 temp_size from dba_temp_files ) +
( select sum(bytes)/1024/1024/1024 redo_size from sys.v_$log ) +
( select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 controlfile_size from v$controlfile) "Tamanho em Gb."
from
dual;

spool off
quit


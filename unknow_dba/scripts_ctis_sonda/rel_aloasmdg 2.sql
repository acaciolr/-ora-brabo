set termout on lines 93 pages 33
col base         new_value banco    noprint
col ndate        new_value datevar  noprint
col ndate2       new_value datevar2 noprint
col sid          new_value nombase  noprint
col server       new_value host     noprint

select substr(host_name,1,14) server from v$instance;
select to_char(sysdate,'dd/mm/yyyy hh24miss') ndate from dual;
select to_char(sysdate,'RRMM') ndate2 from dual;
select name sid from v$database;

spool /home/oracle/exttable/rel_alocacao_asmdg_&host._&nombase._&datevar2..inf

ttitle on
ttitle center 'RELATORIO DE ALOCACAO ASM DG DO BANCO: ' nombase skip 2

col name        format a15
col state       format a10 
col type        format a8
col total_MB    format 99,999,999.99 heading "Usado|Grupo Gb"
col free_MB     format 99,999,999.99 heading "Livre|Grupo Gb"
col percentage  format 99,999,999.99 heading "Percetual|Livre"

compute sum label "Total: " of total_MB   on report
compute sum label "Total: " of free_MB    on report
compute sum label "Total: " of percentage on report

select GROUP_NUMBER DG#, 
       name, 
       STATE,
       TYPE, 
       ((total_mb/1024)/1024) TOTAL_MB, 
       ((free_mb/1024)/1024)  FREE_MB,
       free_mb/total_mb*100 as percentage
from v$asm_diskgroup
order by 2;
quit



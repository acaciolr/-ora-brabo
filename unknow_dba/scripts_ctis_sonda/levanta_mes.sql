lter Session Set nls_language='BRAZILIAN PORTUGUESE';
Alter Session Set NLS_TERRITORY= 'BRAZIL';
Alter Session Set NLS_NUMERIC_CHARACTERS=',.';
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set lines 75
set pages 294

col dthori noprint  new_value dthore
col base   noprint  new_value banco
col server noprint  new_value host
col sid    noprint  new_value mombase
col server noprint  new_value host
col ncl    format a4 noprint  new_value procs
col DiaUp  format a4 noprint  new_value Ativo

select substr(host_name,1,14) server from v$instance;
Select to_char(sysdate,'rrmmdd') dthori from dual;
select instance base from v$thread;
select substr(host_name,1,14) server from v$instance;
select name sid from v$database;
Select to_char(sysdate,'rrrr-mm-dd-hh24mi') ndate from dual;
select distinct(qtdedcore) ncl from monit_server2;
select substr(max(ativadia),1,8) DiaUp from monit_server2;

col Dia       format date            HEADING "DIA"
col serverid  format a15             HEADING "Servidor"
col ativadia  format 99999           HEADING "Ativo| A Dias"
col MEMOLIVRE format 999,999.99      HEADING "Memoria|Livre Gb"
col Swapusado format 999,999.99      HEADING "Swap|Usado"
col qtdedcore format 9999999         HEADING "Nucleos"
col CPUSFREE  format 999,999.99      HEADING "% CPU Free|VMSTAT"
col CPULivre  format 999,999.99      HEADING "% CPU Livre|SAR"
col temprede  format 999.99          HEADING "Tempo|Rede MS"
col loadaver  format 999.99          HEADING "% de |Carga"

--break on Hora
break on Dia skip 1 on serverid skip 1

/*
-- Gera estatistica por hora
compute avg of MEMOLIVRE on Hora
compute avg of CPU_Livre on Hora
compute avg of temprede  on Hora
compute avg of loadaver  on Hora
compute avg of Swapusado on Hora
*/
-- Gera estatistica por Dia
compute avg of MEMOLIVRE on dia
compute avg of CPUFREE   on dia
compute avg of CPULivre  on dia
compute avg of temprede  on dia
compute avg of loadaver  on dia
compute avg of Swapusado on dia
/*
-- Gera O resultato total no final do relatorio.
compute avg of MEMOLIVRE on report skip 1
compute avg of CPU_Livre on report skip 1
compute avg of temprede  on report skip 1
compute avg of loadaver  on report skip 1
compute avg of Swapusado on report skip 1
*/

TTITLE CENTER 'Carga do servidor ' host ', Dias ativo: ' Ativo ', Nucleos: ' procs skip 2

spool /home/oracle/exttable/carga_processa_&host._&dthore..inf

select to_char(dia,'DD/MM/RRRR') Dia,
--               substr(hora,1,2) Hora,
--               serverid,
--               ativadia,
               (MEMOLIVRE/1024/1024) MEMOLIVRE,
               (Swapusado/1024) Swapusado,
--               qtdedcore,
               CPUSFREE,
							 CPULivre,
               temprede,
               loadaver
from monit_server2
order by Dia,hora;

spool off
ttitle off
quit



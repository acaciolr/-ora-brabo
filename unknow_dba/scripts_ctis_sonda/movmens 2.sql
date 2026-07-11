-- Mapa de movimentação de dados 9i/10g/11g/12c movmens.sql
-- Atencao para o parametro control_file_record_keep_time
set feedback off echo off trims off veri on termout off feed 300
set pagesize 	3000
set linesize    148
alter session set optimizer_mode=choose;
alter session set cursor_sharing=exact;

col total_diario format 9,999 heading "Total|Dia"
col MOV_MB       format 99999999.99 heading "Movimenta| Megas"
col tamanho      format 999,999.00  new_value mb noprint
col base         new_value banco    noprint
col ndate        new_value datevar  noprint
col ndate2       new_value datevar2 noprint
col sid          new_value nombase  noprint
col server       new_value host     noprint            

col 00 format 999 

select substr(host_name,1,14) server from v$instance;
select distinct(bytes) tamanho from v$log;
select to_char(sysdate,'dd/mm/yyyy hh24miss') ndate from dual; 
select to_char(sysdate,'RRMM') ndate2 from dual; 
select name sid from v$database; 

break on mes skip 1 on report

ttitle on

ttitle center 'RELATORIO DE QUANTIDADE E TAMANHO DE TRANSACOES DIARIAS DO BANCO: ' nombase left datevar skip 2  
compute sum of total_diario 	on mes
compute sum of MOV_MB 	        on mes

compute sum of total_diario 	on report
compute sum of MOV_MB 	        on report

compute avg of total_diario 	on report
compute avg of MOV_MB 	        on report

--spool /home/oracle/exttable/rel_movimentacao_&host._&nombase._&datevar2..inf
spool /home/oracle/exttable/rel_mov_anali_&host._&nombase._&datevar2..inf

set termout on

select 	
        substr(to_char(first_time,'YYYY-MM-DD'),6,2) mes,
        substr(to_char(first_time,'YYYY-MM-DD'),9,2) dia,
        to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)),'999')  "  00",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)),'999')  "  01",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)),'999')  "  02",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)),'999')  "  03",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)),'999')  "  04",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)),'999')  "  05",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)),'999')  "  06",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)),'999')  "  07",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)),'999')  "  08",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)),'999')  "  09",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)),'999')  "  10",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)),'999')  "  11",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)),'999')  "  12",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)),'999')  "  13",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)),'999')  "  14",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)),'999')  "  15",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)),'999')  "  16",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)),'999')  "  17",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)),'999')  "  18",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)),'999')  "  19",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)),'999')  "  20",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)),'999')  "  21",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)),'999')  "  22",
	to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)),'999')  "  23",
	sum									        
	   (
	    decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)+
	    decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)
								   ) total_diario,
	    sum
	       ((
		decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)+
		decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)
		                                                        ) * &mb. /1024/1024) MOV_MB
from v$log_history
group by substr(to_char(first_time,'YYYY-MM-DD'),6,2), substr(to_char(first_time,'YYYY-MM-DD'),9,2)
order by 1,2	 
/
spool off
quit


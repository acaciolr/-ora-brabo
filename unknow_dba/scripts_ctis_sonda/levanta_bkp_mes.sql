--# Pl/Sql que faz o levantamento do tamanho e tempo de BKP da base.
--# Criado Por: Hiran Horta - Serpro - 20/12/2017
--# Deve ser executado para cada base - nao para cada sid.
--# Vai gerar um arquivo contendo as informacoes a serem colocadas nas planilhas.

set lines 104
set pages 100

col base         new_value banco    noprint
col ndate        new_value datevar  noprint
col ndate2       new_value datevar2 noprint
col sid          new_value nombase  noprint
col server       new_value host     noprint            

select substr(host_name,1,14) server from v$instance;
select to_char(sysdate,'dd/mm/yyyy hh24miss') ndate from dual; 
select to_char(sysdate,'RRMM') ndate2 from dual; 
select name sid from v$database; 
col df for 9,999

col i0 for 9,999
col i1 for 9,999
col l for 9,999
col output_mbytes      for 999,999.99  heading "GBYTES"
col status             for a10 trunc
col time_taken_display for a10         heading "Tempo"
col output_instance    for 9999        heading "OUT|INST"
col nivel              for 99999       heading "Nivel"
col input_type         for a11         heading "Tipo de|Backup"

spool /home/oracle/exttable/rel_tempoeatmanho_BKP_&host._&nombase._&datevar2..inf

set termout on

ttitle on

ttitle center 'RELATORIO DE TEMPO E TAMANHO DO BACKUP DO BANCO: ' nombase skip 2  

select
  to_char(j.start_time, 'dd-mm-rr hh24:mi') Inicio,
  to_char(j.end_time, 'dd-mm-rr hh24:mi') Fim,
  j.time_taken_display,
  (j.output_bytes/1024/1024/1024) output_mbytes, 
  j.status, 
  j.input_type input_type,
  decode(to_char(j.start_time, 'd'), 1, 'Domingo', 2, 'Segunda',
                                     3, 'Terca', 4, 'Quarta',
                                     5, 'Quinta', 6, 'Sexta',
                                     7, 'Sabado') Dia,
  decode(x.l,0,'Bkp Full',
             'Incremental') Nivel 
  /*, x.cf, x.df, x.i0, x.i1,ro.inst_id output_instance */
from v$RMAN_BACKUP_JOB_DETAILS j
  left outer join (select
                     d.session_recid, d.session_stamp,
                     sum(case when d.controlfile_included = 'YES' then d.pieces else 0 end) CF,
                     sum(case when d.controlfile_included = 'NO'
                               and d.backup_type||d.incremental_level = 'D' then d.pieces else 0 end) DF,
                     sum(case when d.backup_type||d.incremental_level = 'D0' then d.pieces else 0 end) I0,
                     sum(case when d.backup_type||d.incremental_level = 'I1' then d.pieces else 0 end) I1,
                     sum(case when d.backup_type = 'L' then d.pieces else 0 end) L
                   from
                     v$BACKUP_SET_DETAILS d
                     join v$BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
                   where s.input_file_scan_only = 'NO'
                   group by d.session_recid, d.session_stamp) x
    on x.session_recid = j.session_recid and x.session_stamp = j.session_stamp
  left outer join (select o.session_recid, o.session_stamp, min(inst_id) inst_id
                   from Gv$RMAN_OUTPUT o
                   group by o.session_recid, o.session_stamp)
    ro on ro.session_recid = j.session_recid and ro.session_stamp = j.session_stamp
where j.start_time > trunc(sysdate)-8
order by j.start_time
/
quit



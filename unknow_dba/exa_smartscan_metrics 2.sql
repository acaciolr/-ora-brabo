--Baixar e instalar o EXADATA SNAPPER
--1) Para instalação do EXADATA SNAPPER acesse o site http://blog.tanelpoder.com/files/ e clique no item 2. Download all my TPT scripts as a .zip file
--2) Descompacte o arquivo “tpt_public.zip” em um diretório no seu computador
--3) Dentro desse diretório será criado o diretório “scripts” que contem outros diretórios, acesse o diretório exadata onde se encontra o script “exasnapper_install_latest.sql”
--4) Para executar esse script de instalação o usuário do banco no qual será instalado o EXASNAPPER precisa ter as seguintes permissões:
--
--Privilégio SELECT ANY DICTIONARY ou privilégio de SELECT nas visões GV$ referenciadas no script;
--Privilégio EXECUTE no pacote SYS.DBMS_LOCK
--
--5) Utilizando um cliente oracle conectado com o usuário que recebeu os privilégios acima, execute o script “exasnapper_install_latest.sql”

--Criar uma tabela na instância
--Para realizar a demonstração vamos criar um tabela com tamanho de 11GB.

SQL > SELECT * FROM V$VERSION where rownum < 2;

BANNER
--------------------------------------------------------------------------------
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production

SQL > ALTER SESSION SET WORKAREA_SIZE_POLICY=MANUAL;

Sessão alterada.

SQL > ALTER SESSION SET SORT_AREA_SIZE=2000000000;

Sessão alterada.

SQL > CREATE TABLE dbtw01 AS
  2     SELECT 'ABC'||LPAD(MOD(ROWNUM,40617473),80,0) AS texto,
  3            mod(rownum,11) AS situacao,
  4            'XPT'||LPAD(MOD(ROWNUM,4500),100,0) AS texto2,
  5            'XYZ'||LPAD(MOD(ROWNUM+40000,787648),60,0) AS texto3,
  6            SYSDATE-ROUND(ROWNUM/30,0)                    AS data_criacao
  7       FROM dual CONNECT BY LEVEL<=40617473;

Tabela criada.

SQL > select round(bytes/1024/1024/1024,1) as "Tamanho GB"
  2    from user_segments
  3   where segment_name = 'DBTW01';

Tamanho GB
----------
      11,5

SQL > EXEC DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=> USER, TABNAME=> 'DBTW01', CASCADE=> TRUE, METHOD_OPT=> 'FOR ALL COLUMNS SIZE SKEWONLY', DEGREE=>18);

Procedimento PL/SQL concluído com sucesso.

SQL >
 

--Consulta com as funções Exadata desativadas
--Vamos executar uma consulta na tabela criada e inicialmente vamos desativar algumas funções a nível de sessão utilizando parâmetros não documentos.

SQL > SET TAB OFF;
SQL >
SQL > -- Permite a exibição das estatísticas de execução da consulta
SQL > ALTER SESSION SET statistics_level = ALL;

Sessão alterada.

SQL > -- Desativa a função Storage Index do Exadata
SQL > ALTER SESSION SET "_kcfis_storageidx_disabled" = TRUE;

Sessão alterada.

SQL > -- Desativa a leitura de blocos direta sem a passagem pelo Buffer Cache
SQL > ALTER SESSION SET "_serial_direct_read" = FALSE;

Sessão alterada.

SQL > COL NAME FOR A300
SQL >
SQL > -- Definição das variáveis que serão utilizadas no EXASNAPPER
SQL > variable b NUMBER;
SQL > variable e NUMBER;
SQL >
SQL > -- Gera um snapshot das estatisticas e atualiza a variavel "b" com o valor do snap_id antes da execução da consulta
SQL > EXEC :b := exasnap.begin_snap;

Procedimento PL/SQL concluído com sucesso.

SQL > SELECT /* DBTW001 */ situacao, COUNT(1) qtde
  2    FROM dbtw01
  3   WHERE data_criacao BETWEEN SYSDATE-120 AND SYSDATE-30
  4      OR data_criacao BETWEEN SYSDATE-720 AND SYSDATE-630
  5      OR data_criacao BETWEEN SYSDATE-1320 AND SYSDATE-1230
  6      OR data_criacao BETWEEN SYSDATE-1920 AND SYSDATE-1830
  7      OR data_criacao BETWEEN SYSDATE-2520 AND SYSDATE-2430
  8   GROUP BY situacao;

  SITUACAO       QTDE
---------- ----------
         1       1228
         6       1227
         2       1227
         4       1228
         5       1228
         8       1228
         3       1227
         7       1227
         9       1227
        10       1226
         0       1227

11 linhas selecionadas.

Decorrido: 00:00:04.79
SQL > -- Gera um snapshot das estatisticas e atualiza a variavel "e" com o valor do snap_id após da execução da consulta
SQL > EXEC :e := exasnap.end_snap;

Procedimento PL/SQL concluído com sucesso.

SQL > -- Recupera o SQL_ID e o CHILD_NUMBER  da consulta executada
SQL > column sql_id new_value m_sql_id
SQL > column child_number new_value m_child_no
SQL > SELECT sql_id, child_number
  2    FROM v$sql
  3   WHERE sql_text LIKE '%DBTW001%'
  4     AND sql_text NOT LIKE '%v$sql%';

SQL_ID        CHILD_NUMBER
------------- ------------
fmwugmvdrxtuc            1

SQL > -- Gera o relatório do plano de execução da consulta
SQL > SELECT * FROM TABLE (dbms_xplan.display_cursor ('&m_sql_id',&m_child_no,'typical iostats last'));

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  fmwugmvdrxtuc, child number 1
-------------------------------------
SELECT /* DBTW001 */ situacao, COUNT(1) qtde   FROM dbtw01  WHERE
data_criacao BETWEEN SYSDATE-120 AND SYSDATE-30     OR data_criacao
BETWEEN SYSDATE-720 AND SYSDATE-630     OR data_criacao BETWEEN
SYSDATE-1320 AND SYSDATE-1230     OR data_criacao BETWEEN SYSDATE-1920
AND SYSDATE-1830     OR data_criacao BETWEEN SYSDATE-2520 AND
SYSDATE-2430  GROUP BY situacao

Plan hash value: 1822618879

----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name   | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers | Reads  |
----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |        |      1 |        |       |   191K(100)|          |     11 |00:00:04.67 |    1504K|   1504K|
|   1 |  HASH GROUP BY             |        |      1 |     11 |   121 |   191K  (2)| 00:54:11 |     11 |00:00:04.67 |    1504K|   1504K|
|*  2 |   TABLE ACCESS STORAGE FULL| DBTW01 |      1 |  13799 |   148K|   191K  (2)| 00:54:11 |  13500 |00:00:04.67 |    1504K|   1504K|
----------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - storage((("DATA_CRIACAO">=SYSDATE@!-120 AND "DATA_CRIACAO"<=SYSDATE@!-30) OR ("DATA_CRIACAO">=SYSDATE@!-720 AND
              "DATA_CRIACAO"<=SYSDATE@!-630) OR ("DATA_CRIACAO">=SYSDATE@!-1320 AND "DATA_CRIACAO"<=SYSDATE@!-1230) OR
              ("DATA_CRIACAO">=SYSDATE@!-1920 AND "DATA_CRIACAO"<=SYSDATE@!-1830) OR ("DATA_CRIACAO">=SYSDATE@!-2520 AND
              "DATA_CRIACAO"<=SYSDATE@!-2430)))
       filter((("DATA_CRIACAO">=SYSDATE@!-120 AND "DATA_CRIACAO"<=SYSDATE@!-30) OR ("DATA_CRIACAO">=SYSDATE@!-720 AND
              "DATA_CRIACAO"<=SYSDATE@!-630) OR ("DATA_CRIACAO">=SYSDATE@!-1320 AND "DATA_CRIACAO"<=SYSDATE@!-1230) OR
              ("DATA_CRIACAO">=SYSDATE@!-1920 AND "DATA_CRIACAO"<=SYSDATE@!-1830) OR ("DATA_CRIACAO">=SYSDATE@!-2520 AND
              "DATA_CRIACAO"<=SYSDATE@!-2430)))


31 linhas selecionadas.

SQL >
 
--Examinando o plano de execução verificamos que a tabela foi lida utilizando a operação “TABLE ACCESS STORAGE FULL”, esta operação não garante que os dados foram recuperados do Storage Server utilizando o Smart Scan, mas quando presente indica que o Storage Server pode utilizar Smart Scan.
--
--Da mesma forma devemos interpretar a existência da cláusula “storage()” na seção “Predicate Information”.

SQL > -- Gera o relatório com as estatísticas da consulta no Storage Server
SQL > SELECT * FROM TABLE(exasnap.display_snap(:b, :e));

NAME
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ExaSnapper v0.81 BETA by Tanel Poder @ Enkitec - The Exadata Experts ( http://www.enkitec.com )
---------------------------------------------------------------------------------------------------------------------------------------------------------
DB_LAYER_IO                    DB_PHYSIO_BYTES               |##################################################|          11753 MB           2007 MB/sec
DB_LAYER_IO                    DB_PHYSRD_BYTES               |##################################################|          11753 MB           2007 MB/sec
DB_LAYER_IO                    DB_PHYSWR_BYTES               |                                                  |              0 MB              0 MB/sec
AVOID_DISK_IO                  PHYRD_FLASH_RD_BYTES          |                                                  |              0 MB              0 MB/sec
AVOID_DISK_IO                  PHYRD_STORIDX_SAVED_BYTES     |                                                  |              0 MB              0 MB/sec
REAL_DISK_IO                   SPIN_DISK_IO_BYTES            |##################################################|          11753 MB           2007 MB/sec
REAL_DISK_IO                   SPIN_DISK_RD_BYTES            |##################################################|          11753 MB           2007 MB/sec
REAL_DISK_IO                   SPIN_DISK_WR_BYTES            |                                                  |              0 MB              0 MB/sec
REDUCE_INTERCONNECT            PRED_OFFLOADABLE_BYTES        |##################################################|          11753 MB           2007 MB/sec
REDUCE_INTERCONNECT            TOTAL_IC_BYTES                |                                                  |              2 MB              0 MB/sec
REDUCE_INTERCONNECT            SMART_SCAN_RET_BYTES          |                                                  |              2 MB              0 MB/sec
REDUCE_INTERCONNECT            NON_SMART_SCAN_BYTES          |                                                  |              0 MB              0 MB/sec
CELL_PROC_DEPTH                CELL_PROC_DATA_BYTES          |##################################################|          11753 MB           2007 MB/sec
CELL_PROC_DEPTH                CELL_PROC_INDEX_BYTES         |                                                  |              0 MB              0 MB/sec
CLIENT_COMMUNICATION           NET_TO_CLIENT_BYTES           |                                                  |              0 MB              0 MB/sec
CLIENT_COMMUNICATION           NET_FROM_CLIENT_BYTES         |                                                  |              0 MB              0 MB/sec

18 linhas selecionadas.

SQL >
 

--No relatório gerado pelo EXASNAPPER temos as informações detalhadas do que ocorreu no STORAGE SERVER:
--
--DB_LAYER_IO – DB_PHYSIO_BYTES  
--
--Quantidade de I/O em bytes que o banco de dados espera realizar com Storage Server baseado em seu dicionario de dados.
--
--DB_LAYER_IO – DB_PHYSRD_BYTES
--
--Quantidade de bytes que o banco de dados espera recuperar do Storage Server baseado em seu dicionario de dados.
--
--REAL_DISK_IO – SPIN_DISK_IO_BYTES
--
--Quantidade de I/O físico em bytes que o Storage Server realizou durante a execução consulta.
--
--REAL_DISK_IO – SPIN_DISK_RD_BYTES
--
--Quantidade de leitura física em bytes realizada pelo Storage Server durante a execução consulta.
--
--REDUCE_INTERCONNECT – PRED_OFFLOADABLE_BYTES
--
--Quantidade de bytes que pode ser processado a nível de Storage Server durante a execução consulta.
--
--REDUCE_INTERCONNECT – TOTAL_IC_BYTES
--
--Quantidade de bytes que trafegou pelo INTERCONNECT entre o Banco de dados e o Storage Server.
--
--REDUCE_INTERCONNECT – SMART_SCAN_RET_BYTES

--Quantidade de bytes que foi retornada para o banco de dados como resultado do processamento do Smart Scan.
--
--CELL_PROC_DEPTH – CELL_PROC_DATA_BYTES
--
--Quantidade de bytes de dados processados no Storage Server.
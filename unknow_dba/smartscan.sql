/*
Quando uma instrução SQL é executada numa base Oracle utilizando uma plataforma tradicional (Unix-like, Microsoft,…) somos capazes de obter as estatísticas desta execução com detalhes suficientes para determinar onde está o gargalo desta instrução através do pacote DBMS_XPLAN. Na plataforma Exadata muitas funções são executadas no Storage Server durante a execução da instrução SQL e as estatísticas destas funções não estão disponíveis no pacote DBMS_XPLAN, portanto quando analisamos uma plano de execução de uma instrução SQL executada na plataforma Exadata muitas perguntas ficam sem resposta se utilizarmos exclusivamente este pacote:

1) Qual a quantidade de I/O físico real que foi realizada?
2) Quanto desse I/O foi leitura e quanto foi gravação?
3) Qual a quantidade de I/O que foi evitada devido ao recurso Flash Cache?
4) Qual a quantidade de I/O que foi evitada devido ao recurso Storage Indexes?
5) Qual foi o trafego total pelo Interconnect?
6) Qual a quantidade de dados que foi totalmente processada no Storage Server?
7) Qual a quantidade de dados que foi retornada para o Database Server pelo Smart Scan?

Neste artigo vamos fazer uma demonstração de uma ferramenta desenvolvida por Tanel Poder que fornece respostas para todos estas perguntas e permite a visualização de todas estas informações para instruções SQL executadas na plataforma Exadata, possibilitando uma analise de performance completa e a identificação de eventuais gargalos.
https://tanelpoder.com/2013/02/22/exasnapper-0-7-beta-download-and-the-hacking-session-videos/
*/

Roteiro da demonstração
Para demonstrar a utilização da ferramenta EXADATA SNAPPER vamos realizar a seguintes tarefas:

1) Baixar e instalar o EXADATA SNAPPER numa instância Oracle na plataforma Exadata

2) Criar uma tabela na instância

3) Executar uma consulta na tabela com algumas funções do Exadata desativada a nível de sessão

4) Executar a consulta novamente com as funções ativadas a nível de sessão

Baixar e instalar o EXADATA SNAPPER
1) Para instalação do EXADATA SNAPPER acesse o site http://blog.tanelpoder.com/files/ e clique no item 2. Download all my TPT scripts as a .zip file

2) Descompacte o arquivo “tpt_public.zip” em um diretório no seu computador

3) Dentro desse diretório será criado o diretório “scripts” que contem outros diretórios, acesse o diretório exadata onde se encontra o script “exasnapper_install_latest.sql”

4) Para executar esse script de instalação o usuário do banco no qual será instalado o EXASNAPPER precisa ter as seguintes permissões:

Privilégio SELECT ANY DICTIONARY ou privilégio de SELECT nas visões GV$ referenciadas no script;
Privilégio EXECUTE no pacote SYS.DBMS_LOCK

5) Utilizando um cliente oracle conectado com o usuário que recebeu os privilégios acima, execute o script “exasnapper_install_latest.sql”

Criar uma tabela na instância
Para realizar a demonstração vamos criar um tabela com tamanho de 11GB.

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

/*
Consulta com as funções Exadata desativadas
Vamos executar uma consulta na tabela criada e inicialmente vamos desativar algumas funções a nível de sessão utilizando parâmetros não documentos.
*/

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

/*
Examinando o plano de execução verificamos que a tabela foi lida utilizando a operação “TABLE ACCESS STORAGE FULL”, esta operação não garante que os dados foram recuperados do Storage Server utilizando o Smart Scan, mas quando presente indica que o Storage Server pode utilizar Smart Scan.

Da mesma forma devemos interpretar a existência da cláusula “storage()” na seção “Predicate Information”.
*/

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

DB_LAYER_IO – DB_PHYSIO_BYTES  
--Quantidade de I/O em bytes que o banco de dados espera realizar com Storage Server baseado em seu dicionario de dados.

DB_LAYER_IO – DB_PHYSRD_BYTES
--Quantidade de bytes que o banco de dados espera recuperar do Storage Server baseado em seu dicionario de dados.

REAL_DISK_IO – SPIN_DISK_IO_BYTES
--Quantidade de I/O físico em bytes que o Storage Server realizou durante a execução consulta.

REAL_DISK_IO – SPIN_DISK_RD_BYTES
--Quantidade de leitura física em bytes realizada pelo Storage Server durante a execução consulta.

REDUCE_INTERCONNECT – PRED_OFFLOADABLE_BYTES
--Quantidade de bytes que pode ser processado a nível de Storage Server durante a execução consulta.

REDUCE_INTERCONNECT – TOTAL_IC_BYTES
--Quantidade de bytes que trafegou pelo INTERCONNECT entre o Banco de dados e o Storage Server.

REDUCE_INTERCONNECT – SMART_SCAN_RET_BYTES
--Quantidade de bytes que foi retornada para o banco de dados como resultado do processamento do Smart Scan.

CELL_PROC_DEPTH – CELL_PROC_DATA_BYTES
--Quantidade de bytes de dados processados no Storage Server.
 
/*
Consulta com as funções Exadata ativadas
Agora vamos executar a mesma consulta novamente, só que desta vez vamos ativar as funções que haviam sido desativadas na primeira execução.
*/

SQL > SET TAB OFF;
SQL >
SQL > -- Permite a exibição das estatísticas de execução da consulta
SQL > ALTER SESSION SET statistics_level = ALL;

Sessão alterada.

SQL > -- Ativa a função Storage Index do Exadata
SQL > ALTER SESSION SET "_kcfis_storageidx_disabled" = FALSE;

Sessão alterada.

SQL > -- Permite a leitura de blocos direta sem a passagem pelo Buffer Cache
SQL > ALTER SESSION SET "_serial_direct_read" = AUTO;

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

Decorrido: 00:00:00.84
SQL >
SQL > SELECT /* DBTW003 */ situacao, COUNT(1) qtde
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

SQL > -- Gera um snapshot das estatisticas e atualiza a variavel "e" com o valor do snap_id após da execução da consulta
SQL > EXEC :e := exasnap.end_snap;

Procedimento PL/SQL concluído com sucesso.

SQL > -- Recupera o SQL_ID e o CHILD_NUMBER  da consulta executada
SQL > column sql_id new_value m_sql_id
SQL > column child_number new_value m_child_no
SQL > SELECT sql_id, child_number
  2    FROM v$sql
  3   WHERE sql_text LIKE '%DBTW003%'
  4     AND sql_text NOT LIKE '%v$sql%';

SQL_ID        CHILD_NUMBER
------------- ------------
6cbrtk6rxvaz5            1

SQL > -- Gera o relatório do plano de execução da consulta
SQL > SELECT * FROM TABLE (dbms_xplan.display_cursor ('&m_sql_id',&m_child_no,'typical iostats last'));

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  6cbrtk6rxvaz5, child number 1
-------------------------------------
SELECT /* DBTW003 */ situacao, COUNT(1) qtde   FROM dbtw01  WHERE
data_criacao BETWEEN SYSDATE-120 AND SYSDATE-30     OR data_criacao
BETWEEN SYSDATE-720 AND SYSDATE-630     OR data_criacao BETWEEN
SYSDATE-1320 AND SYSDATE-1230     OR data_criacao BETWEEN SYSDATE-1920
AND SYSDATE-1830     OR data_criacao BETWEEN SYSDATE-2520 AND
SYSDATE-2430  GROUP BY situacao

Plan hash value: 1822618879

----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name   | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers | Reads  |
----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |        |      1 |        |       |   191K(100)|          |     11 |00:00:00.05 |    1504K|   1504K|
|   1 |  HASH GROUP BY             |        |      1 |     11 |   121 |   191K  (2)| 00:54:11 |     11 |00:00:00.05 |    1504K|   1504K|
|*  2 |   TABLE ACCESS STORAGE FULL| DBTW01 |      1 |  13799 |   148K|   191K  (2)| 00:54:11 |  13500 |00:00:00.05 |    1504K|   1504K|
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

/*
Comparando os dois planos de execução acima verificamos que quase todas as informações geradas nos relatórios dos planos de execução são idênticas, a unica exceção é o tempo real de execução da consulta que diminuiu de 4,67 segundos para 5 centésimos de segundo. Para descobrir o por que desta redução drástica no tempo de execução da consulta precisamos analisar as informações geradas pelo EXASNAPPER.
*/

SQL > -- Gera o relatório com as estatísticas da consulta no Storage Server
SQL > SELECT * FROM TABLE(exasnap.display_snap(:b, :e));

NAME
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ExaSnapper v0.81 BETA by Tanel Poder @ Enkitec - The Exadata Experts ( http://www.enkitec.com )
---------------------------------------------------------------------------------------------------------------------------------------------------------
DB_LAYER_IO                    DB_PHYSIO_BYTES               |##################################################|          11753 MB          10750 MB/sec
DB_LAYER_IO                    DB_PHYSRD_BYTES               |##################################################|          11753 MB          10750 MB/sec
DB_LAYER_IO                    DB_PHYSWR_BYTES               |                                                  |              0 MB              0 MB/sec
AVOID_DISK_IO                  PHYRD_FLASH_RD_BYTES          |                                                  |              1 MB              1 MB/sec
AVOID_DISK_IO                  PHYRD_STORIDX_SAVED_BYTES     |##################################################|          11744 MB          10742 MB/sec
REAL_DISK_IO                   SPIN_DISK_IO_BYTES            |                                                  |              8 MB              7 MB/sec
REAL_DISK_IO                   SPIN_DISK_RD_BYTES            |                                                  |              8 MB              7 MB/sec
REAL_DISK_IO                   SPIN_DISK_WR_BYTES            |                                                  |              0 MB              0 MB/sec
REDUCE_INTERCONNECT            PRED_OFFLOADABLE_BYTES        |##################################################|          11753 MB          10750 MB/sec
REDUCE_INTERCONNECT            TOTAL_IC_BYTES                |                                                  |              0 MB              0 MB/sec
REDUCE_INTERCONNECT            SMART_SCAN_RET_BYTES          |                                                  |              0 MB              0 MB/sec
REDUCE_INTERCONNECT            NON_SMART_SCAN_BYTES          |                                                  |              0 MB              0 MB/sec
CELL_PROC_DEPTH                CELL_PROC_DATA_BYTES          |                                                  |              9 MB              8 MB/sec
CELL_PROC_DEPTH                CELL_PROC_INDEX_BYTES         |                                                  |              0 MB              0 MB/sec
CLIENT_COMMUNICATION           NET_TO_CLIENT_BYTES           |                                                  |              0 MB              0 MB/sec
CLIENT_COMMUNICATION           NET_FROM_CLIENT_BYTES         |                                                  |              0 MB              0 MB/sec

18 linhas selecionadas.

SQL >

--No relatório gerado pelo EXASNAPPER temos as informações detalhadas do que ocorreu no STORAGE SERVER:

DB_LAYER_IO – DB_PHYSIO_BYTES
--Quantidade de I/O em bytes que o banco de dados espera realizar com Storage Server baseado em seu dicionario de dados.

DB_LAYER_IO – DB_PHYSRD_BYTES
--Quantidade de bytes que o banco de dados espera recuperar do Storage Server baseado em seu dicionario de dados.

AVOID_DISK_IO – PHYRD_FLASH_RD_BYTES
--Quantidade de bytes lida direto do Flash Cache.

AVOID_DISK_IO – PHYRD_STORIDX_SAVED_BYTES
--Quantidade de bytes que não foi lida devido a utilização da função Storage Indexes.

REAL_DISK_IO – SPIN_DISK_IO_BYTES
--Quantidade de I/O físico em bytes que o Storage Server realizou durante a execução consulta.

REAL_DISK_IO – SPIN_DISK_RD_BYTES
--Quantidade de leitura física em bytes realizada pelo Storage Server durante a execução consulta.

CELL_PROC_DEPTH – CELL_PROC_DATA_BYTES
--Quantidade de bytes de dados processada no Storage Server.

/*		Conclusão
Comparando as estatísticas dos relatórios EXASNAPPER das duas execuções da consulta, conseguimos entender claramente por que a segunda execução foi muito mais rápida:

1) Na primeira execução da consulta podemos verificar através da categoria REAL_DISK_IO que o Storage Server fez a leitura física de 11.753 MB de dados e na segunda execução se observarmos a categoria AVOID_DISK_IO verificamos que 11.744 MB simplesmente foram ignorados pelo Storage Server devido a ação da função Storage Indexes que evita a leitura de blocos físicos quando estes não contem os dados que atendem aos critérios do filtro da cláusula WHERE. Os demais blocos de dados da segunda execução (9 MB) foram acessados da seguinte forma:

1 MB foi leitura do Flash Cache (Categoria: AVOID_DISK_IO, tipo: PHYRD_FLASH_RD_BYTES)
8 MB foi leitura física (Categoria: REAL_DISK_IO, tipo: SPIN_DISK_RD_BYTES)
2) Outra estatística que teve grande influência no tempo de execução da consulta foi a quantidade de blocos de dados processada pelo Storage Server. Na categoria CELL_PROC_DEPTH verificamos que na primeira execução o Storage Server processou 11.753 MB, enquanto na segunda execução foram somente 9 MB.

3) Finalmente na Categoria REDUCE_INTERCONNECT verificamos que na primeira execução o Storage Server retornou para o Database Server 2 MB, já na segunda execução não houve a necessidade dessa transferência pois o Storage Server retornou para o Database Server o resultado final esperado pela consulta.
*/

--

'physical read total bytes' 								 --  is all the data including compressed data AND SmartScan-ineligible data.
'cell physical IO interconnect bytes'  						 --  includes the writes (multiplied due to ASM mirroring) AND the reads.
'cell IO uncompressed bytes'  								 --  is the data volume for predicate offloading AFTER the Storage Index filtering and any decompression
'cell physical IO interconnect bytes returned by smart scan' --- includes uncompressed data.

"SmartScan Eligibility Ratio"
--What percentage of the total sum of the physical reads are eligible for SmartScan?

= (100 / 'physical read total bytes') * 'cell physical IO bytes eligible for predicate offload'

'physical read total bytes'  							--all non-system data which was read from the storage cells
'cell physical IO bytes eligible for predicate offload' --data that is eligible for SmartScan processing (total direct path reads)

"Storage Index Filter Ratio"
--What percentage of the SmartScan eligible data is filtered by the Storage Indexes?

= (100 / 'cell physical IO bytes eligible for predicate offload') * 'cell physical IO bytes saved by storage index'

'cell physical IO bytes saved by storage index'  --data that the cells did not need to scan through because the storage indexes told them they were not in that region.

"SmartScan Efficiency Ratio"
--What percentage of the SmartScan eligible data size was returned by the SmartScan? This is probably the most-used / "best" ratio to use, if you could only use one.

= 100 --((100 / 'cell physical IO bytes eligible for predicate offload') * 'cell physical IO interconnect bytes returned by smart scan')

'cell physical IO interconnect bytes returned by smart scan'  -- data returned to the database from the SmartScan.

"SmartScan Offloading Ratio"
--What percentage of the uncompressed, filtered data is returned by the SmartScan?

= (100 / 'cell IO uncompressed bytes') * 'cell physical IO interconnect bytes returned by smart scan'

'cell IO uncompressed bytes'  -- data read from the storage cells for predicate offloading, after the storage index filtering and data decompression. N.B. compressed data has to be uncompressed first before applying the predicates on the storage cells.

/*The easiest way to prove you have a Smart Scan working (from the database server side) is to query the V$SQL view (or GV$SQL if you want to check across the RAC cluster). 
There are two ‘counters’ available, which report on Smart Scan activity; these are IO_CELL_OFFLOAD_ELIGIBLE_BYTES and IO_CELL_OFFLOAD_RETURNED_BYTES. 
I’ve used this example in another article but it’s a good example for showing Smart Scan activity so I’ll use it again here:*/

SQL> select *
  2  from emp
  3  where empid = 7934;

     EMPID EMPNAME                                      DEPTNO
---------- ---------------------------------------- ----------
      7934 Smorthorper7934                                  15

Elapsed: 00:00:00.02

Execution Plan
----------------------------------------------------------
Plan hash value: 3956160932

----------------------------------------------------------------------------------
| Id  | Operation                 | Name | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |      |     1 |    26 |  1167   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS STORAGE FULL| EMP  |     1 |    26 |  1167   (1)| 00:00:01 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - storage("EMPID"=7934)
       filter("EMPID"=7934)


Statistics
----------------------------------------------------------
          1  recursive calls
          1  db block gets
       4349  consistent gets
       4276  physical reads
          0  redo size
        680  bytes sent via SQL*Net to client
        524  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

SQL>
SQL> set autotrace off timing off
SQL>
SQL> select       sql_id,
  2          io_cell_offload_eligible_bytes qualifying,
  3          io_cell_offload_returned_bytes actual,
  4          round(((io_cell_offload_eligible_bytes - io_cell_offload_returned_bytes)/io_cell_offload_eligible_bytes)*100, 2) io_saved_pct,
  5          sql_text
  6  from v$sql
  7  where io_cell_offload_returned_bytes > 0
  8  and instr(sql_text, 'emp') > 0
  9  and parsing_schema_name = 'BING';

SQL_ID        QUALIFYING     ACTUAL IO_SAVED_PCT SQL_TEXT
------------- ---------- ---------- ------------ --------------------------------------
gfjb8dpxvpuv6   35028992       6872        99.98 select * from emp where empid = 7934

SQL>

/*
Looking at the output from the V$SQL query we can see that a Smart Scan was executed since we had both eligible and returned bytes from the cell offload process. 
This is probably the quickest and easiest way to verify Smart Scan activity. 
There is another way though, that is a bit more involved but gives more detailed stats on Smart Scan activity. 
This method involves the storage cells and the cellsrvstat program; since it involves the storage cells it can be a bit more work, 
especially if passwordless ssh connectivity isn’t configured between the database servers and the storage cells. 
[I won’t go into configuring that in this article but there are various resources on the Internet available to assist with that task. 
www.google.com is a great place to start looking for those.] 
I will presume that such connectivity is configured; getting these stats is a fairly straightforward task that can be scripted and run from the command line on one of the database servers. 
The script would be similar to this:
*/

#!/bin/ksh

ssh celladmin@exasrv1cel01-priv.mydomain.com  "cellsrvstat -stat_group=smartio -interval=$1 -count=$2"
ssh celladmin@exasrv1cel02-priv.mydomain.com  "cellsrvstat -stat_group=smartio -interval=$1 -count=$2"
ssh celladmin@exasrv1cel03-priv.mydomain.com  "cellsrvstat -stat_group=smartio -interval=$1 -count=$2"

--The script takes two parameters, the sample interval and the count of samples to execute; as an example of how this would look at the Linux command line:

$ cellsrvstat_smartio.sh 5 10
$ cellsrvstat_smartio.sh 5 10 > cellsrvstat_all_cells_smartio.lst

==Current Time===                                      Fri Mar  8 14:37:15 2013

== SmartIO related stats ==
Number of active smart IO sessions                              8             11
High water mark of smart IO sessions                            0            130
Number of completed smart IO sessions                           4        8490054
Smart IO offload efficiency (percentage)                        0              7
Size of IO avoided due to storage index (KB)                    0  2511867327696
Current smart IO to be issued (KB)                              0         214456
Total smart IO to be issued (KB)                            69592  5335617009440
Current smart IO in IO (KB)                                     0              0
Total smart IO in IO (KB)                                   69592  5333234484896
Current smart IO being cached in flash (KB)                     0              0
Total smart IO being cached in flash (KB)                       0              0
Current smart IO with IO completed (KB)                         0           3200
Total smart IO with IO completed (KB)                       69592  5427224552840
Current smart IO being filtered (KB)                            0              0
Total smart IO being filtered (KB)                          69592  5426811394136
Current smart IO filtering completed (KB)                       0          24528
Total smart IO filtering completed (KB)                     69592  5332811276704
Current smart IO filtered size (KB)                             0           8075
Total smart IO filtered (KB)                                13258   378946996063
Total cpu passthru output IO size (KB)                          0      449965296
Total passthru output IO size (KB)                              0      472758949
Current smart IO with results in send (KB)                      0              0
Total smart IO with results in send (KB)                    69592  5332478889672
Current smart IO filtered in send (KB)                          0              0
Total smart IO filtered in send (KB)                        13258   378925244226
Total smart IO read from flash (KB)                             0              0
Total smart IO initiated flash population (KB)                  0              0
Total smart IO read from hard disk (KB)                     69592  2786064722152
Total smart IO writes (fcre) to hard disk (KB)                  0    35298961256
Number of smart IO requests < 512KB                            20      134456077
Number of smart IO requests >= 512KB and < 1MB                 65      116155599
Number of smart IO requests >= 1MB and < 2MB                    3        2226841
Number of smart IO requests >= 2MB and < 4MB                    0      188723594
Number of smart IO requests >= 4MB and < 8MB                    0     1085851766
Number of smart IO requests >= 8MB                              0              0
Size of the smart IO 1MB IO quota being used                    0              0
Hwm of the smart IO 1MB IO quota being used                     0           1002
Number of failures to get 1MB IO quota for smart IO             0         674099
Number of times smart IO buffer reserve failures                0              0
Number of times smart IO request misses                         0         296985
Number of times IO for smart IO not allowed to be issued        0    58504757930
Number of times smart IO prefetch limit was reached             2      125315622
Number of times smart scan used unoptimized mode                0              0
Number of times smart fcre used unoptimized mode                0              0
Number of times smart backup used unoptimized mode              0              0

--

--It’s fairly easy to see how many Smart Scans followed through and how many didn’t with the following query:

select a.value smart_scan_started, b.value smart_scan_cont, a.value - b.value no_smart_scan
from v$sysstat a, v$sysstat b
where a.statistic#=262
and b.statistic#=263
/

--You may find that none of the Smart Scans that were started actually went on to finish:

SMART_SCAN_STARTED SMART_SCAN_CONT NO_SMART_SCAN
------------------ --------------- -------------
              1222               0          1222

--Or you may find that all of them finished:

SMART_SCAN_STARTED SMART_SCAN_CONT NO_SMART_SCAN
------------------ --------------- -------------
               407             407             0

--You may also find that some did, and some didn’t, continue:

SMART_SCAN_STARTED SMART_SCAN_CONT NO_SMART_SCAN
------------------ --------------- -------------
                53              27            26
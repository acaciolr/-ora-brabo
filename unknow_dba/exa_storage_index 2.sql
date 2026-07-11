YS@LABRAT1> select count(*) from kso.skew3;

  COUNT(*)
----------
 384000048

1 row selected.

Elapsed: 00:00:24.06
SYS@LABRAT1> /

  COUNT(*)
----------
 384000048

1 row selected.

Elapsed: 00:00:23.94

SYS@LABRAT1> set timing off
SYS@LABRAT1> @mystats
Enter value for name: %storage%

NAME                                                                             VALUE
---------------------------------------------------------------------- ---------------
cell physical IO bytes saved by storage index                                        0

1 row selected.

SYS@LABRAT1> set timing on
SYS@LABRAT1> select count(*) from kso.skew3 where col1 is null;

  COUNT(*)
----------
        12

1 row selected.

Elapsed: 00:00:00.07
SYS@LABRAT1> set timing off
SYS@LABRAT1> @fsx
Enter value for sql_text: select count(*) from kso.skew3 where col1 is null
Enter value for sql_id: 
Enter value for inst_id: 


 INST SQL_ID         CHILD  PLAN_HASH      EXECS     AVG_ETIME      AVG_LIO    AVG_PIO AVG_PX OFFLOADABLE IO_SAVED_% SQL_TEXT
----- ------------- ------ ---------- ---------- ------------- ------------ ---------- ------ ----------- ---------- ----------------------------------------
    1 0u1q4b7puqz6g      0 2684249835          5           .09    1,956,226  1,956,219      0 Yes             100.00 select count(*) from kso.skew3 where col

1 row selected.

SYS@LABRAT1> @mystats
Enter value for name: %storage%

NAME                                                                             VALUE
---------------------------------------------------------------------- ---------------
cell physical IO bytes saved by storage index                              16012763136

1 row selected.

--

SYS@LABRAT1> select name, value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

NAME                                                                             VALUE
---------------------------------------------------------------------- ---------------
cell physical IO bytes saved by storage index                                        0

Elapsed: 00:00:00.01
SYS@LABRAT1> alter session set "_kcfis_storageidx_disabled"=true -- turn them off
  2  /

Session altered.

Elapsed: 00:00:00.00
SYS@LABRAT1> select count(*) from kso.skew3 where col1 is null;

  COUNT(*)
----------
        12

Elapsed: 00:00:13.91
SYS@LABRAT1> select name, value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

NAME                                                                             VALUE
---------------------------------------------------------------------- ---------------
cell physical IO bytes saved by storage index                                        0

Elapsed: 00:00:00.00
SYS@LABRAT1> alter session set "_kcfis_storageidx_disabled"=false -- back to default which turns it on
  2  /

Session altered.

Elapsed: 00:00:00.00
SYS@LABRAT1> select count(*) from kso.skew3 where col1 is null;

  COUNT(*)
----------
        12

Elapsed: 00:00:00.07
SYS@LABRAT1> select name, value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

NAME                                                                             VALUE
---------------------------------------------------------------------- ---------------
cell physical IO bytes saved by storage index                              16012763136

Elapsed: 00:00:00.01


/*------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------------*/


--The easiest way to confirm if Storage Index pruning occurred is to check this system or session level metrics or statistics. Typically I query the V$MYSTAT view. This view includes metrics for the current session including the following metrics that show if the current session benefited from Storage Index pruning:
--
--Cell physical IO bytes saved by storage index – This metric shows how many bytes of I/O were eliminated by the application of storage indexes at the storage cell level.
--
--IM scan segments minmax eligible – This metric shows the number of IMCUs that are eligible for Storage Index pruning.
--
--IM scan CUs pruned – This metric shows the number of IMCUs that were eliminated by Storage Index pruning.
--
--Let’s look at another example to see when we benefit from Storage Index pruning and when we don’t’.
--
--We’ll begin by creating a table called BIG_TABLE based off of the dictionary table ALL_OBJECTS and populate it in the In-Memory column store.

CREATE TABLE big_table AS SELECT * FROM all_objects WHERE rownum&lt;10000001;
 
TABLE created.
 
ALTER TABLE big_table inmemory;
 
TABLE Altered.
 
SELECT /*+ full(b) */ COUNT(*) FROM big_table b;
 
COUNT(*)
----------
10000000
 
SELECT segment_name, populate_status, bytes_not_populated FROM v$im_segments;
 
SEGMENT_NAME             POPULATE_STAT  BYTES_NOT_POPULATED
------------------------ -------------- -------------------
BIG_TABLE                   COMPLETED      0

--Now’s that our BIG_TABLE is fully populated in the In-Memory column store, let’s find the maximum OBJECT_ID for the objects owned by SCOTT. The value SCOTT occurs less than 1% of the time in our BIG_TABLE, so we should see some Storage Index pruning.

SELECT COUNT(*) FROM big_table WHERE owner='SCOTT';
 
COUNT(*)
----------
540

--Before and after we issue the query let’s check the appropriate metrics in V$MYSTAT view.

SELECT t1.name, t2.value
FROM   v$sysstat t1, v$mystat t2
WHERE  t1.name LIKE 'IM%'
AND    t1.statistic# = t2.statistic#
AND    t1.name IN ('IM scan CUs memcompress for query low', 
                   'IM scan CUs pruned', 
                   'IM scan segments minmax eligible');
 
NAME                                            VALUE
--------------------------------------------- ----------
IM scan CUs memcompress FOR query low              0
IM scan CUs pruned                                 0
IM scan segments minmax eligible                   0
 
 
SELECT MAX(object_id) FROM big_table WHERE owner ='SCOTT';
 
MAX(OBJECT_ID)
-------------
91774
 
SELECT * FROM TABLE(dbms_xplan.display_cursor);
 
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------
SQL_ID g9r6qxh4dczd4, child NUMBER 0
-------------------------------------
 
SELECT MAX(object_id) FROM big_table WHERE owner ='SCOTT'
Plan hash VALUE: 599409829
-------------------------------------------------------------------------------
| Id | Operation                   | Name     | ROWS | Bytes | Cost (%CPU)|
-------------------------------------------------------------------------------
|  0 | SELECT STATEMENT            |          |      |       | 10730 (100)| 
|   1| SORT AGGREGATE              |          |     1|   11  |            | 
|* 2 |   TABLE ACCESS INMEMORY FULL| BIG_TABLE| 1024 | 11264 | 10730   (3)|
-------------------------------------------------------------------------------
Predicate Information (IDENTIFIED BY operation id):
---------------------------------------------------
2 - inmemory("OWNER"='SCOTT')
    FILTER("OWNER"='SCOTT')
 
20 ROWS selected.
 
SELECT t1.name, t2.value
FROM   v$sysstat t1, v$mystat t2
WHERE  t1.name LIKE 'IM%'
AND    t1.statistic# = t2.statistic#
AND    t1.name IN ('IM scan CUs memcompress for query low', 
                   'IM scan CUs pruned', 
                   'IM scan segments minmax eligible');
 
NAME                                            VALUE
--------------------------------------------- ----------
IM scan CUs memcompress FOR query low             19
IM scan CUs pruned                                 0
IM scan segments minmax eligible                  19

--Even with the value SCOTT only occurs 1% of the time in our table, Storage Index pruning didn’t take place for our query.

--Why?

--The value SCOTT fell between the MIX/MAX range for all 19 IMCUs that make up our BIG_TABLE.
--But how could that happen if the value SCOTT appears less than 1% of the time?
--Take for example a MIX/MAX range of [APEX, XDB] for the owner column on each IMCU. The value SCOTT falls within that range for every IMCU. Therefore no pruning will occur.
--Is there any way I can improve the chances of Storage Index pruning occurring?
--The only way to improve the chances of Storage Index pruning occurring would be to sort the data within the BIG_TABLE on the owner column. It won’t guarantee pruning but it will certainly increase our chances.

CREATE TABLE big_table_sorted AS SELECT * FROM big_table ORDER BY owner;
 
TABLE created.
 
SELECT /*+ full(b) */ COUNT(*) FROM big_table_sorted b;
 
COUNT(*)
----------
10000000
 
SELECT segment_name, populate_status, bytes_not_populated FROM v$im_segments
 
SEGMENT_NAME             POPULATE_STAT  BYTES_NOT_POPULATED
------------------------ -------------- -------------------
BIG_TABLE_SORTED            COMPLETED      0
BIG_TABLE                   COMPLETED      0

--Let’s now try our query again, but this time against the sorted table.

SELECT t1.name, t2.value
FROM   v$sysstat t1, v$mystat t2
WHERE  t1.name LIKE 'IM%'
AND    t1.statistic# = t2.statistic#
AND    t1.name IN ('IM scan CUs memcompress for query low', 
                   'IM scan CUs pruned', 
                   'IM scan segments minmax eligible');
 
NAME                                            VALUE
--------------------------------------------- ----------
IM scan CUs memcompress FOR query low              0
IM scan CUs pruned                                 0
IM scan segments minmax eligible                   0
 
SELECT MAX(object_id) FROM big_table_sorted WHERE owner ='SCOTT'; 
 
MAX(OBJECT_ID) 
-------------- 
91774 
 
SELECT * FROM TABLE(dbms_xplan.display_cursor); 
PLAN_TABLE_OUTPUT 
------------------------------------------------------------------------------- 
SQL_ID f4a2z8wsqjdm0, child NUMBER 0 
------------------------------------- 
SELECT MAX(object_id) FROM big_table_sorted WHERE owner ='SCOTT' 
Plan hash VALUE: 3625205436 
------------------------------------------------------------------------------- 
| Id | Operation                   | Name             | ROWS | Bytes | Cost (%CPU)|     
| ------------------------------------------------------------------------------- 
|   0 | SELECT STATEMENT           |                  |       |        4184      |  
|   1 | SORT AGGREGATE             |                  |     1 |   11 |           | 
|* 2  |  TABLE ACCESS INMEMORY FULL| BIG_TABLE_SORTED |   904K| 9714K| 4184      |
------------------------------------------------------------------------------- 
Predicate Information (IDENTIFIED BY operation id): 
2 - inmemory("OWNER"='SCOTT') 
    FILTER("OWNER"='SCOTT') 
 
20 ROWS selected. 
 
SELECT t1.name, t2.value
FROM   v$sysstat t1, v$mystat t2
WHERE  t1.name LIKE 'IM%'
AND    t1.statistic# = t2.statistic#
AND    t1.name IN ('IM scan CUs memcompress for query low', 
                   'IM scan CUs pruned', 
                   'IM scan segments minmax eligible');
 
NAME                                            VALUE
--------------------------------------------- ----------
IM scan CUs memcompress FOR query low             19
IM scan CUs pruned                                18
IM scan segments minmax eligible                  19
As you can see the distribution of the


/*------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------------*/


--Here are some sample statistics taken from an actual production system:

SQL> select name,value from v$sysstat where name in ('physical read total bytes','cell physical IO bytes saved by storage index');
NAME                                                                       VALUE
---------------------------------------------------------------- ---------------
physical read total bytes                                        468779565615616
cell physical IO bytes saved by storage index                    251319174832128

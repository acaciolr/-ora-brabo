drop table t1 purge;
drop sequence s1;

create sequence s1 start with 1 cache 100;

create table t1 tablespace data 
as
select /*+ parallel (a,16) */
        s1.nextval as id
      , case when mod(rownum,100) = 1   then null else rownum end as col1
      , dbms_random.string('A',50) as filler1
      , case when mod(rownum,100) = 2   then null else rownum end as col2
      , dbms_random.string('A',50) as filler2
      , case when mod(rownum,100) = 3   then null else rownum end as col3
      , dbms_random.string('A',50) as filler3
      , case when mod(rownum,100) = 4   then null else rownum end as col4
      , dbms_random.string('A',50) as filler4
      , case when mod(rownum,100) = 5   then null else rownum end as col5
      , dbms_random.string('A',50) as filler5
      , case when mod(rownum,100) = 6   then null else rownum end as col6
      , dbms_random.string('A',50) as filler6
      , case when mod(rownum,100) = 7   then null else rownum end as col7
      , dbms_random.string('A',50) as filler7
      , case when mod(rownum,100) = 8   then null else rownum end as col8
      , dbms_random.string('A',50) as filler8
      , case when mod(rownum,100) = 9   then null else rownum end as col9
      , dbms_random.string('A',50) as filler9
      , case when mod(rownum,100) = 10  then null else rownum end as col10
      , dbms_random.string('A',50) as filler10
      , case when mod(rownum,100) = 11  then null else rownum end as col11
      , dbms_random.string('A',50) as filler11
      , case when mod(rownum,100) = 12  then null else rownum end as col12
      , dbms_random.string('A',50) as filler12
      , case when mod(rownum,100) = 13  then null else rownum end as col13
      , dbms_random.string('A',50) as filler13
      , case when mod(rownum,100) = 14  then null else rownum end as col14
      , dbms_random.string('A',50) as filler14
      , case when mod(rownum,100) = 15  then null else rownum end as col15
      , dbms_random.string('A',50) as filler15
      , case when mod(rownum,100) = 16  then null else rownum end as col16
      , dbms_random.string('A',50) as filler16
from
        dual a
connect by
        level <= 1000000;

alter table t1 storage (cell_flash_cache none);

alter session enable parallel dml;
begin
for i in 1..63 loop
insert /*+ append parallel (s,4) */ into t1 s select /* parallel (t,4) */ s1.nextval,
col1,filler1,col2,filler2,col3,filler3,col4,filler4,col5,filler5,
col6,filler6,col7,filler7,col8,filler8,col9,filler9,col10,filler10,
col11,filler11,col12,filler12,col13,filler13,col14,filler14,col15,filler15,
col16,filler16  from t1 t;
commit;
end loop;
end;
/

exec dbms_stats.gather_table_stats(null, 't1',estimate_percent=>100,degree=>16);

col1,col2…col16 are indicators and filler1,filler2…filler16 are for another test case. cell_flash_cache is set to none to make sure data is retrieved from physical disks and not flash cache.

Table Stats are as shown below  and Storage cells were restarted to make sure nothing is stored in flash cache.

vdesai@exadata > @statistics T1

Database: csprod2; Instance: csprod22; ORACLE Release: 11.2.0.3.0; Platform: x86_64/Linux 2.4.xx; Host name: fhdbdb02.fairhe

Table Owner                              Number          Blocks          Blocks        Empty Average Chain Average Global
and Name                                of Rows    (Statistics)       (Segment)       Blocks   Space Count Row Len Stats
------------------------------ ---------------- --------------- --------------- ------------ ------- ----- ------- ------
VDESAI . T1                          64,000,000       9,066,568       9,066,568            0       0     0     902 YES    

                               Block-            Moni-      Modifi- Buffer                 IOT
Tablespace                     size    Size (MB) toring cations (%) Pool    Degree Cluster Type    IOT Name
------------------------------ ------- --------- ------ ----------- ------- ------ ------- ------- -------------------------
DATA                           8 KB    70832.6   YES                DEFAULT 1

                               Column                              Distinct           Number             Number Global User     
Column Name                    Details                               Values  Density Buckets              Nulls Stats  Stats
------------------------------ ------------------------ ------------------- -------- ------- ------------------ ------ -----
ID                             NUMBER(38)                        64,000,000    .0000       1                  0 YES    NO   
COL1                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER1                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL2                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER2                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL3                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER3                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL4                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER4                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL5                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER5                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL6                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER6                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL7                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER7                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL8                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER8                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL9                           NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER9                        VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL10                          NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER10                       VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL11                          NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER11                       VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL12                          NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER12                       VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL13                          NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER13                       VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL14                          NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER14                       VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL15                          NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER15                       VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
COL16                          NUMBER                               990,000    .0000       1            640,000 YES    NO   
FILLER16                       VARCHAR2(4000)                     1,000,000    .0000       1                  0 YES    NO   
vdesai@exadata >

vdesai@exadata > select object_id from user_objects where object_name='T1';

 OBJECT_ID
----------
     81512

vdesai@exadata > select bytes/1024/1024  from user_segments where segment_name='T1';

BYTES/1024/1024
---------------
          70832

[root@fhdbcel01 ~]# dcli -g all_cells -l root "cellcli -e list flashcachecontent attributes dbid,objectnumber,cachedsize where objectnumber=81512"
fhdbcel03: 2215964125    81512   8192
fhdbcel05: 2215964125    81512   966656

[root@fhdbcel01 ~]# dcli -c fhdbcel01 -l root "cellcli -e alter cell restart services all"                                             
fhdbcel01:
fhdbcel01: Stopping the RS, CELLSRV, and MS services...
fhdbcel01: The SHUTDOWN of services was successful.
fhdbcel01: Starting the RS, CELLSRV, and MS services...
fhdbcel01: Getting the state of RS services...
fhdbcel01: running
fhdbcel01: Starting CELLSRV services...
fhdbcel01: The STARTUP of CELLSRV services was successful.
fhdbcel01: Starting MS services...
fhdbcel01: The STARTUP of MS services was successful.
[root@fhdbcel01 ~]# dcli -c fhdbcel02 -l root "cellcli -e alter cell restart services all"
fhdbcel02:
fhdbcel02: Stopping the RS, CELLSRV, and MS services...
fhdbcel02: The SHUTDOWN of services was successful.
fhdbcel02: Starting the RS, CELLSRV, and MS services...
fhdbcel02: Getting the state of RS services...
fhdbcel02: running
fhdbcel02: Starting CELLSRV services...
fhdbcel02: The STARTUP of CELLSRV services was successful.
fhdbcel02: Starting MS services...
fhdbcel02: The STARTUP of MS services was successful.
[root@fhdbcel01 ~]# dcli -c fhdbcel03 -l root "cellcli -e alter cell restart services all"
fhdbcel03:
fhdbcel03: Stopping the RS, CELLSRV, and MS services...
fhdbcel03: The SHUTDOWN of services was successful.
fhdbcel03: Starting the RS, CELLSRV, and MS services...
fhdbcel03: Getting the state of RS services...
fhdbcel03: running
fhdbcel03: Starting CELLSRV services...
fhdbcel03: The STARTUP of CELLSRV services was successful.
fhdbcel03: Starting MS services...
fhdbcel03: The STARTUP of MS services was successful.
[root@fhdbcel01 ~]# dcli -c fhdbcel04 -l root "cellcli -e alter cell restart services all"
fhdbcel04:
fhdbcel04: Stopping the RS, CELLSRV, and MS services...
fhdbcel04: The SHUTDOWN of services was successful.
fhdbcel04: Starting the RS, CELLSRV, and MS services...
fhdbcel04: Getting the state of RS services...
fhdbcel04: running
fhdbcel04: Starting CELLSRV services...
fhdbcel04: The STARTUP of CELLSRV services was successful.
fhdbcel04: Starting MS services...
fhdbcel04: The STARTUP of MS services was successful.
[root@fhdbcel01 ~]# dcli -c fhdbcel05 -l root "cellcli -e alter cell restart services all"
fhdbcel05:
fhdbcel05: Stopping the RS, CELLSRV, and MS services...
fhdbcel05: The SHUTDOWN of services was successful.
fhdbcel05: Starting the RS, CELLSRV, and MS services...
fhdbcel05: Getting the state of RS services...
fhdbcel05: running
fhdbcel05: Starting CELLSRV services...
fhdbcel05: The STARTUP of CELLSRV services was successful.
fhdbcel05: Starting MS services...
fhdbcel05: The STARTUP of MS services was successful.
[root@fhdbcel01 ~]# dcli -c fhdbcel06 -l root "cellcli -e alter cell restart services all"
fhdbcel06:
fhdbcel06: Stopping the RS, CELLSRV, and MS services...
fhdbcel06: The SHUTDOWN of services was successful.
fhdbcel06: Starting the RS, CELLSRV, and MS services...
fhdbcel06: Getting the state of RS services...
fhdbcel06: running
fhdbcel06: Starting CELLSRV services...
fhdbcel06: The STARTUP of CELLSRV services was successful.
fhdbcel06: Starting MS services...
fhdbcel06: The STARTUP of MS services was successful.
[root@fhdbcel01 ~]# dcli -c fhdbcel07 -l root "cellcli -e alter cell restart services all"
fhdbcel07:
fhdbcel07: Stopping the RS, CELLSRV, and MS services...
fhdbcel07: The SHUTDOWN of services was successful.
fhdbcel07: Starting the RS, CELLSRV, and MS services...
fhdbcel07: Getting the state of RS services...
fhdbcel07: running
fhdbcel07: Starting CELLSRV services...
fhdbcel07: The STARTUP of CELLSRV services was successful.
fhdbcel07: Starting MS services...
fhdbcel07: The STARTUP of MS services was successful.

[root@fhdbcel01 ~]# dcli -g all_cells -l root "cellcli -e list flashcachecontent attributes dbid,objectnumber,cachedsize where objectnumber=81512"
[root@fhdbcel01 ~]#
Case 1: In this case we will consecutively loop though each column twice i.e. col1 to col16

Case 1 Scripts part 1:

drop table storage_ind_stat purge;

create table storage_ind_stat (exec varchar2(15),
                               col1 number,
                               col2 number,
                               col3 number,
                               col4 number,
                               col5 number,
                               col6 number,
                               col7 number,
                               col8 number,
                               col9 number,
                               col10 number,
                               col11 number,
                               col12 number,
                               col13 number,
                               col14 number,
                               col15 number,
                               col16 number);
insert into storage_ind_stat(exec) values ('Execute1');
insert into storage_ind_stat(exec) values ('Execute2');
commit;

alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

set serveroutput on
declare
stmt varchar2(200);
is_null number;
val1 number;
val2 number;
val3 number;
cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
begin
for v1 in c1 loop
select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;

select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;

select value into val3 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';


stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
execute immediate stmt;
stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val3-val2) || ' where exec= ' || '''' || 'Execute2' || '''';
execute immediate stmt;
commit;

val1:=0;
val2:=0;
val3:=0; 

end loop;
end;
/
Case 1 output part 1:

vdesai@exadata > select * from STORAGE_IND_STAT;

EXEC                    COL1         COL2         COL3         COL4         COL5         COL6         COL7         COL8         COL9        COL10        COL11        COL12        COL13        COL14        COL15        COL16
--------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------
Execute1                   0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
Execute2         31727861760  31097012224  31102484480  31726813184  31723601920  31077318656  31098060800  31728910336  31731990528  31094161408  31090786304  31733170176  31728779264  31087640576  31091965952  31732842496

“cell physical IO bytes saved by storage index” statistics are updated for all 16 columns so the storage indexes are created for more than 16 columns.

Case 1 Scripts part 2:

insert into storage_ind_stat(exec) values ('Execute3');
commit;

alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

set serveroutput on
declare
stmt varchar2(200);
is_null number;
val1 number;
val2 number;
val3 number;
cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
begin
for v1 in c1 loop
select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute3' || '''';
execute immediate stmt;

commit;

val1:=0;
val2:=0;
val3:=0; 

end loop;
end;
/
Case 1 output part2:

vdesai@exadata > select * from STORAGE_IND_STAT order by 1; 

EXEC                    COL1         COL2         COL3         COL4         COL5         COL6         COL7         COL8         COL9        COL10        COL11        COL12        COL13        COL14        COL15        COL16
--------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------
Execute1                   0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
Execute2         31727861760  31097012224  31102484480  31726813184  31723601920  31077318656  31098060800  31728910336  31731990528  31094161408  31090786304  31733170176  31728779264  31087640576  31091965952  31732842496
Execute3         31727861760  31097012224  31102484480  31726813184  31723601920  31077318656  31098060800  31728910336  31731990528  31094161408  31090786304  31733170176  31728779264  31087640576  31091965952  31732842496 

As you can see from above that stroage indexes are not only created for more than 8 columns but are also maintained for more than 8 columns.

Case 2: In this case first I will run single sql statement using filter for all 16 columns and then run queries one by one with single column filter.

Case 2 Scripts:

alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

select count(1) from t1 where col1 is null
                          and col2 is null
                          and col3 is null
                          and col4 is null
                          and col5 is null
                          and col6 is null
                          and col7 is null
                          and col8 is null
                          and col9 is null
                          and col10 is null
                          and col11 is null
                          and col12 is null
                          and col13 is null
                          and col14 is null
                          and col15 is null
                          and col16 is null;
                          
select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
                          
                          
drop table storage_ind_stat purge;

create table storage_ind_stat (exec varchar2(15),
                               col1 number,
                               col2 number,
                               col3 number,
                               col4 number,
                               col5 number,
                               col6 number,
                               col7 number,
                               col8 number,
                               col9 number,
                               col10 number,
                               col11 number,
                               col12 number,
                               col13 number,
                               col14 number,
                               col15 number,
                               col16 number);
insert into storage_ind_stat(exec) values ('Execute1');
commit;

alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

set serveroutput on
declare
stmt varchar2(200);
is_null number;
val1 number;
val2 number;
val3 number;
cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
begin
for v1 in c1 loop
select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
execute immediate stmt;

commit;

val1:=0;
val2:=0;
val3:=0; 

end loop;
end;
/

Case 2 output:

vdesai@exadata > alter session set "_serial_direct_read"=true;

Session altered.

vdesai@exadata > alter system flush shared_pool;

System altered.

vdesai@exadata > alter system flush buffer_cache;

System altered.

vdesai@exadata >
vdesai@exadata > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

vdesai@exadata > select count(1) from t1 where col1 is null
  2                                               and col2 is null
  3                                               and col3 is null
  4                                               and col4 is null
  5                                               and col5 is null
  6                                               and col6 is null
  7                                               and col7 is null
  8                                               and col8 is null
  9                                               and col9 is null
 10                                               and col10 is null
 11                                               and col11 is null
 12                                               and col12 is null
 13                                               and col13 is null
 14                                               and col14 is null
 15                                               and col15 is null
 16                                               and col16 is null;

  COUNT(1)
----------
         0



vdesai@exadata > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

vdesai@exadata >
vdesai@exadata > alter session set "_serial_direct_read"=true;

Session altered.

vdesai@exadata > alter system flush shared_pool;

System altered.

vdesai@exadata > alter system flush buffer_cache;

System altered.

vdesai@exadata >
vdesai@exadata > set serveroutput on
vdesai@exadata > declare
  2  stmt varchar2(200);
  3  is_null number;
  4  val1 number;
  5  val2 number;
  6  val3 number;
  7  cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
  8  begin
  9  for v1 in c1 loop
 10  select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 11  execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
 12  select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 13
 14  stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
 15  execute immediate stmt;
 16
 17  commit;
 18
 19  val1:=0;
 20  val2:=0;
 21  val3:=0;
 22
 23  end loop;
 24  end;
 25  /

PL/SQL procedure successfully completed.

vdesai@exadata >

vdesai@exadata > select * from STORAGE_IND_STAT order by 1;

EXEC                    COL1         COL2         COL3         COL4         COL5         COL6         COL7         COL8         COL9        COL10        COL11        COL12        COL13        COL14        COL15        COL16
--------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------
Execute1         31727861760  31097012224  31102484480  31726813184  31723601920  31077318656  31098060800  31728910336            0            0            0            0            0            0            0            0

As you can see from above that Storage indexes were created and used for columns COL1 to COL8 (8 columns).

Case 3: Same as Case 2 but replaced AND condition in query with OR.

Case 3 Scripts:

alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

select count(1) from t1 where col1 is null
                          or col2 is null
                          or col3 is null
                          or col4 is null
                          or col5 is null
                          or col6 is null
                          or col7 is null
                          or col8 is null
                          or col9 is null
                          or col10 is null
                          or col11 is null
                          or col12 is null
                          or col13 is null
                          or col14 is null
                          or col15 is null
                          or col16 is null;
                          
select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
                          
                          

alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

set serveroutput on
declare
stmt varchar2(200);
is_null number;
val1 number;
val2 number;
val3 number;
cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
begin
for v1 in c1 loop
select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
execute immediate stmt;

commit;

val1:=0;
val2:=0;
val3:=0; 

end loop;
end;
/
Case 3 output:

vdesai@exadata > alter session set "_serial_direct_read"=true;

Session altered.

vdesai@exadata > alter system flush shared_pool;

System altered.

vdesai@exadata > alter system flush buffer_cache;

System altered.

vdesai@exadata >
vdesai@exadata > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

vdesai@exadata >
vdesai@exadata > select count(1) from t1 where col1 is null
  2                                               or col2 is null
  3                                               or col3 is null
  4                                               or col4 is null
  5                                               or col5 is null
  6                                               or col6 is null
  7                                               or col7 is null
  8                                               or col8 is null
  9                                               or col9 is null
 10                                               or col10 is null
 11                                               or col11 is null
 12                                               or col12 is null
 13                                               or col13 is null
 14                                               or col14 is null
 15                                               or col15 is null
 16                                               or col16 is null;

  COUNT(1)
----------
  10240000

vdesai@exadata >
vdesai@exadata > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

vdesai@exadata > alter session set "_serial_direct_read"=true;

Session altered.

vdesai@exadata > alter system flush shared_pool;

System altered.

vdesai@exadata > alter system flush buffer_cache;

System altered.

vdesai@exadata >
vdesai@exadata > set serveroutput on
vdesai@exadata > declare
  2  stmt varchar2(200);
  3  is_null number;
  4  val1 number;
  5  val2 number;
  6  val3 number;
  7  cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
  8  begin
  9  for v1 in c1 loop
 10  select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 11  execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
 12  select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 13
 14  stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
 15  execute immediate stmt;
 16
 17  commit;
 18
 19  val1:=0;
 20  val2:=0;
 21  val3:=0;
 22
 23  end loop;
 24  end;
 25  /

PL/SQL procedure successfully completed.

vdesai@exadata >

vdesai@exadata > select * from STORAGE_IND_STAT order by 1;

EXEC                    COL1         COL2         COL3         COL4         COL5         COL6         COL7         COL8         COL9        COL10        COL11        COL12        COL13        COL14        COL15        COL16
--------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------
Execute1                   0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0

I tried above test case with "_cell_storidx_mode"=ALL but got same results. As the main query fetched 10,240,000 rows (scattered) out of 64,000,000 may be Oracle Storage cell optimizer decided not to create storage indexes. 🙂

Case 4: Same as Case 3 but will use only two column filters

Case 4 Scripts:

alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

select count(1) from t1 where col1 is null
                          or col2 is null;
                          
select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
                          
                          
alter session set "_serial_direct_read"=true;
alter system flush shared_pool;
alter system flush buffer_cache;

set serveroutput on
declare
stmt varchar2(200);
is_null number;
val1 number;
val2 number;
val3 number;
cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
begin
for v1 in c1 loop
select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
execute immediate stmt;

commit;

val1:=0;
val2:=0;
val3:=0; 

end loop;
end;
/

Case 4 output:

vdesai@exadata > alter session set "_serial_direct_read"=true;

Session altered.

vdesai@exadata > alter system flush shared_pool;

System altered.

vdesai@exadata > alter system flush buffer_cache;

System altered.

vdesai@exadata >
vdesai@exadata > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

vdesai@exadata >
vdesai@exadata > select count(1) from t1 where col1 is null
                                          or col2 is null;

  COUNT(1)
----------
   1280000

vdesai@exadata >
vdesai@exadata > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

vdesai@exadata > alter session set "_serial_direct_read"=true;

Session altered.

vdesai@exadata > alter system flush shared_pool;

System altered.

vdesai@exadata > alter system flush buffer_cache;

System altered.

vdesai@exadata >
vdesai@exadata > set serveroutput on
vdesai@exadata > declare
  2  stmt varchar2(200);
  3  is_null number;
  4  val1 number;
  5  val2 number;
  6  val3 number;
  7  cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
  8  begin
  9  for v1 in c1 loop
 10  select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 11  execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
 12  select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 13
 14  stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
 15  execute immediate stmt;
 16
 17  commit;
 18
 19  val1:=0;
 20  val2:=0;
 21  val3:=0;
 22
 23  end loop;
 24  end;
 25  /

PL/SQL procedure successfully completed.

vdesai@exadata >

vdesai@exadata > select * from STORAGE_IND_STAT order by 1;

EXEC                    COL1         COL2         COL3         COL4         COL5         COL6         COL7         COL8         COL9        COL10        COL11        COL12        COL13        COL14        COL15        COL16
--------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------ ------------
Execute1                   0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0

This time storage indexes should have kicked in for 1,028,000 records but it did not. To prove that Oracle Storage optimizer exists next I’m going to minimize number of nulls in col1 and col2.

Case 4 output with reduced number of nulls:

VDESAI@csprod2_exa > alter session enable parallel dml;

Session altered.

VDESAI@csprod2_exa > update /*+ parallel(t1,4) */ t1 set col1=100 where col1 is null;

640000 rows updated.

VDESAI@csprod2_exa >  update /*+ parallel(t1,4) */ t1 set col2=100 where col2 is null;

640000 rows updated.

VDESAI@csprod2_exa >

VDESAI@csprod2_exa > commit;

Commit complete.

VDESAI@csprod2_exa > update /*+ parallel(t1,4) */ t1 set col1=null,col2=null where rownum=1;

1 row updated.

VDESAI@csprod2_exa > commit;

Commit complete.

VDESAI@csprod2_exa > alter session set "_serial_direct_read"=true;

Session altered.

VDESAI@csprod2_exa > alter system flush shared_pool;

System altered.

VDESAI@csprod2_exa > alter system flush buffer_cache;

System altered.

VDESAI@csprod2_exa >
VDESAI@csprod2_exa > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

VDESAI@csprod2_exa >
VDESAI@csprod2_exa > select count(1) from t1 where col1 is null
  2                                               or col2 is null;

  COUNT(1)
----------
         1

VDESAI@csprod2_exa >
VDESAI@csprod2_exa > select value from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';

     VALUE
----------
         0

VDESAI@csprod2_exa > alter session set "_serial_direct_read"=true;

Session altered.

VDESAI@csprod2_exa > alter system flush shared_pool;

System altered.

VDESAI@csprod2_exa > alter system flush buffer_cache;

System altered.

VDESAI@csprod2_exa >
VDESAI@csprod2_exa > set serveroutput on
VDESAI@csprod2_exa > declare
  2  stmt varchar2(200);
  3  is_null number;
  4  val1 number;
  5  val2 number;
  6  val3 number;
  7  cursor c1 is select column_name from user_tab_columns where table_name='T1' and column_name like 'COL%';
  8  begin
  9  for v1 in c1 loop
 10  select value into val1 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 11  execute immediate 'select count(1) from t1 where '  || v1.column_name || '  is null' into is_null;
 12  select value into val2 from v$mystat s, v$statname n where n.statistic# = s.statistic# and name like '%storage%';
 13
 14  stmt := ' update storage_ind_stat set ' ||  v1.column_name || ' = ' || to_number(val2-val1) || ' where exec= ' || '''' || 'Execute1' || '''';
 15  execute immediate stmt;
 16
 17  commit;
 18
 19  val1:=0;
 20  val2:=0;
 21  val3:=0;
 22
 23  end loop;
 24  end;
 25  /

PL/SQL procedure successfully completed.

VDESAI@csprod2_exa > select * from storage_ind_stat;

EXEC                        COL1             COL2       COL3       COL4       COL5       COL6       COL7       COL8       COL9      COL10      COL11      COL12      COL13      COL14      COL15      COL16
--------------- ---------------- ---------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
Execute1             74113728512      74113728512          0          0          0          0          0          0          0          0          0          0          0          0          0          0

Storage indexes were created and used this time and Storage indexes almost eliminated scan of entire table.

PS: I have used Oracle Storage optimizer term loosely but probably Oracle Marketing folks should rename Storage Indexes to Smart Storage Indexes.
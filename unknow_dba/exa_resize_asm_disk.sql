--Oracle Advanced customer support configured Exadata disk groups by allocating 40% of space to DATA disk group and 60% of space to RECO disk group.  Flashback and force logging was not required for our DW environment so we decided to resize ASM disk groups and give maximum available space to DATA disk group for future data growth and to accommodate more databases.

--Steps are provided by metalink note 1245494.1 but I have made some changes to commands and additions to monitor ASM rebalance operation. ASM rebalance operation can be monitored using shell script provided by metalink note 1274322.1.

--First step is to check for space and make sure we have full database backup.

--1. "free_mb" should be greater than "required_mirror_free_mb".

SQL> select name, total_mb, free_mb, required_mirror_free_mb from v$asm_diskgroup; 

NAME                             TOTAL_MB    FREE_MB REQUIRED_MIRROR_FREE_MB
------------------------------ ---------- ---------- -----------------------
DATA_FHDB                        18235392   15863580                 2605056
RECO_FHDB                        27240192   25419252                 3891456
DBFS_DG                           2087680    1037092                  298240
 
--2. Backup your databases.

--3. Checks disks are balanced and have free space.

SQL> select name,total_mb,free_mb from v$asm_disk where mount_status='CACHED' and (name like 'DATA%' or name like 'RECO%') order by 1; 

NAME                             TOTAL_MB    FREE_MB
------------------------------ ---------- ----------
DATA_FHDB_CD_00_FHDBCEL01          217088     188852
DATA_FHDB_CD_00_FHDBCEL02          217088     188864
DATA_FHDB_CD_00_FHDBCEL03          217088     188868
DATA_FHDB_CD_00_FHDBCEL04          217088     188828
DATA_FHDB_CD_00_FHDBCEL05          217088     188864
DATA_FHDB_CD_00_FHDBCEL06          217088     188880
DATA_FHDB_CD_00_FHDBCEL07          217088     188696
...
...
RECO_FHDB_CD_11_FHDBCEL01          324288     302756
RECO_FHDB_CD_11_FHDBCEL02          324288     302656
RECO_FHDB_CD_11_FHDBCEL03          324288     302560
RECO_FHDB_CD_11_FHDBCEL04          324288     302436
RECO_FHDB_CD_11_FHDBCEL05          324288     302672
RECO_FHDB_CD_11_FHDBCEL06          324288     302608
RECO_FHDB_CD_11_FHDBCEL07          324288     302548

--Drop the disks of Failgroup Storage cell 1 from ASM instance

-- For DATA diskgroup, get the list of disk name for DATA dikgroup and failgroup storage FHDBCEL01

column failgroup format a20
set pages 200
set linesize 200
select name,header_status,mount_status,failgroup from v$asm_disk where group_number=1 and failgroup='FHDBCEL01' order by 1;

NAME                           HEADER_STATU MOUNT_S FAILGROUP
------------------------------ ------------ ------- --------------------
DATA_FHDB_CD_00_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_01_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_02_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_03_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_04_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_05_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_06_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_07_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_08_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_09_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_10_FHDBCEL01      MEMBER       CACHED  FHDBCEL01
DATA_FHDB_CD_11_FHDBCEL01      MEMBER       CACHED  FHDBCEL01

12 rows selected.

 
-- Now use the below command to drop all disks of failgroup "FHDBCEL01"
 
alter diskgroup DATA_FHDB drop disks in failgroup FHDBCEL01 rebalance power 11 NOWAIT;
 
-- Check the rebalance operation has started or not. Use rebalance_progress.sh as shown below to monitor progress of ASM rebalance operation as v$asm_operation will not show you right estimate.
 
select * from v$asm_operations;
GROUP_NUMBER OPERA STAT      POWER     ACTUAL      SOFAR   EST_WORK   EST_RATE EST_MINUTES ERROR_CODE
------------ ----- ---- ---------- ---------- ---------- ---------- ---------- ----------- --------------------------------------------
           1 REBAL RUN          11         11     112691     142408       9782           3


--Once the rebalance complets ,check the header_status column in v$asm_disk by running below sql..It should show as FORMER for dropped disk
 
set linesize 300
column path format a40
select name,path,header_status,mount_status from v$asm_disk where group_number=0;

NAME                           PATH                                     HEADER_STATU MOUNT_S
------------------------------ ---------------------------------------- ------------ -------
                               o/192.168.10.5/DATA_FHDB_CD_00_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_06_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_02_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_10_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_01_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_03_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_09_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_11_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_08_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_05_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_04_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/DATA_FHDB_CD_07_fhdbcel01 FORMER       CLOSED

12 rows selected.
 
-- Now peform the steps for RECO diskgroup. For RECO diskgroup, get the list of disk name for RECO dikgroup and failgroup FHDBCEL01

column failgroup format a20
set pages 200
set linesize 200 
select name,header_status,mount_status,group_number,failgroup from v$asm_disk where group_number=2 and failgroup='FHDBCEL01';

NAME                           HEADER_STATU MOUNT_S GROUP_NUMBER FAILGROUP
------------------------------ ------------ ------- ------------ --------------------
RECO_FHDB_CD_02_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_11_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_00_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_06_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_01_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_05_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_04_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_07_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_10_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_09_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_08_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01
RECO_FHDB_CD_03_FHDBCEL01      MEMBER       CACHED             2 FHDBCEL01

12 rows selected.

 
-- Now use the below command to drop all disks of failgroup  "FHDBCEL01'
 
alter diskgroup RECO_FHDB drop disks in failgroup FHDBCEL01 rebalance power 11 NOWAIT;

Diskgroup altered.

-- Check the rebalance operation has started or not. Use rebalance_progress.sh as shown below to monitor progress of ASM rebalance operation as v$asm_operation will not show you right estimate.
 
select * from v$asm_operations;

GROUP_NUMBER OPERA STAT      POWER     ACTUAL      SOFAR   EST_WORK   EST_RATE EST_MINUTES ERROR_CODE
------------ ----- ---- ---------- ---------- ---------- ---------- ---------- ----------- --------------------------------------------
           2 REBAL RUN          11         11       9909      18242       3159           2


 
-- Once the rebalance completes ,check the header_status column in v$asm_disk. It should show as FORMER for dropped disk
 
set linesize 300
column path format a40
select name,path,header_status,mount_status from v$asm_disk where group_number=0 order by 2;

NAME                           PATH                                     HEADER_STATU MOUNT_S
------------------------------ ---------------------------------------- ------------ -------
                               o/192.168.10.5/RECO_FHDB_CD_00_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_06_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_02_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_10_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_01_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_03_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_09_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_11_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_08_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_05_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_04_fhdbcel01 FORMER       CLOSED
                               o/192.168.10.5/RECO_FHDB_CD_07_fhdbcel01 FORMER       CLOSED

--Drop and re-create the Grid disks at Storage cell node FHDBCEL01 with desired size.

cellcli> list griddisk attributes name,cellDisk,size,status;

         DATA_FHDB_CD_00_fhdbcel01       CD_00_fhdbcel01         212G            active
         DATA_FHDB_CD_01_fhdbcel01       CD_01_fhdbcel01         212G            active
         DATA_FHDB_CD_02_fhdbcel01       CD_02_fhdbcel01         212G            active
         DATA_FHDB_CD_03_fhdbcel01       CD_03_fhdbcel01         212G            active
         DATA_FHDB_CD_04_fhdbcel01       CD_04_fhdbcel01         212G            active
         DATA_FHDB_CD_05_fhdbcel01       CD_05_fhdbcel01         212G            active
         DATA_FHDB_CD_06_fhdbcel01       CD_06_fhdbcel01         212G            active
         DATA_FHDB_CD_07_fhdbcel01       CD_07_fhdbcel01         212G            active
         DATA_FHDB_CD_08_fhdbcel01       CD_08_fhdbcel01         212G            active
         DATA_FHDB_CD_09_fhdbcel01       CD_09_fhdbcel01         212G            active
         DATA_FHDB_CD_10_fhdbcel01       CD_10_fhdbcel01         212G            active
         DATA_FHDB_CD_11_fhdbcel01       CD_11_fhdbcel01         212G            active
         DBFS_DG_CD_02_fhdbcel01         CD_02_fhdbcel01         29.125G         active
         DBFS_DG_CD_03_fhdbcel01         CD_03_fhdbcel01         29.125G         active
         DBFS_DG_CD_04_fhdbcel01         CD_04_fhdbcel01         29.125G         active
         DBFS_DG_CD_05_fhdbcel01         CD_05_fhdbcel01         29.125G         active
         DBFS_DG_CD_06_fhdbcel01         CD_06_fhdbcel01         29.125G         active
         DBFS_DG_CD_07_fhdbcel01         CD_07_fhdbcel01         29.125G         active
         DBFS_DG_CD_08_fhdbcel01         CD_08_fhdbcel01         29.125G         active
         DBFS_DG_CD_09_fhdbcel01         CD_09_fhdbcel01         29.125G         active
         DBFS_DG_CD_10_fhdbcel01         CD_10_fhdbcel01         29.125G         active
         DBFS_DG_CD_11_fhdbcel01         CD_11_fhdbcel01         29.125G         active
         RECO_FHDB_CD_00_fhdbcel01       CD_00_fhdbcel01         316G             active
         RECO_FHDB_CD_01_fhdbcel01       CD_01_fhdbcel01         316G             active
         RECO_FHDB_CD_02_fhdbcel01       CD_02_fhdbcel01         316G             active
         RECO_FHDB_CD_03_fhdbcel01       CD_03_fhdbcel01         316G             active
         RECO_FHDB_CD_04_fhdbcel01       CD_04_fhdbcel01         316G             active
         RECO_FHDB_CD_05_fhdbcel01       CD_05_fhdbcel01         316G             active
         RECO_FHDB_CD_06_fhdbcel01       CD_06_fhdbcel01         316G             active
         RECO_FHDB_CD_07_fhdbcel01       CD_07_fhdbcel01         316G             active
         RECO_FHDB_CD_08_fhdbcel01       CD_08_fhdbcel01         316G             active
         RECO_FHDB_CD_09_fhdbcel01       CD_09_fhdbcel01         316G             active
         RECO_FHDB_CD_10_fhdbcel01       CD_10_fhdbcel01         316G             active
         RECO_FHDB_CD_11_fhdbcel01       CD_11_fhdbcel01         316G             active

--#Login into FHDBCEL01 cell server and start cellcli.
 
cellcli> ALTER GRIDDISK  DATA_FHDB_CD_00_FHDBCEL01,DATA_FHDB_CD_01_FHDBCEL01,DATA_FHDB_CD_02_FHDBCEL01,DATA_FHDB_CD_03_FHDBCEL01,DATA_FHDB_CD_04_FHDBCEL01,DATA_FHDB_CD_05_FHDBCEL01,DATA_FHDB_CD_06_FHDBCEL01,DATA_FHDB_CD_07_FHDBCEL01,DATA_FHDB_CD_08_FHDBCEL01,DATA_FHDB_CD_09_FHDBCEL01,DATA_FHDB_CD_10_FHDBCEL01,DATA_FHDB_CD_11_FHDBCEL01 INACTIVE

GridDisk DATA_FHDB_CD_00_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_01_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_02_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_03_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_04_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_05_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_06_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_07_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_08_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_09_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_10_fhdbcel01 successfully altered
GridDisk DATA_FHDB_CD_11_fhdbcel01 successfully altered

cellcli> DROP GRIDDISK ALL PREFIX=DATA_FHDB

GridDisk DATA_FHDB_CD_00_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_01_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_02_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_03_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_04_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_05_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_06_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_07_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_08_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_09_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_10_fhdbcel01 successfully dropped
GridDisk DATA_FHDB_CD_11_fhdbcel01 successfully dropped


cellcli> ALTER GRIDDISK  RECO_FHDB_CD_00_FHDBCEL01,RECO_FHDB_CD_01_FHDBCEL01,RECO_FHDB_CD_02_FHDBCEL01,RECO_FHDB_CD_03_FHDBCEL01,RECO_FHDB_CD_04_FHDBCEL01,RECO_FHDB_CD_05_FHDBCEL01,RECO_FHDB_CD_06_FHDBCEL01,RECO_FHDB_CD_07_FHDBCEL01,RECO_FHDB_CD_08_FHDBCEL01,RECO_FHDB_CD_09_FHDBCEL01,RECO_FHDB_CD_10_FHDBCEL01,RECO_FHDB_CD_11_FHDBCEL01 INACTIVE

GridDisk RECO_FHDB_CD_00_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_01_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_02_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_03_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_04_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_05_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_06_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_07_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_08_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_09_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_10_fhdbcel01 successfully altered
GridDisk RECO_FHDB_CD_11_fhdbcel01 successfully altered


cellcli> DROP GRIDDISK ALL PREFIX=RECO_FHDB

GridDisk RECO_FHDB_CD_00_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_01_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_02_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_03_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_04_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_05_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_06_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_07_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_08_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_09_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_10_fhdbcel01 successfully dropped
GridDisk RECO_FHDB_CD_11_fhdbcel01 successfully dropped


-- Create the grid disk with desired size
 
cellcli> CREATE GRIDDISK ALL PREFIX=DATA_FHDB, size=516G;

Cell disks were skipped because they had no freespace for grid disks: FD_00_fhdbcel01, FD_01_fhdbcel01, FD_02_fhdbcel01, FD_03_fhdbcel01, FD_04_fhdbcel01, FD_05_fhdbcel01, FD_06_fhdbcel01, FD_07_fhdbcel01, FD_08_fhdbcel01, FD_09_fhdbcel01, FD_10_fhdbcel01, FD_11_fhdbcel01, FD_12_fhdbcel01, FD_13_fhdbcel01, FD_14_fhdbcel01, FD_15_fhdbcel01.
GridDisk DATA_FHDB_CD_00_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_01_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_02_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_03_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_04_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_05_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_06_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_07_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_08_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_09_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_10_fhdbcel01 successfully created
GridDisk DATA_FHDB_CD_11_fhdbcel01 successfully created

cellcli> CREATE GRIDDISK ALL PREFIX=RECO_FHDB, size=12G;

Cell disks were skipped because they had no freespace for grid disks: FD_00_fhdbcel01, FD_01_fhdbcel01, FD_02_fhdbcel01, FD_03_fhdbcel01, FD_04_fhdbcel01, FD_05_fhdbcel01, FD_06_fhdbcel01, FD_07_fhdbcel01, FD_08_fhdbcel01, FD_09_fhdbcel01, FD_10_fhdbcel01, FD_11_fhdbcel01, FD_12_fhdbcel01, FD_13_fhdbcel01, FD_14_fhdbcel01, FD_15_fhdbcel01.
GridDisk RECO_FHDB_CD_00_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_01_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_02_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_03_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_04_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_05_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_06_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_07_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_08_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_09_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_10_fhdbcel01 successfully created
GridDisk RECO_FHDB_CD_11_fhdbcel01 successfully created

-- Check Griddisk information

cellcli> list griddisk attributes name,cellDisk,size,status;

         DATA_FHDB_CD_00_fhdbcel01       CD_00_fhdbcel01         516G            active
         DATA_FHDB_CD_01_fhdbcel01       CD_01_fhdbcel01         516G            active
         DATA_FHDB_CD_02_fhdbcel01       CD_02_fhdbcel01         516G            active
         DATA_FHDB_CD_03_fhdbcel01       CD_03_fhdbcel01         516G            active
         DATA_FHDB_CD_04_fhdbcel01       CD_04_fhdbcel01         516G            active
         DATA_FHDB_CD_05_fhdbcel01       CD_05_fhdbcel01         516G            active
         DATA_FHDB_CD_06_fhdbcel01       CD_06_fhdbcel01         516G            active
         DATA_FHDB_CD_07_fhdbcel01       CD_07_fhdbcel01         516G            active
         DATA_FHDB_CD_08_fhdbcel01       CD_08_fhdbcel01         516G            active
         DATA_FHDB_CD_09_fhdbcel01       CD_09_fhdbcel01         516G            active
         DATA_FHDB_CD_10_fhdbcel01       CD_10_fhdbcel01         516G            active
         DATA_FHDB_CD_11_fhdbcel01       CD_11_fhdbcel01         516G            active
         DBFS_DG_CD_02_fhdbcel01         CD_02_fhdbcel01         29.125G         active
         DBFS_DG_CD_03_fhdbcel01         CD_03_fhdbcel01         29.125G         active
         DBFS_DG_CD_04_fhdbcel01         CD_04_fhdbcel01         29.125G         active
         DBFS_DG_CD_05_fhdbcel01         CD_05_fhdbcel01         29.125G         active
         DBFS_DG_CD_06_fhdbcel01         CD_06_fhdbcel01         29.125G         active
         DBFS_DG_CD_07_fhdbcel01         CD_07_fhdbcel01         29.125G         active
         DBFS_DG_CD_08_fhdbcel01         CD_08_fhdbcel01         29.125G         active
         DBFS_DG_CD_09_fhdbcel01         CD_09_fhdbcel01         29.125G         active
         DBFS_DG_CD_10_fhdbcel01         CD_10_fhdbcel01         29.125G         active
         DBFS_DG_CD_11_fhdbcel01         CD_11_fhdbcel01         29.125G         active
         RECO_FHDB_CD_00_fhdbcel01       CD_00_fhdbcel01         12G             active
         RECO_FHDB_CD_01_fhdbcel01       CD_01_fhdbcel01         12G             active
         RECO_FHDB_CD_02_fhdbcel01       CD_02_fhdbcel01         12G             active
         RECO_FHDB_CD_03_fhdbcel01       CD_03_fhdbcel01         12G             active
         RECO_FHDB_CD_04_fhdbcel01       CD_04_fhdbcel01         12G             active
         RECO_FHDB_CD_05_fhdbcel01       CD_05_fhdbcel01         12G             active
         RECO_FHDB_CD_06_fhdbcel01       CD_06_fhdbcel01         12G             active
         RECO_FHDB_CD_07_fhdbcel01       CD_07_fhdbcel01         12G             active
         RECO_FHDB_CD_08_fhdbcel01       CD_08_fhdbcel01         12G             active
         RECO_FHDB_CD_09_fhdbcel01       CD_09_fhdbcel01         12G             active
         RECO_FHDB_CD_10_fhdbcel01       CD_10_fhdbcel01         12G             active
         RECO_FHDB_CD_11_fhdbcel01       CD_11_fhdbcel01         12G             active

--Last step is to add disks back to ASM disk groups and rebalance disks.

ALTER DISKGROUP DATA_FHDB ADD DISK 'o/192.168.10.5/DATA_FHDB_CD*' rebalance power 11 NOWAIT;

Diskgroup altered.

select * from v$asm_operation;

GROUP_NUMBER OPERA STAT      POWER     ACTUAL      SOFAR   EST_WORK   EST_RATE EST_MINUTES ERROR_CODE
------------ ----- ---- ---------- ---------- ---------- ---------- ---------- ----------- --------------------------------------------
           1 REBAL RUN          11         11       7761     257561       9649          25

[oracle@fhdbdb01 scripts]$ ./rebalance_progress.sh 120
######################################################################
This script will monitor Phase 1 (rebalance) file by file and Phase 2
(compaction) disk by disk. Both phases should increment, showing progress.
This script will *not* estimate how long the rebalance will take.
######################################################################

Diskgroup being rebalanced is DATA_FHDB
ASM file numbers for databases start at 256.
Default check interval is 600 seconds. This run using 120 seconds...

Mon Oct  1 16:06:53 EDT 2012: PHASE 1 (of 2): Processing file 444 out of 641
Mon Oct  1 16:08:53 EDT 2012: PHASE 1 (of 2): Processing file 542 out of 641
Mon Oct  1 16:10:53 EDT 2012: PHASE 1 (of 2): Processing file 593 out of 641
Mon Oct  1 16:12:53 EDT 2012: PHASE 1 (of 2): Processing file 634 out of 641
Mon Oct  1 16:14:53 EDT 2012: PHASE 1 (of 2): Processing file 639 out of 641
*******************************************************
Mon Oct  1 16:17:23 EDT 2012: PHASE 1 (of 2) complete.
*******************************************************
Mon Oct  1 16:17:23 EDT 2012: PHASE 2 (of 2): 11 disks processed out of 84


ALTER DISKGROUP RECO_FHDB ADD DISK 'o/192.168.10.5/RECO_FHDB_CD*' rebalance power 11 NOWAIT; 

Diskgroup altered.

select * from v$asm_operation;

GROUP_NUMBER OPERA STAT      POWER     ACTUAL      SOFAR   EST_WORK   EST_RATE EST_MINUTES ERROR_CODE
------------ ----- ---- ---------- ---------- ---------- ---------- ---------- ----------- --------------------------------------------
           2 REBAL RUN          11         11        918       4067       1469           2

 
-- Check the disks are added properly.
 
select name,header_status,mount_status from v$asm_disk where group_number=1 and failgroup='FHDBCEL01';

NAME                           HEADER_STATU MOUNT_S
------------------------------ ------------ -------
DATA_FHDB_CD_04_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_08_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_05_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_09_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_11_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_01_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_03_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_10_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_06_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_02_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_00_FHDBCEL01      MEMBER       CACHED
DATA_FHDB_CD_07_FHDBCEL01      MEMBER       CACHED

12 rows selected.

select name,header_status,mount_status from v$asm_disk where group_number=2 and failgroup='FHDBCEL01';

NAME                           HEADER_STATU MOUNT_S
------------------------------ ------------ -------
RECO_FHDB_CD_02_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_11_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_00_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_06_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_01_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_05_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_04_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_07_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_10_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_09_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_08_FHDBCEL01      MEMBER       CACHED
RECO_FHDB_CD_03_FHDBCEL01      MEMBER       CACHED

12 rows selected.

Repeat same steps on other cell servers.
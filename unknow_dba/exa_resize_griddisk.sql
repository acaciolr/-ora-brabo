-- 1. Determine the amount of space to allocate from RECOC1 to DATAC1 Diskgroups
-- View space usage in diskgroups

SQL> select name, total_mb, free_mb, total_mb - free_mb used_mb, round(100*free_mb/total_mb,2) pct_free
from v$asm_diskgroup
order by 1;
NAME                             TOTAL_MB    FREE_MB    USED_MB   PCT_FREE
------------------------------ ---------- ---------- ---------- ----------
DATAC1                           68812800    9985076   58827724      14.51
RECOC1                           94980480   82594920   12385560      86.96
 
-- We have about 15% free in DATAC1 and about 87% free in RECOC1.  Our goal is to shrink RECOC1's disks to half of their size and give that space to DATAC1.  Please note that this free space is raw free space and not usable free space which takes into account space to rebalance after a disk failure and redundancy.
-- View the failure groups used by the diskgroup that will shrink

SQL> select dg.name, d.failgroup, d.state, d.header_status, d.mount_status, d.mode_status, count(1) num_disks
from v$asm_disk d, v$asm_diskgroup dg
where d.group_number = dg.group_number
and dg.name IN ('RECOC1', 'DATAC1')
group by dg.name, d.failgroup, d.state, d.header_status, d.mount_status, d.mode_status
order by 1,2,3;

NAME                           FAILGROUP                      STATE    HEADER_STATU MOUNT_S MODE_ST  NUM_DISKS
------------------------------ ------------------------------ -------- ------------ ------- ------- ----------
DATAC1                         EXACELL01                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL02                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL03                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL04                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL05                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL06                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL07                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL08                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL09                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL10                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL11                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL12                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL13                 NORMAL   MEMBER       CACHED  ONLINE          12
DATAC1                         EXACELL14                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL01                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL02                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL03                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL04                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL05                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL06                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL07                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL08                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL09                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL10                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL11                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL12                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL13                 NORMAL   MEMBER       CACHED  ONLINE          12
RECOC1                         EXACELL14                 NORMAL   MEMBER       CACHED  ONLINE          12
 
-- We see that we have a full rack of 14 cells (failure groups) for RECOC1 and DATAC1. We want to ensure that each failgroup has 12 disks that are in the state shown.
-- 
-- If there are some disks listed as missing or you see an unexpected number for your configuration, then do not proceed until you resolve this.
-- 
-- In the case of Extreme Flash (EF) systems (X5-EF or X6-EF), you would expect a disk count of 8 instead of 12 (you would see this reflected in the above query in the "NUM_DISKS" column).
-- 
-- The following query will show you the exact physical mapping between the failure group names and the cells with corresponding griddisks (this tells you which cells have griddisks you will need to resize):

SQL> select dg.name, d.failgroup, d.path
from v$asm_disk d, v$asm_diskgroup dg
where d.group_number = dg.group_number
and dg.name IN ('RECOC1', 'DATAC1')
order by 1,2,3
  
NAME       FAILGROUP                      PATH
---------- ------------------------------ --------------------------------------------------
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_00_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_01_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_02_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_03_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_04_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_05_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_06_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_07_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_08_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_09_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_10_EXACELL01
DATAC1     EXACELL01                 o/192.168.74.43/DATAC1_CD_11_EXACELL01
DATAC1     EXACELL02                 o/192.168.74.44/DATAC1_CD_00_EXACELL02
DATAC1     EXACELL02                 o/192.168.74.44/DATAC1_CD_01_EXACELL02
DATAC1     EXACELL02                 o/192.168.74.44/DATAC1_CD_02_EXACELL02
...
RECOC1     EXACELL13                 o/192.168.74.55/RECOC1_CD_07_EXACELL13
RECOC1     EXACELL13                 o/192.168.74.55/RECOC1_CD_08_EXACELL13
RECOC1     EXACELL13                 o/192.168.74.55/RECOC1_CD_09_EXACELL13
RECOC1     EXACELL13                 o/192.168.74.55/RECOC1_CD_10_EXACELL13
RECOC1     EXACELL13                 o/192.168.74.55/RECOC1_CD_11_EXACELL13
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_00_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_01_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_02_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_03_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_04_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_05_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_06_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_07_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_08_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_09_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_10_EXACELL14
RECOC1     EXACELL14                 o/192.168.74.56/RECOC1_CD_11_EXACELL14
 
-- Check celldisks for available free space
-- Free space on celldisks can be used to increase the size of the DATAC1 griddisks.  If the available free space is insufficient to expand DATAC1 griddisks, then RECOC1 griddisks will need to be shrunk to meet the desired new size of DATAC1 griddisks. 

[root@exa01adm01 tmp]# dcli -g ~/cell_group -l root "cellcli -e list celldisk attributes name,freespace"
EXACELL01: CD_00_EXACELL01 0
EXACELL01: CD_01_EXACELL01 0
EXACELL01: CD_02_EXACELL01 0
EXACELL01: CD_03_EXACELL01 0
EXACELL01: CD_04_EXACELL01 0
EXACELL01: CD_05_EXACELL01 0
EXACELL01: CD_06_EXACELL01 0
EXACELL01: CD_07_EXACELL01 0
EXACELL01: CD_08_EXACELL01 0
EXACELL01: CD_09_EXACELL01 0
EXACELL01: CD_10_EXACELL01 0
EXACELL01: CD_11_EXACELL01 0 ...

-- In this case, there is no free space available, so we will need to shrink the RECOC1 griddisks and give that space to DATAC1.  In other configurations there might be plenty of free space available and you will not need to shrink griddisks.
-- 
-- Calculate the amount of space to shrink from the RECO diskgroup and per each griddisk
-- 
-- In this configuration we see that RECO1 has plenty of free space and DATAC1 has less than 15% free. We would like to shrink RECOC1 and give the space to DATAC1.
-- 
-- We decide that RECOC1 will now be 94980480 / 2 = 47490240 MB
-- 
-- We know there are 168 disks from the above query since there are 14 cells * 12 disks/cell
-- 
-- We estimate that RECOO's griddisk size should be about 47490240 / 168 = 282680 MB
-- 
-- Let's ensure this number is at the closest 16 MB boundary since the cell will round down to this:

select 16*TRUNC(&new_disk_size/16) new_disk_size from dual;

NEW_DISK_SIZE
-------------
       282672

-- This shows us that we will need to choose 282672 MB as the new disk size for RECOC1.
-- After we resize RECOC1's disks to this new size, we can expect the RECOC1 diskgroup to be 47488896 MB.

-- Calculate the amount of space per griddisk to increase the DATA griddisks and diskgroup
-- Ensure the ASM disk size and griddisk sizes match across the entire diskgroup. This query will show the combinations of disk sizes in each diskgroup - ideally, there is only one size found for all disks and both ASM (total_mb) and griddisks (os_mb) match.

SQL> select dg.name, d.total_mb, d.os_mb, count(1) num_disks
from v$asm_diskgroup dg, v$asm_disk d
where dg.group_number = d.group_number
group by dg.name, d.total_mb, d.os_mb;

NAME                             TOTAL_MB      OS_MB  NUM_DISKS
------------------------------ ---------- ---------- ----------
DATAC1                             409600     409600        168
RECOC1                             565360     565360        168

-- After shrinking RECOC1's gridisks we will have the following space left per disk for DATAC1:
-- Additional space for DATAC1 disks = RECOC1 current size - RECOC1 new size
--                                                   = 565360 - 282672 = 282688 MB
-- 
-- DATAC1's disks new size = DATAC1 disks current size + new free space from RECOC1
--                                     = 409600 + 282688 = 692288 MB

-- IMPORTANT - Do not skip the following step to check the 16 MB boundary!

-- Let's ensure this number is at the closest 16 MB boundary since the cell will round down to this:

select 16*TRUNC(&new_disk_size/16) new_disk_size from dual;

NEW_DISK_SIZE
-------------
       692288

-- We will use the calculated size of 692288 MB for DATAC1's disks since it is on a 16 MB boundary.  If the result of the query above is different than the value you supplied, you must use the resulting value given by the query because that is the value the cell will round the griddisk size.

-- This value of griddisk size will make DATAC1's diskgroup have a total of 116304384 MB (i.e., 12 disks/cell * 14 cells * 692288 MB)

-- 2. Shrink all of the RECO ASM disks down to the new desired size for all disks
-- The RECO diskgroup's disks are shrunk to the new, smaller size calculated in step 1.

alter diskgroup RECOC1 resize all size 282672M rebalance power 64;

-- NOTE: be patient and wait for the prompt to come back, it may take some time 
-- 
-- Wait for rebalance to finish by checking GV$ASM_OPERATION

SQL> set lines 250 pages 1000
SQL> col error_code form a10
SQL> select dg.name, o.*
from gv$asm_operation o, v$asm_diskgroup dg
where o.group_number = dg.group_number;

-- Proceed ONLY when the query against gv$asm_operation doesn't show any rows for the diskgroup we just shrank.
-- Verify the new size of the ASM disks using the following query:

SQL> select name, total_mb, free_mb, total_mb - free_mb used_mb, round(100*free_mb/total_mb,2) pct_free
from v$asm_diskgroup
order by 1;

NAME                             TOTAL_MB    FREE_MB    USED_MB   PCT_FREE
------------------------------ ---------- ---------- ---------- ----------
DATAC1                           68812800    9985076   58827724      14.51
RECOC1                           47488896   35103336   12385560      73.92

SQL> select dg.name, d.total_mb, d.os_mb, count(1) num_disks
from v$asm_diskgroup dg, v$asm_disk d
where dg.group_number = d.group_number
group by dg.name, d.total_mb, d.os_mb;
NAME                             TOTAL_MB      OS_MB  NUM_DISKS
------------------------------ ---------- ---------- ----------
DATAC1                             409600     409600        168
RECOC1                             282672     565360        168

-- Our RECOC1 ASM disks are now at the desired size. Next, we will shrink the griddisks down to the same size as the ASM disks.

-- 3. Shrink the RECO griddisks on all cells down to the new, smaller size
-- For each storage cell identified in step 1, shrink the griddisks to match the size of the ASM disks that were shrunk in step 2.

dcli -c EXACELL01 -l root "cellcli -e alter griddisk RECOC1_CD_00_EXACELL01 \
,RECOC1_CD_01_EXACELL01 \
,RECOC1_CD_02_EXACELL01 \
,RECOC1_CD_03_EXACELL01 \
,RECOC1_CD_04_EXACELL01 \
,RECOC1_CD_05_EXACELL01 \
,RECOC1_CD_06_EXACELL01 \
,RECOC1_CD_07_EXACELL01 \
,RECOC1_CD_08_EXACELL01 \
,RECOC1_CD_09_EXACELL01 \
,RECOC1_CD_10_EXACELL01 \
,RECOC1_CD_11_EXACELL01 \
size=282672M "

dcli -c EXACELL02 -l root "cellcli -e alter griddisk RECOC1_CD_00_EXACELL02 \
,RECOC1_CD_01_EXACELL02 \
,RECOC1_CD_02_EXACELL02 \
,RECOC1_CD_03_EXACELL02 \
,RECOC1_CD_04_EXACELL02 \
,RECOC1_CD_05_EXACELL02 \
,RECOC1_CD_06_EXACELL02 \
,RECOC1_CD_07_EXACELL02 \
,RECOC1_CD_08_EXACELL02 \
,RECOC1_CD_09_EXACELL02 \
,RECOC1_CD_10_EXACELL02 \
,RECOC1_CD_11_EXACELL02 \
size=282672M "

...

dcli -c EXACELL14 -l root "cellcli -e alter griddisk RECOC1_CD_00_EXACELL14 \
,RECOC1_CD_01_EXACELL14 \
,RECOC1_CD_02_EXACELL14 \
,RECOC1_CD_03_EXACELL14 \
,RECOC1_CD_04_EXACELL14 \
,RECOC1_CD_05_EXACELL14 \
,RECOC1_CD_06_EXACELL14 \
,RECOC1_CD_07_EXACELL14 \
,RECOC1_CD_08_EXACELL14 \
,RECOC1_CD_09_EXACELL14 \
,RECOC1_CD_10_EXACELL14 \
,RECOC1_CD_11_EXACELL14 \
size=282672M "

-- Check that griddisks are at the expected size.

[root@exa01adm01 tmp]# dcli -g cell_group -l root "cellcli -e list griddisk attributes name,size where name like \'RECOC1.*\' "
EXACELL01: RECOC1_CD_00_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_01_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_02_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_03_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_04_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_05_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_06_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_07_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_08_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_09_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_10_EXACELL01 276.046875G
EXACELL01: RECOC1_CD_11_EXACELL01 276.046875G  ...

-- Note: 276.046875 * 1024 = 282672 M

-- 4. Increase the DATA grididisks on all cells to use the newly available free space
-- Check that celldisks have the expected amount of free space.  Since we shrank the ASM and griddisks in steps 2 and 3 above, we now expect to see the following free space on our celldisks:

[root@exa01adm01 tmp]# dcli -g ~/cell_group -l root "cellcli -e list celldisk attributes name,freespace"
EXACELL01: CD_00_EXACELL01 276.0625G
EXACELL01: CD_01_EXACELL01 276.0625G
EXACELL01: CD_02_EXACELL01 276.0625G
EXACELL01: CD_03_EXACELL01 276.0625G
EXACELL01: CD_04_EXACELL01 276.0625G
EXACELL01: CD_05_EXACELL01 276.0625G
EXACELL01: CD_06_EXACELL01 276.0625G
EXACELL01: CD_07_EXACELL01 276.0625G
EXACELL01: CD_08_EXACELL01 276.0625G
EXACELL01: CD_09_EXACELL01 276.0625G
EXACELL01: CD_10_EXACELL01 276.0625G
EXACELL01: CD_11_EXACELL01 276.0625G ...

-- For each storage cell, increase the size of the DATA griddisks to the desired new size (as computed in step 1).  

dcli -c EXACELL01 -l root "cellcli -e alter griddisk DATAC1_CD_00_EXACELL01 \
,DATAC1_CD_01_EXACELL01 \
,DATAC1_CD_02_EXACELL01 \
,DATAC1_CD_03_EXACELL01 \
,DATAC1_CD_04_EXACELL01 \
,DATAC1_CD_05_EXACELL01 \
,DATAC1_CD_06_EXACELL01 \
,DATAC1_CD_07_EXACELL01 \
,DATAC1_CD_08_EXACELL01 \
,DATAC1_CD_09_EXACELL01 \
,DATAC1_CD_10_EXACELL01 \
,DATAC1_CD_11_EXACELL01 \
size=692288M "
...
dcli -c EXACELL14 -l root "cellcli -e alter griddisk DATAC1_CD_00_EXACELL14 \
,DATAC1_CD_01_EXACELL14 \
,DATAC1_CD_02_EXACELL14 \
,DATAC1_CD_03_EXACELL14 \
,DATAC1_CD_04_EXACELL14 \
,DATAC1_CD_05_EXACELL14 \
,DATAC1_CD_06_EXACELL14 \
,DATAC1_CD_07_EXACELL14 \
,DATAC1_CD_08_EXACELL14 \
,DATAC1_CD_09_EXACELL14 \
,DATAC1_CD_10_EXACELL14 \
,DATAC1_CD_11_EXACELL14 \
size=692288M "

-- verify the new size

dcli -g cell_group -l root "cellcli -e list griddisk attributes name,size where name like \'DATAC1.*\' "
EXACELL01: DATAC1_CD_00_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_01_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_02_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_03_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_04_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_05_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_06_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_07_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_08_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_09_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_10_EXACELL01 676.0625G
EXACELL01: DATAC1_CD_11_EXACELL01 676.0625G

-- Instead of increasing the DATA diskgroup, you may opt to create new disk groups with the newly freed free space or keep it free for future use. In general, Oracle recommends using the smallest number disk groups needed (typically DATA, RECO, DBFS_DG) to give the greatest flexibility and ease of administration; however, there may be cases, perhaps when using VMs or consolidating many databases, where additional diskgroups or available free space for future use may be desired.  See Best Practices For Database Consolidation On Oracle Exadata Database Machine for more information. If you decide to leave free space on the griddisks in reserve for future use, please see Doc ID 1684112.1 for the steps on how to allocate free space to an existing diskgroup later.

-- 5.Increase the size of all ASM disks in DATA to use the larger griddisks
-- Increase the ASM disks for DATAC1 diskgroup to the new size on the storage cells.

SQL> alter diskgroup DATAC1 resize all ;

-- This will resize the ASM disks to match the size of the griddisks.

-- NOTE: Known Issue if Disk Group has Quorum Disks Configured
-- In case the specified diskgroup DATAC1 has Quorum disks configured in it, the above ASM “resize all” command could fail with error ORA-15277.

-- Quorum disks are configured if the requirements specified here are met:

-- As a workaround specify the storage server failure group names (for the ones of FAILURE_TYPE "REGULAR", not "QUORUM") explicitly in the ASM SQL command. E.g.

SQL> alter diskgroup DATAC1 resize disks in failgroup exacell01, exacell02, exacell03;
 
-- Wait for rebalance to finish

SQL> set lines 250 pages 1000
SQL> col error_code form a10
SQL> select dg.name, o.*
from gv$asm_operation o, v$asm_diskgroup dg
where o.group_number = dg.group_number;

-- Proceed only when this query doesn't show any rows related to the DATAC1 diskgroup.
-- 
-- Verify the new sizes for the ASM disks and diskgroup is at the desired sizes

SQL> select name, total_mb, free_mb, total_mb - free_mb used_mb, round(100*free_mb/total_mb,2) pct_free
from v$asm_diskgroup
order by 1;
NAME                             TOTAL_MB    FREE_MB    USED_MB   PCT_FREE
------------------------------ ---------- ---------- ---------- ----------
DATAC1                          116304384   57439796   58864588      49.39
RECOC1                           47488896   34542516   12946380      72.74

SQL>  select dg.name, d.total_mb, d.os_mb, count(1) num_disks
from v$asm_diskgroup dg, v$asm_disk d
where dg.group_number = d.group_number
group by dg.name, d.total_mb, d.os_mb;
 
NAME                             TOTAL_MB      OS_MB  NUM_DISKS
------------------------------ ---------- ---------- ----------
DATAC1                             692288     692288        168
RECOC1                             282672     282672        168
 
-- The RECOC1 and DATAC1 diskgroups are now at the new desired sizes that were calculated in step 1 above.
-- 
-- At the end of this procedure the newly freed space from the RECO griddisks will be taken by the DATA griddisks.  This space will not be contiguous with other space used by the DATA diskgroups, but this has no impact on performance and is completely expected and normal.
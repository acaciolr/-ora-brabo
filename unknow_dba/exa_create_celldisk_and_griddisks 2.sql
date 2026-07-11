--Create Cell Disk and Grid Disk Manually on Exadata
--We had a failed hard disk on a Exadata Storage cell X6-2. So we scheduled the Oracle Field Engineer to replace the bad disk. Oracle Field Engineer came onsite and replaced the faulty hard disk. Post hard disk replacement we found that the physical disk and luns are created successfully but the Cell disk and Grid disks were not created automatically. When a hard disk is replaced, the lun, cell disk and grid disks are created automatically and grid disks are added to ASM disk group for you without any manual intervention. In some odd cases, the Cell disk and grid disks are not created automatically, in those cases you must manually create the Cell disk, create the Grid disks with proper sizes and add them to the ASM disk group.

--In this article we will demonstrate how to create the Cell disk, Grid disks manually and add them to the respective ASM Disk Group.

/*
Environment

Exadata X6-2 Elastic Configuration
4 Compute nodes and 6 Storage cells
Hard Disk Size: 8TB
3 ASM Disk Group: DATA, RECO & DBFS_DG
Total Number of Grid disks: DATA - 72, RECO - 72 & DBFS_DG - 60
*/

--Here the disk in the location 8:5 was back and replaced.

--Before Replacing Hard Disk:

CellCLI> list physicaldisk
         8:0             PYJZKV                  normal
         8:1             PMU3LV                  normal
         8:2             P1Y2KV                  normal
         8:3             PYH48V                  normal
         8:4             PY7MAV                  normal
         8:5             PPZ47V                  not present
         8:6             PEJKHR                  normal
         8:7             PY4XSV                  normal
         8:8             PYL00V                  normal
         8:9             PV5RGV                  normal
         8:10            PSU26V                  normal
         8:11            PY522V                  normal
         FLASH_1_1       CVMD522500AG1P6NGN      normal
         FLASH_2_1       CVMD522401AC1P6NGN      normal
         FLASH_4_1       CVMD522500AC1P6NGN      normal
         FLASH_5_1       CVMD5230000Y1P6NGN      normal

CellCLI> list lun
         0_0     0_0     normal
         0_1     0_1     normal
         0_2     0_2     normal
         0_3     0_3     normal
         0_4     0_4     normal
         0_5     0_5     not present
         0_6     0_6     normal
         0_7     0_7     normal
         0_8     0_8     normal
         0_9     0_9     normal
         0_10    0_10    normal
         0_11    0_11    normal
         1_1     1_1     normal
         2_1     2_1     normal
         4_1     4_1     normal
         5_1     5_1     normal

After replacing Hard Disk:

CellCLI> list physicaldisk
         8:0             PYJZKV                  normal
         8:1             PMU3LV                  normal
         8:2             P1Y2KV                  normal
         8:3             PYH48V                  normal
         8:4             PY7MAV                  normal
         8:5             PPZ47V                  normal
         8:6             PEJKHR                  normal
         8:7             PY4XSV                  normal
         8:8             PYL00V                  normal
         8:9             PV5RGV                  normal
         8:10            PSU26V                  normal
         8:11            PY522V                  normal
         FLASH_1_1       CVMD522500AG1P6NGN      normal
         FLASH_2_1       CVMD522401AC1P6NGN      normal
         FLASH_4_1       CVMD522500AC1P6NGN      normal
         FLASH_5_1       CVMD5230000Y1P6NGN      normal

CellCLI> list lun
         0_0     0_0     normal
         0_1     0_1     normal
         0_2     0_2     normal
         0_3     0_3     normal
         0_4     0_4     normal
         0_5     0_5     normal
         0_6     0_6     normal
         0_7     0_7     normal
         0_8     0_8     normal
         0_9     0_9     normal
         0_10    0_10    normal
         0_11    0_11    normal
         1_1     1_1     normal
         2_1     2_1     normal
         4_1     4_1     normal
         5_1     5_1     normal

[root@dm01cel03 ~]# cellcli -e list physicaldisk 8:5 detail
         name:                   8:5
         deviceId:               21
         deviceName:             /dev/sdf
         diskType:               HardDisk
         enclosureDeviceId:      8
         errOtherCount:          0
         luns:                   0_5
         makeModel:              "HGST    H7280A520SUN8.0T"
         physicalFirmware:       PD51
         physicalInsertTime:     2018-05-18T10:52:29-05:00
         physicalInterface:      sas
         physicalSerial:         PPZ47V
         physicalSize:           7.1536639072000980377197265625T
         slotNumber:             5
         status:                 normal

[root@dm01cel03 ~]# cellcli -e list celldisk where lun=0_5 detail


[root@dm01cel03 ~]# cellcli -e list griddisk where cellDisk=CD_05_cm01cel01 attributes name,status
DATA_CD_05_dm01cel03  not present
DBFS_DG_CD_05_dm01cel03  not present
RECO_CD_05_dm01cel03  not present

[root@dm01cel03 ~]# cellcli -e list griddisk where celldisk=CD_05_dm01cel03 detail
         name:                   DATA_CD_05_dm01cel03
         availableTo:
         cachingPolicy:          default
         cellDisk:               CD_05_dm01cel03
         comment:                "Cluster dm01-cluster diskgroup DATA"
         creationTime:           2016-03-29T20:25:56-05:00
         diskType:               HardDisk
         errorCount:             0
         id:                     db221d77-25b0-4f9e-af6f-95e1c3134af5
         size:                   5.6953125T
         status:                 not present

         name:                   DBFS_DG_CD_05_dm01cel03
         availableTo:
         cachingPolicy:          default
         cellDisk:               CD_05_dm01cel03
         comment:                "Cluster dm01-cluster diskgroup DBFS_DG"
         creationTime:           2016-03-29T20:25:53-05:00
         diskType:               HardDisk
         errorCount:             0
         id:                     216fbec9-6ed4-4ef6-a0d4-d09517906fd5
         size:                   33.796875G
         status:                 not present

         name:                   RECO_CD_05_dm01cel03
         availableTo:
         cachingPolicy:          none
         cellDisk:               CD_05_dm01cel03
         comment:                "Cluster dm01-cluster diskgroup RECO"
         creationTime:           2016-03-29T20:25:58-05:00
         diskType:               HardDisk
         errorCount:             0
         id:                     e8ca6943-0ddd-48ab-b890-e14bbf4e591c
         size:                   1.42388916015625T
         status:                 not present

--We can clearly see that the GRID DISKs are not present. So we have to create the GRID DISKs Manually.

--Steps to create Celldisk, Griddisks and add them to ASM Disk Group

List Cell Disks

[root@dm01cel03 ~]# cellcli -e list celldisk
         CD_00_dm01cel03         normal
         CD_01_dm01cel03         normal
         CD_02_dm01cel03         normal
         CD_03_dm01cel03         normal
         CD_04_dm01cel03         normal
         CD_05_dm01cel03         not present
         CD_06_dm01cel03         normal
         CD_07_dm01cel03         normal
         CD_08_dm01cel03         normal
         CD_09_dm01cel03         normal
         CD_10_dm01cel03         normal
         CD_11_dm01cel03         normal
         FD_00_dm01cel03         normal
         FD_01_dm01cel03         normal
         FD_02_dm01cel03         normal
         FD_03_dm01cel03         normal

List Grid Disks

[root@dm01cel03 ~]# cellcli -e list griddisk
         DATA_CD_00_dm01cel03       active
         DATA_CD_01_dm01cel03       active
         DATA_CD_02_dm01cel03       active
         DATA_CD_03_dm01cel03       active
         DATA_CD_04_dm01cel03       active
         DATA_CD_05_dm01cel03       not present
         DATA_CD_06_dm01cel03       active
         DATA_CD_07_dm01cel03       active
         DATA_CD_08_dm01cel03       active
         DATA_CD_09_dm01cel03       active
         DATA_CD_10_dm01cel03       active
         DATA_CD_11_dm01cel03       active
         DBFS_DG_CD_02_dm01cel03    active
         DBFS_DG_CD_03_dm01cel03    active
         DBFS_DG_CD_04_dm01cel03    active
         DBFS_DG_CD_05_dm01cel03    not present
         DBFS_DG_CD_06_dm01cel03    active
         DBFS_DG_CD_07_dm01cel03    active
         DBFS_DG_CD_08_dm01cel03    active
         DBFS_DG_CD_09_dm01cel03    active
         DBFS_DG_CD_10_dm01cel03    active
         DBFS_DG_CD_11_dm01cel03    active
         RECO_CD_00_dm01cel03       active
         RECO_CD_01_dm01cel03       active
         RECO_CD_02_dm01cel03       active
         RECO_CD_03_dm01cel03       active
         RECO_CD_04_dm01cel03       active
         RECO_CD_05_dm01cel03       not present
         RECO_CD_06_dm01cel03       active
         RECO_CD_07_dm01cel03       active
         RECO_CD_08_dm01cel03       active
         RECO_CD_09_dm01cel03       active
         RECO_CD_10_dm01cel03       active
         RECO_CD_11_dm01cel03       active

List Physical Disk details

[root@dm01cel03 ~]# cellcli -e list physicaldisk where physicalSerial=PPZ47V detail
         name:                   8:5
         deviceId:               21
         deviceName:             /dev/sdf
         diskType:               HardDisk
         enclosureDeviceId:      8
         errOtherCount:          0
         luns:                   0_5
         makeModel:              "HGST    H7280A520SUN8.0T"
         physicalFirmware:       PD51
         physicalInsertTime:     2018-05-18T10:52:29-05:00
         physicalInterface:      sas
         physicalSerial:         PPZ47V
         physicalSize:           7.1536639072000980377197265625T
         slotNumber:             5
         status:                 normal


--Let's try to create the Cell Disk

[root@dm01cel03 ~]# cellcli -e create celldisk CD_09_dm01cel03 lun=0_5

CELL-02526: Pre-existing cell disk: CD_09_dm01cel03

--It says the Cell Disk already exists.
--Let's try to create the Grid Disk. To create the Grid Disk with proper size, get the Grid Disk size from a good Cell Disk as shown below.

[root@dm01cel03 ~]# cellcli -e list griddisk where celldisk=CD_07_dm01cel03 attributes name,size,offset
         DATA_CD_07_dm01cel03       5.6953125T              32M
         DBFS_DG_CD_07_dm01cel03         33.796875G         7.1192474365234375T
         RECO_CD_07_dm01cel03       1.42388916015625T       5.6953582763671875T

Now create the Grid Disk

[root@dm01cel03 ~]# cellcli -e create griddisk DATA_CD_05_dm01cel03 celldisk=CD_05_dm01cel03,size=5.6953125T

CELL-02701: Cannot create grid disk on cell disk CD_05_dm01cel03 because its status is not normal.

--Looks like we can't create the Grid Disk. We will now drop the Cell Disk and recreate it.

Drop Cell Disk

CellCLI> drop celldisk CD_05_dm01cel03 force
CellDisk CD_05_dm01cel03 successfully dropped

Create Cell Disk

CellCLI> create celldisk CD_05_dm01cel03 lun=0_5
CellDisk CD_05_dm01cel03 successfully created

Create Grid Disks with proper sizes

CellCLI> create griddisk DATA_CD_05_dm01cel03 celldisk=CD_05_dm01cel03,size=5.6953125T
GridDisk DATA_CD_05_dm01cel03 successfully created

CellCLI> create griddisk RECO_CD_05_dm01cel03 celldisk=CD_05_dm01cel03,size=1.42388916015625T
GridDisk RECO_CD_05_dm01cel03 successfully created

CellCLI> create griddisk DBFS_DG_CD_05_dm01cel03 celldisk=CD_05_dm01cel03,size=33.796875G
GridDisk DBFS_DG_CD_05_dm01cel03 successfully created

List Grid Disks

CellCLI> list griddisk where celldisk=CD_05_dm01cel03 attributes name,size,offset
         DATA_CD_05_dm01cel03       5.6953125T              32M
         DBFS_DG_CD_05_dm01cel03         33.796875G              7.1192474365234375T
         RECO_CD_05_dm01cel03       1.42388916015625T       5.6953582763671875T

CellCLI> list griddisk
         DATA_CD_00_dm01cel03       active
         DATA_CD_01_dm01cel03       active
         DATA_CD_02_dm01cel03       active
         DATA_CD_03_dm01cel03       active
         DATA_CD_04_dm01cel03       active
         DATA_CD_05_dm01cel03       active
         DATA_CD_06_dm01cel03       active
         DATA_CD_07_dm01cel03       active
         DATA_CD_08_dm01cel03       active
         DATA_CD_09_dm01cel03       active
         DATA_CD_10_dm01cel03       active
         DATA_CD_11_dm01cel03       active
         DBFS_DG_CD_02_dm01cel03    active
         DBFS_DG_CD_03_dm01cel03    active
         DBFS_DG_CD_04_dm01cel03    active
         DBFS_DG_CD_05_dm01cel03    active
         DBFS_DG_CD_06_dm01cel03    active
         DBFS_DG_CD_07_dm01cel03    active
         DBFS_DG_CD_08_dm01cel03    active
         DBFS_DG_CD_09_dm01cel03    active
         DBFS_DG_CD_10_dm01cel03    active
         DBFS_DG_CD_11_dm01cel03    active
         RECO_CD_00_dm01cel03       active
         RECO_CD_01_dm01cel03       active
         RECO_CD_02_dm01cel03       active
         RECO_CD_03_dm01cel03       active
         RECO_CD_04_dm01cel03       active
         RECO_CD_05_dm01cel03       active
         RECO_CD_06_dm01cel03       active
         RECO_CD_07_dm01cel03       active
         RECO_CD_08_dm01cel03       active
         RECO_CD_09_dm01cel03       active
         RECO_CD_10_dm01cel03       active
         RECO_CD_11_dm01cel03       active

--The Grid Disks show active now. We can go ahead and add them to ASM disk Group Manually by connecting to ASM instance.

--Log into +ASM1 instance and add the new disk.  Set the rebalance power higher (11) to perform faster rebalance operation.

dm01db01-orcldb1 {/home/oracle}:. oraenv
ORACLE_SID = [orcldb1] ? +ASM1
The Oracle base remains unchanged with value /u01/app/oracle
dm01db01-+ASM1 {/home/oracle}:sqlplus / as sysasm

SQL*Plus: Release 11.2.0.4.0 Production on Wed May 23 09:30:13 2018
Copyright (c) 1982, 2013, Oracle.  All rights reserved.

Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Real Application Clusters and Automatic Storage Management options

SQL> alter diskgroup DATA add failgroup dm01CEL03 disk 'o/192.168.10.1;192.168.10.2/DATA_CD_05_dm01cel03' name DATA_CD_05_dm01cel03 rebalance power 11;

Diskgroup altered.

SQL> alter diskgroup RECO add failgroup dm01CEL03 disk 'o/192.168.10.1;192.168.10.2/RECO_CD_05_dm01cel03' name RECO_CD_05_dm01cel03 rebalance power 11;

Diskgroup altered.

SQL> alter diskgroup DBFS_DG add failgroup dm01CEL03 disk 'o/192.168.10.1;192.168.10.2/DBFS_DG_CD_05_dm01cel03' name DBFS_DG_CD_05_dm01cel03 rebalance power 11;

Diskgroup altered.

SQL> select a.name,a.total_mb,a.free_mb,a.type,
    decode(a.type,'NORMAL',a.total_mb/2,'HIGH',a.total_mb/3) avail_mb,
    decode(a.type,'NORMAL',a.free_mb/2,'HIGH',a.free_mb/3) usable_mb,
    count(b.path) cell_disks  from v$asm_diskgroup a, v$asm_disk b
    where a.group_number=b.group_number group by a.name,a.total_mb,a.free_mb,a.type,
    decode(a.type,'NORMAL',a.total_mb/2,'HIGH',a.total_mb/3) ,
    decode(a.type,'NORMAL',a.free_mb/2,'HIGH',a.free_mb/3)
   order by 2,1;

               Total MB    Free MB          Total MB    Free MB
Disk Group          Raw        Raw TYPE       Usable     Usable     CELL_DISKS
------------ ---------- ---------- ------ ---------- ---------- ----------
DBFS_DG    2076480    2074688 NORMAL    1038240    1037344         60
RECO     107500032   57573496 HIGH     35833344   19191165         72
DATA     429981696  282905064 HIGH    143327232   94301688         72

SQL> select * from v$asm_operation;

GROUP_NUMBER OPERA STAT      POWER     ACTUAL      SOFAR   EST_WORK   EST_RATE EST_MINUTES ERROR_CODE
------------ ----- ---- ---------- ---------- ---------- ---------- ---------- ----------- --------------------------------------------
           1 REBAL RUN          11         11      85992    6697959      11260         587
           3 REBAL WAIT         11


SQL> select * from gv$asm_operation;

no rows selected


--Conclusion

--In this article we have learned how to create the Celldisk, Griddisks and add the newly created Griddisks to ASM Disk Group. When a hard disk is replaced, the lun, celldisk and griddisks are created automatically and griddisks are added to ASM disk group for you without any manual intervention. In some cases, if the Celldisk and grid disks are not created automatically, then you must manually create them and add them to the ASM disk group.
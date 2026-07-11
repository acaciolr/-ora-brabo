--Exadata Disk creation and Management:

--Exadata Storage Layout:
PHYSICAL DISK -> LUN -> CELL DISK -> GRID DISK -> ASM DISK

--a). 
-- List LUN and PHYSICAL DISK.
CellCLI> LIST LUN -- List of all LUN's on a cell.
CellCLI> LIST LUN
0_0 0_0 normal
0_1 0_1 normal
0_2 0_2 normal
0_3 0_3 normal
0_4 0_4 normal
0_5 0_5 normal
0_6 0_6 normal
0_7 0_7 normal
0_8 0_8 normal
0_9 0_9 normal
0_10 0_10 normal
0_11 0_11 normal
1_0 1_0 normal
1_1 1_1 normal
1_2 1_2 normal
1_3 1_3 normal
2_0 2_0 normal
2_1 2_1 normal
2_2 2_2 normal
2_3 2_3 normal
4_0 4_0 normal
4_1 4_1 normal
4_2 4_2 normal
4_3 4_3 normal
5_0 5_0 normal
5_1 5_1 normal
5_2 5_2 normal
5_3 5_3 normal


CellCLI> LIST LUN where disktype = harddisk -- List all the hard disks on a cell.
CellCLI> LIST LUN where disktype = harddisk
0_0 0_0 normal
0_1 0_1 normal
0_2 0_2 normal
0_3 0_3 normal
0_4 0_4 normal
0_5 0_5 normal
0_6 0_6 normal
0_7 0_7 normal
0_8 0_8 normal
0_9 0_9 normal
0_10 0_10 normal
0_11 0_11 normal

CellCLI> LIST LUN where disktype = flashdisk -- List all the flash disks on a cell.
CellCLI> LIST LUN where disktype = flashdisk
1_0 1_0 normal
1_1 1_1 normal
1_2 1_2 normal
1_3 1_3 normal
2_0 2_0 normal
2_1 2_1 normal
2_2 2_2 normal
2_3 2_3 normal
4_0 4_0 normal
4_1 4_1 normal
4_2 4_2 normal
4_3 4_3 normal
5_0 5_0 normal
5_1 5_1 normal
5_2 5_2 normal
5_3 5_3 normal


CellCLI> LIST LUN where celldisk = null -- List all the LUN's not associated with a cell disk.
CellCLI> LIST LUN where celldisk = null


CellCLI> LIST LUN where name = 0_7 detail -- Check isSystemLun=FALSE, this indicates that LUN is not located on a system disk.
CellCLI> LIST LUN where name = 0_7 detail
name: 0_7
cellDisk: CD_07_atl02cel01
deviceName: /dev/sdh
diskType: HardDisk
id: 0_7
isSystemLun: FALSE
lunAutoCreate: FALSE
lunSize: 1861.712890625G
lunUID: 0_7
physicalDrives: 24:7
raidLevel: 0
lunWriteCacheMode: "WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU"
status: normal


CellCLI> LIST PHYSICALDISK where name = 24:7 detail -- List the physical disk attributes (pass the "physicalDrives" name)
CellCLI> LIST PHYSICALDISK where name = 24:7 detail
name: 24:7
deviceId: 23
diskType: HardDisk
enclosureDeviceId: 24
errMediaCount: 0
errOtherCount: 0
foreignState: false
luns: 0_7
makeModel: "HITACHI H7220AA30SUN2.0T"
physicalFirmware: JKAOA28A
physicalInsertTime: 2010-07-13T21:22:00-04:00
physicalInterface: sata
physicalSerial: JK1130YAHBXL2T
physicalSize: 1862.6559999994934G
slotNumber: 7
status: normal


--b).
-- How to create Cell disk?

CellCLI> LIST CELLDISK -- List all the cell disks on a cell node.
CellCLI> LIST CELLDISK
CD_00_atl02cel01 normal
CD_01_atl02cel01 normal
CD_02_atl02cel01 normal
CD_03_atl02cel01 normal
CD_04_atl02cel01 normal
CD_05_atl02cel01 normal
CD_06_atl02cel01 normal
CD_07_atl02cel01 normal
CD_08_atl02cel01 normal
CD_09_atl02cel01 normal
CD_10_atl02cel01 normal
CD_11_atl02cel01 normal
FD_00_atl02cel01 normal
FD_01_atl02cel01 normal
FD_02_atl02cel01 normal
FD_03_atl02cel01 normal
FD_04_atl02cel01 normal
FD_05_atl02cel01 normal
FD_06_atl02cel01 normal
FD_07_atl02cel01 normal
FD_08_atl02cel01 normal
FD_09_atl02cel01 normal
FD_10_atl02cel01 normal
FD_11_atl02cel01 normal
FD_12_atl02cel01 normal
FD_13_atl02cel01 normal
FD_14_atl02cel01 normal
FD_15_atl02cel01 normal

-- Hard Disk
CellCLI> LIST CELLDISK where name = CD_07_atl02cel01 detail
name: CD_07_atl02cel01
comment:
creationTime: 2010-07-14T19:56:09-04:00
deviceName: /dev/sdh
devicePartition: /dev/sdh
diskType: HardDisk
errorCount: 0
freeSpace: 560M
freeSpaceMap: offset=1832.046875G,size=560M
id: 00000129-d363-0901-0000-000000000000
interleaving: none
lun: 0_7
raidLevel: 0
size: 1861.703125G
status: normal

CellCLI> CREATE CELLDISK CD_07_atl02cel01 LUN='0_7' HARDDISK


-- Flash Disk
CellCLI> LIST CELLDISK where name = FD_00_atl02cel01 detail
name: FD_00_atl02cel01
comment:
creationTime: 2011-03-27T03:17:59-04:00
deviceName: /dev/sdq
devicePartition: /dev/sdq
diskType: FlashDisk
errorCount: 0
freeSpace: 0
id: caf0be8d-4061-451a-a9da-090945a9c8d5
interleaving: none
lun: 1_0
size: 22.875G
status: normal

CellCLI> CREATE CELLDISK FD_00_atl02cel01 LUN='1_0' FLASHDISK


--c).
-- How to create Grid disk?
--All the grid disks are created on cell disks (HARDDISK, not FLASHDISK).

CellCLI> LIST GRIDDISK -- List all the grid disks on a cell node.
CellCLI> LIST GRIDDISK
DATA_CD_00_atl02cel01 active
DATA_CD_01_atl02cel01 active
DATA_CD_02_atl02cel01 active
DATA_CD_03_atl02cel01 active
DATA_CD_04_atl02cel01 active
DATA_CD_05_atl02cel01 active
DATA_CD_06_atl02cel01 active
DATA_CD_07_atl02cel01 active
DATA_CD_08_atl02cel01 active
DATA_CD_09_atl02cel01 active
DATA_CD_10_atl02cel01 active
DATA_CD_11_atl02cel01 active
RECO_CD_00_atl02cel01 active
RECO_CD_01_atl02cel01 active
RECO_CD_02_atl02cel01 active
RECO_CD_03_atl02cel01 active
RECO_CD_04_atl02cel01 active
RECO_CD_05_atl02cel01 active
RECO_CD_06_atl02cel01 active
RECO_CD_07_atl02cel01 active
RECO_CD_08_atl02cel01 active
RECO_CD_09_atl02cel01 active
RECO_CD_10_atl02cel01 active
RECO_CD_11_atl02cel01 active
SYSTEMDG_CD_02_atl02cel01 active
SYSTEMDG_CD_03_atl02cel01 active
SYSTEMDG_CD_04_atl02cel01 active
SYSTEMDG_CD_05_atl02cel01 active
SYSTEMDG_CD_06_atl02cel01 active
SYSTEMDG_CD_07_atl02cel01 active
SYSTEMDG_CD_08_atl02cel01 active
SYSTEMDG_CD_09_atl02cel01 active
SYSTEMDG_CD_10_atl02cel01 active
SYSTEMDG_CD_11_atl02cel01 active

CellCLI> LIST GRIDDISK where celldisk=CD_07_atl02cel01 detail -- List the different grid disks names on one celldisk and the OFFSET is starting point on the physical disk.
CellCLI> LIST GRIDDISK where celldisk=CD_07_atl02cel01 detail
name: DATA_CD_07_atl02cel01
availableTo:
cellDisk: CD_07_atl02cel01
comment:
creationTime: 2010-07-14T19:58:53-04:00
diskType: HardDisk
errorCount: 0
id: 00000129-d365-88f0-0000-000000000000
offset: 32M
size: 1582G
status: active

name: RECO_CD_07_atl02cel01
availableTo:
cellDisk: CD_07_atl02cel01
comment:
creationTime: 2010-08-20T12:27:25-04:00
diskType: HardDisk
errorCount: 0
id: 0000012a-9053-7f16-0000-000000000000
offset: 1582G
size: 250G
status: active

name: SYSTEMDG_CD_07_atl02cel01
availableTo:
cellDisk: CD_07_atl02cel01
comment:
creationTime: 2010-07-14T19:56:50-04:00
diskType: HardDisk
errorCount: 0
id: 00000129-d363-a6e5-0000-000000000000
offset: 1832.59375G
size: 29.109375G
status: active

CellCLI> CREATE GRIDDISK DATA_CD_07_atl02cel01 celldisk=CD_07_atl02cel01,size=1582G,offset=32M -- Where "offset" is starting point on the disk.
CellCLI> CREATE GRIDDISK RECO_CD_07_atl02cel01 celldisk=CD_07_atl02cel01,size=250G,offset=1582G
CellCLI> CREATE GRIDDISK SYSTEMDG_CD_07_atl02cel01 celldisk=CD_07_atl02cel01,size=29.109375G,offset=1832.59375G


--d).
-- How to create ASM disk on Exadata?

CellCLI> LIST GRIDDISK attributes name, size, asmmodestatus where asmmodestatus='UNUSED' -- To identify all the unused grid disks to create ASM disks.

asmca
--(or)
. oraenv
+ASM1

sqlplus / as sysasm

set linesize 200
col path for a50
-- No CANDIDATE disks.
SQL> select name, header_status, path 
	   from v$asm_disk
	  where header_status <> 'MEMBER';

no rows selected

-- Print Existing disk name and the paths.
SQL> select * from (select name, header_status, path from v$asm_disk order by name) where rownum < 16;

NAME HEADER_STATU PATH
------------------------- ------------ --------------------------------------------------
DATA_CD_00_ATL02CEL01 MEMBER o/192.168.10.1/DATA_CD_00_atl02cel01
DATA_CD_00_ATL02CEL02 MEMBER o/192.168.10.2/DATA_CD_00_atl02cel02
DATA_CD_00_ATL02CEL03 MEMBER o/192.168.10.3/DATA_CD_00_atl02cel03
DATA_CD_00_ATL02CEL04 MEMBER o/192.168.10.4/DATA_CD_00_atl02cel04
DATA_CD_00_ATL02CEL05 MEMBER o/192.168.10.5/DATA_CD_00_atl02cel05
DATA_CD_00_ATL02CEL06 MEMBER o/192.168.10.6/DATA_CD_00_atl02cel06
DATA_CD_00_ATL02CEL07 MEMBER o/192.168.10.7/DATA_CD_00_atl02cel07
DATA_CD_00_ATL02CEL08 MEMBER o/192.168.10.8/DATA_CD_00_atl02cel08
DATA_CD_00_ATL02CEL09 MEMBER o/192.168.10.9/DATA_CD_00_atl02cel09
DATA_CD_00_ATL02CEL10 MEMBER o/192.168.10.10/DATA_CD_00_atl02cel10
DATA_CD_01_ATL02CEL01 MEMBER o/192.168.10.1/DATA_CD_01_atl02cel01
DATA_CD_01_ATL02CEL02 MEMBER o/192.168.10.2/DATA_CD_01_atl02cel02
DATA_CD_01_ATL02CEL03 MEMBER o/192.168.10.3/DATA_CD_01_atl02cel03
DATA_CD_01_ATL02CEL04 MEMBER o/192.168.10.4/DATA_CD_01_atl02cel04
DATA_CD_01_ATL02CEL05 MEMBER o/192.168.10.5/DATA_CD_01_atl02cel05

15 rows selected.

col failgroup_type for a15;
SQL> select * from (select name, header_status, path, failgroup, failgroup_type, sector_size from v$asm_disk order by name) where rownum < 16;

NAME HEADER_STATU PATH FAILGROUP FAILGROUP_TYPE SECTOR_SIZE
------------------------- ------------ --------------------------------------------- ----------- ------------------ -------------
DATA_CD_00_ATL02CEL01 MEMBER o/192.168.10.1/DATA_CD_00_atl02cel01 ATL02CEL01 REGULAR 512
DATA_CD_00_ATL02CEL02 MEMBER o/192.168.10.2/DATA_CD_00_atl02cel02 ATL02CEL02 REGULAR 512
DATA_CD_00_ATL02CEL03 MEMBER o/192.168.10.3/DATA_CD_00_atl02cel03 ATL02CEL03 REGULAR 512
DATA_CD_00_ATL02CEL04 MEMBER o/192.168.10.4/DATA_CD_00_atl02cel04 ATL02CEL04 REGULAR 512
DATA_CD_00_ATL02CEL05 MEMBER o/192.168.10.5/DATA_CD_00_atl02cel05 ATL02CEL05 REGULAR 512
DATA_CD_00_ATL02CEL06 MEMBER o/192.168.10.6/DATA_CD_00_atl02cel06 ATL02CEL06 REGULAR 512
DATA_CD_00_ATL02CEL07 MEMBER o/192.168.10.7/DATA_CD_00_atl02cel07 ATL02CEL07 REGULAR 512
DATA_CD_00_ATL02CEL08 MEMBER o/192.168.10.8/DATA_CD_00_atl02cel08 ATL02CEL08 REGULAR 512
DATA_CD_00_ATL02CEL09 MEMBER o/192.168.10.9/DATA_CD_00_atl02cel09 ATL02CEL09 REGULAR 512
DATA_CD_00_ATL02CEL10 MEMBER o/192.168.10.10/DATA_CD_00_atl02cel10 ATL02CEL10 REGULAR 512
DATA_CD_01_ATL02CEL01 MEMBER o/192.168.10.1/DATA_CD_01_atl02cel01 ATL02CEL01 REGULAR 512
DATA_CD_01_ATL02CEL02 MEMBER o/192.168.10.2/DATA_CD_01_atl02cel02 ATL02CEL02 REGULAR 512
DATA_CD_01_ATL02CEL03 MEMBER o/192.168.10.3/DATA_CD_01_atl02cel03 ATL02CEL03 REGULAR 512
DATA_CD_01_ATL02CEL04 MEMBER o/192.168.10.4/DATA_CD_01_atl02cel04 ATL02CEL04 REGULAR 512
DATA_CD_01_ATL02CEL05 MEMBER o/192.168.10.5/DATA_CD_01_atl02cel05 ATL02CEL05 REGULAR 512

15 rows selected.


col name for a10
col compatibility for a10
col database_compatibility for a22
SQL> select name, allocation_unit_size, block_size, compatibility, database_compatibility from v$asm_diskgroup;

NAME ALLOCATION_UNIT_SIZE BLOCK_SIZE COMPATIBIL DATABASE_COMPATIBILITY
---------- -------------------- ---------- ---------- ----------------------
SYSTEMDG 4194304 4096 11.2.0.0.0 11.2.0.0.0
DATA 4194304 4096 11.2.0.0.0 11.2.0.0.0
RECO 4194304 4096 11.2.0.0.0 11.2.0.0.0


. oraenv
+ASM1

sqlplus / as sysasm

-- Createing SYSTEMDG diskgroup:
CREATE DISKGROUP SYSTEMDG NORMAL REDUNDANCY
DISK 'o/*/SYSTEMDG*'
ATTRIBUTE 'AU_SIZE' = '4M',
'cell.smart_scan_capable'='TRUE',
'compatible.rdbms'='11.2.0.0',
'compatible.asm'='11.2.0.0';

-- Createing DATA diskgroup
CREATE DISKGROUP DATA NORMAL REDUNDANCY
DISK 'o/*/DATA*'
ATTRIBUTE 'AU_SIZE' = '4M',
'cell.smart_scan_capable'='TRUE',
'compatible.rdbms'='11.2.0.0',
'compatible.asm'='11.2.0.0';

-- Createing RECO diskgroup
CREATE DISKGROUP RECO NORMAL REDUNDANCY
DISK 'o/*/RECO*'
ATTRIBUTE 'AU_SIZE' = '4M',
'cell.smart_scan_capable'='TRUE',
'compatible.rdbms'='11.2.0.0',
'compatible.asm'='11.2.0.0';


------------------------------------------------------------------------------------------------------------------------------------

CellCLI> list physicaldisk detail
 
name:                   [5:3:2:0]
diskType:               FlashDisk
id:                     00000200000000000000
luns:                   1_2
makeModel:              "MARVELL SD88SA02"
physicalFirmware:       D20R
physicalInsertTime:     2010-10-04T21:05:46+00:00
physicalInterface:      sas
physicalSerial:         0000000000000000000
physicalSize:           22.8880615234375G
slotNumber:             "PCI Slot: 1; FDOM: 2"
status:                 normal
<pre>

CellCLI> list cell detail
 
name:                   mycellnet0
bmcType:                IPMI
cellVersion:            OSS_11.2.0.1.0_LINUX.X64_100818.1
cpuCount:               16
fanCount:               12/12
fanStatus:              normal
id:                     0000X00000
interconnectCount:      3
interconnect1:          bond0
iormBoost:              0.0
ipaddress1:
kernelVersion:          2.6.18-194.3.1.0.2.el5
makeModel:              SUN MICROSYSTEMS SUN FIRE X4275 SERVER SAS
metricHistoryDays:      7
notificationMethod:     snmp
notificationPolicy:     critical,warning,clear
offloadEfficiency:      47,485.1
powerCount:             2/2
powerStatus:            normal
smtpFrom:
smtpFromAddr:
smtpPort:
smtpServer:
smtpToAddr:
smtpUseSSL:
snmpSubscriber:
status:                 online
temperatureReading:     27.0
temperatureStatus:      normal
upTime:                 16 days, 14:01
cellsrvStatus:          running
msStatus:               running
rsStatus:               running
<pre>

CellCLI> list celldisk detail
 
name:                   FD_15_mycellnet0
comment:
creationTime:           2010-07-14T02:05:06+00:00
deviceName:             /dev/sdy
devicePartition:        /dev/sdy
diskType:               FlashDisk
errorCount:             0
freeSpace:              0
id:                     00000000-0000-0000-0000-000000000000
interleaving:           none
lun:                    5_3
size:                   22.875G
status:                 normal
<pre>

CellCLI> list griddisk detail
 
name:                   CD_15_mycellnet0
availableTo:
cellDisk:               CD_15_mycellnet0
comment:
creationTime:           2010-07-14T02:12:55+00:00
diskType:               FlashDisk
errorCount:             0
id:                     00000000-0000-000-0000-000000000000
offset:                 528.734375G
size:                   29.125G
status:                 active
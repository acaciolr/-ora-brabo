/*
Exadata is the Ferrari of the technology world. It’s considered the technology for the select few, but everyone dreams about it. There is very little information available on the Internet right now about the architecture and the administration of Exadata, though it’s a huge subject in itself, which demand numerous high quality books, dedicated blogs, websites and special interest groups.
This blog post just mentions some of very important components of Exadata Storage Server, which are physical disks, cell disks, grid disks and ASM disks and their correspondence.
The Exadata Storage Server contains 12 physical disks.
There is one to one relationship between a physical disk and the cell disk. One physical disk corresponds to a single cell disk.
Then a Grid disk comprises of many cell disks.
And a Grid disk corresponds to one ASM disk.
An ASM diskgroup comprises of many ASM disks.
On the Exadata Storage Server, We can use cellcli command line utility in Exadata to see the information about physical disks, cell disks, grid disks and the cell.
The cellcli utility works from the root, celladmin and cellmonitor (read-only) users. The best practice is actually to run it from the last two less-privileged users, and not from the root user.
*/

--Now let’s have look at some of the disk management commands using cellcli utility.

[root@mycell-net0 ~]# cellcli
CellCLI: Release 11.2.1.3.1 - Production on Fri Oct 29 07:47:26 GMT 2010
Copyright (c) 2007, 2009, Oracle. All rights reserved.
Cell Efficiency Ratio: 140

--Just to give you an idea about what cellcli has on offer, look at the output of the help command:

CellCLI> help
HELP [topic]
Available Topics:
ALTER
ALTER ALERTHISTORY
ALTER CELL
ALTER CELLDISK
ALTER GRIDDISK
ALTER IORMPLAN
ALTER LUN
ALTER THRESHOLD
ASSIGN KEY
CALIBRATE
CREATE
CREATE CELL
CREATE CELLDISK
CREATE FLASHCACHE
CREATE GRIDDISK
CREATE KEY
CREATE THRESHOLD
DESCRIBE
DROP
DROP ALERTHISTORY
DROP CELL
DROP CELLDISK
DROP FLASHCACHE
DROP GRIDDISK
DROP THRESHOLD
EXPORT CELLDISK
IMPORT CELLDISK
LIST
LIST ACTIVEREQUEST
LIST ALERTDEFINITION
LIST ALERTHISTORY
LIST CELL
LIST CELLDISK
LIST FLASHCACHE
LIST FLASHCACHECONTENT
LIST GRIDDISK
LIST IORMPLAN
LIST KEY
LIST LUN
LIST METRICCURRENT
LIST METRICDEFINITION
LIST METRICHISTORY
LIST PHYSICALDISK
LIST THRESHOLD
SET
SPOOL
START

--Let’s see the output of some of the commands listed above:

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

--In the future posts, I will be touching the administration of celldisks, as how to perform operations like (import/export/create/drop/alter) on the celldisks.
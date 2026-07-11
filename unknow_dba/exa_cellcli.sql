Help
CellCLI> help
HELP [topic]
    Available Topics:
        ALTER
        ALTER ALERTHISTORY
        ALTER CELL
        ALTER CELLDISK
        ALTER GRIDDISK
        ALTER IBPORT
        ALTER IORMPLAN
        ALTER LUN
        ALTER PHYSICALDISK
        ALTER QUARANTINE
        ALTER THRESHOLD
        ASSIGN KEY
        CALIBRATE
        CREATE
        CREATE CELL
        CREATE CELLDISK
        CREATE FLASHCACHE
        CREATE GRIDDISK
        CREATE KEY
        CREATE QUARANTINE
        CREATE THRESHOLD
        DESCRIBE
        DROP
        DROP ALERTHISTORY
        DROP CELL
        DROP CELLDISK
        DROP FLASHCACHE
        DROP GRIDDISK
        DROP QUARANTINE
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
        LIST IBPORT
        LIST IORMPLAN
        LIST KEY
        LIST LUN
        LIST METRICCURRENT
        LIST METRICDEFINITION
        LIST METRICHISTORY
        LIST PHYSICALDISK
        LIST QUARANTINE
        LIST THRESHOLD
        SET
        SPOOL
        START
CellCLI> help list ibport
CellCLI> help alter cell

Describe       --- Will display all attributes
CellCLI> describe cell
CellCLI> describe physicaldisk
CellCLI> describe lun
CellCLI> describe celldisk
CellCLI> describe griddisk
CellCLI> describe flashcache
CellCLI> describe flashcachecontent
CellCLI> describe metriccurrent
CellCLI> describe metricdefinition
CellCLI> describe metrichistory 

List
CellCLI> help list
Enter HELP LIST <object_type> for specific help syntax.
    <object_type>:  {ACTIVEREQUEST | ALERTDEFINITION | ALERTHISTORY | CELL | CELLDISK | FLASHCACHE | FLASHCACHECONTENT | GRIDDISK | IBPORT | IORMPLAN | KEY | LUN | METRICCURRENT | METRICDEFINITION | METRICHISTORY | PHYSICALDISK | QUARANTINE | THRESHOLD }

CellCLI> list cell   - Will display Oracle Exadata Storage Servers/Cells information
CellCLI> list cell detail
CellCLI> list cell attributes all
CellCLI> list cell attributes rsStatus

CellCLI> list physicaldisk           - Will display physical disks information
CellCLI> list physicaldisk detail
CellCLI> list physicaldisk 34:5
CellCLI> list physicaldisk 34:11 detail
CellCLI> list physicaldisk attributes all
CellCLI> list physicaldisk attributes name, id, slotnumber
CellCLI> list physicaldisk attributes name, disktype, makemodel, physicalrpm, physicalport, status
CellCLI> list physicaldisk attributes name, disktype, errCmdTimeoutCount, errHardReadCount, errHardWriteCount
CellCLI> list physicaldisk where diskType='Flashdisk'
CellCLI> list physicaldisk attributes name, id, slotnumber where disktype="flashdisk" and status != "not present"
CellCLI> list physicaldisk attributes name, physicalInterface, physicalInsertTime where disktype = 'Harddisk'
CellCLI> list physicaldisk where diskType=flashdisk and status='poor performance' detail

CellCLI> list lun             - Will display LUNs information
CellCLI> list lun detail
CellCLI> list lun 0_8 detail
CellCLI> list lun attributes all
CellCLI> list lun attributes name, cellDisk, raidLevel, status
CellCLI> list lun where disktype=flashdisk

CellCLI> list celldisk        - Will display cell disks information
CellCLI> list celldisk detail
CellCLI> list celldisk FD_01_cell07
CellCLI> list celldisk FD_01_cell13 detail
CellCLI> list celldisk attributes all
CellCLI> list celldisk attributes name, devicePartition
CellCLI> list celldisk attributes name, devicePartition where size>20G
CellCLI> list celldisk attributes name,interleaving where disktype=harddisk

CellCLI> list griddisk      - Will display grid disks information
CellCLI> list griddisk detail
CellCLI> list griddisk DG_01_cell03 detail
CellCLI> list griddisk attributes all
CellCLI> list griddisk attributes name, size
CellCLI> list griddisk attributes name, cellDisk, diskType
CellCLI> list griddisk attributes name, ASMDeactivationOutcome, ASMModeStatus     --- describe command does not show these two attributes
CellCLI> list griddisk attributes name,cellDisk,status where size=476.546875G
CellCLI> list griddisk attributes name where asmdeactivationoutcome != 'Yes'

CellCLI> list flashcache     - Will display flash cache information
CellCLI> list flashcache detail
CellCLI> list flashcache attributes all
CellCLI> list flashcache attributes degradedCelldisks


CellCLI> help list FLASHCACHECONTENT
  Usage: LIST FLASHCACHECONTENT [<filters>] [<attribute_list>] [DETAIL]
  Purpose: Displays specified attributes for flash cache entries.
  Arguments:
   <filters>: An expression which determines the entries to be displayed.
   <attribute_list>: The attributes that are to be displayed. ATTRIBUTES {ALL | attr1 [, attr2]... }
   [DETAIL]: Formats the display as an attribute on each line, with an attribute descriptor preceding each value.

CellCLI> list flashcachecontent        - Will display flash cache content information
CellCLI> list flashcachecontent detail
CellCLI> list flashcachecontent where objectnumber=161441 detail
CellCLI> list flashcachecontent where dbUniqueName like 'EX.?.?' and hitcount > 100 attributes dbUniqueName, objectNumber, cachedKeepSize, cachedSize
CellCLI> list flashcachecontent where dbUniqueName like 'EX.?.?' and objectNumber like '.*007'
CellCLI> list flashcachecontent where dbUniqueName like '.*X.?.?' and objectNumber like '.*456' detail

CellCLI> list metriccurrent    - Will display metrics information
CellCLI> list metriccurrent gd_io_rq_w_sm
CellCLI> list metriccurrent n_nic_rcv_sec detail
CellCLI> list metriccurrent attributes name,metricObjectName,metricType, metricValue,objectType where alertState != 'normal'
CellCLI> list metriccurrent attributes name,metricObjectName,metricType, metricValue,alertState where objectType = 'HOST_INTERCONNECT'
CellCLI> list metriccurrent attributes all where objectType = 'CELL'
CellCLI> list metriccurrent attributes all where objectType = 'GRIDDISK' -
> and metricObjectName = 'DATA_CD_09_cell01' and metricValue > 0

CellCLI> list metricdefinition        - Will display metric's definitions
CellCLI> list metricdefinition cl_cput detail
CellCLI> list metricdefinition attributes all where objecttype='CELL'

CellCLI> list metrichistory           - Will display metric's history
CellCLI> list metrichistory cl_cput
CellCLI> list metrichistory where objectType = 'CELL'
CellCLI> list metrichistory where objectType = 'CELL' and name = 'CL_TEMP'
CellCLI> list metrichistory cl_cput where collectiontime > '*2011-10-15T22:56:04-04:00*'
# cellcli -x -n -e "list metrichistory where objectType='CELL' and name='CL_TEMP'"
--- -x to suppress the banner, and the -n to suppress the command line

CellCLI> list alertdefinition detail    - Will display alert's definitions
CellCLI> list alertdefinition attributes all where alertSource!='Metric'

CellCLI> list alerthistory        - Will display alert's history
CellCLI> list alerthistory detail
CellCLI> list alerthistory where notificationState like '[023]' and severity like '[warning|critical]' and examinedBy = NULL;

CellCLI> list activerequest

CellCLI> list ibport       - Will display InfiniBand configuration details
CellCLI> list ibport detail

CellCLI> list iormplan       - Will display IORM plan details

CellCLI> list key

CellCLI> list quarantine

CellCLI> list threshold      - Will display threshold details

Create
CellCLI> CREATE CELL [cellname] [realmname=realmvalue,] [interconnect1=ethvalue,] [interconnect2=ethvalue,][interconnect3=ethvalue,] [interconnect4=ethvalue,]
 ( ([ipaddress1=ipvalue,] [ipaddress2=ipvalue,] [ipaddress3=ipvalue,] [ipaddress4=ipvalue,]) | ([ipblock=ipblkvalue, cellnumber=numvalue]) )  --- To configure the Oracle Exadata cell network and starts services.

CellCLI> create celldisk all harddisk
CellCLI> create celldisk all
CellCLI> create celldisk all harddisk interleaving='normal_redundancy'
    interleaving -- none(default), normal_redundancy or high_redundancy
CellCLI> create celldisk all flashdisk

CellCLI> create griddisk RECO_CD_11_cell01 celldisk=CD_11_cell01
CellCLI> create griddisk RECO_CD_11_cell01 celldisk=CD_11_cell01 size=100M
CellCLI> create griddisk all prefix RECO 
CellCLI> create griddisk all flashdisk prefix FLASH
CellCLI> create griddisk all harddisk prefix HARD
CellCLI> create griddisk all harddisk prefix='data', size='270g'
CellCLI> create griddisk all prefix='data', size='300g'
CellCLI> create griddisk all prefix='redo', size='150g'
CellCLI> create griddisk all harddisk prefix=systemdg

CellCLI> create flashcache celldisk='FD_00_cell01'
CellCLI> create flashcache celldisk='FD_13_cell01,FD_00_cell01,FD_10_cell01,FD_02_cell01,FD_06_cell01, FD_12_cell01,FD_05_cell01,FD_08_cell01,FD_15_cell01,FD_14_cell01,FD_07_cell01,FD_04_cell01,FD_03_cell01,FD_11_cell01,FD_09_cell01,FD_01_cell01'
CellCLI> create flashcache all
CellCLI> create flashcache all size=365.25G

CellCLI> create key

CellCLI> create quarantine

CellCLI> create threshold cd_io_errs_min.prodb comparison=">", critical=10
CellCLI> create threshold CD_IO_ERRS_MIN warning=1, comparison='>=', occurrences=1, observation=1

Alter
CellCLI> alter cell shutdown services rs - To shutdown the Restart Server service
CellCLI> alter cell shutdown services MS - To shutdown the Management Server service
CellCLI> alter cell shutdown services CELLSRV - To shutdown the Cell Services
CellCLI> alter cell shutdown services all -To shutdown the RS, CELLSRV and MS services
CellCLI> alter cell restart services rs
CellCLI> alter cell restart services all

CellCLI> alter cell led on
CellCLI> alter cell led off

CellCLI> alter cell validate mail
CellCLI> alter cell validate configuration
CellCLI> alter cell smtpfromaddr='cell07@orac.com'
CellCLI> alter cell smtpfrom='Exadata Cell 07'
CellCLI> alter cell smtptoaddr='satya@orac.com'
CellCLI> alter cell emailFormat='text'
CellCLI> alter cell emailFormat='html'


CellCLI> alter cell validate snmp type=ASR - Automatic Service Requests (ASRs)
CellCLI> alter cell snmpsubscriber=((host='snmp01.orac.com,type=ASR'))

CellCLI> alter cell restart bmc  - BMC, Baseboard Management Controller, controls the compoments of the cell.
CellCLI> alter cell configure bmc

CellCLI> alter physicaldisk 34:2,34:3 serviceled on
CellCLI> alter physicaldisk 34:6,34:9 serviceled off
CellCLI> alter physicaldisk harddisk serviceled on
CellCLI> alter physicaldisk all serviceled on

CellCLI> alter lun 0_10 reenable
CellCLI> alter lun 0_04 reenable force

CellCLI> alter celldisk FD_01_cell07 comment='Flash Disk'
CellCLI> alter celldisk all harddisk comment='Hard Disk'
CellCLI> alter celldisk all flashdisk comment='Flash Disk'

CellCLI> alter griddisk RECO_CD_10_cell06 comment='Used for Reco'
CellCLI> alter griddisk all inactive
CellCLI> alter griddisk RECO_CD_11_cell12 inactive
CellCLI> alter griddisk RECO_CD_08_cell01 inactive force
CellCLI> alter griddisk RECO_CD_11_cell01 inactive nowait
CellCLI> alter griddisk DATA_CD_00_CELL01,DATA_CD_02_CELL01,...DATA_CD_11_CELL01 inactive
CellCLI> alter griddisk all active
CellCLI> alter griddisk RECO_CD_11_cell01 active
CellCLI> alter griddisk all harddisk comment='Hard Disk'

CellCLI> alter ibport ibp2 reset counters

CellCLI> alter iormplan active

CellCLI> alter quarantine

CellCLI> alter threshold DB_IO_RQ_SM_SEC.PRODB comparison=">", critical=100

CellCLI> alter alerthistory

Drop
CellCLI> drop cell --- To reset the cell to its factory settings, removes the cell related properties of the server; it does not actually remove the physical server.
CellCLI> drop cell force

CellCLI> drop celldisk CD_01_cell05
CellCLI> drop celldisk CD_00_cell09 force
CellCLI> drop celldisk harddisk
CellCLI> drop celldisk flashdisk
CellCLI> drop celldisk all
CellCLI> drop celldisk all flashdisk force

CellCLI> drop griddisk DBFS_DG_CD_02_cel14
CellCLI> drop griddisk RECO_CD_11_cell01 force
CellCLI> drop griddisk prefix=DBFS
CellCLI> drop griddisk flashdisk
CellCLI> drop griddisk harddisk
CellCLI> drop griddisk all
CellCLI> drop griddisk all prefix=temp_dg

CellCLI> drop flashcache

CellCLI> drop quarantine

CellCLI> drop threshold DB_IO_RQ_SM_SEC.PRODB

CellCLI> drop alerthistory

Export
CellCLI> export celldisk

Import
CellCLI> import celldisk

Assign
CellCLI> assign key

Calibrate
CellCLI> calibrate
CellCLI> calibrate force

Set
CellCLI> help set
  Usage: SET <variable> <value>
  Purpose: Sets a variable to alter the CELLCLI environment settings for your current session.
  Arguments: variable and value represent one of the following clauses:
    DATEFORMAT { STANDARD | LOCAL }
    ECHO { ON | OFF }

CellCLI> set dateformat local
CellCLI> set dateformat standard

CellCLI> set echo on
CellCLI> set echo off

Spool
CellCLI> spool myCellCLI.txt
CellCLI> spool myCellCLI.txt append
CellCLI> spool myCellCLI.txt replace
CellCLI> spool off
CellCLI> spool     --- Will give spool file name

Scripts execution
CellCLI> @listdisks.cli
CellCLI> start listdisks.cli

Comments
REM This is a comment
REMARK This is another comment
-- This is yet another comment

Continuation Character
CellCLI> list metriccurrent attributes name,metricObjectName,metricValue, -
objectType where alertState != 'normal'   --- continuation character for queries spanned in multiple lines

Exit/Quit
CellCLI> exit
CellCLI> quit

CellCLI> list cell detail
         name:                   exa01celadm03
         bbuStatus:              normal
         cellVersion:            OSS_12.1.2.1.2_LINUX.X64_150617.1
         cpuCount:               32/32
         diagHistoryDays:        7
         fanCount:               8/8
         fanStatus:              normal
         flashCacheMode:         writeback
         id:                     1516NM70AX
         interconnectCount:      2
         interconnect1:          ib0
         interconnect2:          ib1
         iormBoost:              0.0
         ipaddress1:             192.168.10.9/22
         ipaddress2:             192.168.10.10/22
         kernelVersion:          2.6.39-400.250.4.el6uek.x86_64
         locatorLEDStatus:       off
         makeModel:              Oracle Corporation ORACLE SERVER X5-2L High Capacity
         memoryGB:               95
         metricHistoryDays:      7
         notificationMethod:     snmp
         notificationPolicy:     critical,warning,clear
         offloadGroupEvents:
         offloadEfficiency:      2,784.9
         powerCount:             2/2
         powerStatus:            normal
         releaseImageStatus:     success
         releaseVersion:         12.1.2.1.2.150617.1
         releaseTrackingBug:     20748218
         snmpSubscriber:         host=200.185.164.217,port=162,community=public,type=ASR
                                 host=exa01dbadm01.exa.voegol.com.br,port=1830,community=public
                                 host=exa01dbadm02.exa.voegol.com.br,port=1830,community=public
         status:                 online
         temperatureReading:     25.0
         temperatureStatus:      normal
         upTime:                 64 days, 16:47
         usbStatus:              normal
         cellsrvStatus:          running
         msStatus:               running
         rsStatus:               running

========================================================================================================

[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e "list metriccurrent attributes name,metricvalue where name like \'FC_BY_DIRTY.*\' "
dm01celadm01: FC_BY_DIRTY        0.000 MB
dm01celadm02: FC_BY_DIRTY        0.000 MB
dm01celadm03: FC_BY_DIRTY        250 MB
dm01celadm04: FC_BY_DIRTY        1,268 MB
dm01celadm05: FC_BY_DIRTY        1,303 MB
dm01celadm06: FC_BY_DIRTY        1,378 MB
dm01celadm07: FC_BY_DIRTY        1,417 MB
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e "LIST CELLDISK ATTRIBUTES name, flushstatus, flusherror" | grep FD
dm01celadm01: FD_00_dm01celadm01         complete
dm01celadm01: FD_01_dm01celadm01         complete
dm01celadm01: FD_02_dm01celadm01         complete
dm01celadm01: FD_03_dm01celadm01         complete
dm01celadm02: FD_00_dm01celadm02         complete
dm01celadm02: FD_01_dm01celadm02         complete
dm01celadm02: FD_02_dm01celadm02         complete
dm01celadm02: FD_03_dm01celadm02         complete
dm01celadm03: FD_00_dm01celadm03         complete
dm01celadm03: FD_01_dm01celadm03         complete
dm01celadm03: FD_02_dm01celadm03         complete
dm01celadm03: FD_03_dm01celadm03         complete
dm01celadm04: FD_00_dm01celadm04
dm01celadm04: FD_01_dm01celadm04
dm01celadm04: FD_02_dm01celadm04
dm01celadm04: FD_03_dm01celadm04
dm01celadm05: FD_00_dm01celadm05
dm01celadm05: FD_01_dm01celadm05
dm01celadm05: FD_02_dm01celadm05
dm01celadm05: FD_03_dm01celadm05
dm01celadm06: FD_00_dm01celadm06
dm01celadm06: FD_01_dm01celadm06
dm01celadm06: FD_02_dm01celadm06
dm01celadm06: FD_03_dm01celadm06
dm01celadm07: FD_00_dm01celadm07
dm01celadm07: FD_01_dm01celadm07
dm01celadm07: FD_02_dm01celadm07
dm01celadm07: FD_03_dm01celadm07







[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e list flashcache attributes name,size,status
dm01celadm01: dm01celadm01_FLASHCACHE    5.82122802734375T       normal - flushed
dm01celadm02: dm01celadm02_FLASHCACHE    5.82122802734375T       normal - flushed
dm01celadm03: dm01celadm03_FLASHCACHE    5.82122802734375T       normal - flushed
dm01celadm04: dm01celadm04_FLASHCACHE    5.82122802734375T       normal - flushed
dm01celadm05: dm01celadm05_FLASHCACHE    5.82122802734375T       normal - flushed
dm01celadm06: dm01celadm06_FLASHCACHE    5.82122802734375T       normal - flushed
dm01celadm07: dm01celadm07_FLASHCACHE    5.82122802734375T       normal - flushed
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e list flashlog attributes name,size,status
dm01celadm01: dm01celadm01_FLASHLOG      512M    normal
dm01celadm02: dm01celadm02_FLASHLOG      512M    normal
dm01celadm03: dm01celadm03_FLASHLOG      512M    normal
dm01celadm04: dm01celadm04_FLASHLOG      512M    normal
dm01celadm05: dm01celadm05_FLASHLOG      512M    normal
dm01celadm06: dm01celadm06_FLASHLOG      512M    normal
dm01celadm07: dm01celadm07_FLASHLOG      512M    normal
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e drop flashlog all
dm01celadm01: Flash log dm01celadm01_FLASHLOG successfully dropped
dm01celadm02: Flash log dm01celadm02_FLASHLOG successfully dropped
dm01celadm03: Flash log dm01celadm03_FLASHLOG successfully dropped
dm01celadm04: Flash log dm01celadm04_FLASHLOG successfully dropped
dm01celadm05: Flash log dm01celadm05_FLASHLOG successfully dropped
dm01celadm06: Flash log dm01celadm06_FLASHLOG successfully dropped
dm01celadm07: Flash log dm01celadm07_FLASHLOG successfully dropped
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e drop flashcache all
dm01celadm01: Flash cache dm01celadm01_FLASHCACHE successfully dropped
dm01celadm02: Flash cache dm01celadm02_FLASHCACHE successfully dropped
dm01celadm03: Flash cache dm01celadm03_FLASHCACHE successfully dropped
dm01celadm04: Flash cache dm01celadm04_FLASHCACHE successfully dropped
dm01celadm05: Flash cache dm01celadm05_FLASHCACHE successfully dropped
dm01celadm06: Flash cache dm01celadm06_FLASHCACHE successfully dropped
dm01celadm07: Flash cache dm01celadm07_FLASHCACHE successfully dropped
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e create flashlog all
dm01celadm01: Flash log dm01celadm01_FLASHLOG successfully created
dm01celadm02: Flash log dm01celadm02_FLASHLOG successfully created
dm01celadm03: Flash log dm01celadm03_FLASHLOG successfully created
dm01celadm04: Flash log dm01celadm04_FLASHLOG successfully created
dm01celadm05: Flash log dm01celadm05_FLASHLOG successfully created
dm01celadm06: Flash log dm01celadm06_FLASHLOG successfully created
dm01celadm07: Flash log dm01celadm07_FLASHLOG successfully created
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e create flashcache all
dm01celadm01: Flash cache dm01celadm01_FLASHCACHE successfully created
dm01celadm02: Flash cache dm01celadm02_FLASHCACHE successfully created
dm01celadm03: Flash cache dm01celadm03_FLASHCACHE successfully created
dm01celadm04: Flash cache dm01celadm04_FLASHCACHE successfully created
dm01celadm05: Flash cache dm01celadm05_FLASHCACHE successfully created
dm01celadm06: Flash cache dm01celadm06_FLASHCACHE successfully created
dm01celadm07: Flash cache dm01celadm07_FLASHCACHE successfully created
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e list flashcache attributes name,size,status
dm01celadm01: dm01celadm01_FLASHCACHE    5.82122802734375T       normal
dm01celadm02: dm01celadm02_FLASHCACHE    5.82122802734375T       normal
dm01celadm03: dm01celadm03_FLASHCACHE    5.82122802734375T       normal
dm01celadm04: dm01celadm04_FLASHCACHE    5.82122802734375T       normal
dm01celadm05: dm01celadm05_FLASHCACHE    5.82122802734375T       normal
dm01celadm06: dm01celadm06_FLASHCACHE    5.82122802734375T       normal
dm01celadm07: dm01celadm07_FLASHCACHE    5.82122802734375T       normal
[root@dm01celadm01 ~]# dcli -g mygroup  -l root cellcli -e list flashlog attributes name,size,status
dm01celadm01: dm01celadm01_FLASHLOG      512M    normal
dm01celadm02: dm01celadm02_FLASHLOG      512M    normal
dm01celadm03: dm01celadm03_FLASHLOG      512M    normal
dm01celadm04: dm01celadm04_FLASHLOG      512M    normal
dm01celadm05: dm01celadm05_FLASHLOG      512M    normal
dm01celadm06: dm01celadm06_FLASHLOG      512M    normal
dm01celadm07: dm01celadm07_FLASHLOG      512M    normal
[root@dm01celadm01 ~]#  dcli -g mygroup  -l root cellcli -e list flashcachecontent attributes dbUniqueName,hitCount,missCount,cachedSize,objectNumber
dm01celadm01: DW11DSV    0       10      950272          2
dm01celadm01: DW11DSV    0       0       212992          8
dm01celadm01: DW11DSV    0       1       65536           9
dm01celadm01: DW08DSV    0       0       8192            10
dm01celadm01: OL85UAT    0       0       8192            18

============================================================================================

Colocar equivalencia de ssh nos cellnodes:

1) arquivo com os grupos:
[root@dm03celadm01 ~]# cat mygroup
dm03celadm01
dm03celadm02
dm03celadm03
dm03celadm04

2) equivalencia:
[root@dm03celadm01 ~]# dcli -g  mygroup -k
celladmin@dm03celadm02's password:
celladmin@dm03celadm03's password:
celladmin@dm03celadm04's password:
celladmin@dm03celadm01's password:
dm03celadm01: ssh key added
dm03celadm02: ssh key added
dm03celadm03: ssh key added
dm03celadm04: ssh key added
============================================================================================

Listando como está as celulas:

[root@dm03celadm01 ~]# dcli -g  mygroup cellcli -e list cell
dm03celadm01: dm03celadm01       online
dm03celadm02: dm03celadm02       online
dm03celadm03: dm03celadm03       online
dm03celadm04: dm03celadm04       online


=============================================================================================

Alert do cellnode:

tail -f /var/log/oracle/diag/asm/cell/`hostname -s`/trace/alert.log

Vendo histórico de alertas no cellcli:
--lista o historico
CellCLI>  LIST ALERTHISTORY
         1       2016-05-01T16:05:30-03:00       critical        "RS-7445 [Serv CELLSRV hang detected] [It will be restarted] [] [] [] [] [] [] [] [] [] []"

-- vê quais são as metricas
CellCLI>  LIST ALERTDEFINITION ATTRIBUTES name, metricName, description
         ADRAlert                "Incident Alert"
         HardwareAlert           "Hardware Alert"
         MetricAlert             "Threshold Alert"
         SoftwareAlert           "Software Alert"

-- ve historico com detalhamento que não foi examinada

CellCLI> LIST ALERTHISTORY WHERE severity = 'critical' AND examinedBy = '' DETAIL
         name:                   1
         alertDescription:       "RS-7445 [Serv CELLSRV hang detected] [It will be restarted] [] [] [] [] [] [] [] [] [] []"
         alertMessage:           "RS-7445 [Serv CELLSRV hang detected] [It will be restarted] [] [] [] [] [] [] [] [] [] []"
         alertSequenceID:        1
         alertShortName:         ADR
         alertType:              Stateless
         beginTime:              2016-05-01T16:05:30-03:00
         endTime:
         examinedBy:
         notificationState:      1
         sequenceBeginTime:      2016-05-01T16:05:30-03:00
         severity:               critical
         alertAction:            "Errors in file /opt/oracle/cell/log/diag/asm/cell/dm03celadm01/trace/rstrc_21468_omt.trc  (incident=17).   Diagnostic package is attached. It is also accessible at https://dm03celadm01.lojasrenner.com.br/diagpack/download?name=dm03celadm01_2016_05_01T16_05_30_1.tar.bz2 It will be retained on the storage server for 7 days. If the diagnostic package has expired, then it can be re-created at https://dm03celadm01.lojasrenner.com.br/diagpack"

-- marca como examinado uma metrica

CellCLI> alter alerthistory 1 examinedBy="Erika Nagamine"
Alert 1 successfully altered


=============================================================================================

[root@dm03celadm01 ~]# dcli -g mygroup -l root cellcli -e list griddisk attributes asmdeactivationoutcome, asmmodestatus
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE
dm03celadm01: Yes        ONLINE

[root@dm03celadm01 ~]# dcli -g mygroup -l root cellcli -e list flashcache detail
dm03celadm01: name:                      dm03celadm01_FLASHCACHE
dm03celadm01: cellDisk:                  FD_02_dm03celadm01,FD_03_dm03celadm01,FD_00_dm03celadm01,FD_01_dm03celadm01
dm03celadm01: creationTime:              2016-07-08T20:01:02-03:00
dm03celadm01: degradedCelldisks:
dm03celadm01: effectiveCacheSize:        5.82122802734375T


[root@dm03celadm01 ~]# dcli -g mygroup -l root cellcli -e  list cell attributes flashcachemode
dm03celadm01: WriteBack
dm03celadm02: WriteBack
dm03celadm03: WriteBack
dm03celadm04: writeback


=============================================================================================
-- explicação das Métricas

CellCLI> list metricdefinition attributes name, description where name like '.*_DIRTY'
         CD_BY_FC_DIRTY          "Number of unflushed megabytes cached in FLASHCACHE on a cell disk"
         FC_BYKEEP_DIRTY         "Number of megabytes unflushed for keep objects on FlashCache"
         FC_BY_ALLOCATED_DIRTY   "Number of megabytes allocated for unflushed data in flash cache"
         FC_BY_DIRTY             "Number of unflushed megabytes in FlashCache"
         FC_BY_STALE_DIRTY       "Number of unflushed megabytes in FlashCache which cannot be flushed because cached disks are not accessible"
         GD_BY_FC_DIRTY          "Number of unflushed megabytes cached in FLASHCACHE for a grid disk"


=============================================================================================
LIST ALERTHISTORY WHERE severity = 'critical' AND examinedBy = '' DETAIL

=============================================================================================

CellCLI> list cell attributes flashcachemode
         WriteThrough

CellCLI> list cell detail
         name:                   dm03celadm04
         accessLevelPerm:        remoteLoginEnabled
         bbuStatus:              normal
         cellVersion:            OSS_12.1.2.3.1_LINUX.X64_160411
         cpuCount:               32/32
         diagHistoryDays:        7
         fanCount:               8/8
         fanStatus:              normal
         flashCacheMode:         WriteThrough
         id:                     1507NM718R
         interconnectCount:      2
         interconnect1:          ib0
         interconnect2:          ib1
         iormBoost:              0.0
         ipaddress1:             192.168.10.70/22
         ipaddress2:             192.168.10.71/22
         kernelVersion:          2.6.39-400.277.1.el6uek.x86_64
         locatorLEDStatus:       off
         makeModel:              Oracle Corporation ORACLE SERVER X5-2L High Capacity
         memoryGB:               95
         metricHistoryDays:      7
         offloadGroupEvents:
         powerCount:             2/2
         powerStatus:            normal
         releaseImageStatus:     success
         releaseVersion:         12.1.2.3.1.160411
         rpmVersion:             cell-12.1.2.3.1_LINUX.X64_160411-1.x86_64
         releaseTrackingBug:     22743631
         securityCert:           PrivateKey   OK
                                 Certificate: Subject CN=localhost,OU=Oracle Exadata,O=Oracle Corporation,L=Redwood City,ST=California,C=US
                                              Issuer  CN=localhost,OU=Oracle Exadata,O=Oracle Corporation,L=Redwood City,ST=California,C=US
         status:                 online
         temperatureReading:     21.0
         temperatureStatus:      normal
         upTime:                 2 days, 4:06
         usbStatus:              normal
         cellsrvStatus:          running
         msStatus:               running
         rsStatus:               running

CellCLI>  drop flashcache
Flash cache dm03celadm04_FLASHCACHE successfully dropped

CellCLI> drop flashlog all
Flash log dm03celadm04_FLASHLOG successfully dropped

CellCLI> list griddisk attributes name,asmmodestatus,asmdeactivationoutcome
         DATA_CD_00_dm03celadm04         ONLINE  Yes
         DATA_CD_01_dm03celadm04         ONLINE  Yes
         DATA_CD_02_dm03celadm04         ONLINE  Yes
         DATA_CD_03_dm03celadm04         ONLINE  Yes
         DATA_CD_04_dm03celadm04         ONLINE  Yes
         DATA_CD_05_dm03celadm04         ONLINE  Yes
         DATA_CD_06_dm03celadm04         ONLINE  Yes
         DATA_CD_07_dm03celadm04         ONLINE  Yes
         DATA_CD_08_dm03celadm04         ONLINE  Yes
         DATA_CD_09_dm03celadm04         ONLINE  Yes
         DATA_CD_10_dm03celadm04         ONLINE  Yes
         DATA_CD_11_dm03celadm04         ONLINE  Yes
         DBFS_CD_02_dm03celadm04         ONLINE  Yes
         DBFS_CD_03_dm03celadm04         ONLINE  Yes
         DBFS_CD_04_dm03celadm04         ONLINE  Yes
         DBFS_CD_05_dm03celadm04         ONLINE  Yes
         DBFS_CD_06_dm03celadm04         ONLINE  Yes
         DBFS_CD_07_dm03celadm04         ONLINE  Yes
         DBFS_CD_08_dm03celadm04         ONLINE  Yes
         DBFS_CD_09_dm03celadm04         ONLINE  Yes
         DBFS_CD_10_dm03celadm04         ONLINE  Yes
         DBFS_CD_11_dm03celadm04         ONLINE  Yes
         FRA_CD_00_dm03celadm04          ONLINE  Yes
         FRA_CD_01_dm03celadm04          ONLINE  Yes
         FRA_CD_02_dm03celadm04          ONLINE  Yes
         FRA_CD_03_dm03celadm04          ONLINE  Yes
         FRA_CD_04_dm03celadm04          ONLINE  Yes
         FRA_CD_05_dm03celadm04          ONLINE  Yes
         FRA_CD_06_dm03celadm04          ONLINE  Yes
         FRA_CD_07_dm03celadm04          ONLINE  Yes
         FRA_CD_08_dm03celadm04          ONLINE  Yes
         FRA_CD_09_dm03celadm04          ONLINE  Yes
         FRA_CD_10_dm03celadm04          ONLINE  Yes
         FRA_CD_11_dm03celadm04          ONLINE  Yes

CellCLI>  alter griddisk all inactive
GridDisk DATA_CD_00_dm03celadm04 successfully altered
GridDisk DATA_CD_01_dm03celadm04 successfully altered
GridDisk DATA_CD_02_dm03celadm04 successfully altered
GridDisk DATA_CD_03_dm03celadm04 successfully altered
GridDisk DATA_CD_04_dm03celadm04 successfully altered
GridDisk DATA_CD_05_dm03celadm04 successfully altered
GridDisk DATA_CD_06_dm03celadm04 successfully altered
GridDisk DATA_CD_07_dm03celadm04 successfully altered
GridDisk DATA_CD_08_dm03celadm04 successfully altered
GridDisk DATA_CD_09_dm03celadm04 successfully altered
GridDisk DATA_CD_10_dm03celadm04 successfully altered
GridDisk DATA_CD_11_dm03celadm04 successfully altered
GridDisk DBFS_CD_02_dm03celadm04 successfully altered
GridDisk DBFS_CD_03_dm03celadm04 successfully altered
GridDisk DBFS_CD_04_dm03celadm04 successfully altered
GridDisk DBFS_CD_05_dm03celadm04 successfully altered
GridDisk DBFS_CD_06_dm03celadm04 successfully altered
GridDisk DBFS_CD_07_dm03celadm04 successfully altered
GridDisk DBFS_CD_08_dm03celadm04 successfully altered
GridDisk DBFS_CD_09_dm03celadm04 successfully altered
GridDisk DBFS_CD_10_dm03celadm04 successfully altered
GridDisk DBFS_CD_11_dm03celadm04 successfully altered
GridDisk FRA_CD_00_dm03celadm04 successfully altered
GridDisk FRA_CD_01_dm03celadm04 successfully altered
GridDisk FRA_CD_02_dm03celadm04 successfully altered
GridDisk FRA_CD_03_dm03celadm04 successfully altered
GridDisk FRA_CD_04_dm03celadm04 successfully altered
GridDisk FRA_CD_05_dm03celadm04 successfully altered
GridDisk FRA_CD_06_dm03celadm04 successfully altered
GridDisk FRA_CD_07_dm03celadm04 successfully altered
GridDisk FRA_CD_08_dm03celadm04 successfully altered
GridDisk FRA_CD_09_dm03celadm04 successfully altered
GridDisk FRA_CD_10_dm03celadm04 successfully altered
GridDisk FRA_CD_11_dm03celadm04 successfully altered

CellCLI> alter cell shutdown services cellsrv

Stopping CELLSRV services...
The SHUTDOWN of CELLSRV services was successful.


CellCLI> alter cell flashCacheMode=writeback
Cell dm03celadm04 successfully altered

CellCLI>  alter cell startup services cellsrv

Starting CELLSRV services...
The STARTUP of CELLSRV services was successful.

CellCLI> alter griddisk all active
GridDisk DATA_CD_00_dm03celadm04 successfully altered
GridDisk DATA_CD_01_dm03celadm04 successfully altered
GridDisk DATA_CD_02_dm03celadm04 successfully altered
GridDisk DATA_CD_03_dm03celadm04 successfully altered
GridDisk DATA_CD_04_dm03celadm04 successfully altered
GridDisk DATA_CD_05_dm03celadm04 successfully altered
GridDisk DATA_CD_06_dm03celadm04 successfully altered
GridDisk DATA_CD_07_dm03celadm04 successfully altered
GridDisk DATA_CD_08_dm03celadm04 successfully altered
GridDisk DATA_CD_09_dm03celadm04 successfully altered
GridDisk DATA_CD_10_dm03celadm04 successfully altered
GridDisk DATA_CD_11_dm03celadm04 successfully altered
GridDisk DBFS_CD_02_dm03celadm04 successfully altered
GridDisk DBFS_CD_03_dm03celadm04 successfully altered
GridDisk DBFS_CD_04_dm03celadm04 successfully altered
GridDisk DBFS_CD_05_dm03celadm04 successfully altered
GridDisk DBFS_CD_06_dm03celadm04 successfully altered
GridDisk DBFS_CD_07_dm03celadm04 successfully altered
GridDisk DBFS_CD_08_dm03celadm04 successfully altered
GridDisk DBFS_CD_09_dm03celadm04 successfully altered
GridDisk DBFS_CD_10_dm03celadm04 successfully altered
GridDisk DBFS_CD_11_dm03celadm04 successfully altered
GridDisk FRA_CD_00_dm03celadm04 successfully altered
GridDisk FRA_CD_01_dm03celadm04 successfully altered
GridDisk FRA_CD_02_dm03celadm04 successfully altered
GridDisk FRA_CD_03_dm03celadm04 successfully altered
GridDisk FRA_CD_04_dm03celadm04 successfully altered
GridDisk FRA_CD_05_dm03celadm04 successfully altered
GridDisk FRA_CD_06_dm03celadm04 successfully altered
GridDisk FRA_CD_07_dm03celadm04 successfully altered
GridDisk FRA_CD_08_dm03celadm04 successfully altered
GridDisk FRA_CD_09_dm03celadm04 successfully altered
GridDisk FRA_CD_10_dm03celadm04 successfully altered
GridDisk FRA_CD_11_dm03celadm04 successfully altered

CellCLI> list griddisk attributes name, asmmodestatus
         DATA_CD_00_dm03celadm04         SYNCING
         DATA_CD_01_dm03celadm04         SYNCING
         DATA_CD_02_dm03celadm04         SYNCING
         DATA_CD_03_dm03celadm04         SYNCING
         DATA_CD_04_dm03celadm04         SYNCING
         DATA_CD_05_dm03celadm04         SYNCING
         DATA_CD_06_dm03celadm04         SYNCING
         DATA_CD_07_dm03celadm04         SYNCING
         DATA_CD_08_dm03celadm04         SYNCING
         DATA_CD_09_dm03celadm04         SYNCING
         DATA_CD_10_dm03celadm04         SYNCING
         DATA_CD_11_dm03celadm04         SYNCING
         DBFS_CD_02_dm03celadm04         ONLINE
         DBFS_CD_03_dm03celadm04         ONLINE
         DBFS_CD_04_dm03celadm04         ONLINE
         DBFS_CD_05_dm03celadm04         ONLINE
         DBFS_CD_06_dm03celadm04         ONLINE
         DBFS_CD_07_dm03celadm04         ONLINE
         DBFS_CD_08_dm03celadm04         ONLINE
         DBFS_CD_09_dm03celadm04         ONLINE
         DBFS_CD_10_dm03celadm04         ONLINE
         DBFS_CD_11_dm03celadm04         ONLINE
         FRA_CD_00_dm03celadm04          SYNCING
         FRA_CD_01_dm03celadm04          SYNCING
         FRA_CD_02_dm03celadm04          SYNCING
         FRA_CD_03_dm03celadm04          SYNCING
         FRA_CD_04_dm03celadm04          SYNCING
         FRA_CD_05_dm03celadm04          SYNCING
         FRA_CD_06_dm03celadm04          SYNCING
         FRA_CD_07_dm03celadm04          SYNCING
         FRA_CD_08_dm03celadm04          SYNCING
         FRA_CD_09_dm03celadm04          SYNCING
         FRA_CD_10_dm03celadm04          SYNCING
         FRA_CD_11_dm03celadm04          SYNCING

CellCLI> create flashcache all
Flash cache dm03celadm04_FLASHCACHE successfully created

CellCLI> create flashlog all
Flash log dm03celadm04_FLASHLOG successfully created

CellCLI> list griddisk attributes name,asmmodestatus,asmdeactivationoutcome
         DATA_CD_00_dm03celadm04         SYNCING         Yes
         DATA_CD_01_dm03celadm04         SYNCING         Yes
         DATA_CD_02_dm03celadm04         SYNCING         Yes
         DATA_CD_03_dm03celadm04         SYNCING         Yes
         DATA_CD_04_dm03celadm04         SYNCING         Yes
         DATA_CD_05_dm03celadm04         SYNCING         Yes
         DATA_CD_06_dm03celadm04         SYNCING         Yes
         DATA_CD_07_dm03celadm04         SYNCING         Yes
         DATA_CD_08_dm03celadm04         SYNCING         Yes
         DATA_CD_09_dm03celadm04         SYNCING         Yes
         DATA_CD_10_dm03celadm04         SYNCING         Yes
         DATA_CD_11_dm03celadm04         SYNCING         Yes
         DBFS_CD_02_dm03celadm04         ONLINE          Yes
         DBFS_CD_03_dm03celadm04         ONLINE          Yes
         DBFS_CD_04_dm03celadm04         ONLINE          Yes
         DBFS_CD_05_dm03celadm04         ONLINE          Yes
         DBFS_CD_06_dm03celadm04         ONLINE          Yes
         DBFS_CD_07_dm03celadm04         ONLINE          Yes
         DBFS_CD_08_dm03celadm04         ONLINE          Yes
         DBFS_CD_09_dm03celadm04         ONLINE          Yes
         DBFS_CD_10_dm03celadm04         ONLINE          Yes
         DBFS_CD_11_dm03celadm04         ONLINE          Yes
         FRA_CD_00_dm03celadm04          ONLINE          Yes
         FRA_CD_01_dm03celadm04          ONLINE          Yes
         FRA_CD_02_dm03celadm04          ONLINE          Yes
         FRA_CD_03_dm03celadm04          ONLINE          Yes
         FRA_CD_04_dm03celadm04          ONLINE          Yes
         FRA_CD_05_dm03celadm04          ONLINE          Yes
         FRA_CD_06_dm03celadm04          ONLINE          Yes
         FRA_CD_07_dm03celadm04          ONLINE          Yes
         FRA_CD_08_dm03celadm04          ONLINE          Yes
         FRA_CD_09_dm03celadm04          ONLINE          Yes
         FRA_CD_10_dm03celadm04          ONLINE          Yes
         FRA_CD_11_dm03celadm04          ONLINE          Yes



dcli -g -l celladmin "/home/celladmin/metric_iorm.pl > /var/log/oracle/diag/asm/cell/metric_output"



CellCLI> ALTER CELL smtpServer='mail.lojasrenner.com.br',smtpFromAddr='exadata_dm03@lojasrenner.com.br',smtpFrom='Alerta Exadata DM03',smtpToAddr='infraestrutura_ti@lojcom.br,pdt-dbm@tivit.com.br',notificationPolicy='critical,warning,clear',notificationMethod='mail'
Cell dm03celadm04 successfully altered

CellCLI>  alter cell validate mail
Cell dm03celadm04 successfully altered



[root@dm03celadm04 ~]#  cellcli -e list cell detail
         name:                   dm03celadm04
         accessLevelPerm:        remoteLoginEnabled
         bbuStatus:              normal
         cellVersion:            OSS_12.1.2.3.1_LINUX.X64_160411
         cpuCount:               32/32
         diagHistoryDays:        7
         fanCount:               8/8
         fanStatus:              normal
         flashCacheMode:         writeback
         id:                     1507NM718R
         interconnectCount:      2
         interconnect1:          ib0
         interconnect2:          ib1
         iormBoost:              1.9
         ipaddress1:             192.168.10.70/22
         ipaddress2:             192.168.10.71/22
         kernelVersion:          2.6.39-400.277.1.el6uek.x86_64
         locatorLEDStatus:       off
         makeModel:              Oracle Corporation ORACLE SERVER X5-2L High Capacity
         memoryGB:               95
         metricHistoryDays:      7
         notificationMethod:     mail
         notificationPolicy:     critical,warning,clear
         offloadGroupEvents:
         powerCount:             2/2
         powerStatus:            normal
         releaseImageStatus:     success
         releaseVersion:         12.1.2.3.1.160411
         rpmVersion:             cell-12.1.2.3.1_LINUX.X64_160411-1.x86_64
         releaseTrackingBug:     22743631
         securityCert:           PrivateKey   OK
                                 Certificate: Subject CN=localhost,OU=Oracle Exadata,O=Oracle Corporation,L=Redwood City,ST=California,C=US
                                              Issuer  CN=localhost,OU=Oracle Exadata,O=Oracle Corporation,L=Redwood City,ST=California,C=US
         smtpFrom:               "Alerta Exadata DM03"
         smtpFromAddr:           exadata_dm03@lojasrenner.com.br
         smtpServer:             mail.lojasrenner.com.br
         smtpToAddr:             infraestrutura_ti@lojasrenner.com.br,pdt-dbm@tivit.com.br
         status:                 online
         temperatureReading:     21.0
         temperatureStatus:      normal
         upTime:                 27 days, 20:11
         usbStatus:              normal
         cellsrvStatus:          running
         msStatus:               running
         rsStatus:               running

=============================================================================================


dcli -g cell_group -l root "tail -100 /opt/oracle/cell/log/diag/asm/cell/exa01celadm0*/trace/alert.log"

dcli -g ~/cell_group -l root "perl /root/metric_iorm.pl |grep latency"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='FC_BY_DIRTY'"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='DB_IO_WT_SM_RQ'"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='CG_IO_WT_SM_RQ'"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='CT_IO_BY_SEC'"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='DB_IO_BY_SEC'"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='CG_IO_BY_SEC'"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where objectType = 'FLASHCACHE'"

dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='FC_IO_BY_R_MISS_SEC'"

dcli -g ~/cell_group -l root cellcli -e "list flashcache detail|grep effectiveCacheSize"

dcli -g ~/cell_group -l root "perl /root/metric_iorm.pl |grep -i total"

dcli -g ~/cell_group -l root "perl metric_iorm.pl | egrep -w 'Database|Consumer|IOPS'"

while true
do
date
dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='DB_IO_WT_SM_RQ'" | grep DW08
sleep 60
done


dcli -g ~/cell_group -l root cellcli -e "list flashcachecontent where objectNumber = 119094 detail"

================================================================================================

IORM:

ol14 share 10, limit=100,role=primary,flashcache=on,flashlog=on
OL85      - share 10, limit=100,role=primary,flashcache=on,flashlog=on
ol14stg – share 5, limit=60, flashcache=on,flashlog=on
DW12    – share 5, limit=60, flashcache=on,flashlog=on
DW08    – share 5, limit=60, flashcache=on,flashlog=on
DW11    – share 5, limit=60, flashcache=on,flashlog=on
DW85     – share 5, limit=60, flashcache=on,flashlog=on 


DW07   - share 1,limit=10, flashcache=off,flashlog=off
DW06    - share 1,limit=10, flashcache=off,flashlog=off 
ol14hml   - share 1,limit=10, flashcache=off,flashlog=off
Default   - share 1,limit=10, flashcache=off,flashlog=off



alter iormplan dbplan=(
(name='ol14',share=10, limit=100, flashcache=on,flashlog=on),
(name='ol85',share=10, limit=100, flashcache=on,flashlog=on),
(name='ol14stg',share=5, limit=60, flashcache=on,flashlog=on),
(name='DW85',share=5, limit=60, flashcache=on,flashlog=on),
(name='DW12',share=5, limit=60, flashcache=off,flashlog=off),
(name='DW08',share=5, limit=60, flashcache=off,flashlog=off),
(name='DW11',share=5, limit=60, flashcache=off,flashlog=off),
(name='DW07',share=1, limit=10, flashcache=off,flashlog=off),
(name='DW06',share=1, limit=10, flashcache=off,flashlog=off),
(name='ol14hml',share=1, limit=10, flashcache=off,flashlog=off),
(name=default, share=1,limit=10,flashcache=off,flashlog=off));




alter iormplan dbplan=((name='ol14',share=10, limit=100, flashcache=on,flashlog=on),(name='ol85',share=10, limit=100, flashcache=on,flashlog=on),(name='ol14stg',share=5, limit=60, flashcache=on,flashlog=on),(name='DW85',share=5, limit=100, flashcache=on,flashlog=on),(name='DW12',share=5, limit=100, flashcache=on,flashlog=on),(name='DW08',share=5, limit=100, flashcache=on,flashlog=on),(name='DW11',share=5, limit=60, flashcache=off,flashlog=off),(name='DW07',share=1, limit=10, flashcache=off,flashlog=off),(name='DW06',share=1, limit=10, flashcache=off,flashlog=off),(name='ol14hml',share=1, limit=10, flashcache=off,flashlog=off),(name=default, share=1,limit=10,flashcache=off,flashlog=off));

alter iormplan dbplan=((name='ol14',share=10, limit=100, flashcache=on,flashlog=on),(name='ol85',share=10, limit=100, flashcache=on,flashlog=on),(name='ol14stg',share=5, limit=60, flashcache=on,flashlog=on),(name='DW85',share=5, limit=60, flashcache=on,flashlog=on),(name='DW12',share=5, limit=60, flashcache=off,flashlog=off),(name='DW08',share=10, limit=60, flashcache=off,flashlog=off),(name='DW11',share=5, limit=60, flashcache=off,flashlog=off),(name='DW07',share=1, limit=10, flashcache=off,flashlog=off),(name='DW06',share=1, limit=10, flashcache=off,flashlog=off),(name='ol14hml',share=1, limit=10, flashcache=off,flashlog=off),(name=default, share=1,limit=10,flashcache=off,flashlog=off));

alter iormplan dbplan=((name='ol14',share=10, limit=100, flashcache=on,flashlog=on),(name='ol85',share=10, limit=100, flashcache=on,flashlog=on),(name='ol14stg',share=5, limit=60, flashcache=on,flashlog=on),(name='DW85',share=5, limit=60, flashcache=on,flashlog=on),(name='DW12',share=5, limit=60, flashcache=on,flashlog=on),(name='DW08',share=5, limit=60, flashcache=on,flashlog=on),(name='DW11',share=1, limit=60, flashcache=on,flashlog=on),(name=default, share=1,limit=10,flashcache=off,flashlog=off));


CellCLI>  list iormplan detail
         name:                   dm03celadm01_IORMPLAN
         catPlan:
         dbPlan:                 name=OL14,level=1,allocation=40,flashcache=on,flashlog=on
                                 name=OL14STG,level=1,allocation=10,flashcache=on,flashlog=on
                                 name=OL85,level=1,allocation=50,flashcache=on,flashlog=on
                                 name=DW12,level=2,allocation=20,flashcache=on,flashlog=on
                                 name=DW08,level=2,allocation=20,flashcache=on,flashlog=on
                                 name=DW11,level=2,allocation=20,flashcache=on,flashlog=on
                                 name=DW85,level=2,allocation=40,flashcache=on,flashlog=on
                                 name=DW06,level=3,allocation=50,flashcache=off,flashlog=off
                                 name=DW07,level=3,allocation=50,flashcache=off,flashlog=off
                                 name=OL14HML,level=4,allocation=100,flashcache=off,flashlog=off
                                 name=DBFS,level=5,allocation=100,flashcache=off,flashlog=off
                                 name=other,level=6,allocation=100,flashcache=off,flashlog=off
         objective:              auto
         status:                 active



=======================================================================================================================

[root@dm03celadm01 ~]# dcli -g ~/cell_group -l root cellcli -e "list metriccurrent where name ='DB_IO_WT_SM_RQ'" | grep DW08
dm03celadm01: DB_IO_WT_SM_RQ     DW08                    8.2 ms/request
dm03celadm02: DB_IO_WT_SM_RQ     DW08                    5.3 ms/request
dm03celadm03: DB_IO_WT_SM_RQ     DW08                    5.6 ms/request
dm03celadm04: DB_IO_WT_SM_RQ     DW08                    8.8 ms/request

======

senha ilom:

Oracle(R) Integrated Lights Out Manager

Version 3.2.4.68 r108889

Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.

Hostname: dm03dbadm01-ilom

-> set /SP/users/root password=r1o2o3t4@2016
Changing password for user /SP/users/root...
Enter new password again: *************
New password was successfully set for user /SP/users/root





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--IORM

--1) IORM objectives

list iormplan

list iormplan detail

alter iormplan objective=basic

list iormplan detail

alter iormplan objective=auto

list iormplan detail

alter iormplan objective=low_latency

list iormplan detail

alter iormplan objective=high_throughput

list iormplan detail


--2) IORM Interdatabase plans

list iormplan detail

alter iormplan dbplan=((name=orclexa, level=1, allocation=80), (name=other, level=2, allocation=100))

list iormplan detail

alter iormplan dbplan=((name=orclexa, level=1, allocation=80), (name=other, level=1, allocation=100))

list iormplan detail

alter iormplan dbplan=''

list iormplan detail


--3) IORM Interdatabase plans to limit I/O

alter iormplan dbplan=((name=orclexa, level=1, allocation=80, limit=90), (name=other, level=2, allocation=100))

list iormplan detail

alter iormplan dbplan=''

--4) IORM Interdatabase plans using shares

alter iormplan dbplan=((name=orclexa, share=60), (name=other, share=40))

alter iormplan dbplan=((name=orclexa, share=6), (name=other, share=4))

alter iormplan dbplan=((name=orclexa, share=6), (name=default, share=4))

list iormplan detail


--5) IORM Interdatabase Smart Flash usage


alter iormplan dbplan=((name=orclexa, share=6, flashlog=on, flashcache=on), (name=default, share=1, flashlog=off, flashcache=off))

list iormplan detail


**12.1.2.0: alter iormplan dbplan=((name=orclexa, share=6, flashlog=on, flashcachemin=500M, flashcachelimit=2G), (name=default, share=1, flashlog=off, flashcachemin=500M, flashcachelimit=1G))


--6) IORM metrics

list metriccurrent where objecttype='IORM_DATABASE';

list metrichistory  where objecttype='IORM_DATABASE';


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Storage Server administration*/

--1) Power-off sequence

dbs: crsctl stop cluster
dbs: shutdown -h now
cells: shutdown -h now
rack: power off button on PDUs


--2) Power-on sequence

rack: power on button in PDUs
cells: power on button in storage servers
dbs: power on button in compute nodes
dbs: crsctl start cluster


--3) Power-off a single storage server

*alter griddisk all inactive
alter cell shutdown services all


--4) Power-on a single storage server

*alter griddisk all active
list griddisk attributes name, asmDiskgroupName, asmFailGroupName, diskType, status
alter cell validate configuration

--5) Passwordless SSH setup

### From exacell01:
scp /opt/oracle/cell11.2.3.2.1_LINUX.X64_130109/cellsrv/bin/dcli root@exadb01:/usr/local/bin/

### From exadb01
echo "exacell01
exacell02" > ~/cell_group

ssh-keygen -t rsa

### output
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
35:2c:81:6f:a1:e5:9d:72:6f:fd:ed:d6:9c:33:90:f1 root@exadb01.localdomain
###

dcli -g cell_group -l root -k -s '-o StrictHostKeyChecking=no'

dcli -g cell_group -l root cellcli -e list cell


--6) List Cell details

list cell

list cell detail


--7) List Physical Disks

dcli -g cell_group -l root cellcli -e list physicaldisk


dcli -g cell_group -l root cellcli -e list physicaldisk where diskType=harddisk


dcli -g cell_group -l root cellcli -e list physicaldisk where diskType=flashdisk


--8) List LUNs

dcli -g cell_group -l root cellcli -e list lun

dcli -g cell_group -l root cellcli -e list lun detail


--9) List Cell Disks

dcli -g cell_group -l root cellcli -e list celldisk

dcli -g cell_group -l root cellcli -e list celldisk attributes name, deviceName, diskType, errorCount, freeSpace, freeSpaceMap, interleaving, size, status

--10) List Smart Flash Cache and Smart Flash Log

dcli -g cell_group -l root cellcli -e list flashcache

dcli -g cell_group -l root cellcli -e list flashcache detail

dcli -g cell_group -l root cellcli -e list flashlog 

dcli -g cell_group -l root cellcli -e list flashlog detail

--10) List Smart Flash Cache contents

dcli -g cell_group -l root cellcli -e list flashcachecontent

col object_name for a30
select object_name, object_type, owner, object_id, data_object_id from dba_objects where data_object_id=13050;


select object_name, object_type, owner, object_id, data_object_id from dba_objects where object_name='SALES';

select * from sh.sales;

select * from sh.sales where cust_id=487821;

col object_name for a30
select object_name, object_type, owner, object_id, data_object_id from dba_objects where object_name='SALES';

dcli -g cell_group -l root cellcli -e list flashcachecontent where objectNumber=84015


--11) List Grid Disks

dcli -c exacell01 -l root cellcli -e list griddisk 

dcli -c exacell01 -l root cellcli -e list griddisk detail

dcli -g cell_group -l root "cellcli -e list griddisk attributes name, asmDiskgroupName, asmFailGroupName, cachingPolicy, size, status, asmModeStatus where name like \'FLAS.*\' "

--12) Alter Grid Disk caching policy

dcli -g cell_group -l root "cellcli -e list griddisk attributes name, asmDiskgroupName, asmFailGroupName, cachingPolicy, size, status, asmModeStatus where name like \'FLAS.*\' "

dcli -c exacell01 -l root cellcli -e alter griddisk FLASH_CELL01_FD_00 cachingPolicy=\"none\"
dcli -c exacell01 -l root cellcli -e alter griddisk FLASH_CELL01_FD_01 cachingPolicy=\"none\"
dcli -c exacell01 -l root cellcli -e alter griddisk FLASH_CELL01_FD_02 cachingPolicy=\"none\"
dcli -c exacell01 -l root cellcli -e alter griddisk FLASH_CELL01_FD_03 cachingPolicy=\"none\"
dcli -c exacell02 -l root cellcli -e alter griddisk FLASH_CELL02_FD_00 cachingPolicy=\"none\"
dcli -c exacell02 -l root cellcli -e alter griddisk FLASH_CELL02_FD_01 cachingPolicy=\"none\"
dcli -c exacell02 -l root cellcli -e alter griddisk FLASH_CELL02_FD_02 cachingPolicy=\"none\"
dcli -c exacell02 -l root cellcli -e alter griddisk FLASH_CELL02_FD_03 cachingPolicy=\"none\"

"

ssh exacell01 
cellcli
cellcli> alter griddisk FLASH_CELL01_FD_00 cachingPolicy="none"

--13) Drop Grid Disk

[grid@exadb01 ~]$ asmcmd
ASMCMD> ls -l +FLASH

SQL> drop diskgroup flash including contents;

dcli -g cell_group -l root "cellcli -e list griddisk attributes name, asmDiskgroupName, asmFailGroupName, cachingPolicy, size, status, asmModeStatus where name like \'FLAS.*\' "

dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL01_FD_00 inactive"
dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL01_FD_01 inactive"
dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL01_FD_02 inactive"
dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL01_FD_03 inactive"
dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL02_FD_00 inactive"
dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL02_FD_01 inactive"
dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL02_FD_02 inactive"
dcli -g cell_group -l root "cellcli -e alter griddisk FLASH_CELL02_FD_03 inactive"


col path for a40
select group_number, mount_status, header_status, mode_status, state, total_mb, free_mb, failgroup, name, path from v$asm_disk where upper(path) like '%FLASH%' order by path;


create diskgroup FLASH normal redundancy
failgroup EXACELL01 disk 
'o/192.168.10.11/FLASH_CELL01_FD_00' name FLASH_CELL01_FD_00,
'o/192.168.10.11/FLASH_CELL01_FD_01' name FLASH_CELL01_FD_01,
'o/192.168.10.11/FLASH_CELL01_FD_02' name FLASH_CELL01_FD_02,
'o/192.168.10.11/FLASH_CELL01_FD_03' name FLASH_CELL01_FD_03
failgroup EXACELL02 disk
'o/192.168.10.12/FLASH_CELL02_FD_00' name FLASH_CELL02_FD_00,
'o/192.168.10.12/FLASH_CELL02_FD_01' name FLASH_CELL02_FD_01,
'o/192.168.10.12/FLASH_CELL02_FD_02' name FLASH_CELL02_FD_02,
'o/192.168.10.12/FLASH_CELL02_FD_03' name FLASH_CELL02_FD_03
ATTRIBUTE 'au_size' = '4M',
'compatible.asm' = '11.2',
'compatible.rdbms' = '11.2',
'cell.smart_scan_capable' = 'true';
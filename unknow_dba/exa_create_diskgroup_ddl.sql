create celldisk CD_DISK61_exacell02 lun='/opt/oracle/cell11.2.3.2.1_LINUX.X64_130109/disks/raw/exacell02_DISK61'
--
list lun celldisk='/opt/oracle/cell11.2.3.2.1_LINUX.X64_130109/disks/raw/exacell01_DISK61' detail
--
create griddisk DATA_CELL02_CD_61 celldisk=CD_DISK61_exacell02, size=500m
--
create diskgroup TESTE normal redundancy failgroup EXACELL01 disk 'o/192.168.10.11/DATA_CELL01_CD_60' name DATA_CELL01_CD_60
                                         failgroup EXACELL02 disk 'o/192.168.10.12/DATA_CELL02_CD_61' name DATA_CELL01_CD_61 
										 ATTRIBUTE 'au_size' = '4M','compatible.asm' = '11.2','compatible.rdbms' = '11.2','cell.smart_scan_capable' = 'true';
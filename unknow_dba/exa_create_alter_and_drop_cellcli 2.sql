--Cellcli - Create
CellCLI> CREATE CELL [cellname] [realmname=realmvalue,] [interconnect1=ethvalue,] [interconnect2=ethvalue,][interconnect3=ethvalue,] [interconnect4=ethvalue,] 
( ([ipaddress1=ipvalue,] [ipaddress2=ipvalue,] [ipaddress3=ipvalue,] [ipaddress4=ipvalue,]) | ([ipblock=ipblkvalue, cellnumber=numvalue]) ) --- To configure the Oracle Exadata cell network and starts services. 

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

--Cellcli - Alter
CellCLI> alter cell shutdown services rs --> To shutdown the Restart Server service 
CellCLI> alter cell shutdown services MS --> To shutdown the Management Server service 
CellCLI> alter cell shutdown services CELLSRV --> To shutdown the Cell Services 
CellCLI> alter cell shutdown services all -->To shutdown the RS, CELLSRV and MS services 
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
CellCLI> alter cell restart bmc - BMC, Baseboard Management Controller, controls the compoments of the cell. 
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

--Cellcli - Drop
CellCLI> drop cell --->> To reset the cell to its factory settings, removes the cell related properties of the server; it does not actually remove the physical server. 

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
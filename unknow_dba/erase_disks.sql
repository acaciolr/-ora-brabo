--erase data using drop celldisk

--syntax:

drop celldisk { all [flashdisk | harddisk] | cdisk_name [,disk_name]... } [erase = value [nowait]] [force] 

--purpose:
--this command is necessary if a cell disk fails, or it is replaced by a newer model. 
--before dropping the cell disk, you should drop its grid disks and the corresponding oracle asm disks from the disk groups. 
--the oracle asm disks should be dropped before dropping the grid disks.

--usage:
--if the all option is specified, then all the cell disks on the cell are removed
--if individual cell disks are specified, then the named cell disks (cdisk_name) are dropped.
--when dropping all cell disks using the 1pass or 3pass option, it necessary to drop the flash disks first using the 7pass option, and then drop the cell disks
--use the nowait option with the erase option to run the command asynchronously
--if the lun associated with the celldisk is flagged as automatically created, then that lun is deleted along with the cell disk.

--example:

cellcli> drop celldisk cd_03_cell01
cellcli> drop celldisk cd_02_cell06 force
cellcli> drop celldisk all
cellcli> drop celldisk cd_02_cell09 erase=1pass nowait
celldisk cd_02_cell09 erase is in progress 

--erase data using drop griddisk

--purpose:

--the drop griddisk command removes the named grid disks from the cell or removes all the grid disks specified by the all prefix option.

--syntax:

drop griddisk {all [flashdisk | harddisk ] prefix=gdisk_name_prefix , | gdisk_name [, gdisk_name]... } [erase = value [nowait]] [force]

--usage:
--if the gdisk_name is entered, then the name identifies the individual grid disk to be removed. multiple names can be entered.
--the flashdisk option limits the drop griddisk command to grid disks that are flash disks.
--the harddisk option limits the drop griddisk command to grid disks that are hard disks.
--the erase option erases the content on the disk by overwriting the content
--use the nowait option with the erase option to run the command asynchronously
--when dropping all grid disks using the 1pass or 3pass option, it necessary to drop the flash disks first using the 7pass option.

--example:

cellcli> alter griddisk data01_cd_03_cell01 inactive
cellcli> drop griddisk data01_cd_03_cell01
cellcli> drop griddisk all prefix=data01
cellcli> drop griddisk data02_cd_04_cell01 force
cellcli> drop griddisk data02_cd_04_cell01 erase=1pass
griddisk data02_cd_04_cell01 successfully dropped
cellcli> drop griddisk all flashdisk prefix=data, erase=7pass
cellcli> drop griddisk all prefix=data, erase=3pass 

--check the status of secure erase:

cellcli> list griddisk
  data_cd_03_cell1 erase in progress
  data_cd_04_cell1 erase in progress
  data_cd_06_cell1 active
  data_cd_05_cell1 active
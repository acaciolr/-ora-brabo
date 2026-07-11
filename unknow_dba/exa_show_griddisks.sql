set linesize 200
set pages 300
column cellname format a15
column name format a30
column asmDiskGroupname format a10
column asmdiskname format a30

select cellname, 
     name,
     asmDiskGroupName,
--     asmDiskName,
     availableTo,
     round(disk_size/power(1024,3), 2) disk_size,
     cellDisk,
     diskType,
     errorCount
    from (
     select cellname, XMLTYPE.createXML(confval) confval
      from v$cell_config
      where 
       conftype='GRIDDISKS'
       --and cellname='192.168.10.10'
     ) v,
     xmltable('/cli-output/griddisk' passing v.confval
      columns
       name varchar(25) path 'name',
       asmDiskGroupName varchar(25) path 'asmDiskGroupName',
       asmDiskName varchar(50) path 'asmDiskName',
       availableTo varchar2(10) path 'availableTo',
       cellDisk varchar2(20) path 'cellDisk',
       diskType varchar2(20) path 'diskType',
       disk_size number path 'size',
       status varchar2(10) path 'status',
       errorCount number path 'errorCount'
)
order by substr(name,instr(name,'fhdbcel'),9);


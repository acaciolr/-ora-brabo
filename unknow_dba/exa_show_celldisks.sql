set linesize 200
set pages 200
column cellname format a20
column name format a15
select cellname,
     name,
     deviceName,
     diskType,
     round(freeSpace/power(1024,3), 2) freeSpace,
     round(disk_size/power(1024,3), 2) disk_size,
     status,
     interleaving,
     errorCount
    from (
     select cellname, XMLTYPE.createXML(confval) confval
      from v$cell_config
      where conftype='CELLDISKS'
       --and cellname='192.168.10.10'
     ) v,
     xmltable('/cli-output/celldisk' passing v.confval
      columns
       name varchar(15) path 'name',
       creationtime varchar(25) path 'creationTime',
       deviceName varchar(9) path 'deviceName',
       devicePartition varchar2(10) path 'devicePartition',
       diskType varchar2(9) path 'diskType',
       errorCount number path 'errorCount',
       freeSpace number path 'freeSpace',
       id varchar2(50) path 'id',
       interleaving varchar(10) path 'interleaving',
       lun varchar2(5) path 'lun',
       raidLevel number path 'raidLevel',
       disk_size number path 'size',
       status varchar2(10) path 'status'
)
order by cellname,name,disktype;


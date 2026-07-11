set linesize 200
set pages 300
column name format a20
column cellname format a20
column disktype format a12


select  
  cellname,
  name,
  luns,
	status,
	disktype,
	round(physicalsize/1024/1024/1024) as physicalSize_GB,
	physicalinterface,
	errMediaCount,
	errOtherCount
from (
     select cellname, XMLTYPE.createXML(confval) confval
      from v$cell_config
      where 
       conftype='PHYSICALDISKS'
       --and cellname='192.168.10.10'
     ) v,
          xmltable('/cli-output/physicaldisk' passing v.confval
      columns
       name varchar(25) path 'name',
       diskType varchar2(20) path 'diskType',
       physicalSize number path 'physicalSize',
       status varchar2(10) path 'status',
       physicalInterface varchar2(5) path 'physicalInterface',
       luns varchar2(5) path 'luns',
       errMediaCount number path 'errMediaCount',
       errOtherCount number path 'errOtherCount'
) order by cellname,luns;

set linesize 200
set pages 300
column name format a15
column cellname format a20
column powerstatus format a11
column status format a11
select  
  name,
  cellversion,
  cpucount,
  ipaddress1,
  kernelversion,
  powerstatus,
  status,
  temperaturestatus,
  uptime
from (
     select cellname, XMLTYPE.createXML(confval) confval
      from v$cell_config
      where 
       conftype='CELL'
       --and cellname='192.168.10.10'
     ) v,
          xmltable('/cli-output/cell' passing v.confval
      columns
         name varchar(25) path 'name',
         cellVersion varchar(35) path 'cellVersion',
  cpuCount number path 'cpuCount',
  diagHistoryDays number path 'DiagHistoryDays',
  ipaddress1 varchar(12) path 'ipaddress1',
  kernelVersion varchar(25) path 'kernelVersion',
  powerStatus varchar(10) path 'powerStatus',
  status varchar(10) path 'status',
  temperatureStatus varchar(10) path 'temperatureStatus',
        uptime varchar2(20) path 'upTime'
) order by name;

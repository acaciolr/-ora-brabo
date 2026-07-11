set linesize 200
set pages 300
column cellname format a15
column name format a20
column celldisk format a20
column devicename format a20
column lunwritecachemode format a70
column disktype format a12


select cellname,  
	name,
        celldisk,
	deviceName,
        isSystemLun,
	lunsize,
	disktype,
	status,	
	lunWriteCacheMode
    from (
     select cellname, XMLTYPE.createXML(confval) confval
      from v$cell_config
      where 
       conftype='LUNS'
       --and cellname='192.168.10.10'
     ) v,
     xmltable('/cli-output/lun' passing v.confval
      columns
       name varchar(25) path 'name',
       cellDisk varchar(25) path 'cellDisk',
       deviceName varchar(50) path 'deviceName',
       isSystemLun varchar2(10) path 'isSystemLun',
       lunsize number path 'lunsize',
       diskType varchar2(20) path 'diskType',
       lunWriteCacheMode varchar2(100) path 'lunWriteCacheMode',
       status varchar2(10) path 'status'
) order by cellname,name,celldisk;

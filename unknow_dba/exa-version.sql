set lines 800 pages 1000
select cellname cv_cellname,
       cast(extract(xmltype(confval),
                    '/cli-output/cell/releaseVersion/text()') as
            varchar2(20)) cv_cellversion,
       cast(extract(xmltype(confval),
                    '/cli-output/cell/flashCacheMode/text()') as
            varchar2(20)) cv_flashcachemode,
       cast(extract(xmltype(confval), '/cli-output/cell/cpuCount/text()') as
            varchar2(10)) cpu_count,
       cast(extract(xmltype(confval), '/cli-output/cell/upTime/text()') as
            varchar2(20)) uptime,
       cast(extract(xmltype(confval),
                    '/cli-output/cell/kernelVersion/text()') as
            varchar2(30)) kernel_version,
       cast(extract(xmltype(confval), '/cli-output/cell/makeModel/text()') as
            varchar2(53)) make_model
  from -- gv$ isn't needed, all cells should be visible in all instances
        v$cell_config
 where conftype = 'CELL'
 order by cv_cellname;

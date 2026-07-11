SET SERVEROUTPUT ON

DECLARE

  CURSOR cpu_cur IS
    SELECT instance_name, round(cpu_used/1000000,2) cpu_used_millions,
           round(cpu_allocated/1000000,2) cpu_allocated_millions,
           round((cpu_used/cpu_allocated)*100,2) cpu_pct_used
    FROM v$exadata_oadata_cpu_allocation;

  CURSOR io_cur IS
    SELECT inst_id, io_type, round((bytes/1024)/1024,2) mb,
           round((elapsed_msec/1000),2) sec, round((bytes/elapsed_msec),2) mb_sec
    FROM gv$exadata_oadata_iostats;

  CURSOR network_cur IS
    SELECT instance_name, port_name, round(rx_mbps/1000,2) rx_gbps,
           round(tx_mbps/1000,2) tx_gbps, round((rx_mbps+tx_mbps)/1000,2) total_gbps
    FROM v$exadata_oadata_network;

  CURSOR flash_cur IS
    SELECT owner, object_name, round(bytes/(1024*1024),2) mb,
           round((flash_cache_hits/flash_cache_accesses)*100,2) cache_hit_pct
    FROM dba_flash_cache_objects
    ORDER BY cache_hit_pct DESC;

  CURSOR cell_cur IS
    SELECT cell_name, round((cell_physical_io_bytes_total/1024)/1024/1024,2) physical_io_gb,
           round((cell_flashcache_readbytes_total/1024)/1024/1024,2) flashcache_read_gb,
           round((cell_flashcache_writebytes_total/1024)/1024/1024,2) flashcache_write_gb,
           round((cell_physical_io_bytes_total/(cell_physical_io_bytes_total + cell_flashcache_readbytes_total))*100,2) physical_io_pct
    FROM v$cell_activity
    WHERE ROWNUM = 1;

  CURSOR storage_cur IS
    SELECT round((SUM(bytes)/1024)/1024/1024,2) total_gb,
           round((SUM(bytes - bytes_not_in_use)/1024)/1024/1024,2) used_gb,
           round(((SUM(bytes - bytes_not_in_use)/SUM(bytes))*100),2) used_pct
    FROM v$asm_disk;

  CURSOR exa_cur IS
    SELECT name, value, description
    FROM v$exadata_sysstat
    WHERE name LIKE 'physical%' OR name LIKE 'cell%';

BEGIN
  
  DBMS_OUTPUT.PUT_LINE('CPU Usage Report');
  DBMS_OUTPUT.PUT_LINE('================');
  DBMS_OUTPUT.PUT_LINE('Instance Name    CPU Used (millions)    CPU Allocated (millions)    CPU Pct Used');
  
  FOR cpu_rec IN cpu_cur LOOP
    DBMS_OUTPUT.PUT_LINE(rpad(cpu_rec.instance_name, 16)||rpad(cpu_rec.cpu_used_millions, 25)
                         ||rpad(cpu_rec.cpu_allocated_millions, 30)||cpu_rec.cpu_pct_used);
  END LOOP;
  
  DBMS_OUTPUT.NEW_LINE;
  
  DBMS_OUTPUT.PUT_LINE('I/O Stats Report');
  DBMS_OUTPUT.PUT_LINE('================');
  DBMS_OUTPUT.PUT_LINE('Inst ID    I/O Type    MB/s    Sec    MB/s (Avg)');
    
  FOR io_rec IN io_cur LOOP
    DBMS_OUTPUT.PUT_LINE(rpad(io_rec.inst_id, 11)||rpad(io_rec.io_type, 14)|| rpad(io_rec.mb, 11)||rpad(io_rec.sec, 8)||io_rec.mb_sec);
  END LOOP;

  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Network Usage Report');
  DBMS_OUTPUT.PUT_LINE('====================');
  DBMS_OUTPUT.PUT_LINE('Instance Name Port Name Rx Gbps Tx Gbps Total Gbps');

  FOR network_rec IN network_cur LOOP
    DBMS_OUTPUT.PUT_LINE(rpad(network_rec.instance_name, 16)||rpad(network_rec.port_name, 13) ||rpad(network_rec.rx_gbps, 11)||rpad(network_rec.tx_gbps, 11) ||network_rec.total_gbps);
  END LOOP;
  
  DBMS_OUTPUT.NEW_LINE;

  DBMS_OUTPUT.PUT_LINE('Flash Cache Report');
  DBMS_OUTPUT.PUT_LINE('==================');
  DBMS_OUTPUT.PUT_LINE('Owner Object Name MB Cache Hit Pct');
    
  FOR flash_rec IN flash_cur LOOP
    DBMS_OUTPUT.PUT_LINE(rpad(flash_rec.owner, 8)||rpad(flash_rec.object_name, 16)||rpad(flash_rec.mb, 9) ||flash_rec.cache_hit_pct);
  END LOOP;
  
  DBMS_OUTPUT.NEW_LINE;
  
  DBMS_OUTPUT.PUT_LINE('Cell Activity Report');
  DBMS_OUTPUT.PUT_LINE('=====================');
  DBMS_OUTPUT.PUT_LINE('Cell Name Physical IO GB Flashcache Read GB Flashcache Write GB Physical IO Pct');
  
  FOR cell_rec IN cell_cur LOOP
    DBMS_OUTPUT.PUT_LINE(rpad(cell_rec.cell_name, 12)||rpad(cell_rec.physical_io_gb, 18) ||rpad(cell_rec.flashcache_read_gb, 23)||rpad(cell_rec.flashcache_write_gb, 24) ||cell_rec.physical_io_pct);
  END LOOP;
  
  DBMS_OUTPUT.NEW_LINE;
  
  DBMS_OUTPUT.PUT_LINE('Storage Usage Report');
  DBMS_OUTPUT.PUT_LINE('====================');
  DBMS_OUTPUT.PUT_LINE('Total GB Used GB Used Pct');
  
  FOR storage_rec IN storage_cur LOOP
    DBMS_OUTPUT.PUT_LINE(rpad(storage_rec.total_gb, 11)||rpad(storage_rec.used_gb, 12) ||storage_rec.used_pct);
  END LOOP;

  DBMS_OUTPUT.NEW_LINE;
  
  DBMS_OUTPUT.PUT_LINE('Exadata Statistics Report');
  DBMS_OUTPUT.PUT_LINE('==========================');
  DBMS_OUTPUT.PUT_LINE('Statistic Name Value Description');
  
  FOR exa_rec IN exa_cur LOOP
  DBMS_OUTPUT.PUT_LINE(rpad(exa_rec.name, 18)||rpad(exa_rec.value, 11)||exa_rec.description);
  END LOOP;

END;
/

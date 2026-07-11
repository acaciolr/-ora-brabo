set colsep "|"

set lines 300
set pages 200

alter session set nls_numeric_characters='.,';

col datim             format a10
col type              format a12
col cell              format a16

with disk_type  as (select distinct disk_id,disk_name,disk from dba_hist_cell_disk_name where snap_id = (select max(snap_id) from dba_hist_cell_disk_name)),
     disk_count as (select disk,count(*) qtd from dba_hist_cell_disk_name where snap_id = (select max(snap_id) from dba_hist_cell_disk_name) group by disk),
     snap       as (select snap_id,dbid,max(end_interval_time) end_interval_time from dba_hist_snapshot where end_interval_time > sysdate-14 group by snap_id,dbid)
select 
substr(datim,1,10) datim,
type,
--cell,
trunc(avg(io_requests),3) io_requests,
trunc(avg(reads),3) reads,
trunc(avg(writes),3) writes,
trunc(avg(small_reads),3) small_reads,
trunc(avg(small_writes),3) small_writes,
trunc(avg(large_reads),3) large_reads,
trunc(avg(large_writes),3) large_writes from (
select
to_char(end_interval_time,'yyyymmddhh24mi') datim,
d.disk type,
--substr(d.disk_name,7) cell,
sum((s.small_reads_sum+s.large_reads_sum+s.small_writes_sum+s.large_writes_sum)*c.qtd)/sum(s.num_samples) io_requests,
sum((s.small_reads_sum+s.large_reads_sum)*c.qtd)/sum(s.num_samples) reads,
sum((s.small_writes_sum+s.large_writes_sum)*c.qtd)/sum(s.num_samples) writes,
sum(small_reads_sum*c.qtd)/sum(s.num_samples) small_reads,
sum(small_writes_sum*c.qtd)/sum(s.num_samples) small_writes,
sum(large_reads_sum*c.qtd)/sum(s.num_samples) large_reads,
sum(large_writes_sum*c.qtd)/sum(s.num_samples) large_writes
from 
snap a, disk_type d, disk_count c, dba_hist_cell_disk_summary s
where
a.snap_id         = s.snap_id and
a.dbid            = s.dbid and
d.disk_id         = s.disk_id and
d.disk            = c.disk
group by to_char(end_interval_time,'yyyymmddhh24mi'),d.disk) --,substr(d.disk_name,7)
group by substr(datim,1,10),type --cell
order by 1,2;

col datim             format a10
col dbname            format a20

with snap       as (select snap_id,dbid,max(end_interval_time) end_interval_time from dba_hist_snapshot where end_interval_time > sysdate-14 group by snap_id,dbid)
select 
datim,dbname,
trunc(sum(io_requests)/3600,3) io_requests,
trunc(sum(disk_requests)/3600,3) disk_requests,
trunc(sum(flash_requests)/3600,3) flash_requests,
trunc(sum(disk_small_requests)/3600,3) disk_small_requests,
trunc(sum(disk_large_requests)/3600,3) disk_large_requests,
trunc(sum(flash_small_requests)/3600,3) flash_small_requests,
trunc(sum(flash_large_requests)/3600,3) flash_large_requests
from (
select
datim,dbname,
io_requests - lag(io_requests) over (partition by dbname,cell_hash order by datim) io_requests,
disk_requests - lag(disk_requests) over (partition by dbname,cell_hash order by datim) disk_requests,
flash_requests - lag(flash_requests) over (partition by dbname,cell_hash order by datim) flash_requests,
disk_small_requests - lag(disk_small_requests) over (partition by dbname,cell_hash order by datim) disk_small_requests,
disk_large_requests - lag(disk_large_requests) over (partition by dbname,cell_hash order by datim) disk_large_requests,
flash_small_requests - lag(flash_small_requests) over (partition by dbname,cell_hash order by datim) flash_small_requests,
flash_large_requests - lag(flash_large_requests) over (partition by dbname,cell_hash order by datim) flash_large_requests
from (
select
to_char(end_interval_time,'yyyymmddhh24') datim,
s.src_dbname dbname,
s.cell_hash,
max(s.disk_small_io_reqs+s.disk_large_io_reqs+s.flash_small_io_reqs+s.flash_large_io_reqs) io_requests,
max(s.disk_small_io_reqs+s.disk_large_io_reqs) disk_requests,
max(s.flash_small_io_reqs+s.flash_large_io_reqs) flash_requests,
max(s.disk_small_io_reqs) disk_small_requests,
max(s.disk_large_io_reqs) disk_large_requests,
max(s.flash_small_io_reqs) flash_small_requests,
max(s.flash_large_io_reqs) flash_large_requests
from 
snap a, dba_hist_cell_db s
where
a.snap_id         = s.snap_id and
a.dbid            = s.dbid
group by to_char(end_interval_time,'yyyymmddhh24'),s.src_dbname,s.cell_hash))
group by datim,dbname
order by 1,2;
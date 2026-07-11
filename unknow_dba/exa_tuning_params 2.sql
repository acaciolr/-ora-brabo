#### PARAMETERS

## COMMON
alter system set log_buffer=134217728 sid=’*’ scope=spfile;
alter system set db_ultra_safe=’DATA_ONLY’ sid=’*’ scope=spfile;
alter system set fast_start_mttr_target=600 sid=’*’ scope=spfile;
alter system set parallel_adaptive_multi_user=FALSE sid=’*’ scope=spfile;
alter system set parallel_threads_per_cpu=1 sid=’*’ scope=spfile;
alter system set open_cursors=1000 sid=’*’ scope=spfile;
alter system set use_large_pages=’ONLY’ sid=’*’ scope=spfile;
alter system set “_enable_NUMA_support”=FALSE sid=’*’ scope=spfile;
alter system set sql92_security=TRUE sid=’*’scope=spfile;
alter system set “_file_size_increase_increment” = 2044M sid=’*’ scope=spfile;
alter system set global_names=TRUE sid=’*’ scope=spfile;
alter system set db_create_online_log_dest_1=’+DATA_MZFL’ sid=’*’ scope=spfile;
alter system set os_authent_prefix=” sid=’*’ scope=spfile;
alter system set shared_servers=0 sid=’*’ scope=both;
alter system set DB_LOST_WRITE_PROTECT = ‘TYPICAL’ sid=’*’;

## OLTP
alter system set parallel_max_servers=240 sid=’*’ scope=spfile;
alter system set parallel_min_servers=0 sid=’*’ scope=spfile;
sga = 60%
pga = 40%
alter tablespace TEMP AUTOEXTEND ON NEXT 1G UNIFORM SIZE 16M;

## DW
alter system set parallel_max_servers=240 sid=’*’ scope=spfile;
alter system set parallel_min_servers=96 sid=’*’ scope=spfile;
alter system set parallel_degree_policy=manual sid=’*’ scope=spfile;
alter system set parallel_degree_limit=16 sid=’*’ scope=spfile;
alter system set parallel_servers_target=128 sid=’*’ scope=spfile;
sga = 50%
pga = 50%

## X01DBFS
alter system set parallel_max_servers=2 sid=’*’ scope=spfile;
alter system set parallel_min_servers=0 sid=’*’ scope=spfile;
alter system set sga_target=1536M sid=’*’ scope=spfile;
alter system set pga_aggregate_target=6656M sid=’*’ scope=spfile;
alter system set db_recovery_file_dest=’+DBFS_DG’ sid=’*’ scope=spfile;
alter system set db_recovery_file_dest_size = 30G sid=’*’ scope=spfile;
alter system set cluster_interconnects = ‘10.199.11.1’ sid=’x01dbfs1′ scope=spfile;
alter system set cluster_interconnects = ‘10.199.11.2’ sid=’x01dbfs2′ scope=spfile;
alter tablespace SYSTEM autoextend on maxsize 5G;
alter tablespace SYSAUX autoextend on maxsize 10G;
alter tablespace TEMP autoextend on maxsize 20G;
alter tablespace UNDOTBS1 autoextend on maxsize 10G;
alter tablespace UNDOTBS2 autoextend on maxsize 10G;
alter tablespace USERS autoextend on maxsize 1G;
alter tablespace DBFS_CDCSP autoextend on maxsize 20G;

=======================================================================

alter system set cluster_interconnects = ‘192.168.32.5’ sid=’SIELP1′ scope=spfile;
alter system set cluster_interconnects = ‘192.168.32.6’ sid=’SIELP2′ scope=spfile;
alter system set cluster_interconnects = ‘192.168.32.7’ sid=’SIELP3′ scope=spfile;
alter system set cluster_interconnects = ‘192.168.32.8’ sid=’SIELP4′ scope=spfile;
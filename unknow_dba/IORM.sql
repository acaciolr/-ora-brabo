--Default IORM status
--Automatically enabled it cannot be completely disabled. The default mode, protects critical operations like  flash cache and flash log  I/Os

CellCLI> list iormplan detail
name: tvdceladm06_IORMPLAN
catPlan:
dbPlan:
objective: basic
status: active

CellCLI>
 
--Per Database IORM definition
--This configuration is suitable on environments with a small number of databases, where the I/O resources are individually defined for each database.

alter iormplan objective=auto

ALTER IORMPLAN -
dbplan=((name=ERP01, level=1, allocation=75, limit=95, role=primary),
(name=ERP01, level=1, allocation=5, limit=25, role=standby),         
(name=TREP, level=1, allocation=2, limit=5, flashCacheSize=1G),      
(name=EPA01, level=2, allocation=40, limit=80),                      
(name=DHJ01, level=3, allocation=50, flashCacheSize=20G),            
(name=other, level=3, allocation=30)) 

--The above plan regulates: the database level, allocation (%), soft and hard limits (%), the amount of flash cache and the role (primary or standby).

--DBaaS and IORM
--This configuration is suitable for Cloud like environments, where a large number of databases are consolidated on the same infrastructure. The database services are standardized in few categories (for example Gold, Silver and Bronze) and the I/O resource plan regulates the same service categories.

CellCLI> ALTER IORMPLAN
dbplan=((name=gold, share=20,limit=100, type=profile), 
        (name=silver, share=10, limit=60, type=profile),
        (name=bronze, share=5, limit=20, type=profile))
		
--The datase parameter db_performance_profile allows to associate the corresponding IORM service category to the instance:
SQL> alter system set db_performance_profile=silver scope=spfile;


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--Monitor Current Resource Plan
select name, cpu_managed, con_id from v$rsrc_plan where is_top_plan = 'TRUE';

--Determine Current Resource Plan Details
select pluggable_database, shares, utilization_limit
  from dba_cdb_rsrc_plan_directives
 where plan = (select name
                 from v$rsrc_plan
                where is_top_plan = 'TRUE'
                  and con_id = 1);
				  
select group_or_subplan,
       mgmt_p1,
       mgmt_p2,
       mgmt_p3,
       mgmt_p4,
       mgmt_p5,
       mgmt_p6,
       mgmt_p7,
       mgmt_p8,
       max_utilization_limit
  from dba_rsrc_plan_directives
 where plan = (select name from v$rsrc_plan where is_top_plan = 'TRUE');
 
select group_or_subplan,
       cpu_p1,
       cpu_p2,
       cpu_p3,
       cpu_p4,
       cpu_p5,
       cpu_p6,
       cpu_p7,
       cpu_p8
  from dba_rsrc_plan_directives
 where plan = (select name from v$rsrc_plan where is_top_plan = 'TRUE');

--Monitor CPU Usage and Waits by Consumer Group
select to_char(m.begin_time, 'HH:MI') time,
       m.consumer_group_name,
       m.cpu_consumed_time / 60000 avg_running_sessions,
       m.cpu_wait_time / 60000 avg_waiting_sessions,
       d.mgmt_p1 * (select value from v$parameter where name = 'cpu_count') / 100 allocation
  from v$rsrcmgrmetric_history m, dba_rsrc_plan_directives d, v$rsrc_plan p
 where m.consumer_group_name = d.group_or_subplan
   and p.name = d.plan
 order by m.begin_time, m.consumer_group_name;

--Sample results:

TIME  NAME               AVG_RUNNING AVG_WAITING ALLOCATION
----- ------------------ ----------- ----------- ----------
13:34 ADHOC_GROUP        1.76        8.4         .8
13:34 BATCH_GROUP        2.88        .4          2.4
13:34 ETL_GROUP          0           0           2.4
13:34 INTERACTIVE_GROUP  10.4        6.8         5.6
13:34 OTHER_GROUPS       .32         .08         .8
13:34 SYS_GROUP          0           0           4

--Monitor CPU Usage and Waits by Pluggable Database
select to_char(begin_time, 'HH24:MI'), name, sum(avg_running_sessions) avg_running_sessions, sum(avg_waiting_sessions) avg_waiting_sessions from v$rsrcmgrmetric_history m, v$pdbs p where m.con_id = p.con_id group by begin_time, m.con_id, name order by begin_time;

--Sample results:

TIME  NAME               AVG_RUNNING AVG_WAITING
----- ------------------ ----------- -----------
13:34 PDB1               13.1        5.4       
13:34 PDB2               2.9         0.1 

--

/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/user_consumer_group.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/setup.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/resource_plans.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/resource_manager_doc.pdf
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/plan_directives.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/consumer_groups.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/consumer_group_usage.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/active_plan.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/rm_audit_config-1.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/rm_audit_plan.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/rm_dump_config.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/rm_dump_plan.sql
/drives/c/Users/acarocha/iCloudDrive/DBA/DBA Scripts/resource_manager/metric_iorm.pl

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--Enabling IORM [The best practice recommendation is to set the objective to "auto"]
alter iormplan objective=auto;

--Scenario 1: Managing Workloads Within a Database

--Configuring Resource Manager
begin

dbms_resource_manager.create_pending_area;

dbms_resource_manager.create_plan(
  plan => 'oltp_plan',
  comment => 'Plan that prioritizes short-running operations');

-- Sessions start in this consumer group.
-- If a query, transaction, or PL/SQL procedure consumes more than a minute
-- of CPU, the session is switched to the batch consumer group for the
-- duration of that operation
dbms_resource_manager.create_plan_directive(
  plan => 'oltp_plan',
  group_or_subplan => 'other_groups',
  comment => 'Sessions start in this consumer group',
  mgmt_p1 => 70,
  switch_time => 60,
  switch_group => 'batch_group',
  switch_for_call => TRUE);

dbms_resource_manager.create_plan_directive(
  plan => 'oltp_plan',
  group_or_subplan => 'batch_group',
  comment => 'Long-running operations run in this low-priority consumer group',
  mgmt_p1 => 15);

dbms_resource_manager.create_plan_directive(
  plan => 'oltp_plan',
  group_or_subplan => 'ora$autotask_sub_plan',
  comment => 'Automated maintenance tasks run here',
  mgmt_p1 => 15);

dbms_resource_manager_privs.grant_switch_consumer_group(
  grantee_name => 'public',
  consumer_group => 'batch_group',
  grant_option => true);

dbms_resource_manager.submit_pending_area;

end;
/

alter system set resource_manager_plan = 'oltp_plan' sid='*';

--Maintenance Windows
begin

dbms_scheduler.set_attribute_null(
  name => 'SUNDAY_WINDOW',
  attribute => 'RESOURCE_PLAN');

dbms_scheduler.set_attribute_null(
  name => 'MONDAY_WINDOW',
  attribute => 'RESOURCE_PLAN');

dbms_scheduler.set_attribute_null(
  name => 'TUESDAY_WINDOW',
  attribute => 'RESOURCE_PLAN');

dbms_scheduler.set_attribute_null(
  name => 'WEDNESDAY_WINDOW',
  attribute => 'RESOURCE_PLAN');

dbms_scheduler.set_attribute_null(
  name => 'THURSDAY_WINDOW',
  attribute => 'RESOURCE_PLAN');

dbms_scheduler.set_attribute_null(
  name => 'FRIDAY_WINDOW',
  attribute => 'RESOURCE_PLAN');

dbms_scheduler.set_attribute_null(
  name => 'SATURDAY_WINDOW',
  attribute => 'RESOURCE_PLAN');

end;
/

--Enabling Exadata I/O Resource Manager
alter iormplan active;
alter iormplan objective=auto;
alter iormplan active;

--Scenario 2: Managing Multiple Databases in a Departmental Consolidation
alter iormplan dbplan = -
  ((name=sales,   share=4), -
   (name=finance, share=4), -
   (name=hr,      share=1), -
   (name=default, share=1));
   
--Scenario 3: Managing Multiple Databases in a Cloud Consolidation 

share - specifies the relative priority of a database.
profile - specifies the attributes for a specific profile.
flashcachemin - specifies the guaranteed space in flash cache for a specific database even when the data in flash cache is cold.
flashcachelimit - specifies the soft limit beyond which the database cannot use space in flash cache when flash cache is full.

alter iormplan dbplan = -
  ((name=gold,   share=8,  flashcachemin=1G,   type=profile), -
   (name=silver, share=4,                      type=profile), -
   (name=bronze, share=1,  flashcachelimit=2G, type=profile), -
   (name=clouddb,share=10, flashcachemin=5G,   type=database))

--Scenario 4: Managing Multiple Databases in a Cloud Consolidation with Strict Performance Guarantees

Share - specifies the relative priority of a database.
limit - specifies the maximum disk utilization for a database. This is ideal for 'pay for performance' use cases and should not be used to achieve fairness between workloads.
flashcachesize - specifies the fixed allocation in flash cache reserved for a database. 

alter iormplan dbplan = -
((name=dbhigh,  share=16, flashcachesize=50G), -
 (name=dbmed,   share=8,  flashcachesize=10G), -
 (name=dblow,   share=4,  flashcachesize=5G, limit=90), -
 (name=default, share=1,  flashcachesize=1G, limit=50))  

--Scenario 5: Managing Databases in Oracle Data Guard
alter iormplan dbplan = -
  ((name=oltpdg, share=4, flashcachemin=5G, role=primary), -
   (name=oltpdg, share=2, limit=80,         role=standby),
   (name=dwh,    share=2)
   
--Monitoring IORM

To monitor IORM, use the metric_iorm.pl script and instructions provided in MOS Note 1337265.1.  This script helps you monitor:

Disk utilization, total and per database, pluggable database and consumer group.
IORM throttling, per database, pluggable database and consumer group.
Flash IOPS and space usage, per database and pluggable database.
Read and write latencies


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--Setting the IORM Objective
CellCLI> ALTER IORMPLAN objective=auto

--Setting Up Consumer Groups and Categories
BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();

  DBMS_RESOURCE_MANAGER.CREATE_CATEGORY(
     CATEGORY => 'dss',
     COMMENT => 'DSS consumer groups');

  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP( 
     CONSUMER_GROUP => 'critical_dss',
     CATEGORY => 'dss',
     COMMENT => 'performance-critical DSS queries');

  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP( 
     CONSUMER_GROUP => 'normal_dss',
     CATEGORY => 'dss',
     COMMENT => 'non performance-critical DSS queries');

  DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP( 
     CONSUMER_GROUP => 'etl',
     CATEGORY => 'maintenance',
     COMMENT => 'data import operations');

  DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Consumer Groups and Categories in an Oracle Database
SQL> SELECT consumer_group, category FROM DBA_RSRC_CONSUMER_GROUPS where 
     consumer_group not like 'ORA%' ORDER BY category;

CONSUMER_GROUP                 CATEGORY
------------------------------ ------------------------------
SYS_GROUP                      ADMINISTRATIVE
ETL_GROUP                      BATCH
BATCH_GROUP                    BATCH
DSS_GROUP                      BATCH
CRITICAL_DSS                   DSS
NORMAL_DSS                     DSS
DSS_CRITICAL_GROUP             INTERACTIVE
INTERACTIVE_GROUP              INTERACTIVE
ETL                            MAINTENANCE
LOW_GROUP                      OTHER
OTHER_GROUPS                   OTHER
AUTO_TASK_CONSUMER_GROUP       OTHER
DEFAULT_CONSUMER_GROUP         OTHER
 
13 rows selected

--Creating Consumer Group Mapping Rules, Based on Service and User Name
BEGIN
DBMS_SERVICE.CREATE_SERVICE('SALES', 'SALES');
DBMS_SERVICE.CREATE_SERVICE('AD_HOC', 'AD_HOC');
 
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.SET_CONSUMER_GROUP_MAPPING
     (DBMS_RESOURCE_MANAGER.ORACLE_USER, 'SYS', 'CRITICAL_DSS');
DBMS_RESOURCE_MANAGER.SET_CONSUMER_GROUP_MAPPING
     (DBMS_RESOURCE_MANAGER.SERVICE_NAME, 'SALES', 'CRITICAL_DSS');
DBMS_RESOURCE_MANAGER.SET_CONSUMER_GROUP_MAPPING
     (DBMS_RESOURCE_MANAGER.SERVICE_NAME, 'AD_HOC', 'NORMAL_DSS');
 
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
 
DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP (
   GRANTEE_NAME   => 'PUBLIC',
   CONSUMER_GROUP => 'CRITICAL_DSS',
   GRANT_OPTION   =>  FALSE);
DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SWITCH_CONSUMER_GROUP (
   GRANTEE_NAME   => 'PUBLIC',
   CONSUMER_GROUP => 'NORMAL_DSS',
   GRANT_OPTION   =>  FALSE);
END;
/

--Creating a CDB Plan [If CDB/PDB]
DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN() and CREATE_CDB_PLAN_DIRECTIVE()

--Using a CDB Plan to Distribute Resources Between PDBs [If CDB/PDB]
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();

DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(
    plan    => 'NEWCDB_PLAN ',
    comment => 'CDB resource plan for newcdb');

  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'NEWCDB_PLAN', 
    pluggable_database    => 'SALESPDB', 
    shares                => 3, 
    memory_min            => 20,
    utilization_limit     => 100);
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => ' NEWCDB_PLAN ', 
    pluggable_database    => 'SERVICESPDB', 
    shares                => 3, 
    memory_min            => 20,
    memory_limit          => 75);
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => ' NEWCDB_PLAN ', 
    pluggable_database    => 'HRPDB', 
    shares                => 1, 
    memory_limit          => 50,
    utilization_limit     => 70);

DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Creating a Database Plan
DBMS_RESOURCE_MANAGER.CREATE_PLAN() and CREATE_PLAN_DIRECTIVE()

--Sharing Resources Across Applications
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.CREATE_PLAN('DAYTIME_PLAN', 'Resource plan for managing all
 applications between 9 am and 5 pm');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('SALES', 'Sales App');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('FINANCE', 'Finance App');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('MARKETING', 'Marketing App');
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'SALES', 'Allocation
for SALES', MGMT_P1 => 60);
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'FINANCE', 'Allocation
for FINANCE', MGMT_P1 => 25);
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'MARKETING',
'Allocation for MARKETING', MGMT_P1 => 10);
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'OTHER_GROUPS',
'Allocation for default group', MGMT_P1 => 5);
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Sharing Resources Across Workloads
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.CREATE_PLAN('DAYTIME_PLAN', 'Resource plan for prioritizing
queries between 9 am and 5 pm');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('REPORT_QUERIES', 'Report Queries');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('AD-HOC_QUERIES', 'Ad-Hoc Queries');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('DATA_LOAD', 'Data Load');
 
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'REPORT_QUERIES',
'Allocation for REPORT_QUERIES', MGMT_P1 => 75);
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'AD-HOC_QUERIES',
'Allocation for AD-HOC_QUERIES', MGMT_P1 => 25);
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'DATA_LOAD',
'Allocation for DATA_LOAD', MGMT_P2 => 100);
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE('DAYTIME_PLAN', 'OTHER_GROUPS',
'Allocation for default group', MGMT_P3 => 100);
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Enabling a Database Resource Plan
--Managing Fast File Creation
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP('MAINTENANCE_GROUP', 'Maintenance
activity');
DBMS_RESOURCE_MANAGER.SET_CONSUMER_GROUP_MAPPING(DBMS_RESOURCE_MANAGER.ORACLE_
FUNCTION, 'FASTFILECRE', 'MAINTENANCE_GROUP');
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Mapping a Program to the ETL_GROUP Consumer Group
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.SET_CONSUMER_GROUP_MAPPING  
  (DBMS_RESOURCE_MANAGER.CLIENT_PROGRAM, 'SQLLDR', 'ETL_GROUP');
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Using Consumer Groups to Manage Resources
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.SET_CONSUMER_GROUP_MAPPING(DBMS_RESOURCE_MANAGER.ORACLE_
FUNCTION, 'BACKUP', 'BATCH_GROUP');
DBMS_RESOURCE_MANAGER.SET_CONSUMER_GROUP_MAPPING(DBMS_RESOURCE_MANAGER.ORACLE_
FUNCTION, 'COPY', 'MAINTENANCE_GROUP');
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Setting the IORM Plan
CellCLI> ALTER IORMPLAN                                                 -
         dbplan=((name=sales01, share=4),                               -
                 (name=sales02, share=3),                               -
                 (name=dev01, share=1),                                 -
                 (name=DEFAULT, share=2))
				 
--Using Share-Based Resource Management
CellCLI> ALTER IORMPLAN                                    -
         dbplan=((name=prod, share=16),                    -
                 (name=dw, share=4),                       -
                 (name=prod_test, share=2),                -
                 (name=DEFAULT, share=1))

--Using Allocation-Based Resource Management
CellCLI> ALTER IORMPLAN                                       -
         dbPlan=((name=prod, level=1,allocation=80),          -
                 (name=dw, level=2, allocation=80),           -
                 (name=prod_test,  level=3, allocation=50),   -
                 (name=prod_dev, level=3, allocation=40),     -
                 (name=OTHER, level=3, allocation=10))

--Using the limit Attribute
ALTER IORMPLAN dbplan=((name=prod),               -
                       (name=test, limit=20),     -
                       (name=DEFAULT, limit=10))

--Using Flash Cache Attributes
ALTER IORMPLAN                                                           -
 dbplan=((name=sales, share=8, flashCacheSize=10G),                      -
         (name=finance, share=8, flashCacheLimit=10G, flashCacheMin=2G), -
         (name=dev, share=2, flashCacheLimit=4G, flashCacheMin=1G),      -
         (name=test, share=1, limit=10, flashCacheSize=1G))

--Configuring an Interdatabase Plan with Flash Cache Attributes
ALTER IORMPLAN                                                  -
 dbplan=((name=sales, share=8, flashCacheMin=3G, flashCacheSize=10G),    -
         (name=finance, share=8, flashCacheLimit=10G, flashCacheMin=2G), -
         (name=dev, share=2, flashCacheLimit=4G, flashCacheMin=1G),      -
         (name=test, share=1, limit=10, flashCacheSize=1G))

--Using PMEM Cache Attributes
--Configuring an Interdatabase Plan with PMEM Cache Attributes
ALTER IORMPLAN dbplan=                                            -
((name=sales, share=8, pmemCacheSize= 2G, flashCacheSize=10G), -
(name=finc, share=8, pmemCacheMin= 1G, pmemCacheLimit= 2G, flashCacheLimit=10G, flashCacheMin=2G), -
(name=dev, share=2, pmemCacheMin= 500M, pmemCacheLimit= 1G, flashCacheLimit=4G, flashCacheMin=1G), -
(name=test, share=1, limit=10, pmemCacheSize= 200M))

--Controlling Access to Flash Cache and Flash Log
CellCLI> ALTER IORMPLAN                                          -
         dbplan=((name=prod, flashcache=on, flashlog=on),        -
                (name=dw, flashcache=on, flashlog=on),           -
                (name=prod_test, flashcache=off, flashlog=off),  -
                (name=prod_dev, flashcache=off, flashlog=off),   -
                (name=dw_test, flashcache=on, flashlog=off))
				
--You can also use these attributes in conjunction with other attributes. For example:
--CellCLI> ALTER IORMPLAN                                                   -
         dbplan=((name=prod, share=8, flashcache=on, flashlog=on),        -
                (name=dw, share=6, flashcache=on, flashlog=on),           -
                (name=prod_test, share=2, flashcache=off, flashlog=off),  -
                (name=prod_dev, share=1, flashcache=off, flashlog=off),   -
                (name=dw_test, share=2, flashcache=on, flashlog=off),     -
                (name=other, share=1))
				
--Controlling Access to PMEM Cache and PMEM Log
CellCLI> ALTER IORMPLAN                                        -
         dbplan=((name=prod, pmemcache=on, pmemlog=on),        -
                (name=dw, pmemcache=on, pmemlog=on),           -
                (name=prod_test, pmemcache=off, pmemlog=off),  -
                (name=prod_dev, pmemcache=off, pmemlog=off),   -
                (name=dw_test, pmemcache=on, pmemlog=off))
				
--You can also use these attributes in conjunction with other attributes. For example:
CellCLI> ALTER IORMPLAN                                                 -
         dbplan=((name=prod, share=8, pmemcache=on, pmemlog=on),        -
                (name=dw, share=6, pmemcache=on, pmemlog=on),           -
                (name=prod_test, share=2, pmemcache=off, pmemlog=off),  -
                (name=prod_dev, share=1, pmemcache=off, pmemlog=off),   -
                (name=dw_test, share=2, pmemcache=on, pmemlog=off),     -
                (name=other, share=1))

--Using the role Attribute
ALTER IORMPLAN                                          -
dbPlan=((name=prod, share=8, role=primary),             -
        (name=prod, share=1, limit=25, role=standby)    -
        (name=default, share=2))

--Using the asmcluster Attribute
ALTER IORMPLAN                                          -
dbplan=((name=pdb1, share=4, flashcachemin=5G, asmcluster=asm1),  -
        (name=pdb1, share=2, limit=80, asmcluster=asm2),  -
        (name=pdb2, share=2, flashcachelimit=2G, asmcluster=asm1),  -
        name=default, share=1, flashcachelimit=1G))

--Resetting Default Values in an IORM Plan
CellCLI> ALTER IORMPLAN catplan="", dbplan="", clusterplan=""
CellCLI> ALTER IORMPLAN catplan=""
CellCLI> ALTER IORMPLAN dbplan=""
CellCLI> ALTER IORMPLAN clusterplan=""

--Listing an I/O Resource Management Plan
CellCLI> LIST IORMPLAN DETAIL
   name:                   cell01_IORMPLAN
   status:                 active
   catPlan:                name=administrative,level=1,allocation=80
                           name=interactive,level=2,allocation=90
                           name=batch,level=3,allocation=80
                           name=maintenance,level=4,allocation=50
                           name=other,level=4,allocation=50
   dbplan:                 name=sales_prod, share=8, role=primary
                           name=sales_prod, share=1, limit=50, role=standby
                           name=sales_test, share=1, limit=25
                           name=default, share=2
   objective:              balanced

--Managing Flash Cache Quotas for Databases and PDBs
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
 
DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(
    plan    => 'NEWCDB_PLAN',
    comment => 'CDB resource plan for newcdb');
 
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'NEWCDB_PLAN', 
    pluggable_database    => 'SALESPDB', 
    memory_min            => 20);
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'NEWCDB_PLAN', 
    pluggable_database    => 'SERVICESPDB', 
    memory_min            => 20,
    memory_limit          => 50);
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'NEWCDB_PLAN', 
    pluggable_database    => 'HRPDB', 
    memory_limit          => 25);
 
DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Case 1: PDB Flash Cache Limits with No Interdatabase Plan

PDB	Flash Cache Min	FC Soft Limit	Normalized Soft Limit	FC Hard Limit
SALESPDB

20% = 10 GB

100 (default)

100 / 175 * 50 GB = 28.57 GB

n/a

SERVICESPDB

20% = 10 GB

50

50 / 175 * 50 GB = 14.28 GB

n/a

HRPDB

0

25

25 / 175 * 50 GB = 7.14 GB

n/a

ALTER IORMPLAN dbplan=                                                                                       -
      ((name=newcdb, share=8, pmemCacheSize= 2G, flashCacheSize=10G),                                        -
       (name=finance, share=8, pmemCacheMin= 1G, pmemCacheLimit= 2G, flashCacheLimit=10G, flashCacheMin=2G), -
       (name=dev, share=2, pmemCacheMin= 100M, pmemCacheLimit= 1G, flashCacheLimit=4G, flashCacheMin=1G),    -
       (name=test, share=1, limit=10))

--Case 2: PDB Flash Cache Limits with an InterDatabase Plan
PDB	Flash Cache Min	FC Hard Limit	Normalized Hard Limit	FC Soft Limit
SALESPDB

0

100 (default)

100 / 175 * 10 GB = 5.71 GB

n/a

SERVICESPDB

0

50

50 / 175 * 10 GB = 2.86 GB

n/a

HRPDB

0

25

25 / 175 * 10 GB = 1.43 GB

n/a

--Managing PMEM Cache Quotas for Databases and PDBs
BEGIN
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
 
DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(
    plan    => 'NEWCDB_PLAN',
    comment => 'CDB resource plan for newcdb');
 
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'NEWCDB_PLAN', 
    pluggable_database    => 'SALESPDB', 
    memory_min            => 20);
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'NEWCDB_PLAN', 
    pluggable_database    => 'SERVICESPDB', 
    memory_min            => 20,
    memory_limit          => 50);
  DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN_DIRECTIVE(
    plan                  => 'NEWCDB_PLAN', 
    pluggable_database    => 'HRPDB', 
    memory_limit          => 25);
 
DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/

--Case 1: PDB PMEM Cache Limits with No Interdatabase Plan
PDB	PMEM Cache Min	PMEM Soft Limit	Normalized Soft Limit	PMEM Hard Limit
SALESPDB

20% = 2 GB

100 (default)

100 / 175 * 10 GB = 5.71 GB

n/a

SERVICESPDB

20% = 2 GB

50

50 / 175 * 10 GB = 2.85 GB

n/a

HRPDB

0

25

25 / 175 * 10 GB = 1.42 GB

n/a

ALTER IORMPLAN dbplan=                                                                                       -
      ((name=newcdb, share=8, pmemCacheSize= 2G, flashCacheSize=10G),                                        -
       (name=finance, share=8, pmemCacheMin= 1G, pmemCacheLimit= 2G, flashCacheLimit=10G, flashCacheMin=2G), -
       (name=dev, share=2, pmemCacheMin= 100M, pmemCacheLimit= 1G, flashCacheLimit=4G, flashCacheMin=1G),    -
       (name=test, share=1, limit=10))	   
	   
--Case 2: PDB PMEM Cache Limits with an InterDatabase Plan

PDB	PMEM Cache Min	PMEM Hard Limit	Normalized Hard Limit	PMEM Soft Limit
SALESPDB

0

100 (default)

100 / 175 * 2 GB = 1.14 GB

n/a

SERVICESPDB

0

50

50 / 175 * 2 GB = 0.57 GB

n/a

HRPDB

0

25

25 / 175 * 2 GB = 0.28 GB

n/a

--Using IORM Profiles
CellCLI> ALTER IORMPLAN DBPLAN=((name=gold, share=10, limit=100, type=profile),  -
(name=silver, share=5, limit=60, type=profile), (name=bronze, share=1, limit=20, -
 type=profile))

SQL> ALTER SYSTEM SET db_performance_profile=gold SCOPE=spfile;
SQL> SHUTDOWN IMMEDIATE
SQL> STARTUP
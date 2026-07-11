/*ORACLE EXADATA 11G ESSENTIALS (1Z0-536)*/

--What model of the Exadata Database Machine come with 3 Infiniband switches?

A.Quarter Rack of X2-2

B.Half Rack of X2-2

C.Full Rack of X2-2

D.Full Rack of X2-8

 
Q.2) Which types of data are most likely to be cached In the Exadata SmartFlash Cache?

A.Results of random reads.

B.Results of table scans.

C.Write to a mirror

D.Redo data

E.All data is cached In the Flash Cache


Q.3) Your customer wants to use Hybrid Columnar Compression to get maximum compression on their data. Which option represents a best practice for achieving this goal?
 
A.Load compressed files with Direct Path loading

B.Sort incoming data on a column with a low cardinality

C.Use DBFS and external flies to load the data

D.Use Data Pump to load data

Q.4) Which statement would you make about sharing I/O resources in an Exadata environment?

A.You can manage workloads within a database with Database Resource Manager.

B.You can manage workloads across multiple databases with Database Resource Manager

C.You can manage workloads within a database with I/O Resource Manager

D.You cannot manage workloads across multiple databases

Q.5) How do you back up the software used on an Exadata storage cell?

A.You use RMAN.

B.You back up the software files using an operating system method

C.You do a complete copy of their system storage area.

D.You do not need to backup this software, as there is an automated recovery mechanism built into each cell.

Q.6) Which statement properly describes potential allocation for a grid disk?

A.A grid disk must use all of a cell disk.

B.A grid disk can only use portions of a cell disk across all cells.

C.A grid disk can use portions of a cell disk on a subset of cells.

D.A grid disk can span multiple Exadata Storage Server cells.

Q.7) Which resource plan is evaluated first by the I/O Resource Manager?

A.Storage plan

B.Category plan

C.Inter-database plan

D.Intra-database plan

Q.8)What does the role attribute of a DB plan indicate?

A.The role specified for the category

B.The role specified for the user
 
C.The role specified In a Data Guard environment

D.The role specified for the application

Q.9) If a hard drive is removed from a storage cell, what must you do?

A.Nothing

B.The cell must be rebooted.

C.You must alter ASM to alert IT

D.You must recreate any grid disks that use the drive

Q.10) Your customer has designated a number of database objects to be kept persistently in the Exadata Smart Flash Cache. What happens if the total size of these objects is greater than 80% of the size of the available Exadata Smart Flash Cache?

A.Nothing

B.Exadata Smart Flash Cache expands the allocation to hold the objects

C.Not all objects will be stored in Exadata Smart Flash Cache

D.Overall performance is increased as more objects fit into Exadata Smart Flash Cache

Q.11) 

Which three attributes are likely to result in data being cached in the Exadata Smart Flash Cache?

A.

CELL_FLASH_CACHE attribute on the data object

 

B.

CACHE hint In the SQL statement

 

C.

Data from a table scan

 

D.

Small data less than 128 KBs

 

E.

Control file I/Os

 

Q.12) 

You are going to set up grid disks for your customer. Which is the best practice to use when defining grid disks for a Storage Server?

 	 
 

A.

Create a grid disk for every table space

 

B.

Create two grid disks, one for data and one for recovery

 

C.

Create two grid disks, one for tables and one for Indexes

 

D.

Create a grid disk for each table

 

Q.13) 

When using IORM, which statement accurately describes when redo log file writes take place?

 	 
 

A.

Based on the priority of the user

 

B.

Immediately

 

C.

Based on the resource group of the user

 

D.

Based on the intradatabase resource plan

 

Q.14) 

Your customer asks you what advantage Offload processing gives to the Exadata Storage Server. How can you explain it best?

 	 
 

A.

Offload processing allows PL/SQL functions to be executed on the Exadata Storage Server

 

B.

Offload processing aggregates SQL processing into higher level functions, which are shipped to the Exadata Storage Server

 

C.

Offload processing moves some processing closer to the stored data, which allows the Exadata Storage Server to return only the rows and columns requested

 

D.

Offload processing is just marketing – it provides no real advantage

 

Q.15) 

How is cell-to-cell communication implemented in a Oracle Exadata Database Machine?

 	 
 

A.

Through flash cache.

 

B.

Through the Infiniband switch

 

C.

Through onboard memory

 

D.

There is never any cell-to-cell communication in an Exadata Storage Server

 

Q.16) 

Your customer has estimated that they will need to store 25 TBs of uncompressed data, and they want to use High Performance disks in their Exadata Storage Server. Which size Oracle Exadata Database Machine should you propose to handle this amount of data without compression?

 	 
 

A.

A Quarter Rack, with 20 TB storage

 

B.

A Half Rack, with 50 TB raw storage

 

C.

A Full Rack, with 100 TB of raw storage

 

D.

You should try to talk your customer into using High Capacity disk

 

Q.17) 

What benefit is provided by column filtering?

 	 
 

A.

The Exadata Storage Server can select rows based on column values listed in a SQL predicate

 

B.

Storage indexes are built on columns for use in filtering

 

C.

Only necessary columns are returned to the database server

 

D.

Column filtering is a marketing term, not a real benefit

 

Q.18) 

Striping data across disk is performed with what software?

 	 
 

A.

CELLSRV

 

B.

IORM

 

C.

OEL

 

D.

ASM

 

Q.19) 

How many IP addresses you need to assign for each Exadata storage cell?

 	 
 

A.

1

 

B.

2

 

C.

3

 

D.

4

 

E.

0

 

Q.20) 

Your customer’s high priority applications are throughput-sensitive. Which feature of the Oracle Exadata Database Machine Is crucial to servicing these high priority applications?

 	 
 

A.

Flash Cache

 

B.

IORM

 

C.

ASM

 

D.

RAC

 

Q.21) 

How much flash memory comes with an Oracle Exadata Database Machine Full Rack?

 	 
 

A.

384TB

 

B.

1TB

 

C.

2.6TB

 

D.

5.3TB

 

Q.22) 

Which Exadata Storage Server users can edit Exadata configuration files?

 	 
 

A.

root

 

B.

celladmin

 

C.

cellmonitor

 

D.

celldi

 

Q.23) 

You have completed initial installation of an Exadata Database Machine. Which type of components can you add after installation?

 	 
 

A.

Hardware in the database servers

 

B.

Software in the database servers

 

C.

Software in the Exadata Storage Server

 

D.

Hardware in the Exadata Storage Server

 

Q.24) 

Which is true of a Storage Index in the Oracle Exadata Database Machine?

 	 
 

A.

Stores minimum and maximum values for a 1 MB region

 

B.

Can be used to eliminate cells from queries

 

C.

Is a standard database index

 

D.

Persists through a cell reboot

 

Q.25) 

Which types of prioritization does I/O Resource Manager do automatically?

 	 
 

A.

Production over Test and OLTP over maintenance

 

B.

OLTP over maintenance and control-file I/Os over database writes

 

C.

Apply operations over read-only queries on standby databases and control-file I/Os over database writes

 

D.

Apply operations over read-only queries on standby databases and OLTP over maintenance

 

Q.26) 

Your customer wants to migrate their current large Oracle database to an Oracle Exadata Database Machine. They are currently running Oracle 10.1.0.3 on Linux. Which method could they use to migrate with the least amount of downtime?

 	 
 

A.

Use transportable table spaces to migrate data to the new environment

 

B.

Use Data Guard logical standby to reproduce data on the new system

 

C.

Use Data Guard physical standby to migrate data to the new system

 

D.

Use ASM to rebalance data from the old system to the new system

 

E.

Use Data Pump to move data to the new system

 

Q.27) 

Which statement about the Database Smart Cache and the Exadata Smart Flash Cache Is true

 	 
 

A.

There is no difference – they are different names for the same thing.

 

B.

The Database Smart Cache can only work on Oracle Exadata Database Machines

 

C.

The Exadata Flash Cache can only work on Oracle Exadata Database Machines

 

D.

You can pin tables into the Database Smart Cache

 

Q.28) 

How many IORMPLANs can be active at the same time?

 	 
 

A.

One per Exadata cell

 

B.

One per Exadata Storage Server

 

C.

One per DBRM resource group

 

D.

One per IORM category

 

Q.29) 

What task must you perform to enable intra-database resource management?

 	 
 

A.

Set the IORM parameter to TRUE

 

B.

Manually set the RESOURCE_MANAGER_PLAN parameter with the ALTER SYSTEM statement

 

C.

Activate IORMPLAN on each of the target Exadata cells

 

D.

Activate IORMPLAN for ASM

 

Q.30) 

You are getting ready to prepare your client to obtain the maximum benefit from using the Sun Oracle Database Server. Which features can reduce the amount of I/O processed and are unique to the Exadata Storage Server?

 	 
 

A.

Partitioning

 

B.

Parallelism

 

C.

Storage Indexes and Predicate Filtering

 

D.

Database Resource Manager

 

Q.31) 

Under which condition(s) does IORM manage Exadata cell resources?

 	 
 

A.

All the time

 

B.

When there are IORM resource plans in place

 

C.

When there are more than one resource group for a cell

 

D.

When I/O requests start to saturate the cell

 

E.

When I/O requests start to saturate the cell and there is more than one resource group defined for the cell

 

Q.32) 

How much flash memory comes with each Exadata Storage cell?

 	 
 

A.

24 GB

 

B.

72 GB

 

C.

256 GB

 

D.

384 GB

 

Q.33) 

What happens if you bring a disk in an Exadata Storage Server back online before the disk_repair_time expires?

 	 
 

A.

You only have to drop and add the disk.

 

B.

You have to drop and add the disk and then rebalance data onto it.

 

C.

Nothing.

 

D.

Fast resynch on the disk happens automatically.

 

Q.34) 

Your customer is worried that as they need to upgrade their Exadata Database Machine from a Quarter Rack to a Half Rack to a Full Rack, the overall performance of the Machine will diminish. How should you address this concern?

 	 
 

A.

Tell the customer that when they need more storage, the underlying hardware will be faster so they will not have to worry.

 

B.

Tell the customer they can always move from SATA storage to SAS storage for better performance.

 

C.

Tell the customer that some performance degradation is inevitable in any architecture.

 

D.

Tell the customer that the balanced hardware configuration of the Exadata Storage Server prevents this from happening.

 

Q.35) 

Which assortment of disks on a cell is created by issuing the CREATE CELLDISK ALL command?

 	 
 

A.

12 Flash-based cell disks, 12 disk-based cell disks

 

B.

16 Flash-based cell disks, 16 disk-based cell disks

 

C.

16 Flash-based cell disks, 12 disk-based cell disks

 

D.

12 Flash-based cell disks, 16 disk-based cell disks

 

E.

No Flash-based cell disks, 12 disk-based cell disks

 

Q.36) 

Which three tasks are performed by the Management Server (part of Exadata Storage Server Software)?

 	 
 

A.

Updates to the Exadata Server software

 

B.

Executing distributed CU commands

 

C.

Executing CELLCLI

 

D.

Interaction with the EM Exadata plug-in

 

Q.37) 

Which three types of classification can you use to prioritize I/O requests with IORM?

 	 
 

A.

Based on Database Manager Resource Groups

 

B.

Based on an Intra-database Plan

 

C.

Based on a Category Plan

 

D.

Based on the priority of the background process

 

Q.38) 

Can you use Active Data Guard effectively between an Oracle Exadata Database Machine and a standard database server?

 	 
 

A.

Yes, but only If you use Hybrid Columnar Compression

 

B.

Yes, but tables or partitions that use Hybrid Columnar Compression will not be immediately accessible

 

C.

Yes, but only if you do not allow Smart Scans with the Oracle Exadata Database Machine.

 

D.

No

 

Q.39) 

Your customer does not think that offload processing will give them any advantage, since they are using only packaged applications. How do you address this issue?

 	 
 

A.

You don’t – this customer is not appropriate for the Oracle Exadata Database Machine. Move on

 

B.

You explain that offload processing works with the same SQL in packaged applications as it does in ad hoc queries

 

C.

You explain that they can use stored plans to for packaged applications to modify the SQL so that it can perform well with the Oracle Exadata Database Machine.

 

D.

You try to get them to understand the benefits provided for data warehousing on the same data.

 

Q.40) 

Your customer’s high priority applications are latency-sensitive. Which features of the Oracle Exadata Database Machine are crucial to servicing these high priority applications?

 	 
 

A.

Flash Cache

 

B.

IORM

 

C.

ASM

 

D.

RAC

 

Q.41) 

Your customer is moving their application to an Exadata environment from a standard Oracle environment. What three changes might you expect to make to optimize performance and resource usage in the new environment?

 	 
 

A.

You will add Indexes to your tables for better performance

 

B.

You should consider implementing a different partitioning strategy.

 

C.

You should consider reducing the number of materialized views.

 

D.

You should make the extents larger, such as 8 MBs.

 

Q.42) 

What percent of Flash Cache can be used to hold pinned database objects?

 	 
 

A.

10

 

B.

20

 

C.

50

 

D.

80

 

E.

90

 

Q.43) 

Your customer wants to use their Oracle Exadata Database Machine to consolidate multiple existing Oracle databases. They see a problem, since some of these databases currently use RAC and others do not. How should you address this potential issue?

 	 
 

A.

Suggest that this is a great time to upgrade all their databases to RAC, since an Oracle Exadata Database Machine has to have either all RAC or no RAC databases.

 

B.

Divide the Oracle Exadata Database Machine up into two equal partitions, using one for RAC and the other for their single instance databases.

 

C.

You can assign databases to database servers in any way, regardless of whether the database is RAC or single instance

 

D.

Migrate all databases to single instance databases since they always provide better performance on a Oracle Exadata Database Machine

 

Q.44) 

What is sent from the Oracle database kernel to the Exadata Storage Server using iDB?

 	 
 

A.

Block requests

 

B.

A command representing the SQL statement

 

C.

The filtering predicates from the current SQL statement

 

D.

Statistics on data usage

 

Q.45) 

When initially setting up an Exadata Storage Server, in what order should you run the following Procedures?

 	 
 

A.

ALTER CELL, CREATE CELLDISK, CREATE GRIDDISK, CALIBRATE

 

B.

ALTER CELL, CREATE GRIDDISK, CREATE CELLDISK, CALIBRATE

 

C.

CREATE GRIDDISK, CREATE CELLDISK, CALIBRATE, ALTER CELL

 

D.

CALIBRATE, CREATE GRIDDISK, CREATE CELLDISK, ALTER CELL

 

E.

CALIBRATE, ALTER CELL, CREATE GRIDDISK, CREATE CELLDISK

 

Q.46) 

What action(s) must you perform to create Flash-based grid disks?

 	 
 

A.

None – they are created by default

 

B.

Issue the CREATE DISK… FLASHDISK command after initial setup of the cell

 

C.

Issue DROP FLASHCACHE and then CREATE GRIDDISK FLASHDISK commands

 

D.

Issue the DROP FLASHCACHE and CREATE FLASHCELLDISK commands

 

Q.47) 

Which Exadata Storage Server users can only view Exadata cell objects?

 	 
 

A.

root

 

B.

celladmin

 

C.

cellmonitor

 

D.

CellCLI

 

Q.48) 

Which three load characteristics will benefit from IORM plans?

 	 
 

A.

Conflicting workloads, both of which are latency sensitive.

 

B.

Conflicting workloads, both of which are throughput sensitive.

 

C.

When I/O is a bottleneck.

 

D.

When CPU is a bottleneck.

 

Q.49) 

What three types of resource plans can be used with I/O Resource Manager?

 	 
 

A.

Ratio

 

B.

Priority

 

C.

Hybrid

 

D.

Disk-based

 

Q.50) 

How much memory comes with each Exadata Storage cell?

 	 
 

A.

24 GB

 

B.

72 GB

 

C.

256 GB

 

D.

512 GB

 

Q.51) 

To ensure proper utilization of Exadata Storage, you want to use some of the tools that come with Oracle Exadata. Which software is used to monitor Oracle Exadata storage?

 	 
 

A.

EM Grid Control

 

B.

EM Database Control

 

C.

IORM

 

D.

Oracle Linux

 

Q.52) 

What is the rule for using different types of compression on different partitions of a single table stored on an Exadata Storage Server?

 	 
 

A.

All partitions must either be compressed or uncompressed

 

B.

All partitions must use either OLTP compression or Hybrid Columnar Compression.

 

C.

Any partition can use any type of compression, regardless of the compression of other partitions.

 

D.

You cannot mix compression types among partitions of the same table.

 

Q.53) 

The Oracle Exadata Database Machine retrieves data from disks in response to a SQL statement in the same way as a standard database server.

 	 
 

A.

True

 

B.

False

 

Q.54) 

A Database Resource manager plan includes which three attributes?

 	 
 

A.

Database names, levels, and allocations

 

B.

Database names, levels, and resource groups

 

C.

Database names, allocations, and resource groups

 

D.

Database names, resource groups, and categories

 

Q.55) 

You want to understand which SQL statements have been executing using Smart Scan capabilities. Where can you look for this information?

 	 
 

A.

You can infer from the performance of the statement.

 

B.

Query statistics from the V$ views

 

C.

The hints used in a SQL statement

 

D.

With the CELLCLI SMART.SQL statement

 

Q.56) 

Your customer wants to use Hybrid Column Compression, but they are concerned because they update recent data frequently. Which is the best strategy for addressing this scenario?

 	 
 

A.

Use HCC in archive mode.

 

B.

Batch write operations to increase the efficiency of HCC.

 

C.

Avoid HCC at all costs.

 

D.

Partition table and use HCC on older, less updated partitions.

 

Q.57) 

Which three statements are true with regard to I/O Resource plans?

 	 
 

A.

You define inter-database resource plans with Database Resource Manager.

 

B.

You define Intra-database resource plans with Database Resource Manager.

 

C.

You define categories with Database Resource Manager.

 

D.

You enable a category plan with CellCLI.

 

Q.58) 

You want to use Intelligent Data Placement effectively. Which statements can guide you in these best practices?

 	 
 

A.

Active data is placed on the outer portion of disk

 

B.

Mirrored data is placed on the outer portion of disk

 

C.

Active data from all grid disks is on the inside portion of the disk

 

D.

Active data and mirrored data are placed together, with the first grid disk going on the outside of the disk.

 

Q.59) 

You have defined a category plan for an IORM plan. The Interactive category has an allocation of 90 and level of 1, the Batch category has an allocation of 80 and level 2, and the Maintenance and Other Categories are level 3 with an allocation of 50 for each. If the I/O requests for all categories are saturating the cell, and requests for 20% of the available I/Os are for the Interactive category, 30% of the available I/Os are for the Batch category, what percent of the remaining I/O requests represent the maximum amount allocate for the Maintenance group? 

 	 
 

A.

5%

 

B.

10%

 

C.

25%

 

D.

50%

 

Q.60) 

Which software runs on the Exadata Storage Server?

 	 
 

A.

Enterprise Manager

 

B.

Oracle Enterprise Linux

 

C.

IORM

 

D.

CELLSRV

 

E.

Restart Server

 

Q.61) 

What does the Exadata Server software use Bloom filters for?

 	 
 

A.

Join filtering

 

B.

Query optimization

 

C.

Cardinality analysis

 

D.

Sorting

 

Q.62) 

Your customer has an initial need to store 100 TBs of data In the Oracle Exadata Database Machine. You recommend a full rack with 336 TBs of SATA disk. When your customer asks why you have seemingly recommended too large a machine, what should you reply?

 	 
 

A.

SATA disks are always better.

 

B.

SAS disks could work, but SATA provide more raw bandwidth.

 

C.

You want to make sure your customer has room for growth, even If they don’t think they need it now.

 

D.

When you include the storage space needed for redundant data, logs, rollback and temp space, a full rack of SATA disks provides 100 TBs of storage for user data.

 

Q.63) 

Why is performing an incremental backup of data from an Exadata Storage Server likely faster than backing up data from normal storage?

 	 
 

A.

All data on the Exadata Storage Server is compressed.

 

B.

All backups from the Exadata Storage Server are compressed.

 

C.

Recovery Manager always uses more threads to perform backups from an Exadata Storage Server.

 

D.

Offload processing finds only the changed blocks.

 

Q.64) 

What happens when a grid disk is in a synch state?

 	 
 

A.

ASM writes all changes that occurred while the disk was offline.

 

B.

Log entries on the disk are synched with log files.

 

C.

Data values on the disk are synched with data in the Flash Cache.

 

D.

There is no synch state for grid disks.

 

Q.65) 

If you perform an ALTER on a cell disk or grid disk, you must also modify any ASM group that uses that entity. 

 	 
 

A.

True

 

B.

False

 

Q.66) 

Which two features provide performance benefits in a similar way?

 	 
 

A.

Partitioning and Storage Indexes

 

B.

Storage Indexes and Parallelism

 

C.

Partitioning and parallelism

 

D.

Model scoring and Partitioning

 

Q.67) 

When do you specify the type of interleaving for a grid disk?

 	 
 

A.

When you create the cell disk

 

B.

When you create the grid disk

 

C.

Through ASM

 

D.

When you create a tablespace

 

Q.68) 

Why would you reduce the default disk_repair_time parameter?

 	 
 

A.

To extend the availability of your ASM disk groups.

 

B.

To reduce the need for high redundancy

 

C.

To reduce the amount of data collected for a fast resynch

 

D.

To increase performance of an Exadata Storage Server.
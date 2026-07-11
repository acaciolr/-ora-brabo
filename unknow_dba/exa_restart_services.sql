/*Cell Services (cellsrv)*/

--Cell Services (cellsrv) is the primary component of the Exadata software running in the cell and provides the majority of Exadata storage services.
--It services database requests for disk I/O and advanced Exadata Cell services.
--Cellsrv is implemented as a multithread process and uses the largest portion of CPU / processor cycles on a storage cell.
--It provides the advanced SQL offload capabilities and serves Oracle blocks when SQL offload processing is not possible.
--Cellsrv implements the I/O resource management (IORM) functionality to meter out I/O bandwidth to the various databases and consumer groups issuing I/O.
 

/*Management Server (MS Process)*/

--The Management Server (MS) implements a web service for cell management commands and runs background monitoring threads.
--The MS is the primary interface to administer, manage and query the status of the Exadata cell.
--It works in cooperation with the Exadata cell command line interface (CellCLI) and processes most of the commands from CellCLI.

/*Restart Server (RS Process)*/

--Restart Server (RS) ensures the ongoing functioning of the Exadata software and services. 
--It monitors the heartbeat with the Management Services and the Cellsrv processes.
--If the processes fail to respond within the allowable heartbeat period, the services are re-started and notifications are sent to the user.


/*Manually Restarting the Cell Services*/

--If the MS / RS services fail with an MS/RS 7445 AND fail to automatically restart, they can be restarted manually without effecting the Cell Availability using the commands:

CellCLI> ALTER CELL RESTART SERVICES RS

CellCLI> ALTER CELL RESTART SERVICES MS
 

--If the Cellsrv is re-started either with the CELLSRV or the ALL option, the status of the grid disks must be verified as it may impact ASM.

	--1.  Run the following command to check if there are offline disks on other cells that are mirrored with disks on this cell:

		CellCLI > LIST GRIDDISK ATTRIBUTES name WHERE asmdeactivationoutcome != 'Yes'

--If any grid disks are listed in the returned output, then it is not safe to stop or re-start the CELLSRV process because proper Oracle ASM disk group redundancy will not be intact and will cause Oracle ASM to dismount the affected disk group, causing the databases to shut down abruptly.

--If no grid disks are listed in the returned output, you can safely restart cellsrv or all services in step #2 below.

	--2.  Re-start the cell services using either of the following commands: 

  CellCLI> ALTER CELL RESTART SERVICES CELLSRV

  CellCLI> ALTER CELL RESTART SERVICES ALL
  
--Failure in starting any of these services will require an SR will to be logged with an upload of a current sundiag.

      --See:  Document 1683842.1 SRDC - EEST Sundiag for details on how to collect.

--For additional information on the Cell Server Processes, please review the following whitepaper:

--http://www.oracle.com/technetwork/database/exadata/exadata-technical-whitepaper-134575.pdf

--

--Here last three lines of output shows the status of services which are running. To restart the service use below command

CellCLI> alter cell restart services rs

Stopping RS services...
The SHUTDOWN of RS services was successful.
Starting the RS services...
Getting the state of RS services...  running

CellCLI> alter cell restart services ms
CellCLI> alter cell restart services cellsrv
 
--To Restart all services in one command and shutdown a service use

CellCLI> alter cell restart services all

Stopping the RS, CELLSRV, and MS services...
The SHUTDOWN of services was successful.
Starting the RS, CELLSRV, and MS services...
Getting the state of RS services...  running
Starting CELLSRV services...
The STARTUP of CELLSRV services was successful.
Starting MS services...
The STARTUP of MS services was successful.

CellCLI> alter cell shutdown services rs
CellCLI> alter cell shutdown services ms
CellCLI> alter cell shutdown services cellsrv 
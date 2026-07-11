--MOS note$> 1448069.1

/*
Exadata : How to take an ILOM snapshot with the command line When working with Exadata, you will eventually have to provide an ILOM snapshot to support.

The procedure is described in this documentation but honestly it was not really clear to me before I did it as the procedure does not show real examples.

Before describing a real example from an ILOM snapshot taken from a production cell, one point is worth to be mentioned here :
A full ILOM snapshot (which is the one Oracle support will most likely ask you) may (yes, "may") reset the host as per the documentation :
Note - Using this option might reset the host operating system.
"Reset the host" meaning rebooting the host.
I did it few times on production cells and they have never been rebooted but this is something to keep in mind if you are asked to take a full ILOM snapshot of a database server. Indeed, a cell reboot would be transparent but this is a different story with a database server.

Having said that, one more thing before describing the procedure itself is to check what is needed to proceed :
The name of the target you want to take the snapshot on; in my example I'll take it on "myclustercel07" 
An access to the target's ILOM: here "myclustercel07-ilom"
The ILOM root password (default is welcome1)
The IP address of the host you want to store the ILOM on (it will be 10.11.12.13 in the below example); I personally use the database server 1 for this purpose : "myclusterdb01"; just ping it to get its IP as the ILOM won't resolve the hostname
*/

--First of all, let's connect and set the snapshot type to full :

  [root@myclusterdb01 ~]# ssh myclustercel07-ilom
  Password:
  Oracle(R) Integrated Lights Out Manager
  Version 3.2.7.30.a r112904
  Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
  Warning: HTTPS certificate is set to factory default.
  Hostname: myclustercel07-ilom
  -> set /SP/diag/snapshot dataset=full
  
  Set 'dataset' to 'full'

  ->

--Then start the ILOM snapshot using the IP of the target system we will put the ILOM on and its root password (itll copy the ILOM snapshot in /tmp in the below example) :

  -> set /SP/diag/snapshot dump_uri=sftp://root@10.11.12.13/tmp
  Collecting a "full" dataset may reset the host. Are you sure (y/n)? y
  Enter remote user password: ************
  Set 'dump_uri' to 'sftp://root@10.11.12.13/tmp'
  
  -> 

--An alternative syntax with the password in the command line is also an option :

  -> set /SP/diag/snapshot dump_uri=sftp://root:root_password@10.11.12.13/tmp
  Collecting a "full" dataset may reset the host. Are you sure (y/n)? y
  Set 'dump_uri' to 'sftp://root@10.11.12.13/tmp'
  
  -> 

--Now that the ILOM snapshot has been started, you can monitor it using the below command :

  -> show /SP/diag/snapshot
  
   /SP/diag/snapshot
      Targets:
  
      Properties:
          dataset = full
          dump_uri = (Cannot show property)
          encrypt_output = false
          result = Running
  
      Commands:
          cd
          set
          show
  
  ->

--After few minutes you should see the ILOM snapshot as completed :

  -> show /SP/diag/snapshot
  
   /SP/diag/snapshot
      Targets:
      Properties:
          dataset = full
          dump_uri = (Cannot show property)
          encrypt_output = false
          result = Collecting data into sftp://root@10.11.12.13/tmp/myclustercel07-ilom_1133FMM02D_2018-02-04T23-18-06.zip
                   Snapshot Complete.
                   Done.
  
      Commands:
          cd
          set
          show

  ->

--This is actually quite a small file easy to transfer to MOS :

  [root@myclusterdb01 ~]# du -sh /tmp/myclustercel07-ilom_1133FMM02D_2018-02-04T23-18-06.zip
  2.5M    /tmp/myclustercel07-ilom_1133FMM02D_2018-02-04T23-18-06.zip
  [root@myclusterdb01 ~]#[root@myclusterdb01 ~]#

------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------

--Login related commands
-> start /SP/console        -- start the SP-console
-> show /SP/sessions        -- see the currently active sessions
-> stop /SP/console         -- to stop any user session

--Start and stop system
-> start /SYS                            (start system)  
-> stop [-force] /SYS                    (stop system)
-> show /SYS                             (shows the power status)
-> reset /SYS                            (reset host)
-> reset /SP                             (reset ILOM SP)
-> set /HOST send_break_action=break     (send break signal to the OS)
-> reset /CMM                            (to reset CMM on a blade Chassis)

--Locator commands
--To set the locator on or off

-> set /SYS LOCATE=on
-> set /SYS LOCATE=off

--Networking Commands
--To see the current network configuration of ILOM

-> show /SP/network

--To set an IP address for ILOM

-> set pendingipdiscovery=static 
-> set pendingipaddress=10.10.10.10
-> set pendingipnetmask=255.255.255.0
-> set pendingipgateway=10.10.10.1
-> set commitpending=true

--To show SP MAC address

show /SP/network macaddress

--If on a Blade chassis, to check the CMM IP :

-> show /CMM/network

--User administration
-> show /SP/users                  (Display all the ILOM users)
-> show /SP/user/admin             (Display configuration settings of a specific user)
-> create /SP/users/user_name password=PWD role=[administrator|operator]    (create new user)
-> delete /SP/users/username       (Delete a user)
-> set /SP/users/admin01 role=administrator           (set the role of a user)
-> set /SP/users/admin01           (set or change password of user)

--Monitoring and logs
-> show /SP/logs/event/list     (ILOM event log)
-> show -level all -output table /SP/faultmgmt     (List all hardware faults)
-> show -level all -output table /SYS type==Temperature value       (List all temperature sensor readings)

--hardware info
-> show -level all -output table /SYS type==DIMM                (show DIMMS)
-> show -level all -output table /SYS type=='Host Processor'    (show CPUs)
-> show -l all /SYS type=='Hard Disk'                           (show disks)

------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------

[root@spcdexa0002-adm ~]# ssh spcdexa0002-adm-ilom
Password:

Oracle(R) Integrated Lights Out Manager

Version 4.0.4.36 r128828

Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.

Warning: HTTPS certificate is set to factory default.

Hostname: spcdexa0002-adm-ilom

-> set /SP/diag/snapshot dump_uri=sftp://root:passwd@10.30.94.12/tmp/log_ilom
Set 'dump_uri' to 'sftp://root:rootcdsas@10.30.94.12/tmp/log_ilom'

-> cd /SP/diag/snapshot
/SP/diag/snapshot

-> show

 /SP/diag/snapshot
    Targets:
    

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Running

    Commands:
        cd
        set
        show

-> show

 /SP/diag/snapshot
    Targets:

    Properties:
        dataset = normal
        dump_uri = (Cannot show property)
        encrypt_output = false
        result = Collecting data into sftp://root@10.30.94.12/tmp/log_ilom/spcdexa0002-adm-ilom_1628NM1031_2020-03-12T17-43-49.zip
                 Snapshot Complete.
                 Done.
                

    Commands:
        cd
        set
        show
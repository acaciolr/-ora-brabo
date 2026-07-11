--I was not hands on with onecommand, so I went with command line option. Dropping RECO_FHDB was quite straight forward. Here are the high level steps that I followed to recreate RECO_FHDB diskgroup with normal redundancy.

--Step 1: Drop Diskgroup

SUCCESS:  drop diskgroup RECO_FHDB including contents
Tue Jul 17 22:55:09 2012
NOTE: diskgroup resource ora.RECO_FHDB.dg is dropped

--Step 2: Extract DDL (create diskgroup) command for RECO_FHDB from ASM alert log and replace redundancy clause and run create diskgroup command on ASM instance.

SQL> CREATE DISKGROUP RECO_FHDB NORMAL REDUNDANCY  DISK
'o/192.168.10.10/RECO_FHDB_CD_00_fhdbcel06',
….

….

'o/192.168.10.9/RECO_FHDB_CD_11_fhdbcel05' ATTRIBUTE
'compatible.asm'='11.2.0.2','compatible.rdbms'='11.2.0.2','au_size'='4M','cell.smart_scan_capable'='TRUE' /* ASMCA */

SUCCESS: diskgroup RECO_FHDB was mounted


ASM spfile, OCR and voting disks were located on DATA_FHDB diskgroup and I had to relocate above files from DATA_FHDB to RECO_FHDB to recreate DATA_FHDB diskgroup with normal redundancy.

--Step 1: Drop diskgroup will throw following error when ASM SPFILE is located on same diskgroup.

SQL> drop diskgroup DATA_FHDB including contents
NOTE: Active use of SPFILE in group
Wed Jul 18 14:49:29 2012
GMON querying group 1 at 18 for pid 19, osid 9914
Wed Jul 18 14:49:29 2012
NOTE: Instance updated compatible.asm to 11.2.0.2.0 for grp 1
ORA-15039: diskgroup not dropped
ORA-15027: active use of diskgroup "DATA_FHDB" precludes its dismount



--Step 2: Move OCR and voting disk to RECO_FHDB

[oracle@fhdbdb01 ~]$ ocrcheck
Status of Oracle Cluster Registry is as follows :
         Version                  :          3
         Total space (kbytes)     :     262120
         Used space (kbytes)      :       3344
         Available space (kbytes) :     258776
         ID                       : 1272363019
         Device/File Name         : +DATA_FHDB
                                    Device/File integrity check succeeded 

                                    Device/File not configured 

                                    Device/File not configured 

                                    Device/File not configured 

                                    Device/File not configured 

         Cluster registry integrity check succeeded 

         Logical corruption check bypassed due to non-privileged user

[root@fhdbdb01 cssd]# ocrconfig -add +RECO_FHDB
[root@fhdbdb01 cssd]# 

[root@fhdbdb01 cssd]# ocrconfig -delete +DATA_FHDB
[root@fhdbdb01 cssd]# ocrcheck
Status of Oracle Cluster Registry is as follows :
         Version                  :          3
         Total space (kbytes)     :     262120
         Used space (kbytes)      :       3364
         Available space (kbytes) :     258756
         ID                       : 1272363019
         Device/File Name         : +RECO_FHDB
                                    Device/File integrity check succeeded 

                                    Device/File not configured 

                                    Device/File not configured 

                                    Device/File not configured 

                                    Device/File not configured 

         Cluster registry integrity check succeeded 

         Logical corruption check succeeded

[root@fhdbdb01 ~]$ crsctl query css votedisk
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   75c79c52f88b4fcebf2f84ccad0be646 (o/192.168.10.10/DATA_FHDB_CD_00_fhdbcel06) [DATA_FHDB]
 2. ONLINE   14f6d0e1c8b94f3bbf222b821f7f48ab (o/192.168.10.11/DATA_FHDB_CD_00_fhdbcel07) [DATA_FHDB]
 3. ONLINE   7aed830fb6ee4f70bf9160b2f39ea64b (o/192.168.10.5/DATA_FHDB_CD_00_fhdbcel01) [DATA_FHDB]
 4. ONLINE   9cc87608cabd4fb0bfea7e1f7d403134 (o/192.168.10.6/DATA_FHDB_CD_00_fhdbcel02) [DATA_FHDB]
 5. ONLINE   2c6008a2c0864fbfbf4ae1c9cbc60d5c (o/192.168.10.7/DATA_FHDB_CD_00_fhdbcel03) [DATA_FHDB] 

[root@fhdbdb01 cssd]# crsctl replace votedisk +RECO_FHDB
Successful addition of voting disk 161fa97cc71e4fffbfe10408e1e32aa0.
Successful addition of voting disk 128fb088bd7c4fe7bf6dff63d946dbc6.
Successful addition of voting disk 804b6348a5974f53bfccb328b92f9350.
Successful deletion of voting disk 75c79c52f88b4fcebf2f84ccad0be646.
Successful deletion of voting disk 14f6d0e1c8b94f3bbf222b821f7f48ab.
Successful deletion of voting disk 7aed830fb6ee4f70bf9160b2f39ea64b.
Successful deletion of voting disk 9cc87608cabd4fb0bfea7e1f7d403134.
Successful deletion of voting disk 2c6008a2c0864fbfbf4ae1c9cbc60d5c.
Successfully replaced voting disk group with +RECO_FHDB.
CRS-4266: Voting file(s) successfully replaced 

[root@fhdbdb01 cssd]# crsctl query css votedisk
##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   161fa97cc71e4fffbfe10408e1e32aa0 (o/192.168.10.10/RECO_FHDB_CD_00_fhdbcel06) [RECO_FHDB]
 2. ONLINE   128fb088bd7c4fe7bf6dff63d946dbc6 (o/192.168.10.11/RECO_FHDB_CD_00_fhdbcel07) [RECO_FHDB]
 3. ONLINE   804b6348a5974f53bfccb328b92f9350 (o/192.168.10.5/RECO_FHDB_CD_00_fhdbcel01) [RECO_FHDB]
Located 3 voting disk(s).



--Step 3: Move ASM spfile.

SQL> create pfile='/nfs/zfs/init+ASM.ora' from spfile; 

File created. 

SQL> create spfile='+RECO_FHDB/fhdb-cluster/asmparameterfile/spfileASM.ora' from pfile='/nfs/zfs/init+ASM.ora'; 

File created. 

echo "SPFILE='+RECO_FHDB/fhdb-cluster/asmparameterfile/spfileASM.ora'" > init+ASM.ora



--Step 4: Drop DATA_FHDB diskgroup

SQL> drop diskgroup DATA_FHDB including contents;
drop diskgroup DATA_FHDB including contents
*
ERROR at line 1:
ORA-15039: diskgroup not dropped
ORA-15027: active use of diskgroup "DATA_FHDB" precludes its dismount
ASMCMD> cd DATA_FHDB/
ASMCMD> ls
fhdb-cluster/
ASMCMD> cd fhdb-cluster
ASMCMD> ls
ASMPARAMETERFILE/
OCRFILE/
ASMCMD> cd ASMPARAMETERFILE/
ASMCMD> ls
REGISTRY.253.788355279
ASMCMD> rm REGISTRY.253.788355279
ORA-15032: not all alterations performed
ORA-15028: ASM file '+DATA_FHDB/fhdb-cluster/ASMPARAMETERFILE/REGISTRY.253.788355279' not dropped; currently being accessed (DBD ERROR: OCIStmtExecute)



SQL> alter diskgroup DATA_FHDB dismount force;
Diskgroup altered.
SQL> drop diskgroup DATA_FHDB force including contents;
Diskgroup dropped.



--Step 5: Create DATA_FHDB diskgroup

#### descompactar
for I in $(ls p34538883_190000_Linux-x86-64*f10.zip)
do
unzip $I
done

cat *.tar.* | tar -xvf -

rm -f *.tar*

cd /u01/QSFDP_OCT2022/34538883/Infrastructure/22.1.4.0.0/ExadataStorageServer_InfiniBandSwitch/
unzip *.zip

# 1) Run the prechecks (1) -- cells
cd /u01/QSFDP_OCT2022/34538883/Infrastructure/22.1.4.0.0/ExadataStorageServer_InfiniBandSwitch/patch_22.1.4.0.0.221020
./patchmgr -cells ~/cell_group -patch_check_prereq -rolling

# ) Run the prechecks (2) -- IB Switches
cd /u01/QSFDP_OCT2022/34538883/Infrastructure/22.1.4.0.0/FabricSwitch/patch_switch_22.1.4.0.0.220929
./patchmgr -ibswitches ~/ib_group -upgrade -ibswitch_precheck

# RoCE
## https://netsoftmate.com/blog/Patching-Oracle-Exadata-X8M-RoCE-Switch
## Procedure for upgrading the RoCE switch firmware (Doc ID 2634626.1)
su - dbmadmin
cd /u01/QSFDP_OCT2022/34538883/Infrastructure/22.1.4.0.0/FabricSwitch/patch_switch_22.1.4.0.0.220929
./patchmgr --roceswitches ~/roceswitches.lst --verify-config --log_dir ~/log_precheck
./patchmgr --roceswitches ~/roceswitches.lst --upgrade --roceswitch-precheck --log_dir ~/log_precheck


# 3) Run the prechecks (3) -- DB nodes
## DB Nodes prechecks (launch them from the cel01 server as you will patch them from here)
## As we will use the cell node 1 server to patch the databases servers, we first need to copy patchmgr and the ISO file to this server

# patchmgr
scp /patches/OCT2016_bundle_patch/24436624/Infrastructure/SoftwareMaintenanceTools/DBServerPatch/5.161014/p21634633_121233_Linux-x86-64.zip root@myclustercel01:/tmp/SAVE/.

# This is the ISO file, do NOT unzip it, patchmgr will
scp /patches/OCT2016_bundle_patch/24436624/Infrastructure/12.1.2.3.3/ExadataDatabaseServer_OL6/p24669306_121233_Linux-x86-64.zip root@myclustercel01:/tmp/SAVE/.

## ssh to cell node or DB Node 2
ssh root@myclustercel01

## on cell node1 or DB Node 2
cd /tmp/SAVE
nohup unzip p21634633_121233_Linux-x86-64.zip &
cd /u01/QSFDP_OCT2022/dbserver_patch_221022/
./patchmgr -dbnodes /u01/QSFDP_OCT2022/dbs_group23 -precheck -nomodify_at_prereq -log_dir auto -target_version 22.1.4.0.0.221020 \
-iso_repo /u01/QSFDP_OCT2022/34538883/Infrastructure/22.1.4.0.0/ExadataDatabaseServer_OL7/p34574133_221000_Linux-x86-64.zip

## Note : if you have some NFS mounted, you will have some error messages, you can ignore them at this stage, we will umount the NFS before patching the DB nodes
## Note 2 : these pre requisites are quite long ~1h15 for a full rack
## Note 3 : Consider using the -modify_at_prereq option if you face some dependencies issues

# You can connect to a cell ILOM to check what is happening during a patch application. 
# Please find the procedure on how to connect to an ILOM console. Once connected, you will see everything that is happening on the server console like the reboot sequence, etc
ssh root@myclustercel01-ilom
start /sp/console

################ APPLY ########################################

## checa o disk repair time do ASM e Diskgroups
. oraenv <<< +ASM1
sqlplus / as sysasm
set lines 400
col name format a30
col value format a20
select name,value from v$asm_attribute where group_number=1 and name like '%disk_repair_time%';
select dg.name, a.value from v$asm_diskgroup dg, v$asm_attribute a where dg.group_number=a.group_number and a.name='disk_repair_time';

## Cells patching - Apply the patch in a rolling manner

# check the cells version before patching
dcli -g ~/cell_group -l root imageinfo -ver

cd /u01/QSFDP_OCT2022/34538883/Infrastructure/22.1.4.0.0/ExadataStorageServer_InfiniBandSwitch/patch_22.1.4.0.0.221020
./patchmgr -cells ~/cell_group -reset_force
./patchmgr -cells ~/cell_group -cleanup
./patchmgr -cells ~/cell_group -patch_check_prereq -rolling
nohup ./patchmgr -cells ~/cell_group -patch -rolling &
./patchmgr -cells ~/cell_group -cleanup

## IB Switches patching
cd /patches/OCT2016_bundle_patch/24436624/Infrastructure/12.1.2.3.3/ExadataStorageServer_InfiniBandSwitch/patch_12.1.2.3.3.161013/
nohup ./patchmgr -ibswitches ~/ib_group -upgrade &

# Check the Version of Each IB Switch After the Patch
dcli -g ~/ib_group -l root version | grep "version"

## Patching the DB Nodes
dcli -g ~/dbs_group -l root imageinfo -ver

# We first need to umount the NFS on each DB node, this is a pre-requisite of the patch
df -t nfs | awk '{if ($NF ~ /^\//){print "umount " $NF}}' | bash

cd /u01/QSFDP_OCT2022/dbserver_patch_221022/
nohup ./patchmgr -dbnodes ~/dbs_group1 -upgrade -iso_repo /u01/QSFDP_OCT2022/34538883/Infrastructure/22.1.4.0.0/ExadataDatabaseServer_OL7/p34574133_221000_Linux-x86-64.zip -rolling &
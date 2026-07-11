Atualização de kernel usando o YUM.
É mandatório que haja no mínimo 3Gb de espaço livre no barra “/”
1.    Fazer backup de S.O
Existem 3 métodos de fazer backup de S.O.:

Primeiro método é usando o script dbserver_backup.sh

Para usar esse método, é necessário haver espaço para criar uma nova partição do mesmo tamanho que a partição do file system (/) do root e todas as partições não-locais de sistema devem ser desmontadas (ex. NFS, Samba, etc). O script de auxilio para backup dbserver_backup.sh pode ser usado para fazer backup do root(/) e de partições /boot. Ele pode ser baixado para o seu release pelo patch 13741363.

Esse script verifica se existe espaço suficiente e coloca o backup e uma nova partição chamada /dev/VGExaDb/LVDbSys2. Se não houver espaço suficiente o script não irá funcionar.

Para diminuir o tempo total e reduzir a possibilidade de falhas for falta de espaço antes de rodar o script, é recomendado que sejam removidos os arquivos de log e trace desnecessários, e qualquer outro arquivo grande que possa ser recuperado com facilidade de outra fontes ( ex. Oracle patch ou arquivos de instalação zipados).

NOTA: Por padrão o script dbserver_backup.sh cria um backup da partição 1 (/dev/mapper/LVExaDb-LVDbSys1) considerando como partição ativa em uso na partição 2 (/dev/mapper/VGExaDb-LVDbSys2) considerada como uma partição inativa. Após um rollback bem sucessido, as partições ficarão invertidas. Antes de tentar refazer o upgrade, um novo backup deverá ser criado. Se a partição ativa em uso não for mais a partição 1, o argumento –backup-to-partition precisará ser especificado quando for rodar o script dbserver_backup.sh, assegurando dessa forma que a partição certa estará sendo copiada para o local correto. Para maiores informações por favor verifique o -help do dbserver_backup.sh.

Para saber qual partição está ativa, você pode usar o commando imaginfo como root, no exemplo abaixo a partição ativa é a 1 (/dev/mapper/LVExaDb-LVDbSys1), dessa forma o backup seria feito na partição 2

# imageinfo

Kernel version: 2.6.18-238.12.2.0.2.el5 #1 SMP Tue Jun 28 05:21:19 EDT 2011 x86_64
Image version: 11.2.2.4.2.111221
Image activated: 2012-07-27 13:15:04 -0600
Image status: success

System partition on device: /dev/mapper/VGExaDb-LVDbSys1

Segundo método é através de snapshot conforme descrito no chapter 7 do Database Machine Owners Guide na seção “Recovering a Linux-Based Database Server Using the Most-Recent Backup“.

Quando fizer LVM snapshots, tenha certesa de ter fornecido outro label ao snapshot, ou de ter removido o label após ter feito o backup, caso contrário o sistema não irá subir após a proxima reinicialização.

Para verificar se o database server usa Linux Volume Manager (LVM) para file systems, use o seguinte comando:

# mount | sed -e ‘/VGExaDb/!d;s/.*VGExaDb.*/VGExaDb/g;’

O resultado esperado para esse comando é o seguinte:

VGExaDb
VGExaDb

Quando o database server vem de fabrica, ele tem extatamente o mesmo layout de partições o nomes, Use o seguinte commando para verificar:

# mount | sed -e ‘/VGExaDb/!d;s/.*on \/ type.*/\//g;s/.*on \/u01.*/u01/g;’

O resultado esperado para esse comando é o seguinte:

/
u01

Caso o servidor atenda as condições necessárias, esse método poderá ser usado conforme os passos descritos abaixo.

Taking a Snapshot-based Backup

The following procedure describes how to take a snapshot-based backup. The values shown in the procedure are examples.

1.Prepare a destination to hold the backup, as follows. The destination can be a large, writable NFS location. The NFS location should be large enough to hold the backup tar files. For uncustomized partitions, 145 GB should be adequate.

a.Create a mount point for the NFS share using the following command:

mkdir -p /root/tar

b.Mount the NFS location using the following command:

mount -t nfs -o ro,intr,soft,proto=tcp,nolock ip_address:/nfs_location/ /root/tar

In the preceding command, ip_address is the IP address of the NFS server, and nfs_location is the NFS location.

2.Take a snapshot-based backup of the / (root), /u01, and /boot directories, as follows:

a.Create a snapshot named root_snap for the root directory using the following command:

lvcreate -L1G -s -n root_snap /dev/VGExaDb/LVDbSys1

b.Label the snapshot using the following command:

e2label /dev/VGExaDb/root_snap DBSYS_SNAP

c.Mount the snapshot using the following commands:

mkdir /root/mnt

mount /dev/VGExaDb/root_snap /root/mnt -t ext3

d.Create a snapshot named u01_snap for the /u01 directory using the following command:

lvcreate -L5G -s -n u01_snap /dev/VGExaDb/LVDbOra1

e.Label the snapshot using the following command:

e2label /dev/VGExaDb/u01_snap DBORA_SNAP

f.Mount the snapshot using the following commands:

mkdir -p /root/mnt/u01

mount /dev/VGExaDb/u01_snap /root/mnt/u01 -t ext3

g.Change to the directory for the backup using the following command:

cd /root/mnt

h.Create the backup file using one of the following commands:

–System does not have NFS mount points:

# tar -pjcvf /root/tar/mybackup.tar.bz2 * /boot –exclude \

tar/mybackup.tar.bz2 > /tmp/backup_tar.stdout 2> /tmp/backup_tar.stderr

–System has NFS mount points:

# tar -pjcvf /root/tar/mybackup.tar.bz2 * /boot –exclude \

tar/mybackup.tar.bz2 –exclude nfs_mount_points > \

/tmp/backup_tar.stdout 2> /tmp/backup_tar.stderr

In the preceding command, nfs_mount_points are the NFS mount points. Excluding the mount points prevents the generation of large files and long backup times.

i.Check the /tmp/backup_tar.stderr file for any significant errors. Errors about failing to tar open sockets, and other similar errors, can be ignored.

3.Unmount the snapshots and remove the snapshots for the root and /01 directories using the following commands:

cd /

umount /root/mnt/u01

umount /root/mnt

/bin/rm -rf /root/mnt

lvremove /dev/VGExaDb/u01_snap

lvremove /dev/VGExaDb/root_snap

4.Unmount the NFS share using the following command:

umount /root/tar

Refer to the maintenance chapter in the owners guide for information about back up and restore. Note that the backup created by this procedure facilitates best in both rolling back software changes and recovering from an unbootable system.

Terceira opção é fazer backup do barra “/” usando o TAR.
Ir para o barra “/”

cd /

Fazer um backup usando o comando TAR

tar –pjcvf mybackup.tar.bz2 *

 

Passos para atualizar o kernel
Executar os comandos abaixo como (root)

Importar a chave do GPG RPM usando o seguinte comando
# rpm –import /usr/share/rhn/RPM-GPG-KEY

Rode o comando up2date no modo texto da seguinte forma:
# up2date –nox –register

3)  crie os diretórios necessário para armazenar o repositório

mkdir -p /mnt/iso/yum/unknown/EXADATA/dbserver/11.2/latest
4) Monte o isso no diretório criado anteriormente

mount -o loop /mnt/rman/patch-16432033/112_latest_repo_130302.iso /mnt/iso/yum/unknown/EXADATA/dbserver/11.2/latest
5)  edite o o arquivo Exadata-computenode.repo

vi /etc/yum.repos.d/Exadata-computenode.repo

Exadata-computenode.repo    antes
================================
[exadata_dbserver_11.2.3.2.1_x86_64_base]
name=Oracle Exadata DB server 11.2.3.2.1 Linux $releasever – $basearch – base
baseurl=file:///media/iso/x86_64
gpgcheck=1
enabled=0

Exadata-computenode.repo   depois
================================
[exadata_dbserver_11.2.3.2.1_x86_64_base]
name=Oracle Exadata DB server 11.2.3.2.1 Linux $releasever – $basearch – base
baseurl=file:///mnt/iso/yum/unknown/EXADATA/dbserver/11.2/latest/x86_64
gpgcheck=1
enabled=0

check
=====
[root@dbm01db01 ~]# yum repolist
exadata_dbserver_11.2.3.2.1_x86_64_base                                                                                                      | 1.9 kB     00:00
exadata_dbserver_11.2.3.2.1_x86_64_base/primary_db                                                                                            | 1.1 MB     00:00
Excluding Packages in global exclude list
Finished

repo id                              repo name                                     status
exadata_dbserver_11.2.3.2.1_x86_64_base  Oracle Exadata DB server 11.2.3.2.1 Linux 5 – x86_64 – base                                485+1
repolist: 485

Patch
======

/u01/app/11.2.0.3/grid/bin/crsctl disable crs

CRS-4621: Oracle High Availability Services autostart is disabled.

/u01/app/11.2.0.3/grid/bin/crsctl stop crs -f

CRS-2791: Starting shutdown of Oracle High Availability Services-managed resources on ‘dbm01db01’
…
CRS-4133: Oracle High Availability Services has been stopped.

yum clean all

Cleaning up Everything

Verify the yum repository using the following command:

# yum –enablerepo=<channel name as mentioned in the patch README> repolist

Update the database server using <channel as mentioned in the patch README>.

yum –enablerepo=<channel as mentioned in the patch README> update

exadata_dbserver_11.2.3.2.1_x86_64_base                                                                                                         | 1.9 kB     00:00
exadata_dbserver_11.2.3.2.1_x86_64_base/primary_db                                                                                              | 1.1 MB     00:00
Excluding Packages in global exclude list
Finished
Setting up Update Process
Resolving Dependencies
–> Running transaction check
—> Package device-mapper-multipath.x86_64 0:0.4.9-56.0.3.el5 set to be updated
—> Package device-mapper-multipath-libs.x86_64 0:0.4.9-56.0.3.el5 set to be updated
—> Package exadata-applyconfig.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-asr.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-base.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-commonnode.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-exachk.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-firmware-compute.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-ibdiagtools.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-ipconf.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-onecommand.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-oswatcher.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package exadata-sun-computenode.x86_64 0:11.2.3.2.1.130302-1 set to be updated
–> Processing Dependency: ofa-2.6.32-400.21.1.el5uek = 1.5.1-4.0.58 for package: exadata-sun-computenode
—> Package exadata-validations-compute.x86_64 0:11.2.3.2.1.130302-1 set to be updated
—> Package kernel-uek.x86_64 0:2.6.32-400.21.1.el5uek set to be installed
—> Package kernel-uek-debuginfo.x86_64 0:2.6.32-400.21.1.el5uek set to be updated
—> Package kernel-uek-debuginfo-common.x86_64 0:2.6.32-400.21.1.el5uek set to be updated
—> Package kernel-uek-devel.x86_64 0:2.6.32-400.21.1.el5uek set to be updated
—> Package kernel-uek-doc.noarch 0:2.6.32-400.21.1.el5uek set to be updated
—> Package kernel-uek-firmware.noarch 0:2.6.32-400.21.1.el5uek set to be updated
—> Package kernel-uek-headers.x86_64 0:2.6.32-400.21.1.el5uek set to be updated
—> Package kexec-tools.x86_64 0:1.102pre-161.el5 set to be updated
—> Package kpartx.x86_64 0:0.4.9-56.0.3.el5 set to be updated
—> Package libbdevid-python.x86_64 0:5.1.19.6-79.0.1.el5 set to be updated
—> Package mkinitrd.x86_64 0:5.1.19.6-79.0.1.el5 set to be updated
—> Package nash.x86_64 0:5.1.19.6-79.0.1.el5 set to be updated
–> Running transaction check
—> Package ofa-2.6.32-400.21.1.el5uek.x86_64 0:1.5.1-4.0.58 set to be updated
exadata_dbserver_11.2.3.2.1_x86_64_base/filelists_db                                                                                            | 683 kB     00:00
–> Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================================================================================
Package                                     Arch                  Version                                Repository                                     Size
=======================================================================================================================================================================
Installing:
kernel-uek                                  x86_64                2.6.32-400.21.1.el5uek                 exadata_dbserver_11.2.3.2.1_x86_64_base               26 M
Updating:
device-mapper-multipath                     x86_64                0.4.9-56.0.3.el5                       exadata_dbserver_11.2.3.2.1_x86_64_base             104 k
device-mapper-multipath-libs                x86_64                0.4.9-56.0.3.el5                       exadata_dbserver_11.2.3.2.1_x86_64_base             179 k
exadata-applyconfig                         x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                 28 k
exadata-asr                                 x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                 33 k
exadata-base                                x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                852 k
exadata-commonnode                          x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                 40 M
exadata-exachk                              x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                1.5 M
exadata-firmware-compute                    x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                135 M
exadata-ibdiagtools                         x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                 98 k
exadata-ipconf                              x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                 84 k
exadata-onecommand                          x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                 16 M
exadata-oswatcher                           x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                355 k
exadata-sun-computenode                     x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                424 k
exadata-validations-compute                 x86_64                11.2.3.2.1.130302-1                    exadata_dbserver_11.2.3.2.1_x86_64_base                 55 k
kernel-uek-debuginfo                        x86_64                2.6.32-400.21.1.el5uek                 exadata_dbserver_11.2.3.2.1_x86_64_base              320 M
kernel-uek-debuginfo-common                 x86_64                2.6.32-400.21.1.el5uek                 exadata_dbserver_11.2.3.2.1_x86_64_base               38 M
kernel-uek-devel                            x86_64                2.6.32-400.21.1.el5uek                 exadata_dbserver_11.2.3.2.1_x86_64_base              6.8 M
kernel-uek-doc                              noarch                2.6.32-400.21.1.el5uek                 exadata_dbserver_11.2.3.2.1_x86_64_base              8.5 M
kernel-uek-firmware                         noarch                2.6.32-400.21.1.el5uek                 exadata_dbserver_11.2.3.2.1_x86_64_base              3.8 M
kernel-uek-headers                          x86_64                2.6.32-400.21.1.el5uek                 exadata_dbserver_11.2.3.2.1_x86_64_base              775 k
kexec-tools                                 x86_64                1.102pre-161.el5                       exadata_dbserver_11.2.3.2.1_x86_64_base                588 k
kpartx                                      x86_64                0.4.9-56.0.3.el5                       exadata_dbserver_11.2.3.2.1_x86_64_base             468 k
libbdevid-python                            x86_64                5.1.19.6-79.0.1.el5                    exadata_dbserver_11.2.3.2.1_x86_64_base                 69 k
mkinitrd                                    x86_64                5.1.19.6-79.0.1.el5                    exadata_dbserver_11.2.3.2.1_x86_64_base                475 k
nash                                        x86_64                5.1.19.6-79.0.1.el5                    exadata_dbserver_11.2.3.2.1_x86_64_base                1.4 M
Installing for dependencies:
ofa-2.6.32-400.21.1.el5uek                  x86_64                1.5.1-4.0.58                           exadata_dbserver_11.2.3.2.1_x86_64_base             1.0 M

Transaction Summary
=======================================================================================================================================================================
Install       2 Package(s)
Upgrade      25 Package(s)

Total download size: 603 M

Is this ok [y/N]: y

Esperar até que a máquina reinicie

[root@dbm01db01 ~]# w
23:37:01 up 2 min,  1 user,  load average: 1,39, 0,53, 0,19
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    10.1.0.194       23:36    0.00s  0.01s  0.01s w

rpm -qa | grep ‘ofa-\|^kernel-‘ | grep -v ‘uek\|^kernel-2\.6\.18’ | xargs yum -y remove

Setting up Remove Process
Resolving Dependencies
–> Running transaction check
—> Package kernel-debuginfo.x86_64 0:2.6.18-308.24.1.0.1.el5 set to be erased
—> Package kernel-debuginfo-common.x86_64 0:2.6.18-308.24.1.0.1.el5 set to be erased
—> Package kernel-devel.x86_64 0:2.6.18-308.24.1.0.1.el5 set to be erased
—> Package kernel-doc.noarch 0:2.6.18-308.24.1.0.1.el5 set to be erased
—> Package ofa-2.6.18-238.12.2.0.2.el5.x86_64 0:1.5.1-4.0.53 set to be erased
—> Package ofa-2.6.18-274.18.1.0.1.el5.x86_64 0:1.5.1-4.0.58 set to be erased
–> Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================================================================================
Package                                           Arch                         Version                                          Repository                       Size
=======================================================================================================================================================================
Removing:
kernel-debuginfo                                  x86_64                       2.6.18-308.24.1.0.1.el5                          installed                       610 M
kernel-debuginfo-common                           x86_64                       2.6.18-308.24.1.0.1.el5                          installed                       150 M
kernel-devel                                      x86_64                       2.6.18-308.24.1.0.1.el5                          installed                        16 M
kernel-doc                                        noarch                       2.6.18-308.24.1.0.1.el5                          installed                       8.0 M
ofa-2.6.18-238.12.2.0.2.el5                       x86_64                       1.5.1-4.0.53                                     installed                       3.6 M
ofa-2.6.18-274.18.1.0.1.el5                       x86_64                       1.5.1-4.0.58                                     installed                       3.5 M

Transaction Summary
=======================================================================================================================================================================
Remove        6 Package(s)
Reinstall     0 Package(s)
Downgrade     0 Package(s)

Downloading Packages:
Running rpm_check_debug
Running Transaction Test
Finished Transaction Test
Transaction Test Succeeded
Running Transaction
Erasing        : kernel doc                                                                                                                                      1/6
Erasing        : ofa-2.6.18-274.18.1.0.1.el5                                                                                                                     2/6
Erasing        : kernel-debuginfo                                                                                                                                3/6
Erasing        : kernel-devel                                                                                                                                    4/6
Erasing        : ofa-2.6.18-238.12.2.0.2.el5                                                                                                                     5/6
Erasing        : kernel-debuginfo-common                                                                                                                         6/6

Removed:
kernel-debuginfo.x86_64 0:2.6.18-308.24.1.0.1.el5    kernel-debuginfo-common.x86_64 0:2.6.18-308.24.1.0.1.el5    kernel-devel.x86_64 0:2.6.18-308.24.1.0.1.el5
kernel-doc.noarch 0:2.6.18-308.24.1.0.1.el5          ofa-2.6.18-238.12.2.0.2.el5.x86_64 0:1.5.1-4.0.53           ofa-2.6.18-274.18.1.0.1.el5.x86_64 0:1.5.1-4.0.58

Complete!

yum clean all

Cleaning up Everything

/u01/app/11.2.0.3/grid/bin/crsctl enable crs

CRS-4622: Oracle High Availability Services autostart is enabled.

/u01/app/11.2.0.3/grid/bin/crsctl start crs

CRS-4123: Oracle High Availability Services has been started.

Verificação final

[root@dbm01db01 ~]# dcli -g dbs_group -l root uname -a
dbm01db01: Linux dbm01db01.gruposhark.com.br 2.6.32-400.21.1.el5uek #1 SMP Wed Feb 20 01:35:01 PST 2013 x86_64 x86_64 x86_64 GNU/Linux
dbm01db02: Linux dbm01db02.gruposhark.com.br 2.6.32-400.11.1.el5uek #1 SMP Thu Nov 22 03:29:09 PST 2012 x86_64 x86_64 x86_64 GNU/Linux
dbm01db03: Linux dbm01db03.gruposhark.com.br 2.6.32-400.11.1.el5uek #1 SMP Thu Nov 22 03:29:09 PST 2012 x86_64 x86_64 x86_64 GNU/Linux
dbm01db04: Linux dbm01db04.gruposhark.com.br 2.6.32-400.11.1.el5uek #1 SMP Thu Nov 22 03:29:09 PST 2012 x86_64 x86_64 x86_64 GNU/Linux
dbm02db01: Linux dbm02db01.gruposhark.com.br 2.6.32-400.11.1.el5uek #1 SMP Thu Nov 22 03:29:09 PST 2012 x86_64 x86_64 x86_64 GNU/Linux
dbm02db02: Linux dbm02db02.gruposhark.com.br 2.6.32-400.11.1.el5uek #1 SMP Thu Nov 22 03:29:09 PST 2012 x86_64 x86_64 x86_64 GNU/Linux
dbm02db03: Linux dbm02db03.gruposhark.com.br 2.6.32-400.11.1.el5uek #1 SMP Thu Nov 22 03:29:09 PST 2012 x86_64 x86_64 x86_64 GNU/Linux
dbm02db04: Linux dbm02db04.gruposhark.com.br 2.6.32-400.11.1.el5uek #1 SMP Thu Nov 22 03:29:09 PST 2012 x86_64 x86_64 x86_64 GNU/Linux
Fazer relink do binário do banco de dados e do binário do Grid infrastructure:

Conectado como root:

cd $GRID_HOME/crs/install

perl rootcrs.pl -unlock

Conectado como Owner do GRID_HOME (depende do cliente, pode ser grid, oracle, etc):

export ORACLE_HOME=$GRID_HOME

$ORACLE_HOME/bin/relink all

make -C $ORACLE_HOME/rdbms/lib -f ins_rdbms.mk ipc_rds ioracle

Conectado como Owner do binário do banco de dados (depende do cliente, geralmente é oracle):

export ORACLE_HOME={rdbms home}

$ORACLE_HOME/bin/relink all

make -C $ORACLE_HOME/rdbms/lib -f ins_rdbms.mk ipc_rds ioracle

Conectado como root:

cd $GRID_HOME/crs/install

perl rootcrs.pl -patch

A última chamada rootcrs.pl irá iniciar o GI e as instâncias.
--Configuração do Laboratorio

Database Servers	Storage Servers
Processadores	4	Processadores	4
Memoria	2 GB	Memoria	2 GB
Disco Local	60 GB	Disco	29 GB
Placa de Rede 	2	Placa de Rede 	2
Sistema Operacional	Oracle Linux 5.10	Sistema Operacional	Oracle Linux 5.10
Servidores 	2	Servidores 	3
Name Server	Rede Publica (eth0)	Rede Privada Infiniband (eth1)	
mcsa-cell1	192.168.0.200	10.10.10.200	
mcsa-cell2	192.168.0.201	10.10.10.201	
mcsa-cell3	192.168.0.202	10.10.10.202	
mcsa-db1	192.168.0.203	10.10.10.203	
mcsa-db2	192.168.0.204	10.10.10.204	

--Os procedimentos para a instalação do Sistema Operacional são os mesmos necessários para a instalação do Oracle em Linux, então irei pular esta parte, mas se houver alguma duvida, sobre como instalar o Linux, basta consultar o post já publicado aqui no blog Instalando o Red Hat 6.4 Enterprise .
--https://manualdodba.com/2013/08/18/instalando-o-red-hat-6-4-enterprise/

--Antes baixe aqui no eDelivery Oracle Linux de 64 bits 5.10 (V40139-01.iso) e Oracle Database Machine Exadata Storage Cell Release 12c (V42777-01) para Linux x86_64

/*-----------------------------------------------------------------------------------------------------------------------------------------------*/

#######################
##Instalando os Cells##
#######################

--Apos fazer os downloads e a instalação do S.O, vamos para a instalação :

--Descompacte os arquivos do cell (42777-01)
[root@mcsa-cell1 media]# unzip V42777-01.zip
 Archive: V42777-01.zip
 inflating: README.txt
 inflating: cellImageMaker_12.1.1.1.0_LINUX.X64_131219-1.x86_64.tar
[root@mcsa-cell1 media]#

root@mcsa-cell1 media]# tar -pxvf cellImageMaker_12.1.1.1.0_LINUX.X64_131219-1.x86_64.tar

--Destes aquivos só precisamos do cell.bin, então copie para o local da instalação, que no meu caso será o /opt/oracle, e descompacte
[root@mcsa-cell1 media]# cp dl180/boot/cellbits/cell.bin /opt/oracle/
[root@mcsa-cell1 oracle]# cd /opt/oracle
[root@mcsa-cell1 oracle]# unzip cell.bin
 Crie os diretórios de logs
[root@mcsa-cell1 oracle]# mkdir /var/log/oracle
[root@mcsa-cell1 oracle]# chmod 775 /var/log/oracle

--Defina o kernel padrão para o Enterprise Linux editando o grub.conf e alterando o default para 1
[root@mcsa-cell1 oracle]#  vi /etc/grub.conf
default=1
[root@mcsa-cell1 oracle]# grep default /etc/grub.conf
default=1

--Edite o kernel e altere o valor do fs.aio-max-nr e também o limits.conf
[root@mcsa-cell1 ~]# vi /etc/sysctl.conf
fs.aio-max-nr=50000000

[root@mcsa-cell1 oracle]# sysctl -p
[root@mcsa-cell1 ~]# vi /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
root soft core unlimited
root hard core unlimited
root soft nproc 131072
root hard nproc 131072
root soft nofile 131072
root hard nofile 131072
* soft memlock 55520682
* hard memlock 55520682

--Para se comunicar através de InfiniBand o Oracle usa o protocolo RDS. Todos os módulos de rds deve ser carregado (e configurado para ser reiniciado automaticamente)
[root@mcsa-cell1 oracle]# modprobe rds
[root@mcsa-cell1 oracle]# modprobe rds_tcp
[root@mcsa-cell1 oracle]# modprobe rds_rdma
[root@mcsa-cell1 oracle]# lsmod | grep rds
rds_rdma              116047  0
rds_tcp                10455  0
rds                   110708  2 rds_rdma,rds_tcp
rdma_cm                64047  2 rds_rdma,ib_iser
ib_core                75634  7 rds_rdma,ib_iser,rdma_cm,ib_cm,iw_cm,ib_sa,ib_mad
[root@mcsa-cell1 oracle]# vi /etc/modprobe.d/rds.conf
install rds /sbin/modprobe –ignore-install rds && /sbin/modprobe rds_tcp && /sbin/modprobe rds_rdma

--Terminadas as configurações irei reiniciar a máquina
[root@mcsa-cell1 oracle]#  init 6
Instale o jdk
[root@mcsa-cell1 oracle]# rpm -ivh jdk-1.7.0_25-fcs.x86_64.rpm
warning: jdk-1.7.0_25-fcs.x86_64.rpm: Header V3 DSA signature: NOKEY, key ID 1e5e0159
Preparing...                ########################################### [100%]
   1:jdk                    ########################################### [100%]
Unpacking JAR files...
          rt.jar...
          jsse.jar...
          charsets.jar...
          tools.jar...
          localedata.jar...

--Instale o cellsrv
[root@mcsa-cell1 oracle]# rpm -ivh cell-12.1.1.1.0_LINUX.X64_131219-1.x86_64.rpm
Preparing...                ########################################### [100%]
Pre Installation steps in progress ...
   1:cell                   ########################################### [100%]
Post Installation steps in progress ...
Set cellusers group for /opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/cellsrv/deploy/log directory
Set 775 permissions for /opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/cellsrv/deploy/log directory
/opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/cellsrv/deploy
/opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/cellsrv/deploy
/opt/oracle/cell12.1.1.1.0_LINUX.X64_131219
Installation SUCCESSFUL.
Starting RS and MS... as user celladmin
Done. Please Login as user celladmin and create cell to startup CELLSRV to complete cell configuration.
If this is a manual installation, please stop and restart ExaWatcher to pick up newly installed binaries.
You can run "/opt/oracle.ExaWatcher/ExaWatcher.sh --stop" and then "/opt/oracle.ExaWatcher/ExaWatcher.sh --fromconf" to stop and restart ExaWatcher.
Logout and then re-login to use the new cell environment.

[root@mcsa-cell1 oracle]#

--Em resumo já instalai o Oracle Linux e também o software cellserv, que automaticamente cria o usuário celladmin que é o dono do cellsrv.
--Agora preciso criar os discos.
--Criando os discos
--Eu usei 12 discos de 512 MB para simular o discos High Capacity. E 16 discos de 419 MB para simular os discos de Flash.

[root@mcsa-cell1 oracle]#  init 0

--Crie os discos e associem com VirtualBoxCreate
cd "C:\Program Files\Oracle\VirtualBox"
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD1.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD2.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD3.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD4.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD5.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD6.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD7.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD8.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD9.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD10.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD11.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_HDD12.vdi --size 512 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA1.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA2.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA3.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA4.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA5.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA6.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA7.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA8.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA9.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA10.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA11.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA12.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA13.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA14.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA15.vdi --size 419 --format VDI --variant Fixed
VBoxManage createhd --filename E:\VM\MCSA-CELL1\MCSA-CELL1_FLA16.vdi --size 419 --format VDI --variant Fixed
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 1 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD1.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 2 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD2.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 3 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD3.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 4 --device 0 --type hdd --medium E:\VM\MCSA-CELL2\HDD4.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 5 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD5.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 6 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD6.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 7 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD7.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 8 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD8.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 9 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD9.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 10 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD10.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 11 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD11.vdi --mtype shareable
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 12 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_HDD12.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 13 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA1.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 14 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA2.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 15 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA3.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 16 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA4.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 17 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA5.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 18 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA6.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 19 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA7.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 20 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA8.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 21 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA9.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 22 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA10.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 23 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA11.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 24 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA12.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 25 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA13.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 26 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA14.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 27 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA15.vdi --mtype shareable 
VBoxManage storageattach MCSA-CELL1 --storagectl "SATA" --port 28 --device 0 --type hdd --medium E:\VM\MCSA-CELL1\MCSA-CELL1_FLA16.vdi --mtype shareable

--Inicie o servidor
--O cellsrv procura as luns dentro do seguinte diretório $T_WORK

[root@mcsa-cell1 ~]# echo $T_WORK
/opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/disks
[root@mcsa-cell1 ~]# ls -ltrha /opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/disks
ls: /opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/disks: No such file or directory
[root@mcsa-cell1 ~]# mkdir -p /opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/disks/raw
[root@mcsa-cell1 ~]# cd $T_WORK/raw
[root@mcsa-cell1 raw]# pwd
/opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/disks/raw
[root@mcsa-cell1 raw]# fdisk -l 2>/dev/null |grep "B,"
[root@mcsa-cell1 raw]#
ln -s /dev/sdb mcsa-cell1_DISK01
ln -s /dev/sdc mcsa-cell1_DISK02
ln -s /dev/sdd mcsa-cell1_DISK03
ln -s /dev/sde mcsa-cell1_DISK04
ln -s /dev/sdf mcsa-cell1_DISK05
ln -s /dev/sdg mcsa-cell1_DISK06
ln -s /dev/sdh mcsa-cell1_DISK07 
ln -s /dev/sdi mcsa-cell1_DISK08
ln -s /dev/sdj mcsa-cell1_DISK09
ln -s /dev/sdk mcsa-cell1_DISK10
ln -s /dev/sdl mcsa-cell1_DISK11
ln -s /dev/sdm mcsa-cell1_DISK12
ln -s /dev/sdn mcsa-cell1_FLASH01
ln -s /dev/sdo mcsa-cell1_FLASH02
ln -s /dev/sdp mcsa-cell1_FLASH03
ln -s /dev/sdq mcsa-cell1_FLASH04
ln -s /dev/sdr mcsa-cell1_FLASH05
ln -s /dev/sds mcsa-cell1_FLASH06
ln -s /dev/sdt mcsa-cell1_FLASH07
ln -s /dev/sdu mcsa-cell1_FLASH08
ln -s /dev/sdv mcsa-cell1_FLASH09
ln -s /dev/sdw mcsa-cell1_FLASH10
ln -s /dev/sdx mcsa-cell1_FLASH11
ln -s /dev/sdy mcsa-cell1_FLASH12 
ln -s /dev/sdz mcsa-cell1_FLASH13
ln -s /dev/sdaa mcsa-cell1_FLASH14
ln -s /dev/sdab mcsa-cell1_FLASH15
ln -s /dev/sdab mcsa-cell1_FLASH16

--Antes de criar a cell algumas configurações manuais são necessárias
[root@mcsa-cell1 raw]# mkdir -p /opt/oracle/cell/cellofl-12.1.1.1.0_LINUX.X64_131219/oss/deploy/scripts/unix/rs /opt/oracle/cell/cellofl-11.2.3.3.0_LINUX.X64_131219/oss/deploy/scripts/unix/rs 
[root@mcsa-cell1 raw]# cp -p /opt/oracle/cell/cellofl-12.1.1.1.0_LINUX.X64_131219/cellsrv/bin/celloflsrv_start.sh /opt/oracle/cell/cellofl-12.1.1.1.0_LINUX.X64_131219/oss/deploy/scripts/unix/rs/celloflsrv_start.sh
[root@mcsa-cell1 raw]# cp -p /opt/oracle/cell/cellofl-11.2.3.3.0_LINUX.X64_131219/cellsrv/bin/celloflsrv_start.sh /opt/oracle/cell/cellofl-11.2.3.3.0_LINUX.X64_131219/oss/deploy/scripts/unix/rs/celloflsrv_start.sh
[root@mcsa-cell1 raw]# vi /opt/oracle/cell12.1.1.1.0_LINUX.X64_131219/cellsrv/deploy/config/cellinit.ora
 
_cell_oflsrv_heartbeat_timeout_sec=180 
_cell_reserve_hugepage_memory_mb=1000 
_cell_executing_in_vm=TRUE 

--Pare o service cellsrv
[root@mcsa-cell1 ~]# cellcli -e alter cell shutdown services CELLSRV
Stopping CELLSRV services...
The SHUTDOWN of CELLSRV services was successful.
[root@mcsa-cell1 ~]# service celld status
         rsStatus:               running
         msStatus:               running
         cellsrvStatus:          stopped

--Conecte com o user celladmin e crie o cell com a rede infiniband
[root@mcsa-cell1 ~]# su - celladmin
[celladmin@mcsa-cell1 ~]$ cellcli -e "create cell interconnect1=eth1"

--Note que neste momento  ele cria o cell, edita o arquivo cellinit.ora e adiciona o ipaddres cria as luns e também o disco de flash, agora vamos configurar os discos

--Configurando os discos
[celladmin@mcsa-cell1 ~]$ cellcli -e create celldisk all

--Criando os griddisks
[celladmin@mcsa-cell1 ~]$ cellcli -e create griddisk all harddisk prefix=DATA
 Configurando os discos de Flash
[celladmin@mcsa-cell2 ~]$ cellcli -e drop flashcache
[celladmin@mcsa-cell2 ~]$ cellcli -e drop flashlog
[celladmin@mcsa-cell2 ~]$ cellcli -e  create flashcache all size=3G
[celladmin@mcsa-cell2 ~]$ cellcli -e  create flashlog all
[celladmin@mcsa-cell2 ~]$ cellcli -e  list griddisk
         DATA_CD_DISK01_mcsa_cell2       active
         DATA_CD_DISK02_mcsa_cell2       active
         DATA_CD_DISK03_mcsa_cell2       active
         DATA_CD_DISK04_mcsa_cell2       active
         DATA_CD_DISK05_mcsa_cell2       active
         DATA_CD_DISK06_mcsa_cell2       active
         DATA_CD_DISK07_mcsa_cell2       active
         DATA_CD_DISK08_mcsa_cell2       active
         DATA_CD_DISK09_mcsa_cell2       active
         DATA_CD_DISK10_mcsa_cell2       active
         DATA_CD_DISK11_mcsa_cell2       active
         DATA_CD_DISK12_mcsa_cell2       active
[celladmin@mcsa-cell2 ~]$ cellcli -e  list flashcache
         mcsa_cell2_FLASHCACHE   normal
[celladmin@mcsa-cell2 ~]$ cellcli -e list flashlog
         mcsa_cell2_FLASHLOG     normal

--Concluimos a instalação do Exadata Storage Server, repita todos os passos para os dois servidores faltantes. Apos a instalação e configuração dos 3 servidores Storages, atribua uma senha para o usuário celladmin, e cria a relação de confiança conforme abaixo, para todos os servers, tanto com o root e também o celladmin:
[celladmin@mcsa-cell1 ~]$ vi cells.txt
mcsa-cell1
mcsa-cell2
mcsa-cell3
[celladmin@mcsa-cell1 ~]$ dcli -k -g cells.txt

--Testando o comando dcli
[celladmin@mcsa-cell1 ~]$ dcli -c mcsa-cell1,mcsa-cell2,mcsa-cell3 cellcli -e list cell
mcsa-cell1: mcsa_cell1 online
mcsa-cell2: mcsa_cell2 online
mcsa-cell3: mcsa_cell3 online

#######################
##Instalando os Cells##
#######################

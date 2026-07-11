===================================================================================================
===================================================================================================
=================================== DB NODE spcdexa0001-adm =======================================
===================================================================================================
===================================================================================================

[root@spcdexa0001-adm ~]# cd /rpm_ksplice/

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# hostname
spcdexa0001-adm.spo.supcd

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# date
Dom Jun  7 09:13:01 -03 2020

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# uname -a
Linux spcdexa0001-adm.spo.supcd 4.1.12-124.24.3.el6uek.x86_64 #2 SMP Mon Jan 14 15:08:09 PST 2019 x86_64 x86_64 x86_64 GNU/Linux

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.26.5.el6uek.x86_64

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.

Effective kernel version is 4.1.12-124.26.5.el6uek

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# yum list installed | grep 'exadata-sun.*computenode-exact'
exadata-sun-ovs-computenode-exact.noarch

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# yum erase exadata-sun-ovs-computenode-exact.noarch
Configurando o processo de remoção
Resolvendo dependências
--> Executando verificação da transação
---> Package exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1 will be removido
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                  Arq.         Versão                    Repo                                           Tam.
====================================================================================================================================
Removendo:
 exadata-sun-ovs-computenode-exact       noarch       19.2.1.0.0.190510-1       @exadata_generated_070919172143/6Server       0.0

Resumo da transação
====================================================================================================================================
Remove        1 Package(s)

Tamanho depois de instalado: 0
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
Aviso: o RPMDB foi alterado de fora do yum.
** Found 1 pre-existing rpmdb problem(s), 'yum check' output follows:
exadata-sun-ovs-computenode-minimum-19.2.1.0.0.190510-1.noarch tem exigências faltando do exadata-oswatcher >= ('0', '19.2.1.0.0.190510', '1')
  Apagando     : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1
  Verifying    : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1

Removido(s):
  exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1

Concluído!

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# pwd
/rpm_ksplice

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# ls
uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# yum install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
aviso: rpmts_HdrFromFdno: Cabeçalho V3 RSA/SHA256 Signature, key ID ec551f03: NOKEY


A chave pública para o uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm não está instalada

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# yum --nogpgcheck install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
  Atualizando  : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
The following steps will be taken:
Install [get3rovj] Enablement for applying custom alternative instructions.
Install [opm180mz] Improved enablement update for applying custom alternatives instructions.
Install [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Install [hze6qrtf] Known exploit detection.
Install [14i2g9lr] Known exploit detection for CVE-2017-7308.
Install [g7z90bgg] Known exploit detection for CVE-2018-14634.
Install [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Install [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Install [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Install [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Install [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Install [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Install [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Install [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Install [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Install [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Install [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Install [iqwlh0ca] Kernel crash during late microcode updates.
Install [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Install [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Install [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Install [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Install [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Install [iooyacxu] Incorrect return value during CPU microcode updates.
Install [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Install [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Install [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Install [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Install [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Install [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Install [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Install [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Install [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Install [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Install [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Install [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Install [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Install [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Install [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Install [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Install [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Install [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Install [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Install [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Install [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Install [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Install [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Install [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Install [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Install [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Install [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Install [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Install [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Install [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Install [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Install [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Install [lqn7ais6] Network TUN device creation failure with formatted names.
Install [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Install [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Install [cx570frs] Use-after-free in Xen network backend receive path.
Install [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Install [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Install [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Install [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Install [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Install [jwfdgahz] Denial-of-service when receiving segments over TCP.
Install [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Install [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Install [279lqcvw] Performance regression during microcode loading.
Install [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Install [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Install [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Install [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Install [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Install [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Install [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Install [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Install [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Install [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Install [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Install [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Install [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Install [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Install [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Install [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Install [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Install [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Install [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Install [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Install [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Install [gx6br2uw] Infiniband connection hang after failure.
Install [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Install [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Install [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Install [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Install [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Install [ownop36l] Reduced throughput in loopback disk devices.
Install [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Install [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Install [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Install [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Install [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Install [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Install [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Install [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Install [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Install [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Install [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Install [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Install [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Install [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Install [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Install [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Install [2us37bxn] Denial-of-service in XFS whiteout renames.
Install [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Install [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Install [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Install [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Install [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Install [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Install [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Install [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Install [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Install [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Install [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Install [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Install [lirbb7tr] Kernel hang when block layer queue is being frozen.
Install [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Install [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Install [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Install [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Installing [get3rovj] Enablement for applying custom alternative instructions.
Installing [opm180mz] Improved enablement update for applying custom alternatives instructions.
Installing [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Installing [hze6qrtf] Known exploit detection.
Installing [14i2g9lr] Known exploit detection for CVE-2017-7308.
Installing [g7z90bgg] Known exploit detection for CVE-2018-14634.
Installing [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Installing [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Installing [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Installing [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Installing [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Installing [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Installing [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Installing [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Installing [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Installing [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Installing [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Installing [iqwlh0ca] Kernel crash during late microcode updates.
Installing [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Installing [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Installing [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Installing [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Installing [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Installing [iooyacxu] Incorrect return value during CPU microcode updates.
Installing [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Installing [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Installing [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Installing [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Installing [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Installing [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Installing [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Installing [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Installing [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Installing [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Installing [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Installing [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Installing [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Installing [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Installing [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Installing [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Installing [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Installing [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Installing [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Installing [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Installing [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Installing [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Installing [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Installing [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Installing [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Installing [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Installing [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Installing [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Installing [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Installing [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Installing [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Installing [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Installing [lqn7ais6] Network TUN device creation failure with formatted names.
Installing [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Installing [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Installing [cx570frs] Use-after-free in Xen network backend receive path.
Installing [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Installing [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Installing [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Installing [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Installing [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Installing [jwfdgahz] Denial-of-service when receiving segments over TCP.
Installing [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Installing [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Installing [279lqcvw] Performance regression during microcode loading.
Installing [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Installing [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Installing [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Installing [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Installing [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Installing [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Installing [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Installing [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Installing [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Installing [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Installing [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Installing [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Installing [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Installing [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Installing [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Installing [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Installing [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Installing [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Installing [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Installing [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Installing [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Installing [gx6br2uw] Infiniband connection hang after failure.
Installing [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Installing [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Installing [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Installing [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Installing [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Installing [ownop36l] Reduced throughput in loopback disk devices.
Installing [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Installing [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Installing [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Installing [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Installing [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Installing [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Installing [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Installing [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Installing [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Installing [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Installing [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Installing [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Installing [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Installing [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Installing [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Installing [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Installing [2us37bxn] Denial-of-service in XFS whiteout renames.
Installing [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Installing [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Installing [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Installing [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Installing [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Installing [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Installing [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Installing [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Installing [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Installing [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Installing [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Installing [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Installing [lirbb7tr] Kernel hang when block layer queue is being frozen.
Installing [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Installing [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Installing [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Installing [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Your kernel is fully up to date.
Effective kernel version is 4.1.12-124.39.2.el6uek
  Limpeza      : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2

Atualizados:
  uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0

Concluído!

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# uptime
 09:33:32 up 81 days,  6:11,  2 users,  load average: 0.61, 0.71, 0.63
 
===================================================================================================
 
[root@spcdexa0001-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.39.2.el6uek.x86_64

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.
[hze6qrtf] Known exploit detection.
[14i2g9lr] Known exploit detection for CVE-2017-7308.
[g7z90bgg] Known exploit detection for CVE-2018-14634.
[r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
[p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
[6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
[a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
[fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
[avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
[ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
[qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
[faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
[gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
[iqwlh0ca] Kernel crash during late microcode updates.
[of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
[8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
[5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
[iooyacxu] Incorrect return value during CPU microcode updates.
[fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
[oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
[103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
[pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
[7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
[5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
[2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
[lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
[8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
[rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
[sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
[1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
[hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
[rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
[tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
[jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
[btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
[aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
[ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
[clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
[lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
[euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
[59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
[nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
[dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
[299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
[lqn7ais6] Network TUN device creation failure with formatted names.
[opv9u4m1] SUNRPC failure during NFS secure unmounting.
[cx570frs] Use-after-free in Xen network backend receive path.
[badkrwqs] Kernel IO hang during directory entry cache shrinking.
[8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
[8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
[10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
[55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
[jwfdgahz] Denial-of-service when receiving segments over TCP.
[oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
[c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
[279lqcvw] Performance regression during microcode loading.
[sgf7btt8] NFSv4 state list corruption causes denial-of-service.
[tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
[r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
[rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
[ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
[727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
[lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
[ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
[5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
[cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
[8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
[8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
[pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
[ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
[5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
[1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
[a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
[36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
[tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
[a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
[gx6br2uw] Infiniband connection hang after failure.
[5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
[tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
[n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
[sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
[cfhej4sj] Kernel hang in block layer during CPU hotplug.
[ownop36l] Reduced throughput in loopback disk devices.
[get3rovj] Enablement for applying custom alternative instructions.
[1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
[4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
[psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
[opm180mz] Improved enablement update for applying custom alternatives instructions.
[6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
[htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
[2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
[qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
[aj4s64po] Memory allocation stall during direct compaction on large allocations.
[b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
[gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
[jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
[eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
[dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
[t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
[sfxy7gmd] Spectre v2 bypass with EIBRS support.
[t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
[1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
[9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
[1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
[kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
[6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
[lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
[16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
[cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
[enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
[mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
[5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[aaleh5w4] IO stall in the NVMe host driver on request timeout.
[2us37bxn] Denial-of-service in XFS whiteout renames.
[fr0udjqk] Failure to join multipath RDS/TCP cluster.
[duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
[bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
[46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
[85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
[1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
[leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
[4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
[acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
[anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
[aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
[4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
[lirbb7tr] Kernel hang when block layer queue is being frozen.
[m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
[fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
[ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
[h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.

Effective kernel version is 4.1.12-124.39.2.el6uek

===================================================================================================

[root@spcdexa0001-adm rpm_ksplice]# xm list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 15760     4     r----- 4570763.5
spcdexav0018-adm                             7 102403     8     -b---- 15367335.3
spcdexav0022-adm                            10 153603    10     r----- 2858838.2
spcdexav0036-adm                             8 61443     4     ------ 5766646.3
spcdexavbi0001-adm.spo.supcd                 4 409603    40     r----- 117504652.2
spcdexavbi0006-adm                           9 102403    12     r----- 14333457.5

===================================================================================================
===================================================================================================
=================================== DB NODE spcdexa0002-adm =======================================
===================================================================================================
===================================================================================================

[root@spcdexa0002-adm ~]# cd /rpm_ksplice/

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# hostname
spcdexa0002-adm.spo.supcd

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# date
Dom Jun  7 09:36:34 -03 2020

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# uptime
 09:36:36 up 81 days,  7:09,  3 users,  load average: 0.57, 0.55, 0.53
 
=================================================================================================== 

[root@spcdexa0002-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.26.5.el6uek.x86_64

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.

Effective kernel version is 4.1.12-124.26.5.el6uek

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# yum list installed | grep 'exadata-sun.*computenode-exact'
exadata-sun-ovs-computenode-exact.noarch

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# yum erase exadata-sun-ovs-computenode-exact.noarch
Configurando o processo de remoção
Resolvendo dependências
--> Executando verificação da transação
---> Package exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1 will be removido
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                  Arq.         Versão                    Repo                                           Tam.
====================================================================================================================================
Removendo:
 exadata-sun-ovs-computenode-exact       noarch       19.2.1.0.0.190510-1       @exadata_generated_150919004038/6Server       0.0

Resumo da transação
====================================================================================================================================
Remove        1 Package(s)

Tamanho depois de instalado: 0
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
Aviso: o RPMDB foi alterado de fora do yum.
** Found 1 pre-existing rpmdb problem(s), 'yum check' output follows:
exadata-sun-ovs-computenode-minimum-19.2.1.0.0.190510-1.noarch tem exigências faltando do exadata-oswatcher >= ('0', '19.2.1.0.0.190510', '1')
  Apagando     : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1
  Verifying    : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1

Removido(s):
  exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1

Concluído!

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# yum install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
aviso: rpmts_HdrFromFdno: Cabeçalho V3 RSA/SHA256 Signature, key ID ec551f03: NOKEY


A chave pública para o uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm não está instalada

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# yum --nogpgcheck install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
  Atualizando  : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
The following steps will be taken:
Install [get3rovj] Enablement for applying custom alternative instructions.
Install [opm180mz] Improved enablement update for applying custom alternatives instructions.
Install [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Install [hze6qrtf] Known exploit detection.
Install [14i2g9lr] Known exploit detection for CVE-2017-7308.
Install [g7z90bgg] Known exploit detection for CVE-2018-14634.
Install [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Install [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Install [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Install [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Install [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Install [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Install [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Install [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Install [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Install [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Install [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Install [iqwlh0ca] Kernel crash during late microcode updates.
Install [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Install [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Install [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Install [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Install [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Install [iooyacxu] Incorrect return value during CPU microcode updates.
Install [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Install [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Install [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Install [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Install [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Install [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Install [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Install [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Install [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Install [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Install [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Install [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Install [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Install [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Install [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Install [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Install [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Install [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Install [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Install [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Install [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Install [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Install [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Install [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Install [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Install [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Install [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Install [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Install [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Install [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Install [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Install [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Install [lqn7ais6] Network TUN device creation failure with formatted names.
Install [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Install [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Install [cx570frs] Use-after-free in Xen network backend receive path.
Install [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Install [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Install [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Install [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Install [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Install [jwfdgahz] Denial-of-service when receiving segments over TCP.
Install [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Install [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Install [279lqcvw] Performance regression during microcode loading.
Install [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Install [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Install [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Install [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Install [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Install [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Install [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Install [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Install [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Install [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Install [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Install [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Install [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Install [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Install [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Install [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Install [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Install [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Install [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Install [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Install [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Install [gx6br2uw] Infiniband connection hang after failure.
Install [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Install [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Install [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Install [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Install [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Install [ownop36l] Reduced throughput in loopback disk devices.
Install [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Install [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Install [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Install [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Install [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Install [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Install [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Install [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Install [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Install [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Install [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Install [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Install [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Install [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Install [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Install [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Install [2us37bxn] Denial-of-service in XFS whiteout renames.
Install [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Install [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Install [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Install [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Install [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Install [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Install [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Install [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Install [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Install [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Install [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Install [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Install [lirbb7tr] Kernel hang when block layer queue is being frozen.
Install [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Install [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Install [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Install [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Installing [get3rovj] Enablement for applying custom alternative instructions.
Installing [opm180mz] Improved enablement update for applying custom alternatives instructions.
Installing [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Installing [hze6qrtf] Known exploit detection.
Installing [14i2g9lr] Known exploit detection for CVE-2017-7308.
Installing [g7z90bgg] Known exploit detection for CVE-2018-14634.
Installing [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Installing [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Installing [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Installing [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Installing [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Installing [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Installing [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Installing [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Installing [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Installing [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Installing [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Installing [iqwlh0ca] Kernel crash during late microcode updates.
Installing [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Installing [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Installing [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Installing [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Installing [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Installing [iooyacxu] Incorrect return value during CPU microcode updates.
Installing [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Installing [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Installing [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Installing [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Installing [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Installing [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Installing [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Installing [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Installing [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Installing [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Installing [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Installing [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Installing [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Installing [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Installing [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Installing [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Installing [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Installing [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Installing [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Installing [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Installing [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Installing [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Installing [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Installing [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Installing [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Installing [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Installing [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Installing [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Installing [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Installing [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Installing [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Installing [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Installing [lqn7ais6] Network TUN device creation failure with formatted names.
Installing [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Installing [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Installing [cx570frs] Use-after-free in Xen network backend receive path.
Installing [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Installing [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Installing [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Installing [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Installing [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Installing [jwfdgahz] Denial-of-service when receiving segments over TCP.
Installing [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Installing [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Installing [279lqcvw] Performance regression during microcode loading.
Installing [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Installing [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Installing [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Installing [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Installing [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Installing [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Installing [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Installing [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Installing [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Installing [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Installing [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Installing [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Installing [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Installing [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Installing [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Installing [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Installing [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Installing [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Installing [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Installing [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Installing [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Installing [gx6br2uw] Infiniband connection hang after failure.
Installing [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Installing [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Installing [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Installing [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Installing [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Installing [ownop36l] Reduced throughput in loopback disk devices.
Installing [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Installing [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Installing [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Installing [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Installing [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Installing [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Installing [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Installing [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Installing [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Installing [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Installing [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Installing [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Installing [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Installing [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Installing [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Installing [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Installing [2us37bxn] Denial-of-service in XFS whiteout renames.
Installing [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Installing [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Installing [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Installing [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Installing [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Installing [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Installing [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Installing [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Installing [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Installing [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Installing [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Installing [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Installing [lirbb7tr] Kernel hang when block layer queue is being frozen.
Installing [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Installing [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Installing [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Installing [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Your kernel is fully up to date.
Effective kernel version is 4.1.12-124.39.2.el6uek
  Limpeza      : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2

Atualizados:
  uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0

Concluído!

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.39.2.el6uek.x86_64

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.
[hze6qrtf] Known exploit detection.
[14i2g9lr] Known exploit detection for CVE-2017-7308.
[g7z90bgg] Known exploit detection for CVE-2018-14634.
[r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
[p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
[6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
[a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
[fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
[avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
[ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
[qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
[faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
[gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
[iqwlh0ca] Kernel crash during late microcode updates.
[of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
[8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
[5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
[iooyacxu] Incorrect return value during CPU microcode updates.
[fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
[oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
[103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
[pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
[7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
[5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
[2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
[lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
[8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
[rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
[sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
[1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
[hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
[rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
[tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
[jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
[btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
[aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
[ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
[clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
[lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
[euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
[59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
[nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
[dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
[299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
[lqn7ais6] Network TUN device creation failure with formatted names.
[opv9u4m1] SUNRPC failure during NFS secure unmounting.
[cx570frs] Use-after-free in Xen network backend receive path.
[badkrwqs] Kernel IO hang during directory entry cache shrinking.
[8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
[8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
[10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
[55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
[jwfdgahz] Denial-of-service when receiving segments over TCP.
[oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
[c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
[279lqcvw] Performance regression during microcode loading.
[sgf7btt8] NFSv4 state list corruption causes denial-of-service.
[tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
[r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
[rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
[ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
[727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
[lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
[ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
[5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
[cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
[8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
[8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
[pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
[ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
[5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
[1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
[a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
[36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
[tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
[a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
[gx6br2uw] Infiniband connection hang after failure.
[5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
[tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
[n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
[sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
[cfhej4sj] Kernel hang in block layer during CPU hotplug.
[ownop36l] Reduced throughput in loopback disk devices.
[get3rovj] Enablement for applying custom alternative instructions.
[1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
[4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
[psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
[opm180mz] Improved enablement update for applying custom alternatives instructions.
[6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
[htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
[2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
[qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
[aj4s64po] Memory allocation stall during direct compaction on large allocations.
[b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
[gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
[jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
[eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
[dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
[t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
[sfxy7gmd] Spectre v2 bypass with EIBRS support.
[t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
[1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
[9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
[1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
[kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
[6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
[lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
[16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
[cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
[enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
[mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
[5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[aaleh5w4] IO stall in the NVMe host driver on request timeout.
[2us37bxn] Denial-of-service in XFS whiteout renames.
[fr0udjqk] Failure to join multipath RDS/TCP cluster.
[duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
[bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
[46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
[85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
[1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
[leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
[4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
[acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
[anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
[aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
[4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
[lirbb7tr] Kernel hang when block layer queue is being frozen.
[m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
[fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
[ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
[h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.

Effective kernel version is 4.1.12-124.39.2.el6uek

===================================================================================================

[root@spcdexa0002-adm rpm_ksplice]# xm list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 15769     4     r----- 4458833.1
spcdexav0002-adm                             7 102403     4     r----- 8515929.3
spcdexav0019-adm                             9 102403     8     r----- 14030853.3
spcdexav0023-adm                             3 153603    10     r----- 21338754.2
spcdexav0028-adm                             4 51203     6     rb---- 5655833.1
spcdexavbi0002-adm.spo.supcd                 5 409603    40     r----- 114763081.3

===================================================================================================
===================================================================================================
=================================== DB NODE spcdexa0003-adm =======================================
===================================================================================================
===================================================================================================

[root@spcdexa0003-adm ~]# cd /rpm_ksplice/

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# hostname
spcdexa0003-adm.spo.supcd

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# uptime
 09:45:17 up 81 days,  6:43,  4 users,  load average: 1.17, 0.74, 0.62

=================================================================================================== 
 
[root@spcdexa0003-adm rpm_ksplice]# date
Dom Jun  7 09:45:19 -03 2020

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.26.5.el6uek.x86_64

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# yum list installed | grep 'exadata-sun.*computenode-exact'
exadata-sun-ovs-computenode-exact.noarch

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# yum erase exadata-sun-ovs-computenode-exact.noarch
Configurando o processo de remoção
Resolvendo dependências
--> Executando verificação da transação
---> Package exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1 will be removido
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                  Arq.         Versão                    Repo                                           Tam.
====================================================================================================================================
Removendo:
 exadata-sun-ovs-computenode-exact       noarch       19.2.1.0.0.190510-1       @exadata_generated_140919003809/6Server       0.0

Resumo da transação
====================================================================================================================================
Remove        1 Package(s)

Tamanho depois de instalado: 0
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
Aviso: o RPMDB foi alterado de fora do yum.
** Found 1 pre-existing rpmdb problem(s), 'yum check' output follows:
exadata-sun-ovs-computenode-minimum-19.2.1.0.0.190510-1.noarch tem exigências faltando do exadata-oswatcher >= ('0', '19.2.1.0.0.190510', '1')
  Apagando     : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1
  Verifying    : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1

Removido(s):
  exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1

Concluído!

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.

Effective kernel version is 4.1.12-124.26.5.el6uek

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# yum --nogpgcheck install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
  Atualizando  : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
The following steps will be taken:
Install [get3rovj] Enablement for applying custom alternative instructions.
Install [opm180mz] Improved enablement update for applying custom alternatives instructions.
Install [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Install [hze6qrtf] Known exploit detection.
Install [14i2g9lr] Known exploit detection for CVE-2017-7308.
Install [g7z90bgg] Known exploit detection for CVE-2018-14634.
Install [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Install [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Install [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Install [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Install [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Install [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Install [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Install [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Install [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Install [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Install [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Install [iqwlh0ca] Kernel crash during late microcode updates.
Install [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Install [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Install [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Install [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Install [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Install [iooyacxu] Incorrect return value during CPU microcode updates.
Install [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Install [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Install [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Install [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Install [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Install [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Install [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Install [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Install [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Install [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Install [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Install [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Install [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Install [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Install [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Install [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Install [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Install [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Install [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Install [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Install [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Install [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Install [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Install [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Install [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Install [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Install [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Install [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Install [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Install [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Install [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Install [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Install [lqn7ais6] Network TUN device creation failure with formatted names.
Install [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Install [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Install [cx570frs] Use-after-free in Xen network backend receive path.
Install [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Install [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Install [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Install [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Install [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Install [jwfdgahz] Denial-of-service when receiving segments over TCP.
Install [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Install [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Install [279lqcvw] Performance regression during microcode loading.
Install [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Install [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Install [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Install [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Install [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Install [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Install [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Install [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Install [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Install [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Install [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Install [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Install [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Install [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Install [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Install [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Install [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Install [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Install [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Install [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Install [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Install [gx6br2uw] Infiniband connection hang after failure.
Install [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Install [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Install [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Install [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Install [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Install [ownop36l] Reduced throughput in loopback disk devices.
Install [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Install [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Install [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Install [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Install [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Install [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Install [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Install [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Install [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Install [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Install [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Install [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Install [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Install [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Install [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Install [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Install [2us37bxn] Denial-of-service in XFS whiteout renames.
Install [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Install [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Install [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Install [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Install [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Install [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Install [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Install [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Install [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Install [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Install [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Install [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Install [lirbb7tr] Kernel hang when block layer queue is being frozen.
Install [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Install [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Install [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Install [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Installing [get3rovj] Enablement for applying custom alternative instructions.
Installing [opm180mz] Improved enablement update for applying custom alternatives instructions.
Installing [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Installing [hze6qrtf] Known exploit detection.
Installing [14i2g9lr] Known exploit detection for CVE-2017-7308.
Installing [g7z90bgg] Known exploit detection for CVE-2018-14634.
Installing [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Installing [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Installing [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Installing [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Installing [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Installing [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Installing [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Installing [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Installing [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Installing [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Installing [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Installing [iqwlh0ca] Kernel crash during late microcode updates.
Installing [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Installing [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Installing [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Installing [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Installing [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Installing [iooyacxu] Incorrect return value during CPU microcode updates.
Installing [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Installing [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Installing [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Installing [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Installing [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Installing [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Installing [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Installing [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Installing [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Installing [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Installing [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Installing [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Installing [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Installing [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Installing [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Installing [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Installing [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Installing [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Installing [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Installing [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Installing [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Installing [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Installing [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Installing [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Installing [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Installing [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Installing [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Installing [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Installing [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Installing [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Installing [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Installing [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Installing [lqn7ais6] Network TUN device creation failure with formatted names.
Installing [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Installing [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Installing [cx570frs] Use-after-free in Xen network backend receive path.
Installing [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Installing [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Installing [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Installing [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Installing [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Installing [jwfdgahz] Denial-of-service when receiving segments over TCP.
Installing [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Installing [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Installing [279lqcvw] Performance regression during microcode loading.
Installing [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Installing [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Installing [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Installing [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Installing [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Installing [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Installing [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Installing [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Installing [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Installing [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Installing [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Installing [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Installing [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Installing [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Installing [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Installing [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Installing [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Installing [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Installing [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Installing [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Installing [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Installing [gx6br2uw] Infiniband connection hang after failure.
Installing [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Installing [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Installing [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Installing [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Installing [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Installing [ownop36l] Reduced throughput in loopback disk devices.
Installing [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Installing [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Installing [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Installing [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Installing [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Installing [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Installing [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Installing [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Installing [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Installing [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Installing [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Installing [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Installing [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Installing [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Installing [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Installing [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Installing [2us37bxn] Denial-of-service in XFS whiteout renames.
Installing [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Installing [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Installing [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Installing [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Installing [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Installing [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Installing [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Installing [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Installing [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Installing [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Installing [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Installing [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Installing [lirbb7tr] Kernel hang when block layer queue is being frozen.
Installing [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Installing [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Installing [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Installing [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Your kernel is fully up to date.
Effective kernel version is 4.1.12-124.39.2.el6uek
  Limpeza      : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2

Atualizados:
  uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0

Concluído!

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.39.2.el6uek.x86_64

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.
[hze6qrtf] Known exploit detection.
[14i2g9lr] Known exploit detection for CVE-2017-7308.
[g7z90bgg] Known exploit detection for CVE-2018-14634.
[r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
[p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
[6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
[a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
[fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
[avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
[ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
[qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
[faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
[gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
[iqwlh0ca] Kernel crash during late microcode updates.
[of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
[8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
[5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
[iooyacxu] Incorrect return value during CPU microcode updates.
[fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
[oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
[103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
[pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
[7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
[5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
[2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
[lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
[8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
[rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
[sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
[1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
[hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
[rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
[tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
[jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
[btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
[aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
[ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
[clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
[lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
[euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
[59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
[nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
[dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
[299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
[lqn7ais6] Network TUN device creation failure with formatted names.
[opv9u4m1] SUNRPC failure during NFS secure unmounting.
[cx570frs] Use-after-free in Xen network backend receive path.
[badkrwqs] Kernel IO hang during directory entry cache shrinking.
[8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
[8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
[10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
[55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
[jwfdgahz] Denial-of-service when receiving segments over TCP.
[oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
[c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
[279lqcvw] Performance regression during microcode loading.
[sgf7btt8] NFSv4 state list corruption causes denial-of-service.
[tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
[r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
[rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
[ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
[727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
[lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
[ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
[5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
[cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
[8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
[8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
[pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
[ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
[5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
[1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
[a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
[36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
[tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
[a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
[gx6br2uw] Infiniband connection hang after failure.
[5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
[tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
[n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
[sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
[cfhej4sj] Kernel hang in block layer during CPU hotplug.
[ownop36l] Reduced throughput in loopback disk devices.
[get3rovj] Enablement for applying custom alternative instructions.
[1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
[4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
[psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
[opm180mz] Improved enablement update for applying custom alternatives instructions.
[6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
[htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
[2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
[qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
[aj4s64po] Memory allocation stall during direct compaction on large allocations.
[b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
[gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
[jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
[eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
[dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
[t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
[sfxy7gmd] Spectre v2 bypass with EIBRS support.
[t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
[1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
[9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
[1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
[kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
[6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
[lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
[16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
[cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
[enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
[mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
[5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[aaleh5w4] IO stall in the NVMe host driver on request timeout.
[2us37bxn] Denial-of-service in XFS whiteout renames.
[fr0udjqk] Failure to join multipath RDS/TCP cluster.
[duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
[bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
[46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
[85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
[1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
[leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
[4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
[acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
[anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
[aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
[4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
[lirbb7tr] Kernel hang when block layer queue is being frozen.
[m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
[fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
[ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
[h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.

Effective kernel version is 4.1.12-124.39.2.el6uek

===================================================================================================

[root@spcdexa0003-adm rpm_ksplice]# xm list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 15904     4     r----- 4151546.2
spcdexav0012-adm                             7 307203    28     r----- 59220367.9
spcdexav0020-adm                            10 51203     2     rb---- 5143556.5
spcdexav0024-adm                             8 61443     2     r----- 5237531.8
spcdexav0035-adm                             9 86019     4     r----- 3746748.1
spcdexavbi0003-adm.spo.supcd                 5 409603    40     r----- 118094008.0

===================================================================================================
===================================================================================================
=================================== DB NODE spcdexa0004-adm =======================================
===================================================================================================
===================================================================================================

[root@spcdexa0004-adm ~]# cd /rpm_ksplice/

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# hostname
spcdexa0004-adm.spo.supcd

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# uptime
 09:53:16 up 81 days,  8:02,  3 users,  load average: 0.88, 0.59, 0.48
 
===================================================================================================
 
[root@spcdexa0004-adm rpm_ksplice]# date
Dom Jun  7 09:53:18 -03 2020

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.26.5.el6uek.x86_64

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.

Effective kernel version is 4.1.12-124.26.5.el6uek

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# yum list installed | grep 'exadata-sun.*computenode-exact'
exadata-sun-ovs-computenode-exact.noarch

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# yum erase exadata-sun-ovs-computenode-exact.noarch
Configurando o processo de remoção
Resolvendo dependências
--> Executando verificação da transação
---> Package exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1 will be removido
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                  Arq.         Versão                    Repo                                           Tam.
====================================================================================================================================
Removendo:
 exadata-sun-ovs-computenode-exact       noarch       19.2.1.0.0.190510-1       @exadata_generated_140919141051/6Server       0.0

Resumo da transação
====================================================================================================================================
Remove        1 Package(s)

Tamanho depois de instalado: 0
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
Aviso: o RPMDB foi alterado de fora do yum.
** Found 1 pre-existing rpmdb problem(s), 'yum check' output follows:
exadata-sun-ovs-computenode-minimum-19.2.1.0.0.190510-1.noarch tem exigências faltando do exadata-oswatcher >= ('0', '19.2.1.0.0.190510', '1')
  Apagando     : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1
  Verifying    : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1

Removido(s):
  exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1

Concluído!

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# yum --nogpgcheck install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
  Atualizando  : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
The following steps will be taken:
Install [get3rovj] Enablement for applying custom alternative instructions.
Install [opm180mz] Improved enablement update for applying custom alternatives instructions.
Install [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Install [hze6qrtf] Known exploit detection.
Install [14i2g9lr] Known exploit detection for CVE-2017-7308.
Install [g7z90bgg] Known exploit detection for CVE-2018-14634.
Install [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Install [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Install [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Install [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Install [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Install [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Install [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Install [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Install [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Install [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Install [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Install [iqwlh0ca] Kernel crash during late microcode updates.
Install [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Install [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Install [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Install [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Install [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Install [iooyacxu] Incorrect return value during CPU microcode updates.
Install [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Install [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Install [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Install [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Install [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Install [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Install [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Install [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Install [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Install [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Install [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Install [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Install [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Install [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Install [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Install [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Install [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Install [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Install [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Install [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Install [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Install [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Install [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Install [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Install [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Install [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Install [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Install [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Install [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Install [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Install [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Install [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Install [lqn7ais6] Network TUN device creation failure with formatted names.
Install [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Install [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Install [cx570frs] Use-after-free in Xen network backend receive path.
Install [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Install [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Install [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Install [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Install [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Install [jwfdgahz] Denial-of-service when receiving segments over TCP.
Install [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Install [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Install [279lqcvw] Performance regression during microcode loading.
Install [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Install [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Install [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Install [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Install [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Install [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Install [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Install [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Install [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Install [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Install [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Install [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Install [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Install [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Install [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Install [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Install [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Install [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Install [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Install [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Install [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Install [gx6br2uw] Infiniband connection hang after failure.
Install [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Install [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Install [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Install [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Install [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Install [ownop36l] Reduced throughput in loopback disk devices.
Install [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Install [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Install [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Install [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Install [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Install [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Install [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Install [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Install [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Install [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Install [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Install [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Install [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Install [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Install [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Install [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Install [2us37bxn] Denial-of-service in XFS whiteout renames.
Install [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Install [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Install [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Install [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Install [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Install [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Install [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Install [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Install [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Install [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Install [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Install [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Install [lirbb7tr] Kernel hang when block layer queue is being frozen.
Install [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Install [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Install [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Install [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Installing [get3rovj] Enablement for applying custom alternative instructions.
Installing [opm180mz] Improved enablement update for applying custom alternatives instructions.
Installing [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Installing [hze6qrtf] Known exploit detection.
Installing [14i2g9lr] Known exploit detection for CVE-2017-7308.
Installing [g7z90bgg] Known exploit detection for CVE-2018-14634.
Installing [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Installing [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Installing [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Installing [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Installing [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Installing [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Installing [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Installing [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Installing [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Installing [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Installing [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Installing [iqwlh0ca] Kernel crash during late microcode updates.
Installing [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Installing [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Installing [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Installing [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Installing [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Installing [iooyacxu] Incorrect return value during CPU microcode updates.
Installing [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Installing [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Installing [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Installing [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Installing [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Installing [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Installing [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Installing [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Installing [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Installing [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Installing [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Installing [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Installing [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Installing [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Installing [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Installing [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Installing [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Installing [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Installing [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Installing [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Installing [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Installing [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Installing [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Installing [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Installing [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Installing [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Installing [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Installing [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Installing [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Installing [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Installing [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Installing [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Installing [lqn7ais6] Network TUN device creation failure with formatted names.
Installing [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Installing [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Installing [cx570frs] Use-after-free in Xen network backend receive path.
Installing [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Installing [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Installing [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Installing [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Installing [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Installing [jwfdgahz] Denial-of-service when receiving segments over TCP.
Installing [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Installing [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Installing [279lqcvw] Performance regression during microcode loading.
Installing [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Installing [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Installing [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Installing [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Installing [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Installing [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Installing [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Installing [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Installing [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Installing [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Installing [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Installing [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Installing [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Installing [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Installing [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Installing [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Installing [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Installing [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Installing [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Installing [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Installing [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Installing [gx6br2uw] Infiniband connection hang after failure.
Installing [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Installing [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Installing [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Installing [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Installing [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Installing [ownop36l] Reduced throughput in loopback disk devices.
Installing [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Installing [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Installing [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Installing [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Installing [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Installing [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Installing [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Installing [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Installing [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Installing [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Installing [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Installing [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Installing [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Installing [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Installing [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Installing [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Installing [2us37bxn] Denial-of-service in XFS whiteout renames.
Installing [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Installing [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Installing [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Installing [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Installing [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Installing [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Installing [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Installing [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Installing [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Installing [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Installing [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Installing [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Installing [lirbb7tr] Kernel hang when block layer queue is being frozen.
Installing [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Installing [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Installing [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Installing [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Your kernel is fully up to date.
Effective kernel version is 4.1.12-124.39.2.el6uek
  Limpeza      : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2

Atualizados:
  uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0

Concluído!

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.39.2.el6uek.x86_64

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.
[hze6qrtf] Known exploit detection.
[14i2g9lr] Known exploit detection for CVE-2017-7308.
[g7z90bgg] Known exploit detection for CVE-2018-14634.
[r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
[p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
[6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
[a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
[fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
[avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
[ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
[qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
[faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
[gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
[iqwlh0ca] Kernel crash during late microcode updates.
[of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
[8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
[5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
[iooyacxu] Incorrect return value during CPU microcode updates.
[fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
[oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
[103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
[pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
[7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
[5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
[2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
[lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
[8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
[rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
[sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
[1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
[hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
[rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
[tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
[jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
[btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
[aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
[ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
[clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
[lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
[euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
[59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
[nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
[dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
[299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
[lqn7ais6] Network TUN device creation failure with formatted names.
[opv9u4m1] SUNRPC failure during NFS secure unmounting.
[cx570frs] Use-after-free in Xen network backend receive path.
[badkrwqs] Kernel IO hang during directory entry cache shrinking.
[8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
[8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
[10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
[55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
[jwfdgahz] Denial-of-service when receiving segments over TCP.
[oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
[c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
[279lqcvw] Performance regression during microcode loading.
[sgf7btt8] NFSv4 state list corruption causes denial-of-service.
[tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
[r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
[rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
[ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
[727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
[lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
[ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
[5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
[cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
[8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
[8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
[pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
[ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
[5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
[1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
[a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
[36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
[tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
[a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
[gx6br2uw] Infiniband connection hang after failure.
[5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
[tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
[n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
[sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
[cfhej4sj] Kernel hang in block layer during CPU hotplug.
[ownop36l] Reduced throughput in loopback disk devices.
[get3rovj] Enablement for applying custom alternative instructions.
[1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
[4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
[psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
[opm180mz] Improved enablement update for applying custom alternatives instructions.
[6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
[htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
[2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
[qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
[aj4s64po] Memory allocation stall during direct compaction on large allocations.
[b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
[gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
[jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
[eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
[dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
[t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
[sfxy7gmd] Spectre v2 bypass with EIBRS support.
[t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
[1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
[9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
[1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
[kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
[6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
[lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
[16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
[cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
[enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
[mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
[5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[aaleh5w4] IO stall in the NVMe host driver on request timeout.
[2us37bxn] Denial-of-service in XFS whiteout renames.
[fr0udjqk] Failure to join multipath RDS/TCP cluster.
[duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
[bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
[46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
[85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
[1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
[leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
[4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
[acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
[anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
[aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
[4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
[lirbb7tr] Kernel hang when block layer queue is being frozen.
[m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
[fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
[ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
[h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.

Effective kernel version is 4.1.12-124.39.2.el6uek

===================================================================================================

[root@spcdexa0004-adm rpm_ksplice]# xm list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 15936     4     r----- 3529039.1
spcdexav0013-adm                             6 307203    28     r----- 53247810.0
spcdexav0015-adm                             8 153203    12     r----- 7023312.6
spcdexav0031-adm                             9 71683     4     -b---- 4998556.3
spcdexav0044-adm.spo.supcd                   7 122883    20     -b---- 2182748.0

===================================================================================================
===================================================================================================
=================================== DB NODE spcdexa0005-adm =======================================
===================================================================================================
===================================================================================================

[root@spcdexa0005-adm ~]# cd /rpm_ksplice/

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# hostname
spcdexa0005-adm.spo.supcd

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# date
Dom Jun  7 10:01:04 -03 2020

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.26.5.el6uek.x86_64

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.

Effective kernel version is 4.1.12-124.26.5.el6uek

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# yum list installed | grep 'exadata-sun.*computenode-exact'
exadata-sun-ovs-computenode-exact.noarch

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# yum erase exadata-sun-ovs-computenode-exact.noarch
Configurando o processo de remoção
Resolvendo dependências
--> Executando verificação da transação
---> Package exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1 will be removido
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                  Arq.         Versão                    Repo                                           Tam.
====================================================================================================================================
Removendo:
 exadata-sun-ovs-computenode-exact       noarch       19.2.1.0.0.190510-1       @exadata_generated_070919171452/6Server       0.0

Resumo da transação
====================================================================================================================================
Remove        1 Package(s)

Tamanho depois de instalado: 0
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
Aviso: o RPMDB foi alterado de fora do yum.
  Apagando     : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1
  Verifying    : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1

Removido(s):
  exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1

Concluído!

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# yum --nogpgcheck install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
  Atualizando  : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
The following steps will be taken:
Install [get3rovj] Enablement for applying custom alternative instructions.
Install [opm180mz] Improved enablement update for applying custom alternatives instructions.
Install [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Install [hze6qrtf] Known exploit detection.
Install [14i2g9lr] Known exploit detection for CVE-2017-7308.
Install [g7z90bgg] Known exploit detection for CVE-2018-14634.
Install [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Install [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Install [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Install [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Install [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Install [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Install [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Install [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Install [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Install [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Install [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Install [iqwlh0ca] Kernel crash during late microcode updates.
Install [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Install [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Install [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Install [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Install [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Install [iooyacxu] Incorrect return value during CPU microcode updates.
Install [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Install [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Install [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Install [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Install [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Install [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Install [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Install [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Install [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Install [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Install [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Install [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Install [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Install [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Install [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Install [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Install [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Install [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Install [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Install [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Install [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Install [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Install [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Install [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Install [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Install [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Install [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Install [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Install [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Install [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Install [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Install [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Install [lqn7ais6] Network TUN device creation failure with formatted names.
Install [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Install [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Install [cx570frs] Use-after-free in Xen network backend receive path.
Install [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Install [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Install [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Install [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Install [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Install [jwfdgahz] Denial-of-service when receiving segments over TCP.
Install [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Install [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Install [279lqcvw] Performance regression during microcode loading.
Install [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Install [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Install [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Install [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Install [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Install [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Install [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Install [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Install [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Install [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Install [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Install [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Install [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Install [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Install [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Install [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Install [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Install [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Install [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Install [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Install [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Install [gx6br2uw] Infiniband connection hang after failure.
Install [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Install [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Install [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Install [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Install [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Install [ownop36l] Reduced throughput in loopback disk devices.
Install [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Install [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Install [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Install [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Install [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Install [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Install [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Install [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Install [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Install [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Install [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Install [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Install [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Install [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Install [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Install [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Install [2us37bxn] Denial-of-service in XFS whiteout renames.
Install [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Install [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Install [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Install [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Install [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Install [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Install [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Install [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Install [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Install [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Install [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Install [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Install [lirbb7tr] Kernel hang when block layer queue is being frozen.
Install [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Install [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Install [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Install [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Installing [get3rovj] Enablement for applying custom alternative instructions.
Installing [opm180mz] Improved enablement update for applying custom alternatives instructions.
Installing [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Installing [hze6qrtf] Known exploit detection.
Installing [14i2g9lr] Known exploit detection for CVE-2017-7308.
Installing [g7z90bgg] Known exploit detection for CVE-2018-14634.
Installing [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Installing [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Installing [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Installing [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Installing [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Installing [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Installing [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Installing [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Installing [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Installing [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Installing [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Installing [iqwlh0ca] Kernel crash during late microcode updates.
Installing [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Installing [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Installing [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Installing [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Installing [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Installing [iooyacxu] Incorrect return value during CPU microcode updates.
Installing [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Installing [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Installing [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Installing [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Installing [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Installing [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Installing [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Installing [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Installing [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Installing [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Installing [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Installing [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Installing [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Installing [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Installing [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Installing [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Installing [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Installing [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Installing [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Installing [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Installing [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Installing [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Installing [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Installing [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Installing [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Installing [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Installing [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Installing [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Installing [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Installing [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Installing [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Installing [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Installing [lqn7ais6] Network TUN device creation failure with formatted names.
Installing [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Installing [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Installing [cx570frs] Use-after-free in Xen network backend receive path.
Installing [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Installing [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Installing [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Installing [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Installing [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Installing [jwfdgahz] Denial-of-service when receiving segments over TCP.
Installing [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Installing [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Installing [279lqcvw] Performance regression during microcode loading.
Installing [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Installing [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Installing [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Installing [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Installing [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Installing [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Installing [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Installing [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Installing [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Installing [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Installing [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Installing [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Installing [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Installing [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Installing [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Installing [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Installing [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Installing [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Installing [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Installing [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Installing [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Installing [gx6br2uw] Infiniband connection hang after failure.
Installing [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Installing [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Installing [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Installing [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Installing [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Installing [ownop36l] Reduced throughput in loopback disk devices.
Installing [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Installing [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Installing [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Installing [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Installing [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Installing [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Installing [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Installing [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Installing [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Installing [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Installing [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Installing [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Installing [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Installing [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Installing [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Installing [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Installing [2us37bxn] Denial-of-service in XFS whiteout renames.
Installing [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Installing [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Installing [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Installing [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Installing [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Installing [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Installing [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Installing [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Installing [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Installing [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Installing [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Installing [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Installing [lirbb7tr] Kernel hang when block layer queue is being frozen.
Installing [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Installing [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Installing [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Installing [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Your kernel is fully up to date.
Effective kernel version is 4.1.12-124.39.2.el6uek
  Limpeza      : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2

Atualizados:
  uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0

Concluído!

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.39.2.el6uek.x86_64

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.
[hze6qrtf] Known exploit detection.
[14i2g9lr] Known exploit detection for CVE-2017-7308.
[g7z90bgg] Known exploit detection for CVE-2018-14634.
[r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
[p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
[6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
[a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
[fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
[avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
[ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
[qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
[faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
[gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
[iqwlh0ca] Kernel crash during late microcode updates.
[of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
[8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
[5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
[iooyacxu] Incorrect return value during CPU microcode updates.
[fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
[oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
[103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
[pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
[7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
[5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
[2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
[lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
[8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
[rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
[sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
[1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
[hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
[rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
[tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
[jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
[btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
[aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
[ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
[clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
[lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
[euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
[59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
[nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
[dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
[299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
[lqn7ais6] Network TUN device creation failure with formatted names.
[opv9u4m1] SUNRPC failure during NFS secure unmounting.
[cx570frs] Use-after-free in Xen network backend receive path.
[badkrwqs] Kernel IO hang during directory entry cache shrinking.
[8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
[8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
[10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
[55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
[jwfdgahz] Denial-of-service when receiving segments over TCP.
[oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
[c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
[279lqcvw] Performance regression during microcode loading.
[sgf7btt8] NFSv4 state list corruption causes denial-of-service.
[tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
[r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
[rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
[ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
[727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
[lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
[ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
[5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
[cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
[8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
[8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
[pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
[ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
[5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
[1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
[a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
[36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
[tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
[a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
[gx6br2uw] Infiniband connection hang after failure.
[5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
[tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
[n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
[sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
[cfhej4sj] Kernel hang in block layer during CPU hotplug.
[ownop36l] Reduced throughput in loopback disk devices.
[get3rovj] Enablement for applying custom alternative instructions.
[1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
[4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
[psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
[opm180mz] Improved enablement update for applying custom alternatives instructions.
[6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
[htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
[2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
[qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
[aj4s64po] Memory allocation stall during direct compaction on large allocations.
[b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
[gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
[jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
[eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
[dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
[t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
[sfxy7gmd] Spectre v2 bypass with EIBRS support.
[t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
[1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
[9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
[1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
[kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
[6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
[lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
[16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
[cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
[enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
[mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
[5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[aaleh5w4] IO stall in the NVMe host driver on request timeout.
[2us37bxn] Denial-of-service in XFS whiteout renames.
[fr0udjqk] Failure to join multipath RDS/TCP cluster.
[duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
[bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
[46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
[85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
[1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
[leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
[4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
[acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
[anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
[aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
[4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
[lirbb7tr] Kernel hang when block layer queue is being frozen.
[m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
[fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
[ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
[h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.

Effective kernel version is 4.1.12-124.39.2.el6uek

===================================================================================================

[root@spcdexa0005-adm rpm_ksplice]# xm list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 15883     4     r----- 7048619.6
spcdexav0014-adm                             7 307203    28     r----- 53326031.2
spcdexav0016-adm                            10 153203    12     r----- 11589346.2
spcdexav0032-adm                            11 71683     4     -b---- 7528220.9
spcdexav0037-adm                             8 61443     2     -b---- 3987347.1
spcdexav0045-adm.spo.supcd                   9 122883    20     -b---- 3342627.0

===================================================================================================
===================================================================================================
=================================== DB NODE spcdexa0006-adm =======================================
===================================================================================================
===================================================================================================

[root@spcdexa0006-adm ~]# cd /rpm_ksplice/

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# uptime
 09:18:07 up 14:01,  4 users,  load average: 0.94, 0.85, 0.86
 
 ===================================================================================================
 
[root@spcdexa0006-adm rpm_ksplice]# hostname
spcdexa0006-adm.spo.supcd

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# cat /etc/oracle-release
Oracle VM server release 3.4.6

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.26.5.el6uek.x86_64

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.

Effective kernel version is 4.1.12-124.26.5.el6uek

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# yum list installed | grep 'exadata-sun.*computenode-exact'
exadata-sun-ovs-computenode-exact.noarch

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# yum erase exadata-sun-ovs-computenode-exact.noarch
Configurando o processo de remoção
Resolvendo dependências
--> Executando verificação da transação
---> Package exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1 will be removido
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                         Arq.                Versão                             Repo                    Tam.
====================================================================================================================================
Removendo:
 exadata-sun-ovs-computenode-exact              noarch              19.2.1.0.0.190510-1                installed              0.0

Resumo da transação
====================================================================================================================================
Remove        1 Package(s)

Tamanho depois de instalado: 0
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
  Apagando     : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1
  Verifying    : exadata-sun-ovs-computenode-exact-19.2.1.0.0.190510-1.noarch                                                   1/1

Removido(s):
  exadata-sun-ovs-computenode-exact.noarch 0:19.2.1.0.0.190510-1

Concluído!

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# pwd
/rpm_ksplice

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# ls
uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# yum install uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm
Configurando o processo de instalação
Examinando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm: uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch
Marcando uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch.rpm como uma atualização do uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch
Resolvendo dependências
--> Executando verificação da transação
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20190328-0 will be atualizado
---> Package uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0 will be an update
--> Resolução de dependências finalizada

Dependências resolvidas

====================================================================================================================================
 Pacote                                    Arq.   Versão     Repo                                                              Tam.
====================================================================================================================================
Atualizando:
 uptrack-updates-4.1.12-124.24.3.el6uek.x86_64
                                           noarch 20200529-0 /uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch  47 M

Resumo da transação
====================================================================================================================================
Upgrade       1 Package(s)

Tamanho total: 47 M
Correto? [s/N]:s
Baixando pacotes:
Executando o rpm_check_debug
Executando teste de transação
Teste de transação completo
Executando a transação
  Atualizando  : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
The following steps will be taken:
Install [get3rovj] Enablement for applying custom alternative instructions.
Install [opm180mz] Improved enablement update for applying custom alternatives instructions.
Install [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Install [hze6qrtf] Known exploit detection.
Install [14i2g9lr] Known exploit detection for CVE-2017-7308.
Install [g7z90bgg] Known exploit detection for CVE-2018-14634.
Install [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Install [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Install [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Install [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Install [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Install [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Install [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Install [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Install [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Install [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Install [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Install [iqwlh0ca] Kernel crash during late microcode updates.
Install [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Install [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Install [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Install [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Install [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Install [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Install [iooyacxu] Incorrect return value during CPU microcode updates.
Install [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Install [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Install [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Install [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Install [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Install [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Install [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Install [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Install [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Install [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Install [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Install [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Install [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Install [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Install [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Install [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Install [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Install [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Install [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Install [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Install [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Install [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Install [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Install [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Install [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Install [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Install [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Install [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Install [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Install [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Install [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Install [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Install [lqn7ais6] Network TUN device creation failure with formatted names.
Install [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Install [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Install [cx570frs] Use-after-free in Xen network backend receive path.
Install [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Install [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Install [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Install [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Install [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Install [jwfdgahz] Denial-of-service when receiving segments over TCP.
Install [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Install [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Install [279lqcvw] Performance regression during microcode loading.
Install [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Install [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Install [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Install [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Install [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Install [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Install [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Install [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Install [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Install [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Install [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Install [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Install [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Install [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Install [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Install [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Install [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Install [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Install [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Install [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Install [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Install [gx6br2uw] Infiniband connection hang after failure.
Install [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Install [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Install [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Install [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Install [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Install [ownop36l] Reduced throughput in loopback disk devices.
Install [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Install [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Install [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Install [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Install [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Install [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Install [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Install [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Install [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Install [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Install [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Install [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Install [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Install [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Install [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Install [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Install [2us37bxn] Denial-of-service in XFS whiteout renames.
Install [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Install [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Install [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Install [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Install [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Install [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Install [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Install [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Install [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Install [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Install [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Install [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Install [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Install [lirbb7tr] Kernel hang when block layer queue is being frozen.
Install [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Install [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Install [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Install [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Installing [get3rovj] Enablement for applying custom alternative instructions.
Installing [opm180mz] Improved enablement update for applying custom alternatives instructions.
Installing [htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
Installing [hze6qrtf] Known exploit detection.
Installing [14i2g9lr] Known exploit detection for CVE-2017-7308.
Installing [g7z90bgg] Known exploit detection for CVE-2018-14634.
Installing [r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
Installing [p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
Installing [6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
Installing [a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
Installing [fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
Installing [m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
Installing [avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
Installing [ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
Installing [qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
Installing [faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
Installing [gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
Installing [iqwlh0ca] Kernel crash during late microcode updates.
Installing [t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
Installing [33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
Installing [8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
Installing [5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
Installing [sfxy7gmd] Spectre v2 bypass with EIBRS support.
Installing [t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
Installing [iooyacxu] Incorrect return value during CPU microcode updates.
Installing [fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
Installing [oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
Installing [1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
Installing [9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
Installing [1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
Installing [103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
Installing [pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
Installing [7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
Installing [5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
Installing [2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
Installing [lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
Installing [h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
Installing [8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
Installing [rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
Installing [sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
Installing [1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
Installing [hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
Installing [kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
Installing [rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
Installing [tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
Installing [jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
Installing [btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
Installing [aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
Installing [ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
Installing [clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
Installing [lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
Installing [euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
Installing [59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
Installing [6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
Installing [nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
Installing [dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
Installing [299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
Installing [lqn7ais6] Network TUN device creation failure with formatted names.
Installing [opv9u4m1] SUNRPC failure during NFS secure unmounting.
Installing [lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
Installing [cx570frs] Use-after-free in Xen network backend receive path.
Installing [badkrwqs] Kernel IO hang during directory entry cache shrinking.
Installing [8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
Installing [8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
Installing [10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
Installing [55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
Installing [jwfdgahz] Denial-of-service when receiving segments over TCP.
Installing [oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
Installing [c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
Installing [279lqcvw] Performance regression during microcode loading.
Installing [sgf7btt8] NFSv4 state list corruption causes denial-of-service.
Installing [16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
Installing [tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
Installing [r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
Installing [rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
Installing [ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
Installing [727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
Installing [lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
Installing [ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
Installing [5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
Installing [cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
Installing [8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
Installing [8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
Installing [pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
Installing [ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
Installing [5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
Installing [1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
Installing [a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
Installing [36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
Installing [tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
Installing [a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
Installing [gx6br2uw] Infiniband connection hang after failure.
Installing [5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
Installing [tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
Installing [n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
Installing [sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
Installing [cfhej4sj] Kernel hang in block layer during CPU hotplug.
Installing [ownop36l] Reduced throughput in loopback disk devices.
Installing [1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
Installing [4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
Installing [psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
Installing [6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
Installing [2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
Installing [qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
Installing [aj4s64po] Memory allocation stall during direct compaction on large allocations.
Installing [b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
Installing [gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
Installing [jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
Installing [eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
Installing [dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
Installing [cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
Installing [enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
Installing [mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
Installing [5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [aaleh5w4] IO stall in the NVMe host driver on request timeout.
Installing [2us37bxn] Denial-of-service in XFS whiteout renames.
Installing [fr0udjqk] Failure to join multipath RDS/TCP cluster.
Installing [duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
Installing [bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
Installing [46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
Installing [85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
Installing [1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
Installing [leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
Installing [4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
Installing [ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
Installing [acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
Installing [anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
Installing [aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
Installing [4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
Installing [lirbb7tr] Kernel hang when block layer queue is being frozen.
Installing [m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
Installing [fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
Installing [ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
Installing [h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.
Your kernel is fully up to date.
Effective kernel version is 4.1.12-124.39.2.el6uek
  Limpeza      : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20200529-0.noarch                                                1/2
  Verifying    : uptrack-updates-4.1.12-124.24.3.el6uek.x86_64-20190328-0.noarch                                                2/2

Atualizados:
  uptrack-updates-4.1.12-124.24.3.el6uek.x86_64.noarch 0:20200529-0

Concluído!

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# uptrack-uname -r
4.1.12-124.39.2.el6uek.x86_64

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# uptrack-show
Installed updates:
[pwc6xmnr] KAISER/KPTI enablement for Ksplice.
[5dq87kra] Improve the interface to freeze tasks.
[brasm60x] CVE-2019-5489: Side-channel information leak in kernel page cache.
[nz0sbas8] Denial-of-service in Reliable Datagram Socket reconnection.
[ruspn21i] Incorrect file modification time for empty files on NFSv4.1 mounts.
[cc4jh8b9] Denial-of-service in Xen block device on invalid request type.
[els0vptv] CVE-2018-18397: Filesystem permissions bypass with userfaultfd.
[5kfn4iud] CVE-2017-12153: Denial-of-service when using cfg80211 wireless extension with GTK rekey offload.
[qurx51il] CVE-2018-17972: Information leak in kernel stack dumps in /proc.
[honz3g9t] CVE-2018-10877: Out-of-bounds access when using corrupted ext4 filesystem with abnormal extent tree.
[dz2cv9sv] CVE-2018-18559: Denial-of-service when binding a packet on a socket while a notification is raised.
[musu64er] CVE-2018-16862: Potential memory corruption in inode truncation path.
[ry7b4cfc] CVE-2017-17807: Permissions bypass when requesting key on default keyring.
[i4konm7m] CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[ovabwkag] CVE-2018-10876: Use-after-free when removing space in ext4 filesystem.
[nayeinzh] CVE-2018-9568: Privilege escalation in IPv6 to IPv4 socket cloning.
[hhhwajn6] NULL pointer dereference when freeing irq in Broadcom NetXtreme-C/E driver.
[d1u8ybba] Packet loss on ingress on an unmanaged L2TP over IP tunnel interface.
[2d8uhlxy] Denial-of-service when umounting a filesystem with many dentries in the dentry cache.
[7utswooq] Incorrect steal time reporting on hotplugged Xen virtual CPUs.
[kgn8gqqi] CVE-2018-10879: Use-after-free when setting extended attribute entry on ext4 filesystem.
[6lw015pf] NULL pointer dereference on Xen virtual block device removal.
[hze6qrtf] Known exploit detection.
[14i2g9lr] Known exploit detection for CVE-2017-7308.
[g7z90bgg] Known exploit detection for CVE-2018-14634.
[r1ci4o1u] CVE-2018-10882: Out-of-bounds access when unmounting a crafted ext4 filesystem.
[p43iqjn9] CVE-2018-10881: Data corruption when using indirect blocks with ext4 filesystem.
[6tkyixod] CVE-2018-1066: Denial-of-service in CIFS session negotiation.
[a05sdf1l] CVE-2019-3701: Denial-of-service in CAN controller.
[fogmssp8] Denial-of-service in the Infiniband core driver when allocating protection domains.
[avw0qabw] Data corruption on ext4 filesystems while performing direct AIO.
[ewvxiykg] CVE-2017-13305: Information leak in encrypted keys subsystem.
[qc30cloh] Add support for runtime configuration of target LIO inquiry strings.
[faqyus3n] NULL pointer dereference in NFSv4.1 fatal signal handling.
[gs2gf75m] Improved KAISER/KPTI enablement for Ksplice.
[iqwlh0ca] Kernel crash during late microcode updates.
[of37mcqk] Improved update to CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[33nk0cmy] CVE-2019-11190: Information leak using a setuid program and accessing process stats.
[8royj14b] CVE-2018-19985: Out-of-bounds memory access in USB High Speed Mobile device driver.
[5pszsdrf] CVE-2017-18360: Divide-by-zero error when setting port option of USB Inside Out Edgeport Serial Driver.
[iooyacxu] Incorrect return value during CPU microcode updates.
[fc12bzu4] SCSI disk IO failures after max_sectors_kb modification.
[oma01x47] CVE-2015-5327: Kernel crash in X.509 certificate time validation.
[103y1ftd] Transparent hugepage performance degradation under low-memory conditions.
[pj8x2v7r] CVE-2019-11815: Use-after-free in RDS socket creation.
[7o03y1k1] CVE-2018-14633: Information leak in iSCSI CHAP authentication.
[5ol0uxr5] CVE-2019-3819: Deadlock in HID debug events read.
[2j4gn0ys] CVE-2019-3459, CVE-2019-3460: Remote information leak via Bluetooth configuration request.
[lqtb52do] Improved fix for CVE-2018-10878: Out-of-bounds access when initializing ext4 block bitmap.
[h15ktbem] CVE-2019-11884: Information leak in Bluetooth HIDP HIDPCONNADD ioctl().
[8vxf9joc] Kernel crash in OCFS2 reading of deleted inodes.
[rjj7fybg] CVE-2018-20836: Use-after-free in SCSI SAS timeout.
[sidd037w] CVE-2019-11810: Denial-of-service in LSI Logic MegaRAID probing.
[1e3lmmwm] Improved runtime retpoline toggling for Spectre v2 mitigations.
[hnpumuzv] CVE-2019-11477, CVE-2019-11478, CVE-2019-11479: Remote Denial-of-service in TCP stack.
[rflrgnh1] Correctly propagate changes in CPU features after late microcode loading to guests.
[tiqwqcdj] CVE-2017-18208: Denial-of-service when using madvise system call.
[jjke0w9i] CVE-2019-6133: Privilege escalation via forked process impersonation.
[btsmga6i] Improved fix for CVE-2017-5715: Indirect jumps in 32-bit compatibility syscall handling.
[aj46evzx] CVE-2018-7191: Denial-of-service via use of crafted tun device name.
[ly9awu36] CVE-2019-11833: Information leak in ext4 extent tree block.
[clezl4i4] Memory leak in the RDS Infiniband receive path when fragment size changes.
[lwplpwab] CVE-2019-12381, CVE-2019-12378: NULL pointer dereferences in the IP to socket glue.
[euyenqo4] Denial-of-service in the Hyper-V Virtual SCSI driver on invalid Logic Unit Number.
[59oxrzui] CVE-2018-20169: Missing bound check when reading extra USB descriptors.
[nolntn0r] Kernel crash in MEGARAID SAS firmware crashdump loading.
[dt216md1] XSA-300: Denial-of-service in Xen memory ballooning.
[299muh7y] CVE-2019-13631: Denial-of-service in GTCO CalComp/InterWrite tablet.
[lqn7ais6] Network TUN device creation failure with formatted names.
[opv9u4m1] SUNRPC failure during NFS secure unmounting.
[cx570frs] Use-after-free in Xen network backend receive path.
[badkrwqs] Kernel IO hang during directory entry cache shrinking.
[8mq1s4f4] Incorrect IPv4 address reporting in rds-info.
[8eorruhu] CVE-2019-14821: Denial-of-service in KVM MMIO coalesced writes.
[10zy6us9] CVE-2019-15239: Denial-of-service when establishing TCP connection.
[55xqy4ko] CVE-2019-14283: Denial-of-service in floppy disk geometry setting during insertion.
[jwfdgahz] Denial-of-service when receiving segments over TCP.
[oizoe26p] CVE-2019-15666: Denial-of-service when setting network xfrm policy.
[c85rq95p] Memory corruption during Xen Software I/O TLB unregistration.
[279lqcvw] Performance regression during microcode loading.
[sgf7btt8] NFSv4 state list corruption causes denial-of-service.
[tf47fncp] CVE-2017-7495: Information leak when ext4 ordered data mode is used.
[r2eeut85] Kernel crash in Reliable Datagram Socket RDMA pool management.
[rh83ttwh] CVE-2017-14991: Information leak in SCSI Generic Support driver.
[ov9bnl23] CVE-2019-11135: Side-channel information leak in Intel TSX.
[727fpti9] CVE-2019-11478: Denial-of-service when receiving packets over tcp sockets.
[lsgym6md] CVE-2017-15128: Denial-of-service when handling page fault through userfaultfd.
[ejx68eru] NULL pointer dereference when probing Lego Mindstorms infrared device.
[5shyh44e] CVE-2019-14284: Denial-of-service in floppy disk formatting.
[cvlmwy3w] CVE-2019-15916: Denial-of-service in network device registration.
[8vgl85j4] CVE-2017-18551: Denial-of-service when reading data over I2C bus.
[8zk5s7s1] Denial-of-service in Reliable Datagram Socket Infiniband address checks.
[pln9o28q] CVE-2019-15217: NULL pointer deference when using USB ZR364XX Camera driver.
[ire5pzyq] CVE-2019-15213: Denial-of-service when removing a USB DVB device.
[5d6eumfh] CVE-2019-16994: Denial-of-service in IPv6-in-IPv4 tunnel registration.
[1s0k7367] CVE-2019-17055: Permission bypass when creating a Modular ISDN socket.
[a4vjob4k] CVE-2019-17053: Permission bypass when creating a IEEE 802.15.4 socket.
[36o0ka8p] Improved fix for Spectre v1: Bounds check bypass in Vhost ioctl.
[tmncb6mz] CVE-2019-14835: Privilege escalation during live migration of guest.
[a7xgl3qz] Kernel crash on QLogic QLA2XXX device probe failure.
[gx6br2uw] Infiniband connection hang after failure.
[5k4hxnpw] CVE-2019-16995: Denial-of-service in HSR networking finalization.
[tlaw67rk] Kernel crash in OCFS2 direct IO cluster allocation.
[n3d8hma2] I/O hang in write protected iSCSI Target LUNs.
[sfse1lmj] CVE-2019-15219: Denial-of-service in USB 2.0 SVGA dongle driver when using a malicious USB device.
[cfhej4sj] Kernel hang in block layer during CPU hotplug.
[ownop36l] Reduced throughput in loopback disk devices.
[get3rovj] Enablement for applying custom alternative instructions.
[1a7khalv] CVE-2019-16233: NULL pointer dereference when registering QLogic Fibre Channel driver.
[4pq6586u] CVE-2019-15807: Denial-of-service when discovering expander in SAS Domain Transport Attributes fails.
[psqiwn3l] CVE-2017-18595: Use-after-free in kernel trace buffer allocation.
[opm180mz] Improved enablement update for applying custom alternatives instructions.
[6pd0g9r7] Denial-of-service when processing status entries in QLogic Fibre Channel HBA driver.
[htgr0cn9] KSPLICE enablement for applying optimized nops after a module has been fully loaded.
[2hg7a7bo] Memory leak in Mellanox ConnextX HCA Infiniband CX-3 virtual functions.
[qytzxaar] Denial-of-service in Emulex LightPulse Fibre Channel LIP testing.
[aj4s64po] Memory allocation stall during direct compaction on large allocations.
[b2n4ac2a] CVE-2019-17666: Out-of-bounds access when using Realtek Wireless Network driver in P2P mode.
[gw8ngj0m] CVE-2019-19332: Denial-of-service in KVM cpuid emulation reporting.
[jrtxr58s] Improved fix to CVE-2019-11135: Side-channel information leak in Intel TSX on late microcode update.
[eh8lnl2m] Missing CPU vulnerability mitigations on late microcode update.
[dc5d55bo] Denial-of-service in iSCSI IO vector mapping.
[t4u20ttv] CVE-2019-11091, CVE-2018-12126, CVE-2018-12130, CVE-2018-12127: Microarchitectural Data Sampling.
[m4br9owc] Correctly enable CPU bugs mitigations with late microcode loading.
[sfxy7gmd] Spectre v2 bypass with EIBRS support.
[t1axzsf2] Kernel crash in Spectre v2 speculation control on KVM hosts.
[1g6pcdr7] Spectre v2 bypass with EIBRS support and unconditional SSBD Spectre v4 mitigation.
[9jk4cir6] Spectre v4 SSBD setting failure for KVM guests.
[1udzb2t9] Incorrect Meltdown mitigation reporting for HVM Xen guests.
[kk4jnzs3] KVM VMX guest panic with Spectre v4 mitigation.
[6e3qlnax] CVE-2019-1125: Information leak in kernel entry code when swapping GS.
[lvt0vy2k] Improved Spectre v2 vulnerability message on non-retpoline module loading.
[16wun5r3] CVE-2018-12207: Machine Check Exception on page size change.
[cqu17irs] CVE-2019-15291: Denial-of-service in B2C2 FlexCop driver probing.
[enft8nka] IO hang in Reliable Datagram Socket remote DMA socket closing.
[mt8gfw20] Denial-of-service in CIFS POSIX file locks on close.
[5k5tbxmv] CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[aaleh5w4] IO stall in the NVMe host driver on request timeout.
[2us37bxn] Denial-of-service in XFS whiteout renames.
[fr0udjqk] Failure to join multipath RDS/TCP cluster.
[duikkfym] Memory corruption in QLogic QLA2XXX Get Name List.
[bu7bcl1v] CVE-2019-18806: Memory leak when allocating large buffers in QLogic QLA3XXX Network driver.
[46y83q19] CVE-2020-10942: Out-of-bounds memory access in the Virtual host driver.
[85yzbqt7] CVE-2016-5244: Information leak in the RDS network protocol.
[1b94kg5s] CVE-2020-8648: Use-after-free in the virtual terminal driver.
[leclgbzw] CVE-2020-9383: Information leak in the floppy disk driver.
[4u11gay0] Improved fix for CVE-2020-2732: Privilege escalation in Intel KVM nested emulation.
[ibi69wee] CVE-2019-19527: Denial-of-service in USB HID device open.
[acmo37s1] CVE-2017-7346: Denial-of-service when user defines surface in VMware Virtual GPU driver.
[anclpkyd] CVE-2020-8647, CVE-2020-8649: Use-after-free in the VGA text console driver.
[aaluabmf] CVE-2019-19532: Denial-of-service when initializing HID devices.
[4hn5pri6] CVE-2019-19523: Use-after-free when disconnecting ADU USB devices.
[lirbb7tr] Kernel hang when block layer queue is being frozen.
[m1w19h3k] Denial-of-service in the QLogic QLA2XXX Fibre Channel Support when collecting dump failure.
[fs7u7bbu] CVE-2018-5953: Information leak in software IO TLB driver.
[ef78ph72] Soft lockup when multiple threads read /proc/stat simultaneously.
[h7blpl4p] NULL dereference while writing Hyper-V SINT14 MSR.

Effective kernel version is 4.1.12-124.39.2.el6uek

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# xm list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 15576     4     r-----  40525.0
spcdexav0010-adm                             1 204803    26     r----- 225613.0
spcdexav0011-adm                             2 204803    18     r----- 190423.2
spcdexav0021-adm                             3 92163     4     r-----  98788.2
spcdexav0027-adm                             4 61443     4     r-----  37603.8
spcdexav0029-adm                             5 51203     4     r-----  22665.7
spcdexav0030-adm                             6 51203     4     rb----  42492.7
spcdexav0033-adm                             7 51203     4     r-----  63391.8
spcdexav0034-adm                             8 51203     4     r-----  39868.5

===================================================================================================

[root@spcdexa0006-adm rpm_ksplice]# shutdown -r now

Broadcast message from root@spcdexa0006-adm.spo.supcd
        (/dev/pts/2) at 9:45 ...

The system is going down for reboot NOW!

===================================================================================================

[root@spcdexa0006-adm ~]# uname -r
4.1.12-124.24.3.el6uek.x86_64

===================================================================================================

[root@spcdexa0006-adm ~]# uptrack-uname -r
4.1.12-124.39.2.el6uek.x86_64

===================================================================================================

[root@spcdexa0006-adm ~]# xm list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0 15920     4     r-----    766.0
spcdexav0010-adm                             1 204803    26     r-----    104.9
spcdexav0011-adm                             2 204803    18     r-----    110.2
spcdexav0021-adm                             3 92163     4     -b----     92.5
spcdexav0027-adm                             4 61443     4     -b----     94.0
spcdexav0029-adm                             5 51203     4     r-----     87.1
spcdexav0030-adm                             6 51203     4     r-----     80.0
spcdexav0033-adm                             7 51203     4     -b----     44.0
spcdexav0034-adm                             8 51203     4     -b----     42.7

===================================================================================================
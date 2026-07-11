--Exadata Rack

[root@XXXX-db01 ~]# ipmitool sunoem cli "show /SP system_identifier"

--Compute Nodes

[root@XXXX-db01 ~]# dmidecode -s system-serial-number

--Storage Cells

[root@XXXX-cel01-adm ~]# dmidecode -s system-serial-number

--InfiniBand Switches

[root@XXXX-sw-ibb01 ~]# showfruinfo

--Ethernet switch

[root@XXXX-db01 ~]# ssh admin@XXXX-sw-adm01
Password:
XXXX-sw-adm01>enable
Password:
XXXX-sw-adm01# show module

--PDU
You have multiple PDU’s in your Exadata Machine. You need login to them individually as root user to obtain Serial numbers. You need to open PDU admin console using their IP addresses and click module info tab on left hand corner to obtain serial number.

 
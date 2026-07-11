/*
ASR Configuration on Oracle Exadata Database Machine
Assumption: ASR Manager Is Configired
Configure Fault Notification Destinations
Fault Telemetry Options
*/

--1.OEDA – During Initial Setup/Build
--2.After Deployment for adding or changing notification destinations

--To configure fault notification destinations, modify the SNMP subscriber attribute on the database or storage servers

SNMP Subscriber Options

--1.host=[ASR Manager host name or IP] is the Oracle ASR Manager host name or IP address.
--
--The Oracle ASR Manager host name can be used when DNS is enabled for the site. If DNS is not running, then the IP address is preferred.
--However, you can use the Oracle ASR Manager host name if the entry is added to the /etc/hosts file.
--
--2.type=asr represents the Oracle ASR Manager being a special type of SNMP subscriber.
--3.community=public is the required value of the community string
--4.port=162 is the SNMP port. This port value is customer-dependent. You can configure it as a different port based on your network requirements.
--5.asrmPort is an optional element that supports automatic diagnostic package uploads for Service Requests (SR). The default value is 16161. If you plan to use HTTP for upload, then the value should match the HTTP port configured on Oracle ASR Manager. If you plan to use HTTPs for upload, then the value should match the HTTPs port configured on Oracle ASR Manager. The value should be set to the same value as displayed for “HTTP Port” or “HTTPS/SSL Port” in the output of the command asr show_http_receiver on the Oracle ASR Manager host.
--6.fromIP enables you to specify an IP address from which the trap is sent. If this field is not specified, then it defaults to the IP address associated with eth0. To support automatic diagnostic package uploads, you must set fromIP on the database nodes to the value of the IP address of the eth0 network interface.
--
--Note: The fromIP field is allowed only for snmpSubscribers whose type is either ASR or v3ASR.
--
--Configuring the SNMP Subscriber for Fault Notification
--Configure the SNMP subscriber on each database server.

--Log in to the first database server as the root user.
--Retrieve the current SNMP subscriber configuration for the server. 
dcli -g ~/dbs_group -l root "dbmcli -e list dbserver attributes snmpsubscriber"
 
--Modify snmp attributes on Compute Nodes:
dcli -g ~/dbs_group -l root "dbmcli -e alter dbserver snmpSubscriber=((host='ASR Mgr Host',port=162,community=public,type=asr,asrmPort=ASR_Mgr_http_or_https_port))"
 
--Note: If you need to add multiple fault notification destinations, then specify multiple SNMP subscribers using a comma-delimited list.
 
--Verify the changes :
dcli -g ~/dbs_group -l root "dbmcli -e list dbserver attributes snmpsubscriber"
configure the snmp subscriber on each storage server.

--Log in to the first database server as the root user.
--Retrieve the current SNMP subscriber configuration for the Storage server. 
dcli -g ~/cell_group -l root "cellcli -e list cell attributes snmpsubscriber"
 
--Modify snmp attributes on Compute Nodes:
dcli -g ~/cell_group -l root "cellcli -e alter cell snmpSubscriber=((host='ASR Mgr Host',port=162,community=public,type=asr,asrmPort=ASR_Mgr_http_or_https_port))"
 
--Note: If you need to add multiple fault notification destinations, then specify multiple SNMP subscribers using a comma-delimited list.
 
--Verify the changes :
dcli -g ~/cell_group -l root "cellcli -e list cell attributes snmpsubscriber"
Enabling Automatic DiagPack Upload for Oracle ASR

--MS provides support to automatically upload diagpacks over HTTPS starting with Oracle Exadata System Software release 19.1.0.
--From 12.2.1.1.0, Management Server (MS) communicates with Oracle ASR Manager to upload a diagnostic package containing information relevant to the Oracle ASR automatically

--From ASR Manager Server
--Verify the http_receiver is enabled and determine the port being used.
--asr show_http_receiver

--HTTP Receiver configuration:

HTTP Receiver Status: Enabled
Host Name: exa-asr.example.com
HTTP Port: 16161
HTTPS/SSL Port: 8701
HTTPS/SSL: Enabled

--Verify the port used by http_receiver for Oracle ASR is the same as the asrmPort set for the snmpSubscriber on the database servers and storage servers.

--Check the asrmPort for the snmpSubscriber on the database servers:
 
dbmcli -e list dbserver attributes snmpSubscriber

--Expected Output:
--(host=’ASR Mgr Host’,port=162,community=public,type=asr,asrmPort=ASR_Mgr_http_or_https_port))

--Check the asrmPort for the snmpSubscriber on the storage servers:
cellcli -e list cell attributes snmpSubscriber

--Expected Output:
--(host=’ASR Mgr Host’,port=162,community=public,type=asr,asrmPort=ASR_Mgr_http_or_https_port))

--Activating Nodes on Oracle ASR Manager
--Only on ASR Manager Host
--Check list of assets
--asr list_asset
--Activate ILOM and run one of the following commands:

ILOM IP address
 
# asr activate_asset -i Node ILOM IP
 
ILOM host name
 
# asr activate_asset -h Node ILOM host name

Exadata Machines

--Activate the Oracle Exadata Database Machine operating system side of Oracle ASR by running one of the following commands:

# asr activate_exadata -i Node-IP-address -h Node-host-name -l Node-ILOM-IP
 
# asr activate_exadata -i Node-IP-address -h Node-host-name -n Node-ILOM-hostname

--Run the following command to verify that all of the Oracle Exadata Database Machine nodes are visible on Oracle ASR Manager:

asr list_asset

--Validating SNMP Trap Configurations on Oracle Exadata Database Machine
--Run the following commands to validate SNMP trap configurations

--Compute Nodes configuration validation:
dcli -g dbs_group -l root “dbmcli -e list dbserver attributes snmpSubscriber”

--Storage Cell Nodes configuration validation:
dcli -g cell_group -l celladmin “cellcli -e list cell attributes snmpsubscriber”

--Database node SNMP validation
dcli -g dbs_group -l root “dbmcli -e alter dbserver validate snmp type=asr”

--Storage node SNMP validation
dcli -g cell_group -l root “cellcli -e alter cell validate snmp type=asr”

--After validation, Oracle sends e-mail notifications from each of the nodes to:

--The Oracle ASR Manager registration user specified in the Oracle ASR Manager asr register command.
-- 
--The asset contact that is assigned in My Oracle Support.
-- 
--The distribution e-mail list that is assigned in My Oracle Support (optional).
--Note :: Finally run asrexachkscript and get it verified.
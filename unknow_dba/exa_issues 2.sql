/*EXARATA ISSUES*/

Exadata Storage Server and database server 11.2.3.3.1 and 12.1.1.1.1

Bug 19132065 - Oracle Linux semtimedop() wakeups by timeout are lagging causing offload operations to fail (which may degrade performance) and errors similar to one or more of the following:

ORA-700 [Offload issue job timed out]
ORA-700 [Offload group not open]
RS-700 [Celloflsrv hang detected. It will be terminated]
This issue is also present on Oracle Linux database servers, but the negative consequences are currently unknown.

Fixed in 12.1.1.1.2 and 12.1.2.1.0

Workaround - Set operating system kernel parameter rcu_delay=1 on all storage servers and Oracle Linux database servers.

Step 1: Set rcu_delay for runtime

# echo 1 > /proc/sys/kernel/rcu_delay

Verify the setting

# cat /proc/sys/kernel/rcu_delay
1

Step 2: Set rcu_delay in /etc/sysctl.conf for proper setting upon reboot

Add "kernel.rcu_delay=1" to /etc/sysctl.conf

Step 3: Restart cellsrv on storage servers

CellCLI> alter cell restart services cellsrv;

This workaround is automatically applied in the following cases:

When a new system is deployed with Exadata 11.2.3.3.1 or 12.1.1.1.1 using OEDA Sep 2014 or later.
When storage servers are upgraded to 11.2.3.3.1 or 12.1.1.1.1 and the patchmgr plugins patch is properly staged before running patchmgr, as documented.
When database servers are upgraded to 11.2.3.3.1 or 12.1.1.1.1 using dbnodeupdate.sh v3.58 or later.

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/


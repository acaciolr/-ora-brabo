Exadata InfiniBand Related Tools
InfiniBand Related Tools
# ibstat

# ibstatus        — To get the status of the Infiniband services /usr/sbin/ibstatus
# iblinkinfo       — To check the status of the Infiniband Link /usr/sbin/iblinkinfo.pl -Rl
# ibswitches /usr/sbin/ibswitches
# ibtracert <base lid of active interface> <sm lid>
ibdiagnet     — Performs diagnostics upon the InfiniBand fabric and reports status.
ibnetdiscover    — Discovers and displays the InfiniBand fabric topology and connections.
ibcheckerrors    — Checks the entire InfiniBand fabric for errors.
ibqueryerrors.pl -rR -s LinkDowned,RcvSwRelayErrors,XmtDiscards,XmtWait
ibqueryerrors.pl -s RcvSwRelayErrors,RcvRemotePhysErrors,XmtDiscards,XmtConstraintErrors,RcvConstraintErrors, ExcBufOverrunErrors,VL15Dropped    — A single invocation of this command will report on all switch ports on all switches. Run this check from a database server or a switch.
ibclearerrors ibclearcounters
# ibnetdiscover -p      — To identify spine switches # /opt/oracle.SupportTools/ibdiagtools/verify-topology   — To get topology of the infiniband network inside Exadata
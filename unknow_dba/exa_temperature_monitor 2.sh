#Script para monitorar a temperatura ambiente do dbnodes e cellnodes 1
dcli -g all_hosts -l root ipmitool sensor list | grep degree | grep T_AMB

#Script para monitorar a temperatura ambiente do dbnodes e cellnodes 2
dcli -g all_hosts -l root 'ipmitool sunoem cli "show /SYS/T_AMB" | grep value'
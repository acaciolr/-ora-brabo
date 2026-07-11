#Script para monitorar o status dos LEDs
dcli -l root -g all_hosts '/usr/bin/ipmitool  sunoem led get all '
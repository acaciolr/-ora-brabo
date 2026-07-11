#Script para monitorar a temperatura das baterias (Should be < 60 C)
dcli -l root -g all_hosts '/opt/MegaRAID/MegaCli/MegaCli64 -AdpBbuCmd -a0 | grep BatteryType; /opt/MegaRAID/MegaCli/MegaCli64 -AdpBbuCmd -a0 | grep -i temper'

#Script para monitorar a carga das baterias (Should be > 800 mAh)
dcli -l root -g all_hosts '/opt/MegaRAID/MegaCli/MegaCli64 -AdpBbuCmd -GetBbuCapacityInfo -a0 | grep "Full Charge" '

#Script para monitorar a quantidade de erros das baterias (Should be < 10%)
dcli -l root -g all_hosts '/opt/MegaRAID/MegaCli/MegaCli64 -AdpBbuCmd -GetBbuStatus -a0 | grep "Max Error"'
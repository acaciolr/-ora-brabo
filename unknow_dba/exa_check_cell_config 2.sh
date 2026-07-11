#Script para verificar configurações dos cellnodes
dcli -l root -g cell_group " cellcli -e  LIST CELL ATTRIBUTES name,cellNumber,status,fanStatus,powerStatus,temperatureStatus,cellsrvStatus,msStatus,rsStatus,releaseVersion,releaseTrackingBug"

-- 11.2.3.2.0 em diante
dcli -l root -g cell_group " cellcli -e  LIST CELL ATTRIBUTES name,cellNumber,status,flashCacheMode,fanStatus,powerStatus,temperatureStatus,cellsrvStatus,msStatus,rsStatus,releaseVersion,releaseTrackingBug"
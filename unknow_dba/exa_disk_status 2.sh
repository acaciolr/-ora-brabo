#Script para monitorar Physical HardDisks / LUNS com status != normal

-- Physical HardDisks
dcli -l root -g cell_group " cellcli -e \"LIST PHYSICALDISK ATTRIBUTES name,status,diskType,physicalSize,physicalRPM,physicalInsertTime,errorcount,errHardReadCount,errHardWriteCount,errMediaCount,errOtherCount,errSeekCount,lastFailureReason where disktype=harddisk AND status != 'normal'  \" "

-- Physical HardDisks LUNs
dcli -l root -g cell_group " cellcli -e \"LIST LUN ATTRIBUTES name,status,diskType,deviceName,raidLevel,isSystemLun,lunSize,physicalDrives,lunWriteCacheMode,errorCount where disktype=harddisk AND status != 'normal' \" "

#Script para monitorar FLASHDISKS com status != normal
--Flash
dcli -l root -g cell_group " cellcli -e \"LIST PHYSICALDISK ATTRIBUTES name,status,diskType,physicalSize,errorcount,physicalInsertTime,lastFailureReason where disktype=flashdisk AND status != 'normal' \" "
dcli -l root -g cell_group " cellcli -e \"LIST LUN ATTRIBUTES name,status,diskType,deviceName,raidLevel,isSystemLun,lunSize,physicalDrives,lunWriteCacheMode,errorCount where disktype=flashdisk AND status != 'normal' \" "
dcli -l root -g cell_group " cellcli -e \"LIST LUN ATTRIBUTES name,status,diskType,deviceName,raidLevel,isSystemLun,lunSize,physicalDrives,lunWriteCacheMode,errorCount where disktype=flashdisk and physicalDrives='' \" "
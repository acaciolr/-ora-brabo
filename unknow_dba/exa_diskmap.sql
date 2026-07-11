cellcli -e list diskmap
The interesting LIST DISKMAP command in the storage cells links all views to hard disks:
PCI bus address as Name 252:5, OS name (/dev/sdh, for example), GridDisk name DATAC1_CD_05_ed01celadm10 ...

Example:

[root@ed01celadm10 ~]# cellcli -e list diskmap
Name       PhysicalSerial       SlotNumber              Status  PhysicalSize CellDisk         DevicePartition GridDisks
252:0      Q4WPNK               0                       normal  9124G        CD_00_ed01celadm10 /dev/sdc        "DATAC6_CD_00_ed01celadm10, RECOC6_CD_00_ed01celadm10"
252:1      Q56YJK               1                       normal  9124G        CD_01_ed01celadm10 /dev/sdd        "DATAC6_CD_01_ed01celadm10, RECOC6_CD_01_ed01celadm10"
252:2      Q599GK               2                       normal  9124G        CD_02_ed01celadm10 /dev/sde        "DATAC6_CD_02_ed01celadm10, RECOC6_CD_02_ed01celadm10"
252:3      Q573LK               3                       normal  9124G        CD_03_ed01celadm10 /dev/sdf        "DATAC6_CD_03_ed01celadm10, RECOC6_CD_03_ed01celadm10"
252:4      Q566UK               4                       normal  9124G        CD_04_ed01celadm10 /dev/sdg        "DATAC6_CD_04_ed01celadm10, RECOC6_CD_04_ed01celadm10"
252:5      Q575PK               5                       normal  9124G        CD_05_ed01celadm10 /dev/sdh        "DATAC6_CD_05_ed01celadm10, RECOC6_CD_05_ed01celadm10"
252:6      Q578AK               6                       normal  9124G        CD_06_ed01celadm10 /dev/sdi        "DATAC6_CD_06_ed01celadm10, RECOC6_CD_06_ed01celadm10"
252:7      Q59BYK               7                       normal  9124G        CD_07_ed01celadm10 /dev/sdj        "DATAC6_CD_07_ed01celadm10, RECOC6_CD_07_ed01celadm10"
252:8      Q551EK               8                       normal  9124G        CD_08_ed01celadm10 /dev/sdk        "DATAC6_CD_08_ed01celadm10, RECOC6_CD_08_ed01celadm10"
252:9      Q57PRK               9                       normal  9124G        CD_09_ed01celadm10 /dev/sdl        "DATAC6_CD_09_ed01celadm10, RECOC6_CD_09_ed01celadm10"
252:10     Q56NSK               10                      normal  9124G        CD_10_ed01celadm10 /dev/sdm        "DATAC6_CD_10_ed01celadm10, RECOC6_CD_10_ed01celadm10"
252:11     Q56J0K               11                      normal  9124G        CD_11_ed01celadm10 /dev/sdn        "DATAC6_CD_11_ed01celadm10, RECOC6_CD_11_ed01celadm10"
FLASH_10_1 PHLE7423009Q6P4BGN-1 "PCI Slot: 10; FDOM: 1" normal  2981G        FD_00_ed01celadm10 /dev/md310      "FLASHCACHE_FD_00_ed01celadm10, FLASHLOG_FD_00_ed01celadm10"
FLASH_10_2 PHLE7423009Q6P4BGN-2 "PCI Slot: 10; FDOM: 2" normal  2981G        FD_00_ed01celadm10 /dev/md310      "FLASHCACHE_FD_00_ed01celadm10, FLASHLOG_FD_00_ed01celadm10"
FLASH_4_1  PHLE742201RY6P4BGN-1 "PCI Slot: 4; FDOM: 1"  normal  2981G        FD_01_ed01celadm10 /dev/md304      "FLASHCACHE_FD_01_ed01celadm10, FLASHLOG_FD_01_ed01celadm10"
FLASH_4_2  PHLE742201RY6P4BGN-2 "PCI Slot: 4; FDOM: 2"  normal  2981G        FD_01_ed01celadm10 /dev/md304      "FLASHCACHE_FD_01_ed01celadm10, FLASHLOG_FD_01_ed01celadm10"
FLASH_5_1  PHLE742200MK6P4BGN-1 "PCI Slot: 5; FDOM: 1"  normal  2981G        FD_02_ed01celadm10 /dev/md305      "FLASHCACHE_FD_02_ed01celadm10, FLASHLOG_FD_02_ed01celadm10"
FLASH_5_2  PHLE742200MK6P4BGN-2 "PCI Slot: 5; FDOM: 2"  normal  2981G        FD_02_ed01celadm10 /dev/md305      "FLASHCACHE_FD_02_ed01celadm10, FLASHLOG_FD_02_ed01celadm10"
FLASH_6_1  PHLE742300C36P4BGN-1 "PCI Slot: 6; FDOM: 1"  normal  2981G        FD_03_ed01celadm10 /dev/md306      "FLASHCACHE_FD_03_ed01celadm10, FLASHLOG_FD_03_ed01celadm10"
FLASH_6_2  PHLE742300C36P4BGN-2 "PCI Slot: 6; FDOM: 2"  normal  2981G        FD_03_ed01celadm10 /dev/md306      "FLASHCACHE_FD_03_ed01celadm10, FLASHLOG_FD_03_ed01celadm10"
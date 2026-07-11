
[root@spcdcel0010-adm ~]# cellcli
CellCLI: Release 19.2.1.0.0 - Production on Tue Mar 24 10:59:46 BRT 2020

Copyright (c) 2007, 2016, Oracle and/or its affiliates. All rights reserved.

CellCLI> list alerthistory
         1_1     2020-03-24T03:08:57-03:00       critical        "InfinibandHCA check has detected the following issue(s):     Slot Number    : 3     Attribute Name : InfinibandHCAPCIeSlotSpeed     Required       : 8GTs     Found          : Unknown     Attribute Name : InfinibandHCAPCIeSlotWidth     Required       : x8     Found          : Unknown"

CellCLI> Alter cell validate configuration
Cell spcdcel0010_adm successfully altered

CellCLI> list alerthistory
         1_1     2020-03-24T03:08:57-03:00       critical        "InfinibandHCA check has detected the following issue(s):     Slot Number    : 3     Attribute Name : InfinibandHCAPCIeSlotSpeed     Required       : 8GTs     Found          : Unknown     Attribute Name : InfinibandHCAPCIeSlotWidth     Required       : x8     Found          : Unknown"
         1_2     2020-03-24T11:01:22-03:00       clear           "Check for configuration of InfinibandHCA is successful.     Slot Number    : 3"

CellCLI> list alerthistory detail
         name:                   1_1
         alertMessage:           "InfinibandHCA check has detected the following issue(s):     Slot Number    : 3     Attribute Name : InfinibandHCAPCIeSlotSpeed     Required       : 8GTs     Found          : Unknown     Attribute Name : InfinibandHCAPCIeSlotWidth     Required       : x8     Found          : Unknown"
         alertSequenceID:        1
         alertShortName:         Hardware
         alertType:              Stateful
         beginTime:              2020-03-24T03:08:57-03:00
         endTime:                2020-03-24T11:01:22-03:00
         examinedBy:
         metricObjectName:       checkconfig_InfinibandHCA_3
         notificationState:      sent
         sequenceBeginTime:      2020-03-24T03:08:57-03:00
         severity:               critical
         alertAction:            "Correct the configuration problems. Then run CellCLI command:       ALTER CELL VALIDATE CONFIGURATION       Verify that the new configuration is correct.  Diagnostic package is attached. It is also accessible at https://spcdcel0010-adm.spo.supcd/diagpack/download?name=spcdcel0010-adm_2020_03_24T03_08_57_1_1.tar.bz2 It will be retained on the storage server for 28 days, after which it may be automatically purged by MS during accelerated space reclamation. Diagnostic packages for critical alerts can be downloaded and/or re-created at https://spcdcel0010-adm.spo.supcd/diagpack"

         name:                   1_2
         alertMessage:           "Check for configuration of InfinibandHCA is successful.     Slot Number    : 3"
         alertSequenceID:        1
         alertShortName:         Hardware
         alertType:              Stateful
         beginTime:              2020-03-24T11:01:22-03:00
         endTime:                2020-03-24T11:01:22-03:00
         examinedBy:
         metricObjectName:       checkconfig_InfinibandHCA_3
         notificationState:      sent
         sequenceBeginTime:      2020-03-24T03:08:57-03:00
         severity:               clear
         alertAction:            Informational.

CellCLI>
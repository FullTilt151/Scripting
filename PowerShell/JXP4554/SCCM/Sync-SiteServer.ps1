if(test-path -Path C:\Users\jxp4554\repos\SCCM-PowerShell_Scripts\JXP4554\SCCM){
    & robocopy C:\Users\jxp4554\repos\SCCM-PowerShell_Scripts\JXP4554\SCCM\Maintenance_Scripts '\\LOUAPPWTS1140\d$\Maintenance_Scripts' /mir /r:0
    Copy-Item -Path C:\Users\jxp4554\repos\SCCM-PowerShell_Scripts\JXP4554\SCCM\Maintenance_Scripts\SyncDir.ps1 -Destination '\\lounaswps08\pdrive\Dept907.CIT\ConfigMgr\Repos\PowerShell Scripts\PowerShell Scripts\SCCM\Maintenance_Scripts\SyncDir.ps1' -Force
    & robocopy C:\Users\jxp4554\repos\SCCM-PowerShell_Scripts\JXP4554\SCCM\Scripts '\\LOUAPPWTS1140\d$\Scripts' /mir /r:0
    Copy-Item -Path C:\Users\jxp4554\repos\SCCM-PowerShell_Scripts\JXP4554\SCCM\Scripts\SyncDir.ps1 -Destination '\\lounaswps08\pdrive\Dept907.CIT\ConfigMgr\Repos\PowerShell Scripts\PowerShell Scripts\SCCM\Scripts\SyncDir.ps1' -Force
    & robocopy C:\Users\jxp4554\repos\SCCM-PowerShell_Scripts\JXP4554\SCCM\Source '\\LOUAPPWTS1140\d$\Source' /mir /r:0
    Copy-Item -Path C:\Users\jxp4554\repos\SCCM-PowerShell_Scripts\JXP4554\SCCM\Source\SyncDir.ps1 -Destination '\\lounaswps08\pdrive\Dept907.CIT\ConfigMgr\Repos\PowerShell Scripts\PowerShell Scripts\SCCM\Source\SyncDir.ps1 -Force'
}
Get-CMSiteRole -RoleName 'SMS Software Update Point' | Select-Object -ExpandProperty NetworkOSPath | ForEach-Object{
    & \\lounaswps08\PDRIVE\Dept907.CIT\configmgr\scripts\Invoke-SCCMDCMEvaluation.ps1 -computername ($($_.tostring().replace('\\',''))) -baseline 'CIS-SCCM-WSUS Settings ClientScanTesting'
}
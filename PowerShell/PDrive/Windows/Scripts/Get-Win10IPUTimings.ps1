Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    if(Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue) {
        New-Item -Path "\\wkmj059g4b\shared\logs\Win10-IPU-TimingLogs\$_" -ItemType Directory -ErrorAction SilentlyContinue
        Copy-Item -Path "\\$_\c$\windows\ccm\logs\smsts*.log" -Destination "\\wkmj059g4b\shared\logs\Win10-IPU-TimingLogs\$_\" -Verbose
    }
}

Get-ChildItem \\wkmj059g4b\shared\logs\Win10-IPU-TimingLogs -Recurse -Filter *.log | 
ForEach-Object {
    #$_.FullName
    $WKID = (Split-Path $_.FullName -Parent).Split('\')[6]
    $log = Get-Content $_.FullName
    $ErrorActionPreference = 'SilentlyContinue'
    Remove-Variable TSStarttime
    Remove-Variable OSStarttime
    Remove-Variable OSEndtime
    Remove-Variable TSEndtime
    $TSStarttime = Get-Date $($log | Select-String -Pattern 'Successfully completed the action (Check Readiness for Upgrade) with the exit win32 code 0' -SimpleMatch).ToString().Substring(111).split('"')[0].Substring(0,5) -UFormat %R
    $OSStarttime = Get-Date $($log | Select-String -Pattern 'The action (Set TS Var "SMSTS_FinishUpgradeTime" to Date Time) has been skipped because it is disabled' -SimpleMatch).ToString().Substring(123).split('"')[0].Substring(0,5) -UFormat %R
    $OSEndtime =  Get-Date $($log | Select-String -Pattern 'The action (Set TS Var "SMSTS_StartUpgradeTime" to Date Time) has been skipped because it is disabled' -SimpleMatch).ToString().Substring(122).split('"')[0].Substring(0,5) -UFormat %R
    $TSEndtime = Get-Date $($log | Select-String -Pattern 'Setting program history for WP100337:*' -SimpleMatch).ToString().Substring(59).split('"')[0].Substring(0,5) -UFormat %R
    "$WKID,$TSStarttime,$OSStarttime,$OSEndtime,$TSEndtime"
    $ErrorActionPreference = 'Continue'
}
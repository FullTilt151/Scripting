$DT = Get-Date -Format yyyy/MM/dd_hh:mm
$TBDriver = (Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceName -eq "Thunderbolt(TM) Controller - 15BF"}).driverversion
IF ($TBDriver -eq $null) {
    Write-Output "$DT - No ThunderBolt controller found" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
    }
Else {
    Write-Output "$DT - Installing drivers - $TBDriver" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
    Get-ChildItem -Path C:\temp -Filter 'tbt*.inf' -Recurse | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }
    }


$Model= (Get-CimInstance Win32_ComputerSystemProduct).Name.substring(0, 4)

$FWupdate = Get-ChildItem -Path C:\temp -Filter 'FwUpdateCmd.exe' -Recurse
$FWupdate.DirectoryName
Set-Location -Path $FWupdate.DirectoryName
$FWVersion = .\FwUpdateCmd.exe GetCurrentNvmVersion "$(.\FwUpdateCmd.exe EnumControllers)"
IF ($FWVersion -match 'Error') {
    Write-Output "$DT - Unable to determine the version" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
    exit 0
    }

Switch ($Model) {
    #T470s 
    {$_ -eq "20HF" -or $_ -eq "20HG" -or $_ -eq "20JS" -or $_ -eq "20JT"} {
            IF ($FWVersion -lt '21') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool2010.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #T480s
    {$_ -eq "20L7" -or $_ -eq "20L8"} {
            IF ($FWVersion -lt '21') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool2010.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #T490, T590
    {$_ -eq "20N2" -or $_ -eq "20N3" -or $_ -eq "20N4" -or $_ -eq "20N5" -or $_ -eq "20Q9" -or $_ -eq "20QH" -or $_ -eq "20RY" -or $_ -eq "20RX"}  {
            IF ($FWVersion -lt '22') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool210714ur.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #T570
    {$_ -eq "20H9" -or $_ -eq "20HA" -or $_ -eq "20JW" -or $_ -eq "20JX"}  {
        IF ($FWVersion -lt '21') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool2010.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #T580
    {$_ -eq "20L9" -or $_ -eq "20LA"} {
            IF ($FWVersion -lt '21') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool2008.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #X1 Tablet Gen 3
    {$_ -eq "20KJ" -or $_ -eq "20KK"} {
            IF ($FWVersion -lt '46') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool210713.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #X1 Yoga 4th
    {$_ -eq "20QF" -or $_ -eq "20QG" -or $_ -eq "20SA" -or $_ -eq "20SB"} {
            IF ($FWVersion -lt '46') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool210714ur.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #X380 Yoga
    {$_ -eq "20LH" -or $_ -eq "20LJ"} {
            IF ($FWVersion -lt '21') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool2010.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #X390 Yoga
    {$_ -eq "20NN" -or $_ -eq "20NQ"} {
            IF ($FWVersion -lt '22') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool2011ur.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #S1, Yoga 370
    {$_ -eq "20JK" -or $_ -eq "20JL" -or $_ -eq "20JH" -or $_ -eq "20JJ"}  {
            IF ($FWVersion -lt '21') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool2010.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
    #T14, T15, P15s
    {$_ -eq "20T4" -or $_ -eq "20T5" -or $_ -eq "20S0" -or $_ -eq "20S1" -or $_ -eq "20S6" -or $_ -eq "20S7"}  {
            IF ($FWVersion -lt '22') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool210714ur.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
     #X1 Carbon 8th, X1 Yoga 5th
    {$_ -eq "20U9" -or $_ -eq "20UA" -or $_ -eq "20UB" -or $_ -eq "20UC"} {
            IF ($FWVersion -lt '46') {
                Write-Output "$DT - Updating ThunderBolt firmware - $FWVersion" >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                Start-Process -Wait FwUpdateTool210714ur.exe -ArgumentList "1 -s"
                }
            Else {
                Write-Output "$DT - ThunderBolt Firmware version is current." >> C:\temp\Software_Install_Logs\TB_Driver_FW_Update.log
                }
          }
}
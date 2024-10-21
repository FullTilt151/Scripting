$WKID = 'WK024457611157'
$WKIDS = Get-Content -Path C:\CIS_Temp\WKIDs.txt

Get-ChildItem "\\LOUNASWPS08\PDRIVE\Dept907.CIT\OSD\Logs" | Select-Object Name,LastWriteTime | Export-Csv -Path C:\CIS_TEMP\recent_builds.csv
Get-CimInstance CIM_LogicalDisk -ComputerName $WKID
Get-CimInstance Win32_ComputerSystem -ComputerName $WKID
Get-CimInstance Win32_ComputerSystemProduct -ComputerName $WKID
Get-CimInstance CIM_OperatingSystem -ComputerName $WKID | Select-Object CSName,Version,LastBootUpTime
Get-CimInstance -ComputerName $WKID -Namespace "root\cimv2\security\microsofttpm" -Class win32_tpm | Select-Object SpecVersion
.\PsLoggedon.exe -l \\$WKID -accepteula
Invoke-Command -ComputerName $WKID -ScriptBlock {Get-MpComputerStatus}

#CCM Cache Size
Invoke-Command -ComputerName $WKID -ScriptBlock {
    $CacheSize = Get-CimInstance -Namespace ROOT\CCM\SoftMgmtAgent -Query "Select Size from CacheConfig" | Select-Object -Property Size
    $CacheSize
    #$Cache = Get-CimInstance -Namespace 'ROOT\CCM\SoftMgmtAgent' -Class CacheConfig
    #$Cache.Size = '51200'
    #$Cache.Put()
    #Restart-Service -Name CcmExec -Force
}

#CCMExec Service
Get-Service -Name CcmExec -ComputerName $WKID
Invoke-Command -ComputerName $WKID -ScriptBlock {
    $SRV = Get-Service -Name CCMExec
    $SRV.Status
    If ($SRV.Status -eq 'Stopped') {
        sc.exe config CCMExec start= delayed-auto
        Start-Service -Name CcmExec
    }
    $provmode = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode).ProvisioningMode
    If ($provmode -eq "true") {
        Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "SetClientProvisioningMode" $false
        Write-Output "Disabled provisioning, restarting CCMExec service..."
        Restart-Service -Name CcmExec -Force
    }
    else {
        Write-Output "Provisioning Mode is off!"
    }
}

#BIOS and Model
$WKID = 'WKPF24E81G'
$BIOS = Get-CimInstance Win32_BIOS -ComputerName $WKID
$COMSYS = Get-CimInstance Win32_ComputerSystemProduct -ComputerName $WKID
Write-Host $BIOS.Name -NoNewline -ForegroundColor Magenta
Write-Host " , " -NoNewline
Write-Host $COMSYS.Version -NoNewline -ForegroundColor Green
Write-Host " , " -NoNewline
Write-Host $COMSYS.Name -ForegroundColor Green

#Get Drivers
$WKID = 'WKPF2L8SCF'
Get-CimInstance -ComputerName $WKID -name root\cimv2 -Class win32_pnpsigneddriver_custom | Sort-Object DeviceClass, DeviceName | Format-Table DeviceName, DriverVersion, DriverDate, Deviceclass, scriptlastran
Get-CimInstance -ComputerName $WKID Win32_PnPSignedDriver | Sort-Object DeviceClass, DeviceName | Format-Table DeviceName, DriverVersion, DriverDate, Deviceclass

#Get ADSS
$SEG = Read-Host "Enter the Segment"
NLTEST /DSADDRESSTOSITE:$SEG

#Get Enviroment Path values
$WKID = 'WKPC0W9LC8'
Invoke-Command -ComputerName $WKID -ScriptBlock {Get-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" | Select-Object -Property Path | Format-List}
#Set Enviroment Path values
$PathEntry = Read-Host "Enter Path values"
Invoke-Command -ComputerName $WKID -ScriptBlock {Set-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name Path -Value $Using:PathEntry}

#Defender AV/ATP
$WKID = 'SIMXDWDEVE0664'
Get-Service -ComputerName $WKID -Name WinDefend | Select-Object -Property *
Get-Service -ComputerName $WKID -Name Sense | Select-Object -Property *
Foreach ($WKID In $WKIDS) {
    IF (Test-Connection -ComputerName $WKID -Quiet -ErrorAction SilentlyContinue) {
        Invoke-Command -ComputerName $WKID -ScriptBlock {
            & cmd /c regsvr32 /s atl.dll
            & cmd /c regsvr32 /s wuapi.dll
            & cmd /c regsvr32 /s softpub.dll
            & cmd /c regsvr32 /s mssip32.dll
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sense" -Name Start -Value 2 -Force
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" -Name Start -value 2 -Force
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\wscsvc" -Name Start -Value 2 -Force
            #$PMDLL = Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows Defender\Platform" -Filter ProtectionManagement.dll -Recurse | Select-Object -ExpandProperty FullName
            #Register-CimProvider -ProviderName ProtectionManagement -Namespace root\Microsoft\protectionmanagement -Path $PMDLL -Impersonation True -HostingModel LocalServiceHost -SupportWQL -ForceUpdate
            }
        $CurUsr =  .\PsLoggedon.exe -l \\$WKID -accepteula | Select-String -Pattern "No one"
        IF ($CurUsr -match 'No one is logged on locally.') {
            Restart-Computer -ComputerName $WKID -Force
            Write-Output $WKID
        }
    }
}

#Get printers
$WKID = 'WKPF27WV9M'
Get-Printer -ComputerName $WKID | Select-Object -Property Name,PortName

#Store Apps (StickyNotes, Snip & Sketch, etc..
$WKID = 'WKMJ0E2CBB'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RequirePrivateStoreOnly" -Value 0 
    $currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | Select-Object -ExpandProperty UseWUServer 
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 
    Restart-Service wuauserv
}
    #Open Microsoft Store
    #Click the horizontal "Ellipsis".
    #Click Downloads and Updates / Update the desired app
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RequirePrivateStoreOnly" -Value 1 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU 
Restart-Service wuauserv

#Clear Last Log On User
$WKID = 'WKPF27WV9M'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    & cmd /c reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 1 /f
    & cmd /c reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnUser /f
    & cmd /c reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnSAMUser /f
}

#.Net Version
$WKID = 'LOUAPPWQS1766'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    Get-Item -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5"
    Get-Item -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full"
}

#Kill Process on remote
$Proc = 'Powershell'
$WKID = 'WKPF27WV9M'
Foreach ($WKID In $WKIDS) {
    (Get-CimInstance Win32_Process -ComputerName $WKID -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match $Proc }).Terminate()
    Write-Host $WKID -ForegroundColor Green
}

#Get CPU Performance on remote
$WKID = 'WKPF27WV9M'
IF (Test-Connection -ComputerName $WKID -ErrorAction SilentlyContinue) {
    $CpuLoad = (Get-CimInstance -ComputerName $WKID CIM_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object Average ).Average
    $MaxClockSpeed = (Get-CimInstance -ComputerName $WKID CIM_Processor).MaxClockSpeed
    $ProcessorPerformance = (Get-Counter -ComputerName $WKID -Counter "\Processor Information(_Total)\% Processor Performance").CounterSamples.CookedValue
    $CurrentClockSpeed = $MaxClockSpeed*($ProcessorPerformance/100)
    $temps = Get-CimInstance -ComputerName $WKID MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" | Select-Object -Property CriticalTripPoint,CurrentTemperature
    Write-Host "Current Processor Utilization / Speed: " -ForegroundColor Yellow -NoNewLine
    Write-Host "$CpuLoad%, $CurrentClockSpeed, $WKID " -ForegroundColor Cyan -NoNewLine
    Write-Host $temps -ForegroundColor Magenta
}

$temps | Select-Object -Property InstanceName,@{n="Temps F";e={(($_.CriticalTripPoint /10 -273.15) *1.8 +32)}}

#Get Power Scheme
$WKID ='WK1W6J6D3'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    & cmd /c powercfg /l
    }

#Get S0 power capability (Connected Standby)
$WKID ='WKPF2E8LG2'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    #Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name CsEnabled -Value 1 -Force
    & cmd /c powercfg /a #> C:\Temp\PowercfgA.txt 
    }

#T_Azure_Intune_USBAllowed
Start-Process notepad C:\CIS_Temp\WKIDs.txt -Wait
$WKIDS = Get-Content -Path C:\CIS_Temp\WKIDs.txt
Foreach ($WKID In $WKIDS) {
    $DistinguishedName = Get-ADComputer -Identity "$wkid"
    #Get-ADGroupMember -Identity 'T_Azure_Intune_USBAllowed'
    Get-ADGroup -Server louadmwps05 -SearchBase "OU=Azure,OU=Testing,DC=humad,DC=com" -Filter "Name -like 'T_Azure_Intune_USBAllowed'" | Add-ADGroupMember -Members $DistinguishedName
}

Invoke-Command -ComputerName $WKID -ScriptBlock {Get-ChildItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices"}


#T_Azure_Intune_WindowsHelloForBusiness
$WKID = 'WK005095212957'
$DistinguishedName = Get-ADComputer -Identity "$wkid"
#Get-ADGroupMember -Identity 'T_Azure_Intune_WindowsHelloForBusiness'
Add-ADGroupMember -Identity 'T_Azure_Intune_WindowsHelloForBusiness' -Members $DistinguishedName

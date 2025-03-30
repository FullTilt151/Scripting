$TaskXML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Sync Maintenance_Scripts</Description>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>2019-04-03T07:00:00</StartBoundary>
      <Enabled>true</Enabled>
      <RandomDelay>P0DT0H0M0S</RandomDelay>
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>HUMAD\SCCM_Service</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <Duration>PT10M</Duration>
      <WaitTimeout>PT1H</WaitTimeout>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>Powershell</Command>
      <Arguments>-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -command ".\SyncDir.ps1"</Arguments>
      <WorkingDirectory>D:\Maintenance_Scripts\</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@

$Script = @'
if ($env:COMPUTERNAME -eq 'LOUAPPWTS1441') {
    Write-Output 'This is the source server, please do not sync'
    exit
}
else {
    $source = Split-Path $PSScriptRoot -Leaf
    $destination = "D:\$source"
    Switch ($env:COMPUTERNAME) {
        'GRBAPPWPS12' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1405' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1642' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1643' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1644' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1645' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1646' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1647' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1648' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1649' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1653' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1654' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1655' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1656' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1657' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1658' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1700' {$source = "\\LOUAPPWPS1658.rsc.humad.com\d$\$source"}
        'LOUAPPWPS1701' {$source = "\\LOUAPPWPS1700.dmzad.hum\$source"}
        'LOUAPPWPS1740' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1741' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1742' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1750' {$source = "\\LOUAPPWPS1825.rsc.humad.com\d$\$source"}
        'LOUAPPWPS1821' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1822' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWPS1825' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1020' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1021' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1022' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1023' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1024' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1025' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1150' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1151' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWTS1150' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWTS1151' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWTS1152' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LTLSCMDPWTS01' {$source = "\\LOUAPPWQS1150.rsc.humad.com\d$\$source"}
        'LOUAPPWTS1442' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWTS1443' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWTS1444' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWTS1445' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1562' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1563' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1564' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1567' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1568' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        'LOUAPPWQS1569' {$source = "\\LOUAPPWTS1441.rsc.humad.com\$source"}
        default {
            Write-Host 'Do not sync this server'
            exit
        }
    }
    if (!(Test-Path $destination)) {
        Write-Output "Creating directory $destination"
        New-Item -Path $destination -ItemType Directory
    }
    $shareName = Split-Path $destination -Leaf
    if($env:COMPUTERNAME -in ('LOUAPPWTS1441','LOUAPPWQS1150','LOUAPPWQS1151','LOUAPPWPS1658','LOUAPPWPS1825','LOUAPPWPS1742','LOUAPPWPS1405')){
        if((Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue).Name -eq $shareName){
            Write-Output 'Removing Share'
            Remove-SmbShare -Name $shareName -Force
        }
    }
    elseif ((Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue).Name -ne $shareName) {
        Write-Output 'Creating share'
        New-SmbShare -Name $shareName -Path $destination -ReadAccess 'Everyone'
    }
    Write-Host "Copying $source -> $destination"
    $cmd = 'robocopy'
    $robocopyOptions = @('/mir', '/r:0')
    $fileList = '*.*'
    $switches = @($source, $destination, $fileList) + $robocopyOptions
    & $cmd $switches
    if (test-path -Path "$destination\LastSync.txt") {Remove-Item -Path "$destination\LastSync.txt"}
    New-Item -path "$destination\LastSync.txt" -ItemType File
}
'@
$Cred = Get-Credential -Message "Please provide the password for humad\sccm_service which runs the scheduled tasks" -UserName 'humad\sccm_service'
foreach ($Server in @('LOUAPPWQS1567', 'LOUAPPWQS1568', 'LOUAPPWQS1569')) {
    $CimSession = New-CimSession -ComputerName $Server
    if ($null -ne $CimSession) {
        $exists = Get-ScheduledTask -TaskName 'Sync Maintenance_Scripts' -TaskPath "\Microsoft\Configuration Manager\" -CimSession $CimSession -ErrorAction SilentlyContinue
        if (-not (Test-Path -Path "\\$Server\d$\Maintenance_Scripts")) {
            New-Item -Path "\\$Server\d$" -ItemType Directory -Name 'Maintenance_Scripts'
        }
        if (-not (Test-Path -Path "\\$Server\d$\Maintenance_Scripts\SyncDir.ps1")) {
            New-Item -Path  "\\$Server\d$\Maintenance_Scripts" -Name 'SyncDir.ps1' -ItemType File -Value $Script 
        }
        if ($null -eq $exists) {
            Register-ScheduledTask -Xml $TaskXML -TaskName 'Sync Maintenance_Scripts' -TaskPath "\Microsoft\Configuration Manager\" -User $Cred.UserName -Password $cred.GetNetworkCredential().Password -CimSession $CimSession
        }
        $CimSession.Close()
    }
}
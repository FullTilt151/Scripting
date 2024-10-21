# USMT Script for Saving data and Restoring data
#
## variables
# 
$hostname = $env:COMPUTERNAME
$prog = "\\lounaswps01\pdrive\dept907.cit\osd\packages\userstatemigrationtool\amd64"
$pstools = "\\lounaswps01\pdrive\dept907.cit\osd\packages\pstools"
$pstoolsLocalDest = "\\$hostname\c$\temp\"
$pstoolsRemoteDest = "\\$targetComp\c$\temp\"
$usmtState = "\\$targetComp\c$\temp\amd64"
$checkFolder = Test-Path "\\$targetComp\c$\temp\amd64"
$checkFolder1 = Test-Path "c:\temp\psexec.exe"
$checkFolder2 = Test-Path "\\$targetComp\c$\temp\psexec.exe"
$scanstateArgs =   "-accepteula \\" + $targetComp + " -u " + $InvokingUser + " -p " + $ElevatedPW + " " + $usmtState + "\scanstate.exe " + $finalDest + " /o /localonly /efs:skip /c /l:\\" + $targetComp + "\C$\WINDOWS\CCM\Logs\SMSTSLog\scanstate.log /progress:\\" + $targetComp + "\C$\WINDOWS\CCM\Logs\SMSTSLog\scanstateprogress.log /i:" + $usmtState + "\MigUser.xml /i:" + $usmtState + "\MigApp.xml /i:" + $usmtState + "\MigDocs.xml /i:" + $usmtState + "\MigLinks.xml /config:" + $usmtState + "\config.xml /v:13"
$loadstateArgs =   "-accepteula \\" + $targetComp + " -u " + $InvokingUser + " -p " + $ElevatedPW + " " + $usmtState + "\loadstate.exe " + $usmtLocale + "\ /i:" + $usmtState + "\MigUser.xml /i:" + $usmtState + "\MigApp.xml /i:" + $usmtState + "\MigDocs.xml /i:" + $usmtState + "\MigLinks.xml /l:\\"+ $targetComp + "\C$\Windows\CCM\logs\loadstate.log /progress:\\"+ $targetComp + "\C$\Windows\CCM\logs\loadstateprog.log /v:13 /lac"
$success = 'Successful run'
#$caplog = '\\'+ $targetComp + '\C$\WINDOWS\CCM\Logs\SMSTSLog\scanstateprogress.log'
#$loadlog = '\\'+ $targetComp + '\C$\WINDOWS\CCM\Logs\loadstateprog.log'

### Prompt for creds
$Credentials = Get-Credential 
$InvokingUser = $Credentials.UserName
$ElevatedPW = $Credentials.GetNetworkCredential().Password

### Determine which task and copy PSTools
$decision = Read-Host -prompt "(B)ackup or (R)estore?"
copyPSTools_Local

## Main function
function mainFunc{
    copyPSTools_Local
    Switch ($decision){
        "B" {
        # USMT destination (to save state)
		$global:targetComp = Read-Host "Workstation to capture "
        $global:usmtDest = Read-Host "Path to save UserState "
        enableWinRM
		copyPSTools_Remote
        copyUSMT
        $global:finalDest = $usmtDest +"\" + $targetComp
        write-host "Saving UserState to " $finalDest
        saveState
        }
        "R" {
        # USMT location (to restore state)
		$global:targetComp = Read-Host "Workstation to restore "
        $global:usmtLocale = Read-Host "Path to restore UserState "
		copyPSTools_Remote
        write-host "Restoring UserState from " $usmtLocale
        restoreState
        }
    }
}

## Check for and copy USMTools
function copyUSMT{
 if (!($checkFolder)) {
    Copy-Item -Path $prog -destination "\\$targetComp\c$\temp\" -Recurse -Container
    }
    else {
    echo "USMT files exist on $targetComp"
    }
}

## Check for and copy PSMTools - Local
function copyPSTools_Local{
 if (!($checkFolder1)) {
    Copy-Item -Path "\\lounaswps01\pdrive\dept907.cit\osd\packages\PSTools\*" -destination c:\temp -Recurse -Container
    }
    else {
    echo "PSTools exist on Local"
    }
}

## Check for and copy PSTools - Remote
function copyPSTools_Remote{
 if (!($checkFolder2)) {
    Copy-Item -Path "\\lounaswps01\pdrive\dept907.cit\osd\packages\PSTools\*" -destination "\\$targetComp\c$\temp\" -Recurse -Container -Force
    }
    else {
    echo "PSTools exist on $targetComp"
    }
}

## Save Data
function saveState{
# scanstate
#$proc = Invoke-Expression $scanstateArgs
$proc = Start-Process -filepath "c:\temp\psexec.exe " $scanstateArgs -credential $Credentials -workingdirectory "\\$targetComp\c$\temp\" -passThru
do {start-sleep -Milliseconds 500}
until ($proc.HasExited)
<#$StringExist = (Get-Content $caplog) | Where-Object { $_.Contains($success) }
    if ($StringExist) {
    Write-Host "Save complete"
    }#>
}

## Restore Data
function restoreState{
# loadstate
#$proc2 = Invoke-Expression $loadstateArgs
$proc2 = Start-Process -filepath "c:\temp\PSEXEC.exe " $loadstateArgs -credential $credentials -workingdirectory "\\$hostname\c$\temp\" -passThru 
do {start-sleep -Milliseconds 500}
until ($proc2.HasExited)
<#$StringExist = (Get-Content $loadlog) | Where-Object { $_.Contains($success) }
    if ($StringExist) {
    Write-Host "Save complete"
    }#>
}

## Enable winRM
function enableWinRM {
    $result = winrm id -r:$targetComp 2>$null
    Write-Host	
    if ($LastExitCode -eq 0) {
	Write-Host "WinRM already enabled on" $targetComp "..." -ForegroundColor green
    } else {
	Write-Host "Enabling WinRM on" $targetComp "..." -ForegroundColor red
	c:\temp\psexec.exe -accepteula \\$targetComp -s C:\Windows\system32\winrm.cmd qc -quiet
	
	if ($LastExitCode -eq 0) {
	c:\temp\psservice.exe -acceptueula \\$targetComp restart WinRM
	$result = winrm id -r:$targetComp 2>$null
		
	   if ($LastExitCode -eq 0) {write-host "...continuing..."}
	   else {exit 1}
		} 
	else {exit 1}
	}
}

<## Copy PSTools to local
function copyPSTools{
 if (!($checkFolder)) {
    Copy-Item $pstools\* -destination c:\windows\system32 
    }
    else {
    echo "PSTools exist"
    enableWinRM
    }
}

#enableWinRM#>
mainFunc
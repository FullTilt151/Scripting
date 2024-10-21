## Meat

Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form 
$Form.Text = "Form"
$Form.TopMost = $true
$Form.Width = 434
$Form.Height = 382

$label3 = New-Object system.windows.Forms.Label 
$label3.Text = "USMT Capture GUI"
$label3.AutoSize = $true
$label3.Width = 25
$label3.Height = 10
$label3.location = new-object system.drawing.point(35,30)
$label3.Font = "Microsoft Sans Serif,14,style=Bold"
$Form.controls.Add($label3) 

$label4 = New-Object system.windows.Forms.Label 
$label4.Text = "Enter workstation name:"
$label4.AutoSize = $true
$label4.Width = 25
$label4.Height = 10
$label4.location = new-object system.drawing.point(36,78)
$label4.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($label4) 

$capTarget = New-Object system.windows.Forms.TextBox 
$capTarget.Width = 120
$capTarget.Height = 20
$capTarget.location = new-object system.drawing.point(35,102)
$capTarget.Font = "Microsoft Sans Serif,11"
$capTarget.CharacterCasing = "Upper"
$Form.controls.Add($capTarget) 

$label8 = New-Object system.windows.Forms.Label 
$label8.Text = "CAUTION: This will capture all user profiles on the listed WKID"
$label8.AutoSize = $true
$label8.Width = 25
$label8.Height = 10
$label8.location = new-object system.drawing.point(35,240)
$label8.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($label8) 

$button = New-Object system.windows.Forms.Button 
$button.Text = "GO"
$button.Width = 60
$button.Height = 40
$button.location = new-object system.drawing.point(36,298)
$button.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($button) 
$button.Add_Click({

## Variables
$CompName = $capTarget.text

$checkFolder = Test-Path "\\$($capTarget.Text)\c$\temp\UserStateMigrationtool"
$checkScanLog = Test-Path "\\$CompName\c$\windows\ccm\logs\scanstate.log"
$prog = "\\lounaswps01\pdrive\Dept907.CIT\OSD\packages\UserStateMigrationtool\"

## Enable copy the USMT files to temp

function copyUSMT{
 if (!($checkFolder)) {
    Copy-Item -Path $prog -destination "\\$($capTarget.Text)\c$\temp\" -Recurse -Container -verbose
     }else {
	 $result = [System.Windows.Forms.MessageBox]::Show('USMT files exist on ' + $CompName,'Copy files')
     {exit 1}
    }
}

## Capture Data

function capState{
enableWinRM
getUSMTEst
copyUSMT
if (!($checkScanLog)) {$result = [System.Windows.Forms.MessageBox]::Show('Scanstate Log removed from ' + $CompName,'ScanState Log')}else{ 
Remove-Item \\$CompName\c$\windows\ccm\logs\scanstate.log | Out-Null
     {exit 1}
    }
Invoke-Command -ComputerName $CompName -verbose -ScriptBlock {
$capstateArgs = "c:\temp /o /localonly /efs:skip /c /l:C:\WINDOWS\CCM\Logs\scanstate.log /progress:C:\WINDOWS\CCM\Logs\scanstateprogress.log /i:c:\temp\UserStateMigrationTool\amd64\MigUser.xml /i:c:\temp\UserStateMigrationTool\amd64\MigApp.xml /i:c:\temp\UserStateMigrationTool\amd64\MigDocs.xml /i:c:\temp\UserStateMigrationTool\amd64\MigLinks.xml /v:13"
Start-Process -filepath C:\temp\UserStateMigrationTool\amd64\scanstate.exe -argumentlist $capstateArgs -wait -passthru -verbose
}
}

## Get the USMT estimate

function getUSMTEst{
$OSVersion = Get-WmiObject -ComputerName $capTarget.Text -Class Win32_OperatingSystem
if ($OSVersion.version  -eq "6.1.7601")
    {
    $amount = (Get-WmiObject -computername $CompName -Namespace root\itlocal -Class usmt_estimate | Sort-Object datetime -Descending | select -First 1).SizeEstimate
    [System.Windows.Forms.MessageBox]::Show('User State on ' + $CompName + ' is estimated to be ' + $amount + 'MB','UserState Size')
    }else{
    $result = [System.Windows.Forms.MessageBox]::Show('USMT Estimate is not supported on '+ $CompName,'UserState Size')
    {exit 1}
    }
}

## Enable winRM

function enableWinRM {
    $result = winrm id -r:$migLocation.Text 2>$null
    Write-Host	
    if ($LastExitCode -eq 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('WinRM is already enabled on ' + $CompName,'WinRM Results')
    } else {
	Write-Host "Enabling WinRM on" $CompName "..." -ForegroundColor red
	\\lounaswps01\pdrive\Dept907.CIT\OSD\packages\PSTools\psexec.exe -accepteula \\$CompName -s C:\Windows\system32\winrm.cmd qc -quiet
	
	if ($LastExitCode -eq 0) {$result = [System.Windows.Forms.MessageBox]::Show('WinRM is already enabled on ' + $CompName,'WinRM Results')
	\\lounaswps01\pdrive\Dept907.CIT\OSD\packages\PSTools\psservice.exe -acceptueula \\$CompName restart WinRM
	$result = winrm id -r:$CompName 2>$null
		
	   if ($LastExitCode -eq 0) {}
	   else {exit 1}
		} 
	else {exit 1}
	}
}

capState
})

############# This is when you have to close the form after getting values
$eventHandler = [System.EventHandler]{
#$capTarget.Text;
#$restLocation.Text;
Read-Host -Prompt "`nUSMT Process has completed! Check USMT logs for details. (Press Enter to exit) "
$form.Close();};



$Form.Add_Shown({$Form.Activate()})
[void]$Form.ShowDialog() 

return $capTarget.Text, $capLocation.Text
$button.Add_Click($eventHandler) ;

$Form.Dispose() 
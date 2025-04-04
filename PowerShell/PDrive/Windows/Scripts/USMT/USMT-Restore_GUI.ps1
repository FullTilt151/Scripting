﻿## Meat

Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form 
$Form.Text = "Form"
$Form.TopMost = $true
$Form.Width = 434
$Form.Height = 382

$label3 = New-Object system.windows.Forms.Label 
$label3.Text = "USMT Restore GUI"
$label3.AutoSize = $true
$label3.Width = 25
$label3.Height = 10
$label3.location = new-object system.drawing.point(35,30)
$label3.Font = "Microsoft Sans Serif,14,style=Bold"
$Form.controls.Add($label3) 

$label4 = New-Object system.windows.Forms.Label 
$label4.Text = "Enter WKID of save file:"
$label4.AutoSize = $true
$label4.Width = 25
$label4.Height = 10
$label4.location = new-object system.drawing.point(36,78)
$label4.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($label4) 

$migLocation = New-Object system.windows.Forms.TextBox 
$migLocation.Width = 120
$migLocation.Height = 20
$migLocation.location = new-object system.drawing.point(35,102)
$migLocation.Font = "Microsoft Sans Serif,11"
$migLocation.CharacterCasing = "Upper"
$Form.controls.Add($migLocation) 

$label6 = New-Object system.windows.Forms.Label 
$label6.Text = "Enter WKID to restore:"
$label6.AutoSize = $true
$label6.Width = 25
$label6.Height = 10
$label6.location = new-object system.drawing.point(35,158)
$label6.Font = "Microsoft Sans Serif,11"
$Form.controls.Add($label6) 

$restLocation = New-Object system.windows.Forms.TextBox 
$restLocation.Width = 120
$restLocation.Height = 20
$restLocation.location = new-object system.drawing.point(37,185)
$restLocation.Font = "Microsoft Sans Serif,11"
$restLocation.CharacterCasing = "Upper"
$Form.controls.Add($restLocation) 

$label8 = New-Object system.windows.Forms.Label 
$label8.Text = "CAUTION: This will restore all user profiles to the listed WKID"
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

$CompName = $restLocation.text
$migFileLocation = "\\$($CompName)\c$\temp\USMT"
$checkFolder = Test-Path "\\$($CompName)\c$\temp\UserStateMigrationtool"
$checkMigFolder = Test-Path $migFileLocation
$prog = "\\lounaswps01\pdrive\Dept907.CIT\OSD\packages\UserStateMigrationtool\"

## Copy the USMT files to temp

function copyUSMT{
 if (!($checkFolder)) {
    Copy-Item -Path $prog -destination "\\$($CompName)\c$\temp\" -Recurse -Container -verbose
     }else {
	 $result = [System.Windows.Forms.MessageBox]::Show('USMT files exist on ' + $CompName,'Copy files')
     {exit 1}
    }
}

## Copy the USMT to temp
function copyMigFile{
	Invoke-Command -ComputerName $CompName -credential (get-credential "$env:USERDOMAIN\$env:USERNAME") -Authentication CredSSP -ScriptBlock {
	Copy-Item -Path $using:migFileLocation -destination "c:\temp\" -Recurse -Container -verbose 
	}
  }
	
## Restore Data

function restoreState{
#enableWinRM
#copyUSMT
copyMigFile
#$loadstateArgs =  "c:\temp\USMT /i:c:\temp\UserStateMigrationTool\amd64\MigUser.xml /i:c:\temp\UserStateMigrationTool\amd64\MigApp.xml /i:c:\temp\UserStateMigrationTool\amd64\MigPrinters.xml /i:c:\temp\UserStateMigrationTool\amd64\MigDocs.xml /i:c:\temp\UserStateMigrationTool\amd64\MigLinks.xml /l:C:\Windows\CCM\logs\loadstate.log /progress:C:\Windows\CCM\logs\loadstateprog.log /v:13 /lac"
#Invoke-Command -ComputerName $CompName -ScriptBlock {
#Start-Process -filepath c:\temp\UserStateMigrationTool\amd64\loadstate.exe -Verb RunAs -argumentlist $using:loadstateArgs -wait -passthru -verbose
#}
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

restoreState
})


############# This is when you have to close the form after getting values
$eventHandler = [System.EventHandler]{
#$migLocation.Text;
#$restLocation.Text;
Read-Host -Prompt "`nUSMT Process has completed! Check USMT logs for details. (Press Enter to exit) "
$form.Close();};



$Form.Add_Shown({$Form.Activate()})
[void]$Form.ShowDialog() 

return $migLocation.Text, $restLocation.Text
$button.Add_Click($eventHandler) ;

$Form.Dispose() 

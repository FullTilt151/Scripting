Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Push-Location WP1:

[System.Windows.MessageBox]::Show('Paste the Pkg Ids of the HUMINST and ATSInst Program Name in the notepad that will open automatically.')
#
$FLDRPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Create-CMProgram-OSD-EnableTaskSequence\Completed"
$InputPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Create-CMProgram-OSD-EnableTaskSequence\Pkg_Id.txt"
$timestamp = Get-Date -UFormat %H%M
$Rename = "$timestamp.txt"
$CompletedPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Create-CMProgram-OSD-EnableTaskSequence\Completed\"

IF (!(test-path -path $FLDRPath)) {New-Item -ItemType Directory -path $FLDRPath}
New-Item $InputPath -ItemType file
Start-Process notepad \\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Create-CMProgram-OSD-EnableTaskSequence\Pkg_Id.txt -Wait
#Start-Process notepad $InputPath -Wait

(Get-Content $InputPath | foreach-object {Get-CMPackage -Id $_} | Get-CMProgram).where({$_.ProgramName -eq 'huminst'}) | 
ForEach-Object {
    $NewProgramName = "$($_.ProgramName)-OSD"
    $NewProgramName
    $CommandLine = $_.CommandLine
    $CommandLine
    $PackageID = $_.PackageID
    $PackageID
    New-CMProgram -CommandLine $CommandLine -PackageId $PackageID -StandardProgramName $NewProgramName -RunMode RunWithAdministrativeRights -ProgramRunType WhetherOrNotUserIsLoggedOn -UserInteraction $false | Set-CMProgram  -StandardProgram -EnableTaskSequence $true

    #New-CMProgram -CommandLine $CommandLine -PackageId $PackageID -StandardProgramName $NewProgramName -AddSupportedOperatingSystemPlatform IResultObject -RunMode RunWithAdministrativeRights -ProgramRunType WhetherOrNotUserIsLoggedOn -UserInteraction $false | Set-CMProgram  -StandardProgram -EnableTaskSequence $true
}



Move-Item -Path $InputPath -Destination $CompletedPath
Start-Sleep -s 5
Rename-Item -Path "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Create-CMProgram-OSD-EnableTaskSequence\Completed\Pkg_Id.txt" -NewName $Rename


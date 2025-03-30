[System.Windows.MessageBox]::Show('Paste the Pkg Ids of the HUMINST and ATSInst Program Name in the notepad that will open automatically.')
#
$FLDRPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Set-CMProgram-EnableTaskSequence\Completed"
$InputPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Set-CMProgram-EnableTaskSequence\Pkg_Id.txt"
$timestamp = Get-Date -UFormat %H%M
$Rename = "$timestamp.txt"
$CompletedPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Set-CMProgram-EnableTaskSequence\Completed\"

IF (!(test-path -path $FLDRPath)) {New-Item -ItemType Directory -path $FLDRPath}
New-Item $InputPath -ItemType file
Start-Process notepad \\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Set-CMProgram-EnableTaskSequence\Pkg_Id.txt -Wait

(Get-Content $InputPath | foreach-object {Get-CMPackage -Id $_}| Get-CMProgram).where({$_.ProgramName -eq 'huminst'}) | Set-CMProgram -StandardProgram -EnableTaskSequence $true
(Get-Content $InputPath | foreach-object {Get-CMPackage -Id $_}| Get-CMProgram).where({$_.ProgramName -eq 'HUMINST-OSD'}) | Set-CMProgram -StandardProgram -EnableTaskSequence $true
(Get-Content $InputPath | foreach-object {Get-CMPackage -Id $_}| Get-CMProgram).where({$_.ProgramName -eq 'atsinst'}) | Set-CMProgram -StandardProgram -EnableTaskSequence $true

Move-Item -Path $InputPath -Destination $CompletedPath
Start-Sleep -s 5
Rename-Item -Path "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\Tasks\$env:UserName\Set-CMProgram-EnableTaskSequence\Completed\Pkg_Id.txt" -NewName $Rename

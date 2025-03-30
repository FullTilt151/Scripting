[System.Windows.MessageBox]::Show('Paste the WKIDs for the IPU in the notepad that will open automatically.')
#
$FLDRPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Add-ADGroupMember\Completed"
$InputPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Add-ADGroupMember\WKIDs.txt"
$timestamp = Get-Date -UFormat %H%M
$Rename = "$timestamp.txt"
$CompletedPath = "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Add-ADGroupMember\Completed\"

IF (!(test-path -path $FLDRPath)) {New-Item -ItemType Directory -path $FLDRPath}
New-Item $InputPath -ItemType file
Start-Process notepad \\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Add-ADGroupMember\WKIDs.txt -Wait


(Get-Content -Path $InputPath | ForEach-Object {Add-ADGroupMember -Identity T_Windows10IPU -Members $_$})

Move-Item -Path $InputPath -Destination $CompletedPath
Start-Sleep -s 5
Rename-Item -Path "filesystem::\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Add-ADGroupMember\Completed\WKIDs.txt" -NewName $Rename
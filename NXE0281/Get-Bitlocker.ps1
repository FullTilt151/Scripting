Remove-PSDrive X
$Credential = Get-Credential
New-PSDrive -Name "X" -Root "\\lounaswps08\pdrive\dept907.cit\osd\BitLockerPIN" -PSProvider "FileSystem" -Credential ($Credential)
$Counter = 0

Do
{
    $WKID = Read-Host -Prompt 'Enter WKID of Bitlocker PIN you need pulled'
    $PIN = Get-Content "X:\$WKID.txt"
    Write-Host $PIN
    Pause

} While ($Counter -eq 0)
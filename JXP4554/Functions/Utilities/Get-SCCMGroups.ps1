Function Show-GroupMembers
{
    PARAM
    (
        [Parameter(Mandatory=$true)]
        [String]$Group,
        [Parameter(Mandatory=$false)]
        [int]$Level = 1
    )

    $Indent = "`t" * $Level
    $Members=Get-ADGroupMember $Group | Sort-Object -Property objectClass, Name
    foreach($Member in $Members)
    {
        if ($Member.objectClass -eq 'group')
        {
            $selection.TypeText("$Indent---Group $($Member.Name) ----`n")
            Show-GroupMembers $($Member.Name) ($Level + 1)
            $selection.TypeText("$Indent---End Group $($Member.Name) ----`n")
        }
        else
        {
            $selection.TypeText("$Indent$($Member.Name)`n")
        }
    }
}

$date = get-date -format MM-dd-yyyy
$filePath = 'C:\Temp\'

[ref]$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]
$word = New-Object -ComObject word.application
$word.visible = $true
$doc = $word.documents.add()
$selection = $word.Selection
$selection.WholeStory
$selection.Style = 'No Spacing'

$SCCMGroups = Get-ADGroup -Filter "Name -like 'G_SCCM_*'"
foreach($SCCMGroup in $SCCMGroups)
{
    $Members = Get-ADGroupMember  ($SCCMGroup.Name) | Sort-Object -Property objectClass, Name
    if(($Members.count -ne 0) -or ($Members.ObjectClass -eq 'group'))
    {
        $selection.InsertBreak()
        $selection.Font.Bold = $true
        $selection.TypeText("Group $($SCCMGroup.Name) has $($Members.Count) members.`n")
        $selection.Font.Bold = $false
        $selection.TypeText("`tThe members are:`n")
        Show-GroupMembers $SCCMGroup.Name
        $selection.InsertBreak()
    }
    else
    {
        $selection.Font.Bold = $true
        $selection.TypeText("Group $($SCCMGroup.Name) has $($Members.Count) members.`n")
        $selection.Font.Bold = $false
    }
}

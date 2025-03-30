<#
.Synopsis
Return the details of Software Updates in a Software Update Group.
.DESCRIPTION
Return information such as the number of files, and the total size of each software update in a software update group.
.EXAMPLE
Get-SoftwareUpdateGroupDetails -UpdateGroupName "2014-07 Workstations"
.EXAMPLE
Get-SoftwareUpdateGroupDetails -UpdateGroupName "2014-07 Wo*"
.EXAMPLE
Get-SoftwareUpdateGroupDetails -UpdateGroupID (Get-CMSoftwareUpdateGroup -Name "*2014-07*" | select -first 1).CI_ID
.EXAMPLE
Get-SoftwareUpdateGroupDetails -UpdateGroupName "2014-07 Wo*" | Measure-Object -Property Size -Sum
#>

[CmdletBinding(DefaultParameterSetName='SUGByName', 
                SupportsShouldProcess=$true, 
                PositionalBinding=$false,
                ConfirmImpact='Low')]
Param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, ParameterSetName="SUGByName")]
    [string]$UpdateGroupName,
    $SiteCode,
    $SiteServer
)

Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
$PSD = Get-PSDrive -PSProvider CMSite
Set-Location "$($SiteCode):"

$SoftwareUpdateGroup = Get-CMSoftwareUpdateGroup -Name $UpdateGroupName
        
Write-Verbose "UpdateGroup: $($SoftwareUpdateGroup.LocalizedDisplayName)"
$UpdateInfo = @()
$SUGMemberCount = ($SoftwareUpdateGroup.Updates).Count
$cnt = 1
foreach ($Update in Get-CMSoftwareUpdate -UpdateGroupId $SoftwareUpdateGroup.CI_ID -Fast) {
    Write-Verbose "Update ($cnt/$SUGMemberCount) :: $($Update.LocalizedDisplayName)"
    try {
        $CIToContent = @(Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$($SiteCode) -Query "Select * from SMS_CItoContent where CI_ID = '$($Update.CI_ID)'")
        
        Write-Verbose "  Got CIToContent References: $($CIToContent.Count)"
        
        $TotalUpdateSize = 0
        $TotalContentRefs = 0
        $TotalFiles = 0
        foreach ($ContentRef in $CIToContent)  {
            $CIContentFiles = @(Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$($SiteCode) -Query "select * from SMS_CIContentFiles where ContentID = '$($ContentRef.ContentID)'")
            $UpdateSize = 0
            foreach ($file in $CIContentFiles) {
                $UpdateSize += $file.filesize
                $TotalFiles += 1
            }
            $TotalUpdateSize += $UpdateSize
            $TotalContentRefs += 1
        }
        $obj = New-Object pscustomobject -Property @{
                Name = $Update.LocalizedDisplayName
                Size = ($TotalUpdateSize / 1MB)
                TotalContentRefs = $TotalContentRefs
                TotalFiles = $TotalFiles
        }
        Write-Verbose "  Size: $($obj.Size)"
        Write-Verbose "  TotalFiles: $($obj.TotalFiles)"
        $UpdateInfo += $obj
        $cnt += 1
    }
    catch {
        Write-Warning "Error: $($Error[0])"
    }
}

Write-Output "Total size: $(($UpdateInfo.Size | Measure-Object -Sum).Sum)"

$UpdateInfo | Format-Table -AutoSize
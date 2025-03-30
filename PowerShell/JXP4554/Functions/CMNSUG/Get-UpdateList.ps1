<#
.Synopsis
   Lists assigned software updates in a configuration manager 2012 software update group
.DESCRIPTION
   Lists all assigned software updates in a configuration manager 2012 software update group that is selected 
   from the list of available update groups or provided as a command line option
.EXAMPLE
   Get-UpdateGroupcontent.ps1
.EXAMPLE
   Get-UpdateGroupcontent.ps1 -UpdateGroup "Win7x64_12_11_15"


#>

[CmdletBinding()]


param(


    # Software Update Group
    [Parameter(Mandatory = $false, ValueFromPipeline=$true)]
    [String] $UpdateGroup,
    [Parameter(Mandatory = $false)]
    [string] $SiteCode = "TST"
    )

Function Get-UpdateGroupcontent
{
    # Load ConfigMgr module if it isn't loaded already
    if (-not(Get-Module -name ConfigurationManager)) 
    {
        Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
    }

    # Change to site
    Push-Location
    Set-Location ${SiteCode}:


    #Set-CMQueryResultMaximum -Maximum 5000


    if ($UpdateGroup.Length -eq 0) 
    {
        $UpdateGroup = Get-CMSoftwareUpdateGroup | Select-Object LocalizedDisplayName | Out-GridView -Title "Select the Software Update Group " -PassThru 
    }
    Else
    {
        $UpdateGroup = Get-CMSoftwareUpdateGroup | Where-Object {$_.LocalizedDisplayName -like "$($UpdateGroup)"} |  Select-Object LocalizedDisplayName 
    }

    $info = @()

    ForEach ($item in $UpdateGroup)
    {
       Write-host "Processing Software Update Group" $($item.LocalizedDisplayName)
       forEach ($item1 in (Get-CMSoftwareUpdate -UpdateGroupName $($item.LocalizedDisplayName)))
       {
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name ArticleID -Value "KB$($item1.ArticleID)"
        $object | Add-Member -MemberType NoteProperty -Name BulletinID -Value $item1.BulletinID
        $object | Add-Member -MemberType NoteProperty -Name Title -Value $item1.LocalizedDisplayName
        $info += $object
        }
    }


    $Title = "Total assigned software updates in " + $item.LocalizedDisplayName + " = " + $info.count
    $info | Out-GridView -Title "$Title"
}


# -----------------------------------------------------------------------------------------------------*
# Get the list of software updates in the selected update group
Get-UpdateGroupcontent
Pop-Location
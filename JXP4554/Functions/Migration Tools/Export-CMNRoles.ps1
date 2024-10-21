PARAM
(
    [Parameter(Mandatory=$true)]
    [String[]]$ComputerName,
    [Parameter(Mandatory=$true,HelpMessage='Where to put the exported files')]
    [ValidateScript({Test-Path $_ -PathType ‘Container’})] 
    [String]$ExportPath
)

foreach($SiteServer in $ComputerName)
{
    $SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer
    if(!(Test-Path "$ExportPath\$($SCCMConnectionInfo.SiteCode)"))
    {
        New-Item -Name ($SCCMConnectionInfo.SiteCode) -Path $ExportPath -ItemType Directory | Out-Null
    }

    Push-Location
    Set-Location "$($SCCMConnectionInfo.SiteCode):"
    $Roles = Get-CMSecurityRole
    foreach($Role in $Roles)
    {
        if(!$Role.IsBuiltIn)
        {
            Write-Verbose "Exporting $($Role.RoleName)"
            Export-CMSecurityRole -Path "$ExportPath\$($SCCMConnectionInfo.SiteCode)\$($Role.RoleName).xml" -RoleId $Role.RoleID
        }
        else
        {
            Write-Verbose "Not Exporting $($Role.RoleName)"
        }
    }
    Pop-Location
}
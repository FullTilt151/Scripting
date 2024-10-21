Function Get-CMNADSites {
    <#
    .SYNOPSIS
        Gets sites from current domain

    .DESCRIPTION
        Gets sites from current domain

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    2018-12-26
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0
        http://powershellblogger.com/2015/10/export-subnets-from-active-directory-sites-and-services/	
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM()

    $sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites

    $sitesubnets = @()

    foreach ($site in $sites) {
        foreach ($subnet in $site.subnets) {
            $temp = New-Object PSCustomObject -Property @{
                'Site'   = $site.Name
                'Subnet' = $subnet.Name; 
            }
            $sitesubnets += $temp
        }
    }
    Return $sitesubnets
} #End Get-CMNADSites

Get-CMNADSites
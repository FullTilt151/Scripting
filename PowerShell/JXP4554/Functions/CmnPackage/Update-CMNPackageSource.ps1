Function Update-CMNPackageSource {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER ObjectID

	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package ID')]
        [String[]]$PackageIDs,

        [Parameter(Mandatory = $true, HelpMessage = 'Updated Pacakge Source')]
        [String]$PackageSource,

        [string]$logname = 'Update-CMNPackageSource.txt'
    )

    begin {
    }

    process {
        write-verbose "Beginning process loop"

        foreach ($PackageID in $PackageIDs) {
            if ($PSCmdlet.ShouldProcess($PackageID)) {
                $Package = Get-WmiObject -Class SMS_Package -Namespace root/sms/site_$($sccmConnectionInfo.SiteCode) -ComputerName $sccmConnectionInfo.ComputerName -Filter "PackageID = '$PackageID'"

                Write-Verbose "Processing $($Package.Name)"

                $Package.Get()
                $Package.PkgSourcePath = $PackageSource
                $Package.RefreshPkgSourceFlag = $true

                Write-Verbose 'Applying settings'
                $Package.Put()

                Write-Output $Package
            }
        }
    }

    end {
    }
} #End Update-CMNPackageSource

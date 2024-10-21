Function Get-CMNRoleOnPackage {
    <#
	.SYNOPSIS
		This Function will get all the roles on a Package

	.DESCRIPTION
		You provide the ObjectID to add the scope to, the Type of object, and the RoleName. If you add a role that already exists,
		the function will behave the same as if the role wasn't there. In either case, the role will be there afterwards.

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"
		}

	.PARAMETER ObjectID
		This is the ID of the object to add the role to (PackageID, DriverID, etc.)

	.PARAMETER ObjectTypeID
		ObjectTypeID for the object you are working with. Valid values are:
			2 - SMS_Package
			3 - SMS_Advertisement
			7 - SMS_Query
			8 - SMS_Report
			9 - SMS_MeteredProductRule
			11 - SMS_ConfigurationItem
			14 - SMS_OperatingSystemInstallPackage
			17 - SMS_StateMigration
			18 - SMS_ImagePackage
			19 - SMS_BootImagePackage
			20 - SMS_TaskSequencePackage
			21 - SMS_DeviceSettingPackage
			23 - SMS_DriverPackage
			25 - SMS_Driver
			1011 - SMS_SoftwareUpdate
			2011 - SMS_ConfigurationBaselineInfo
			5000 - SMS_Collection_Device
			5001 - SMS_Collection_User
			6000 - SMS_ApplicationLatest
			6001 - SMS_ConfigurationItemLatest

	.PARAMETER RoleName
		The Role to add to the Object

	.EXAMPLE
		Add-CMNRoleOnObject 'CAS003F2' 2 'Workstations'

		This will add the Workstations Role to PackageID CAS003F2

	.EXAMPLE
		'CAS003F2' | Add-CMNRoleOnObject -ObjectTypeID 2 -RoleName 'Workstations'

		This will add the Workstations role to PacakgeID CAS003F2

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageID to get roles on',
            ValueFromPipeLine = $true)]
        [String[]]$PackageID
    )

    begin {}

    process {
        Write-Verbose 'Starting Get-CMNRoleOnPackage'
        foreach ($PkgID in $PackageID) {
            if ($PSCmdlet.ShouldProcess($PkgID)) {
                Return (Get-WmiObject -Class SMS_Package -Filter "PackageID = '$PkgID'" @WMIQueryParameters).SecuredScopeNames
            }
        }
    }

    end {}
} #End Get-CMNRoleOnPackage

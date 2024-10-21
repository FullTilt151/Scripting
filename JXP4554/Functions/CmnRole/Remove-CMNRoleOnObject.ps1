Function Remove-CMNRoleOnObject {
    <#
	.SYNOPSIS
		This Function will remove a role from an object
	.DESCRIPTION
		You provide the ObjectID to remove the scope from, the Type of object, and the RoleName

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.EXAMPLE
		Remove-CMNRoleOnObject 'CAS003F2' 2 'Workstations'

		This will remove the Workstations Role from PackageID CAS003F2

	.PARAMETER ObjectID
		This is the ID of the object to remove the role from

	.PARAMETER ObjectTypeID
		ObjectTypeID for the object you are working with. Valid values are:
			2
			3
			7
			8
			9
			11
			14
			17
			18
			19
			20
			21
			23
			25
			1011
			2011
			5000
			5001
			6000
			6001

	.PARAMETER RoleName
		The Role to remove from the Object

	.NOTES
		If you remove a role that is not there, the function generate an error

		https://social.technet.microsoft.com/Forums/en-US/d3e0d59a-2f6e-4e35-90b7-cea730436f88/how-do-i-use-the-powershell-parameter-securedscopenames-within-setcmpackage?forum=configmanagergeneral
		https://msdn.microsoft.com/en-us/library/hh948702.aspx
		https://msdn.microsoft.com/en-us/library/hh948196.aspx

	.LINK
		http://configman-notes.com
	#>

    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Package to Add Scope to')]
        [Array]$ObjectID,

        [Parameter(Mandatory = $true, HelpMessage = 'ObjectTypeID')]
        [ValidateSet('2', '3', '7', '8', '9', '11', '14', '17', '18', '19', '20', '21', '23', '25', '1011', '2011', '5000', '5001', '6000', '6001')]
        [String]$ObjectTypeID,

        [Parameter(Mandatory = $true, HelpMessage = 'Role to add')]
        [String]$RoleName
    )

    #New-LogEntry 'Starting Script' 1 'Remove-CMNRoleOnObject'
    [ARRAY]$SecurityScopeCategoryID = (Get-WmiObject -Class SMS_SecuredCategory -Filter "CategoryName = '$RoleName'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).CategoryID

    Invoke-WmiMethod -Name RemoveMemberShips -Class SMS_SecuredCategoryMemberShip -ArgumentList $SecurityScopeCategoryID, $ObjectiD, $ObjectTypeID -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName | Out-Null
} #End Remove-CMNRoleOnObject

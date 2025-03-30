Function New-CMNSCCMSiteSystemCollections {
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
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Folder to put the collections in (0 for root)')]
        [String]$CollectionFolder
    )

    begin {
        $ContainerID = Get-CMNObjectContainerNodeID -SCCMConnectionInfo $sccmConnectionInfo -Name $CollectionFolder -ObjectType SMS_Collection_Device
    }

    process {
        write-verbose "Beginning process loop"
        $roles = Get-WmiObject -Class SMS_R_System -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName | Select-Object -ExpandProperty SystemRoles | Sort-Object -Unique
        foreach ($role in $roles) {
            $collectionName = "SCCM $($role -replace 'SMS (.*)','$1')"
            $collection = Get-WmiObject -Class SMS_Collection -Filter "Name = '$collectionName'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            if ($collection) {
                Write-Verbose "$($collection.Name) already exists, skipping."
                if ($ContanerID -ne 0) {Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $collection.CollectionID -destinationContainerID $ContainerID -objectType SMS_Collection_Device | Out-Null}
            }
            else {
                Write-Verbose "Creating $collectionName"
                $collection = New-CMNDeviceCollection -SCCMConnectionInfo $sccmConnectionInfo -Comment "SCCM $role Systems" -LimitToCollectionID SMS00001 -Name $collectionName
                $query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemRoles = '$role'"
                New-CMNDeviceCollectionQueryMemberRule -SCCMConnectionInfo $sccmConnectionInfo -CollectionID $collection.CollectionID -query $query -ruleName $role | Out-Null
                [DateTime]$startTime = Get-Date "01:00 AM"
                New-CMNDailySchedule -SCCMConnectionInfo $sccmConnectionInfo -collectionID $collection.CollectionID -startTime $startTime | Out-Null
                if ($ContanerID -ne 0) {Move-CMNObject -SCCMConnectionInfo $sccmConnectionInfo -objectID $collection.CollectionID -destinationContainerID $ContainerID -objectType SMS_Collection_Device | Out-Null}
            }
        }
    }

    end {
    }
} #End New-CMNSCCMSiteSystemCollections

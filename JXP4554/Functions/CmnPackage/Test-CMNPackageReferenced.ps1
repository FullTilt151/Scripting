Function Test-CMNPKGReferenced {
    #Rename 
    <#
        .Synopsis
            This function will return true if the PackageID is referenced by a task sequence or used in a deployment

        .DESCRIPTION
            This function will return true if the PackageID is referenced by a task sequence or used in a deployment

        .PARAMETER PackageID
            This is the PackageID to be checked

        .EXAMPLE

        .LINK
            http://configman-notes.com

        .NOTES

        #>
    Param
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [parameter(Mandatory = $True)]
        [String]$PackageID
    )

    $WMIQueryParameters = $sccmConnectionInfo.WMIParameters
    #New-LogEntry 'Starting Function IsPKGReferenced' 1 'IsPKGReferenced'
    $Package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$PackageID'" @WMIQueryParameters
    #New-LogEntry "Package - $PackageID" 1 'IsPKGReferenced'
    $IsPKGReferenced = $false

    #Check for task sequence
    $TaskSequence = Get-WmiObject -Class SMS_TaskSequenceReferencesInfo -Filter "ReferencePackageID = '$PackageID'"  -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    if ($TaskSequence) {
        $IsPKGReferenced = $True
        #New-LogEntry 'It is referenced by a task sequence' 1 'IsPKGReferenced'
    }
    else {
        #New-LogEntry 'It is not referenced by a task sequence' 1 'IsPKGReferenced'
    }

    #Check for distribution
    $DistributionStatus = Get-WmiObject -Class SMS_Advertisement -Filter "PackageID = '$PackageID'"  -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    if ($DistributionStatus) {
        $IsPKGReferenced = $True
        #New-LogEntry 'It is referenced by a distribution' 1 'IsPKGReferenced'
    }
    else {
        #New-LogEntry 'It is not referenced by a distribution' 1 'IsPKGReferenced'
    }
    #New-LogEntry "End Function - Returning $IsPKGReferenced" 1 'IsPKGReferenced'
    return $IsPKGReferenced
} #End Test-CMNPKGReferenced

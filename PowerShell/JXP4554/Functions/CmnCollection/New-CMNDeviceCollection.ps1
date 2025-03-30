Function New-CMNDeviceCollection {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true)]
        [String]$comment,

        [Parameter(Mandatory = $true)]
        [String]$limitToCollectionID,

        [Parameter(Mandatory = $true)]
        [String]$name
    )

    begin {}

    process {
        if ($PSCmdlet.ShouldProcess($Name)) {
            $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$LimitToCollectionID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            $SCCMCollection = ([WMIClass]"\\$($sccmConnectionInfo.ComputerName)\root\SMS\Site_$($sccmConnectionInfo.SiteCode):SMS_Collection").CreateInstance()
            $SCCMCollection.CollectionType = 2
            $SCCMCollection.Comment = $Comment
            $SCCMCollection.Name = $Name
            $SCCMCollection.LimitToCollectionID = ($LimitingCollection.CollectionID)
            $SCCMCollection.LimitToCollectionName = ($LimitingCollection.Name)
            $SCCMCollection.RefreshType = 1 #Manual
            $SCCMCollection.Put()
            $SCCMCollection.Get()
            #$SCCMCollection.PSObject.TypeNames.Insert(0,'CMN.BitFlagSet')
        }
    }

    end {
        return $SCCMCollection
    }
} #End New-CMDeviceCollection

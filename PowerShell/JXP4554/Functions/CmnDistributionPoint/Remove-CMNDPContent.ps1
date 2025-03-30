Function Remove-CMNDPContent {
    <#
    .Synopsis
        This function will remove the package from the DP's and DP Group's.

    .DESCRIPTION
        This function will remove the package from the DP's and DP Group's.

    .PARAMETER PackageID
        This is the PackageID to be removed

	.PARAMETER DPKeeps
		This is the list of DP Group's that if the package is on, should be kept on.

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

        [Parameter(Mandatory = $true)]
        [String]$PackageID,

        [Parameter(Mandatory = $false)]
        [Array]$DPkeeps = @()
    )

    #First, get a list of DP/DPGroup's the package is on
    Write-Verbose 'Starting Function Remove-CMNDPContent'
    Write-Verbose "Package -  $PackageID"

    #Get DP deployment status for PackageID
    $DPStatus = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter "ObjectID = '$PackageID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName

    #Go through and remove each DP/DPGroup, if it exists
    if ($DPStatus) {
        foreach ($DP in $DPStatus) {
            if ($DP.Name -match '\\') {
                $DPName = $DP.Name -replace '([\[])', '[$1]' -replace '(\\)', '$1' -replace '\\\\(.*)', '$1'
            }
            else {
                $DPName = $DP.Name
            }

            foreach ($DPK in $DPKeeps) {
                if ($DPName -match $DPK) {
                    #New-LogEntry "Package $PackageID exists on a $DPName so we'll need to add that back." 1 'Remove-CMDPPackage'

                    #See if it's in the list
                    $DPKeepExists = $false
                    foreach ($x in $DPTargets) {
                        if ($DPName -match $x) {$DPKeepExists = $true}
                    }

                    if (-not ($DPKeepExists)) {
                        $DPTargets = $DPTargets + $DPName
                    }
                }
            }
            if ($DP.ContentServerType -eq 1) { 
                #Is it on a DP 
                Write-Verbose "Removing Package $PackageID from $DPName"
                $DistPoint = Get-WmiObject -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName -Class SMS_DistributionPoint -Filter "PackageID = '$PackageID'" | Where-Object {$_.ServerNALPath -match $DPName}
                $DistPoint | Remove-WmiObject
            }
            else {
                #It's on a DP Group
                Write-Verbose "Removing Package $PackageID from $DPName"
                $DistPointGroup = Get-WmiObject -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName -Class SMS_DPGroupContentInfo -Filter "PackageID = '$PackageID'"
                $DistPointGroupInfo = Get-WmiObject -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName -Class SMS_DistributionPointGroup  -Filter "GroupID = '$($DistPointGroup.GroupID)'"# and PkgID = '$PackageID'"
                $DistPointGroupInfo.RemovePackages($PackageID) | Out-Null
            }
        }
        Return , $DPkeeps
    }
    #If DPStatus is null, no package content is distributed
    else {
        Write-Verbose "Package $PackageID is not currently distributed"
    }
} #End Remove-CMNDPContent

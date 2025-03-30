<#
		[Parameter(
			Mandatory = $true,
			HelpMessage = 'SCCM Connection Info')]
		[PSObject]$SCCMConnectionInfo,

	@WMIQueryParameters
	http://www.get-blog.com/?p=189
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'SCCM Connection Info')]
    [PSObject]$SCCMConnectionInfo,

    [Parameter(Mandatory = $false)]
    [Switch]$ShowProgress,

    [parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [string]$LogFile = 'C:\Temp\Error.log',

	[Parameter(Mandatory = $false,
		HelpMessage = 'Max Log size')]
	[Int32]$maxLogSize = 5242880,

	[Parameter(Mandatory = $false,
        HelpMessage = 'Max number of history logs')]
    [Int32]$maxHistory = 5

)

$WMIQueryParameters = $SCCMConnectionInfo.WMIParameters

$NewCMNLogEntry = @{
	LogFile = $LogFile;
	Component = 'Clean-CMNUnreferencedPackages';
	maxLogSize = $maxLogSize;
	maxHistory = $maxHistory;
}

Write-Verbose "Get a list of the packageID's in the site"

$packageIDs = (Get-WmiObject -Class SMS_Package @WMIQueryParameters).PackageID

Write-Verbose 'Get the WMI version of the DPGroup Name'
$dpGroupWMI = ConvertTo-CMNWMISingleQuotedString -Text $dpGroup
$dpGroupID = Get-WmiObject -Class SMS_DPGroupInfo -Filter "Name = '$dpGroupWMI'" @WMIQueryParameters
$dpGroupMembers = Get-WmiObject -Class SMS_DPGroupMembers -Filter "GroupID = '$($dpGroupID.GroupID)'" @WMIQueryParameters

Write-Verbose 'Build HashTable Template'
$dpHashTable = @{}
$dpNames = @()
$dpHashTable.Add($dpGroup,$false)
$dpNames += $dpGroup
foreach($dp in $dpGroupMembers.DPNalPath)
{
    $dpName = $dp -replace '\["Display=\\\\([^.]+).*','$1'
    $dpHashTable.Add($dpName,$false)
    $dpNames += $dpName
}

$intPackageCount = 1

foreach($packageID in $packageIDs)
{
    Write-Verbose "Grabbing package $packageID"
    if($packageID -eq 'MT100015')
    {
        Write-Verbose 'This one'
    }
    $package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" @WMIQueryParameters
    $package.Get()
    if($ShowProgress)
    {
        Write-Progress -Activity "Processing Package $intPackageCount of $($packageIDs.Count)" -Id 1 -Status "$($package.Name) - $($package.PackageID)" -PercentComplete ($intPackageCount / $packageIDs.Count * 100)
        $intPackageCount++
    }

    Write-Verbose "`tWorking Package $($package.Name)"
    Write-Verbose "`tGetting deployments"
    $deployments = Get-WmiObject @WMIQueryParameters -Class SMS_Advertisement -Filter "PackageID = '$packageID'"

    Write-Verbose "`tChecking if $($package.PkgSourcePath) exists"
    if($package.PkgSourceFlag -eq 2){$isPkgSourcePathValid = (Test-Path -Path $package.PkgSourcePath) -or (-not ($package.PkgSourcePath -match '^\\\\'))}
    else{$isPkgSourcePathValid = $true}

    if($isPkgSourcePathValid){Write-Verbose "`tPackage Path is valid!"}
    else{Write-Verbose "`t*** INVALID PACKAGE PATH ***"}

    Write-Verbose "`tGetting DP status for the packages"
    $DPStatus = Get-WmiObject -Class SMS_PackageContentServerInfo -Filter "ObjectID = '$packageID'" @WMIQueryParameters

    if($isPkgSourcePathValid)
    {
        $isCopyContentSet = Test-CMNBitFlagSet -BitFlagHashTable $SMS_Package_PkgFlags -KeyName COPY_CONTENT -CurrentValue $package.PkgFlags
        $isRunFromDP = $false
        $isCopyFlagChange = $false

        Write-Verbose "`tFinding out if there are any deployments that are run from DP"
        foreach($deployment in $deployments)
        {
            if(Test-CMNBitFlagSet -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RUN_FROM_REMOTE_DISPPOINT -CurrentValue $Deployment.RemoteClientFlags){$isRunFromDP = $true}
        }

        Write-Verbose "`tisRunFromDP = $isRunFromDP"

#        if(Test-CMNPKGReferenced -SCCMConnectionInfo $SCCMConnectionInfo -PackageID $packageID)
#        {
            Write-Verbose "`tPackage is referenced by a deployment/task sequence"
            $isCopyFlagChange = $false
            if($isRunFromDP)
            {
                #Yes - Set Copy Content
                if(-not $isCopyContentSet)
                {
                    Write-Verbose "`t`tSetting copy content flag"
                    $package.PkgFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Package_PkgFlags -KeyName COPY_CONTENT -CurrentValue $package.PkgFlags
                    $package.put() | Out-Null
                    $isCopyFlagChange = $true
                }
            }
            else
            {
                #No - Clear Copy Content
                if($isCopyContentSet)
                {
                    Write-Verbose "`t`tClearing copy content flag"
                    $package.PkgFlags = Set-CMNBitFlagForControl -ProposedValue $false -BitFlagHashTable $SMS_Package_PkgFlags -KeyName COPY_CONTENT -CurrentValue $package.PkgFlags
                    $package.put() | Out-Null
                    $isCopyFlagChange = $true
                }
            }

            Write-Verbose "`tFiguring out what DP's this package is on."

            foreach($dp in $dpNames)
            {
                $dpHashTable[$dp] = $false
            }

            $isOnDPGroup = $true
            foreach($dp in $DPStatus)
            {
                $matchString = "SMS_Site=$($SCCMConnectionInfo.SiteCode)"
                if($dp.ContentServerID -match $matchString -or $dp.DPType -eq 3)
                {
                    if ($DP.Name -match '\\')
                    {
                        $DPName = $DP.Name -replace '\\\\([^.]+).*','$1'
                        if($dpHashTable.ContainsKey($DPName)){$dpHashTable[$DPName] = $true}
                        else{$isOnDPGroup = $false}
                    }
                    else
                    {
                        $DPName = $DP.Name
                        if($dpHashTable.ContainsKey($DPName)){$dpHashTable[$DPName] = $true}
                        else{$isOnDPGroup = $false}
                    }
                }
            }

            foreach($dp in $dpHashTable.GetEnumerator())
            {
                if(-not ($dp.value)){$isOnDPGroup = $false}
            }

            if($isOnDPGroup)
            {
                Write-Verbose "`tPackage $($package.Name) is already on $dpGroup!!!!"
            }
            else
            {
                Write-Verbose "`tPackage $($package.Name) isn't correctly distributed to $dpGroup"
            }

            if($isCopyFlagChange -and $isOnDPGroup)
            {
                Write-Verbose "`t`tRefreshing package $($package.Name)"
                $package.RefreshPkgSource() | Out-Null
            }
            elseif(-not $isOnDPGroup)
            {
                Write-Verbose "`t`tRemove all content from DP's"
                Remove-CMNDPContent -SCCMConnectionInfo $SCCMConnectionInfo -PackageID $package.PackageID

                Write-Verbose "`t`tSleeping 30 seconds"
                start-sleep -Seconds 30

                Write-Verbose "`t`tDeploying content to $dpGroup"
                Start-CMNPackageContentDistribution -SCCMConnectionInfo $SCCMConnectionInfo -PackageID $package.PackageID -DPGroup $dpGroup | Out-Null
            }
        }
 <#       else
        {
            if($DPStatus)
            {
                Write-Verbose "`tNot being deployed, removing content from DP's"
                Remove-CMNDPContent -SCCMConnectionInfo $SCCMConnectionInfo -PackageID $packageID
            }
        }
    }#>
    else
    {
        if($DPStatus)
        {
            Write-Verbose "`t****Package with invalid path has content distributed, removing from DP's"
            Remove-CMNDPContent -SCCMConnectionInfo $SCCMConnectionInfo -PackageID $packageID
        }
    }
    Write-Verbose "Finished with $($package.Name)"
}
if($ShowProgress){Write-Progress -Activity 'Processing packages' -ID 1 -Completed}
param(
    $SiteServer = 'LOUAPPWPS1658',
    $TaskSequencePackageID = 'WP1000D2'
)

# Gather site code from Site Server
$SiteCode = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\SMS" -Class "SMS_ProviderLocation").SiteCode

# Query the SQL DB for Package ID, version, and hash
$sqlserver = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Class SMS_SCI_SiteDefinition).SQLServerName
$sqldb = "CM_$SiteCode"
$sqlquery = "
SELECT DISTINCT [PkgID], ContentDPMap.Version, [NewHash]
FROM ContentDPMap
INNER JOIN SMSPackages ON ContentDPMap.ContentID = SMSPackages.PkgID
WHERE AccessType = 1
and PackageType not in (5,8) 
AND ContentID in (select RefPackageID from v_TaskSequencePackageReferences where PackageID = '$TaskSequencePackageID')"

$connection_string = "server=$sqlserver;database=$sqldb;integrated security=true"
$sqlConnection = new-object System.Data.SqlClient.SqlConnection $connection_string
$sqlConnection.Open()
$adapter = new-object data.sqlclient.sqldataadapter($sqlquery, $sqlConnection)
$set = new-object data.dataset
$adapter.fill($set) | out-null
$TSPackageInfo = new-object data.datatable
$TSPackageInfo = $set.tables[0]
$sqlConnection.Close()

# Get list of all DPs
$DPList = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Class SMS_DistributionPointInfo).ServerName

workflow Validate-DPLsZHash {

foreach -parallel ($Package in $TSPackageInfo) {
    foreach -parallel ($DP in $DPList) {
        $DPCompliance = New-Object System.Object
        $DPCompliance | Add-Member -MemberType NoteProperty -Name $DP -Value 
        $HashMatrix += $Package.PkgID

        # Get Nomad LocalCachePath for each DP found
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
        $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\")
        $DPLocalCachePath = $ref.GetValue("LocalCachePath")
    
        # Get LsZ files for each references package
        $DPLsZFiles = Get-ChildItem "\\$_\$($DPLocalCachePath.Replace(':','$'))\LSZfiles" 
    
        #$DPLsZFiles.Where({$_.Name.Split('_')[0] -in $TSPackageInfo.PkgID})
        #$DPLsZHash = (Get-Content $_.FullName | Select-String 'HashV4').ToString().Split(' ')[1]
    }
}

}
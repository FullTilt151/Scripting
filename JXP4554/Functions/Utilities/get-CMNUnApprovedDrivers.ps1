Function get-SQLQuery
{
    PARAM
    (
    [Parameter(Mandatory=$true)]
    [String]$DataSource,
    [Parameter(Mandatory=$true)]
    [String]$Database,
    [Parameter(Mandatory=$true)]
    [String]$SQLCommand
    )
    $ConnectionString = "Data Source=$DataSource;" +
    "Integrated Security=SSPI; " +
    "Initial Catalog=$Database"

    $Connection = new-object system.data.SqlClient.SQLConnection($ConnectionString)
    $Command = new-object system.data.sqlclient.sqlcommand($SQLCommand,$Connection)
	$Command.CommandTimeout = 300
    $Connection.Open()

    $Adapter = New-Object System.Data.sqlclient.sqlDataAdapter $Command
    $DataSet = New-Object System.Data.DataSet
    $Adapter.Fill($DataSet) | Out-Null

    $Connection.Close()

    Return $DataSet.Tables
}

$CSVFile = 'c:\temp\DriverVersions.csv'
$Header = "Driver,Version,Count"
$Header | Out-File $CSVFile
$DataSource = "LOUSQLWPS401"
$Database = "CM_CAS"
$SQLCommand = "SELECT DISTINCT CIM.ModelName, DCI.DriverVersion
FROM         v_DriverContentToPackage CTP INNER JOIN
                      v_ConfigurationItems CFI ON CTP.CI_ID = CFI.CI_ID INNER JOIN
                      v_DriverContentToPackage DTP ON DTP.PkgID = CTP.PkgID INNER JOIN
                      v_CI_DriversCIs DCI ON DCI.CI_ID = CFI.CI_ID INNER JOIN
                      v_CI_DriverModels CIM on CFI.CI_ID = CIM.CI_ID
Where	CIM.ModelName not like '%Realtek%'
		and CIM.ModelName not like '%wlan%'
		and CIM.ModelName not like '%Sierra%'
		and CIM.ModelName not like '%WIMAX%'
		and CIM.ModelName not like '%USB%'
		and CIM.ModelName not like '%Novatel%'
		and CIM.ModelName not like '%Mobile%'
		and CIM.ModelName like '%Wireless%'
ORDER BY CIM.ModelName"
$ApprovedDrivers = get-SQLQuery $DataSource $Database $SQLCommand
$ApprovedDrivers | ConvertTo-Csv -NoTypeInformation | Out-File 'C:\Temp\ApprovedDrivers.csv'

foreach($ApprovedDriver in $ApprovedDrivers)
{
    if($CurrentDriver -ne $ApprovedDriver.ModelName)
        {
        $CurrentDriver = $ApprovedDriver.ModelName
        $SQLCommand = "select Version0, DriverDesc0, DriverVersion0, count(*) [Total]
            from v_r_system SYS join
            v_GS_NETWORK_drivers NET ON sys.ResourceID = NET.ResourceID join
            v_GS_COMPUTER_SYSTEM CS ON SYS.ResourceID = CS.ResourceID join
            v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = CSP.ResourceID
            where DriverDesc0 = '$($ApprovedDriver.ModelName)' and
            DriverVersion0 > '$($ApprovedDriver.DriverVersion)'
            group by Version0, DriverDesc0, DriverVersion0"
        $InstalledDrivers = get-SQLQuery $DataSource $Database $SQLCommand
        foreach($InstalledDriver in $InstalledDrivers)
        {
            $Drivers = $InstalledDriver | ConvertTo-Csv
            $Drivers[2] | Out-File $CSVFile -Append
        }
    }
}
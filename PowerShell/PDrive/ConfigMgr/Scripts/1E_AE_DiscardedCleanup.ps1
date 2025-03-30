<#  
	.NOTES
	===========================================================================
	 Created on:   	1/22/2019
	 Created by:   	Richard.Fellows
	 Organization: 	1E Ltd Copyright 2018
	 Filename: AE_DiscardedCleanup.ps1
	 Version: 1.0
	===========================================================================
	.DESCRIPTION
		This script is intended remove devices with 'Discarded-Guid'
     

        
 Disclaimer:                                                                                                                                                                                                                                        
 Your use of this script is at your sole risk. This script is provided "as-is", without any warranty, whether express               
 or implied, of accuracy, completeness, fitness for a particular purpose, title or non-infringement, and is not                      
 supported or guaranteed by 1E. 1E shall not be liable for any damages you may sustain by using this script, whether      
 direct, indirect, special, incidental or consequential, even if it has been advised of the possibility of such damages. 
#>
$commandTimeout = "0" # configurable timeout for SQL commands default is 1200 seconds / 20 mins
$AESErverName = "SERVERNAME,PORT"
$AEDatabaseName = "ActiveEfficiency"


if (!$AEServerName){
    $AEServerName = read-host -Prompt "Type the instance name (SERVER1\PROD1) or the servername (MYSQLSERVER) `n that is hosting the ActiveEfficiency database?"
}
if (!$AEDatabaseName){
    if(($AEDatabaseName = Read-Host "type the database name? or Press enter to accept default name [ActiveEfficiency]") -eq ''){$AEDatabaseName ="ActiveEfficiency"}else{$AEDatabaseName}
}

$AESQLConnectString = "Server=$AEServerName;Database=$AEDatabaseName;Trusted_Connection=True;;MultipleActiveResultSets=true;"
"-------------------------------------------------------------------------------"
"SQLConnectionString for the ActiveEfficiency database is: `n '$AESQLConnectString'" 
"-------------------------------------------------------------------------------"

function qryExecute([string]$qry,[string]$connection)
{
	    $SqlCon = New-Object System.Data.SqlClient.SqlConnection
	    $SqlCon.ConnectionString = $connection
	    $SqlCon.Open()
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
	    $SqlCmd.CommandText = $qry
	    $SqlCmd.Connection = $SqlCon
        $SqlCmd.CommandTimeout = $commandTimeout
	    [void]$SqlCmd.ExecuteNonQuery()
	    $sqlCon.Close()

}

$qryPurgeDiscarded = @"
IF OBJECT_ID( 'tempdb..#tblDeviceList' ) IS NOT NULL DROP TABLE #tblDeviceList;
IF OBJECT_ID( 'tempdb..#tblList' ) IS NOT NULL DROP TABLE #tblList;

WITH Data AS (
SELECT 
   Id
    from Devices d
    where fqdn like 'discarded%'
)
SELECT *
into #tblDeviceList
FROM
   Data
;

--setup a table to hold our devicelist to purge
CREATE  TABLE #tblList(
       ID uniqueidentifier
);

--grab all device ids
INSERT INTO #tblList (ID) 
Select TOP 100000 Id from  #tblDeviceList 

-- purge DeviceSystemProperties
BEGIN
       DELETE d FROM DeviceSystemProperties d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging DeviceIdentities
BEGIN
       DELETE d from DeviceIdentities d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

--purging AdapterConfigurations
BEGIN
       DELETE d from AdapterConfigurations d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging ContentDeliveries
BEGIN
       DELETE d from ContentDeliveries d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END 

--purging ApplicationUsage
BEGIN
       DELETE d from ApplicationUsage d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

--purging ApplicationUsageOverride
BEGIN
       DELETE d from ApplicationUsageOverride d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END 

-- purging DeviceTags
BEGIN
       DELETE d from  DeviceTags d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END 

--purging Installations
BEGIN
       DELETE d from Installations d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging OracleUsage
BEGIN
       DELETE d from  OracleUsage d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging SqlUsage
BEGIN
       DELETE d from SqlUsage d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging devices
BEGIN
       DELETE d from  Devices d
       INNER JOIN #tblList dl on 
       d.Id=dl.ID
END
"@


"Purging invalid Devices with FQDN = Discarded"
qryExecute -qry $qryPurgeDiscarded -connection $AESQLConnectString


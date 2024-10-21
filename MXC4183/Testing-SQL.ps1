$AESErverName = "LOUSQLWQS513.rsc.humad.com"
$AEDatabaseName = "ActiveEfficiency"

$AESQLConnectString = "Server=$AEServerName;Database=$AEDatabaseName;Trusted_Connection=True;;MultipleActiveResultSets=true;"

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

$qryTEST = "
Select top 5 HostName
from devices"

#qryExecute -qry $qryTEST -connection $AESQLConnectString
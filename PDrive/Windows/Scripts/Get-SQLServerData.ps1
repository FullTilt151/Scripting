param(
[Parameter(Mandatory=$true)]
$sqlserver = "LOUSQLWPS360",
[Parameter(Mandatory=$true)]
$sqldb = "SecureWipe",
[Parameter(Mandatory=$true)]
$sqlquery = "
select *
from DiskOperationLog
",
[Parameter(Mandatory=$true)]
$username,
[Parameter(Mandatory=$true)]
$password
)

#$connection_string = "server=$sqlserver;database=$sqldb;integrated security=true"
$connection_string = "server=$sqlserver;database=$sqldb;User Id=$username;Password=$password"

$sqlConnection = new-object System.Data.SqlClient.SqlConnection $connection_string
$sqlConnection.Open()

$adapter = new-object data.sqlclient.sqldataadapter($sqlquery, $sqlConnection)

$set = new-object data.dataset
$adapter.fill($set) | out-null
$table = new-object data.datatable
$table = $set.tables[0] 
$table
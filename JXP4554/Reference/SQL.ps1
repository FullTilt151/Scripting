#https://cmatskas.com/execute-sql-query-with-powershell/

[string] $Server = ".\SQLEXPRESS2014"
[string] $Database = "MyDatabase"
[string] $UserSqlQuery = $("SELECT * FROM [dbo].[User]")

# declaration not necessary, but good practice
$resultsDataTable = New-Object System.Data.DataTable
$resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery 

# executes a query and populates the $datatable with the data
function ExecuteSqlQuery  {
	PARAM (
		[Parameter(Mandatory = $true)]
		[String]$Server, 

		[Parameter(Mandatory = $true)]
		[String]$Database,

		[Parameter(Mandatory = $true)]
		[String]$SQLQuery
	)
	$Datatable = New-Object System.Data.DataTable
	$Connection = New-Object System.Data.SQLClient.SQLConnection
	$Connection.ConnectionString = "server='$Server';database='$Database';trusted_connection=true;"
	$Connection.Open()
	$Command = New-Object System.Data.SQLClient.SQLCommand
	$Command.Connection = $Connection
	$Command.CommandText = $SQLQuery
	$Reader = $Command.ExecuteReader()
	$Datatable.Load($Reader)
	$Connection.Close()
    
	return $Datatable
}

#validate we got data
Write-Host ("The table contains: " + $resultsDataTable.Rows.Count + " rows")

Function Get-CMNDatabaseData {
    <#
    .Synopsis
        This function will query the database specified in the connectionString using the query. If it's a SQL server, isSQLServer should be set to true.

    .DESCRIPTION
        This function will query the database specified in the connectionString using the query. If it's a SQL server, isSQLServer should be set to true.
		This script was taken straight out of Learn PowerShell ToolMaking in a Month of Lunches, it's a great book that I used to develop this module.
		Can be found at http://www.manning.com

    .PARAMETER connectionString
        This is the connectionstring to connect to the SQL server

    .PARAMETER query
        query to be executed to retrieve the data

    .PARAMETER isSQLServer
        Lets us know if it's a SQL server

    .EXAMPLE
		Get-CMNSQLQuery 'Data source=SQLServer1;Integrated Security=SSPI;Initial Catalog=Shopping' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$connectionString,
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [switch]$isSQLServer
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandTimeout = 600
    $command.CommandText = $query
    if ($isSQLServer) {
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    }
    else {
        $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
    }
    $dataset = New-Object -TypeName System.Data.DataSet
    $adapter.Fill($dataset) | Out-Null
    $connection.close()
    return $dataset.Tables[0]
} #End Get-CMNDatabaseData

Function Invoke-CMNDatabaseQuery {
    <#
    .Synopsis
        This function will query the database $Database on $DatabaseServer using the $SQLCommand

    .DESCRIPTION
        This function will query the database $Database on $DatabaseServer using the $SQLCommand. It uses windows authentication

    .PARAMETER connectionString
        This is the database server that the query will be run on

    .PARAMETER query
        This is the query to be run

    .PARAMETER isSQLServer
        This is the query to be run

    .EXAMPLE
		Get-CMNSQLQuery 'DB1' 'DBServer' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess = $True,
        ConfirmImpact = 'Low')]
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
    $command.CommandText = $query
    if ($pscmdlet.shouldprocess($query)) {
        $connection.Open()
        $command.ExecuteNonQuery() | Out-Null
        $connection.close()
    }
} #End Invoke-CMNDatabaseQuery

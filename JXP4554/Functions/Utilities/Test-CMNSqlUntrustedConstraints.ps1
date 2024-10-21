[CmdletBinding()]

param(
    [parameter(Mandatory=$true,HelpMessage="Site server where the SMS Provider is installed")]
    [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$SiteServer
)

Function Get-CMSQLQuery
{
    <#
    .Synopsis
        This function will query the database $Database on $DatabaseServer using the $SQLCommand

    .DESCRIPTION
        This function will query the database $Database on $DatabaseServer using the $SQLCommand. It uses windows authentication

    .PARAMETER DatabaseServer
        This is the database server that the query will be run on

    .PARAMETER Database
        This is the database on the server to be queried

    .PARAMETER SQLCommand
        This is the query to be run

    .EXAMPLE
		Get-CMSQLQuery 'DB1' 'DBServer' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>

    PARAM
    (
    [Parameter(Mandatory=$true)]
    [String]$DataBaseServer,

    [Parameter(Mandatory=$true)]
    [String]$Database,

    [Parameter(Mandatory=$true)]
    [String]$SQLCommand
    )
	Write-Verbose 'Starting Function Get-CMSQLQuery'
    $ConnectionString = "Data Source=$DataBaseServer;" +
    "Integrated Security=SSPI; " +
    "Initial Catalog=$Database"

    $Connection = new-object system.data.SqlClient.SQLConnection($ConnectionString)
    $Command = new-object system.data.sqlclient.sqlcommand($SQLCommand,$Connection)
    $Command.CommandTimeout = 0
    $Connection.Open()

    $Adapter = New-Object System.Data.sqlclient.sqlDataAdapter $Command
    $DataSet = New-Object System.Data.DataSet
    $Adapter.Fill($DataSet) | Out-Null

    $Connection.Close()

    Return $DataSet.Tables
}
#End Get-CMSQLQuery
Write-Verbose "Starting Script at $(Get-Date)"
Write-Verbose 'Getting Connection Info'
$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer

$SQLCommand = "Exec sp_MSforeachtable 'DBCC CheckConstraints(''?'')'"
Write-Verbose 'Getting Constraint info'

$Results = Get-CMSQLQuery -DataBaseServer $($SCCMConnectionInfo.SCCMDBServer) -Database $($SCCMConnectionInfo.SCCMDB) -SQLCommand $SQLCommand

foreach($Table in $Results)
{
    foreach($Result in $Table)
    {
        if($Result.Table -ne '[dbo].[Users]')
        {
            $SQLCommand = "Delete from $($Result.Table) where $($Result.Where)"
            Write-Verbose "Cleaning $($Result.Table)"
            $DelResult = Get-CMSQLQuery -DataBaseServer $($SCCMConnectionInfo.SCCMDBServer) -Database $($SCCMConnectionInfo.SCCMDB) -SQLCommand $SQLCommand
        }
    }
    If($Table.Rows.Count -gt 1)
    {
        $SQLCommand = "ALTER TABLE $($Table.Table[0]) with check CHECK CONSTRAINT $($Table.Constraint[0])"
        Write-Verbose "Checking Constraints on $($Table.Table[0])"
    }
    else
    {
        $SQLCommand = "ALTER TABLE $($Table.Table) with check CHECK CONSTRAINT $($Table.Constraint)"
        Write-Verbose "Checking Constraints on $($Table.Table)"
    }
    if($Result.Table -ne '[dbo].[Users]')
    {
        $ConstraintResult = Get-CMSQLQuery -DataBaseServer $($SCCMConnectionInfo.SCCMDBServer) -Database $($SCCMConnectionInfo.SCCMDB) -SQLCommand $SQLCommand
    }
}
Write-Verbose "Finishing script at $(Get-Date)"
[CmdletBinding()]

param(
	[parameter(Mandatory = $true, HelpMessage = "Site server where the SMS Provider is installed")]
	[ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
	[string]$SiteServer
)

Function Get-CMSQLQuery {
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
		[Parameter(Mandatory = $true)]
		[String]$DataBaseServer,

		[Parameter(Mandatory = $true)]
		[String]$Database,

		[Parameter(Mandatory = $true)]
		[String]$SQLCommand
	)
	#Write-Verbose 'Starting Function Get-CMSQLQuery'
	$ConnectionString = "Data Source=$DataBaseServer;" +
	"Integrated Security=SSPI; " +
	"Initial Catalog=$Database"

	$Connection = new-object system.data.SqlClient.SQLConnection($ConnectionString)
	$Command = new-object system.data.sqlclient.sqlcommand($SQLCommand, $Connection)
	$Command.CommandTimeout = 0
	$Connection.Open()

	$Adapter = New-Object System.Data.sqlclient.sqlDataAdapter $Command
	$DataSet = New-Object System.Data.DataSet
	try {
		$Adapter.Fill($DataSet) | Out-Null
	}
	catch [SqlException] {
		if (ex.Number == 1205) {
			#Get-CMSQLQuery 
		}
		else {
			throw $Error[0];
		}    
	}

	$Connection.Close()

	Return $DataSet.Tables
}
#End Get-CMSQLQuery
Write-Verbose "Starting Script at $(Get-Date)"
Write-Verbose 'Getting Connection Info'
$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer

$SQLCommand = "Select Child.Name [Constraint], Parent.Name [Table] From sys.objects Child join sys.objects parent on parent.object_id = Child.parent_object_id where child.type = 'F' order by [Table]"
Write-Verbose 'Getting Constraint info'

$Results = (Get-CMSQLQuery -DataBaseServer $($SCCMConnectionInfo.SCCMDBServer) -Database $($SCCMConnectionInfo.SCCMDB) -SQLCommand $SQLCommand)[0]
$PreviousTable = ''
foreach ($Table in $Results) {
	#Checkingif we're in the same table so we only DBCC CheckConstraint once.
	if ($PreviousTable -ne ($Table.Table)) {
		$PreviousTable = ($Table.Table)
		$SQLCommand = "DBCC CheckConstraints('$($Table.Table)')"
		Write-Verbose "Checking constraints on $($Table.Table)"
		try {
			$Result = Get-CMSQLQuery -DataBaseServer $($SCCMConnectionInfo.SCCMDBServer) -Database $($SCCMConnectionInfo.SCCMDB) -SQLCommand $SQLCommand
		}
		catch [System.Exception] {
			throw "Query failed $Error[0]"
		}
	}
	$SQLCommand = "ALTER TABLE $($Table.Table) with check CHECK CONSTRAINT $($Table.Constraint)"
	Write-Verbose "`tChecking Constraint $($Table.Constraint) on $($Table.Table)"
	try {
		$Result = Get-CMSQLQuery -DataBaseServer $($SCCMConnectionInfo.SCCMDBServer) -Database $($SCCMConnectionInfo.SCCMDB) -SQLCommand $SQLCommand
	}
	catch [System.Exception] {
		throw "Query failed $Error[0]"
	}
}
Write-Verbose "Finishing script at $(Get-Date)"
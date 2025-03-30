Function Get-CMNConnectionString {
    <#
    .Synopsis
        This function will return the connection string

    .DESCRIPTION
        This function will query the database $Database on $DatabaseServer using the $SQLCommand. It uses windows authentication

    .PARAMETER DatabaseServer
        This is the database server that the query will be run on

    .PARAMETER Database
        This is the database on the server to be queried

    .EXAMPLE
		Get-CMNSQLQuery 'DB1' 'DBServer' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$DatabaseServer,
        [Parameter(Mandatory = $true)]
        [String]$Database
    )
    Return "Data Source=$DataBaseServer;Integrated Security=SSPI;Initial Catalog=$Database"
} #End Get-CMNConnectionString

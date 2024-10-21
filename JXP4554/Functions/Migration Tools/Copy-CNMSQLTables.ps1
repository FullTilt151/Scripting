[CMDLetBinding()]
PARAM
(
	[Parameter(Mandatory = $true,
		HelpMessage = "Source SQL Server"
	)]
	[String]$sourceSQLServer,

	[Parameter(Mandatory = $true,
		Helpmessage = 'Source Database'
	)]
	[String]$sourceDatabase,

	[Parameter(Mandatory = $true,
		HelpMessage = "Destination SQL Server"
	)]
	[String]$destinationSQLServer,

	[Parameter(Mandatory = $true,
		Helpmessage = 'Destination Database'
	)]
	[String]$destinationDatabase
)

$sourceCS = Get-CMNConnectionString -DatabaseServer $sourceSQLServer -Database $sourceDatabase
$destinationCS = Get-CMNConnectionString -DatabaseServer $destinationSQLServer -Database $destinationDatabase
$query = "SELECT [caption], [displayname]
FROM   [humana_os_caption_displayname]"
$oss = Get-CMNDatabaseData -connectionString $sourceCS -query $query -isSQLServer

$query = "IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Humana_OS_Caption_DisplayName]') AND type in (N'U')) DROP TABLE [dbo].[Humana_OS_Caption_DisplayName]"
Invoke-CMNDatabaseQuery -connectionString $destinationCS -query $query -isSQLServer

$query = "IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Humana_OS_Caption_DisplayName]') AND type in (N'U'))`
BEGIN`
CREATE TABLE [dbo].[Humana_OS_Caption_DisplayName](`
	[Caption] [nvarchar](100) NOT NULL,`
	[DisplayName] [nvarchar](100) NOT NULL,`
PRIMARY KEY CLUSTERED `
(`
	[Caption] ASC`
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]`
) ON [PRIMARY]`
END"
Invoke-CMNDatabaseQuery -connectionString $destinationCS -query $query -isSQLServer

foreach($os in $oss)
{
    $query = "INSERT INTO [Humana_OS_Caption_DisplayName] ([Caption],[DisplayName])`
    VALUES ('$($os.Caption)','$($os.DisplayName)')"
    Invoke-CMNDatabaseQuery -connectionString $destinationCS -query $query -isSQLServer
}
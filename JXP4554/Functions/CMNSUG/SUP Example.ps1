<#
	WID Connection String
	SQLCMD -S \\.\pipe\MSSQL$MICROSOFT##SSEE\sql\query -E -i "WSUS Database Defragmentation.sql" -o C:\Temp\WSUSMaintenance.log
#>
$WSUSRegPath = 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup'
$WSUSSQLName = (Get-ItemProperty -Path $WSUSRegPath -Name 'SQLServerName').SQLServerName
$WSUSDBName = (Get-ItemProperty -Path $WSUSRegPath -Name 'SQLDatabaseName').SQLDatabaseName
Write-Output "Database Server - $WSUSSQLName; Database $WSUSDBName"
$DBCon = Get-CMNConnectionString -DatabaseServer $WSUSDBName -Database $WSUSDBName
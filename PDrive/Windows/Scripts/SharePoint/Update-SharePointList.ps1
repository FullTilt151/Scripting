$dataSource = 'e:\Reports\SoftwareCertPrioritization.accdb'

$strQuery = "SELECT * FROM [Software Cert Prioritization]"
$dsn = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=$datasource; Jet OLEDB:System Database=system.mdw;"

## create connection object and open the database
$objConn = New-Object System.Data.OleDb.OleDbConnection $dsn
$objCmd  = New-Object System.Data.OleDb.OleDbCommand $strQuery,$objConn
$objConn.Open()

## get query results, populate data-adapter, close connection
$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $objCmd
$dataset = New-Object System.Data.DataSet
[void] $adapter.Fill($dataSet)
$objConn.Close()

## display query results
$dataSet.Tables
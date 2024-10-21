$erroractionpreference = "silentlycontinue"

#$db = "http://workspaces.humana.com/sites/atsdocdb/"
#$list = "{78E4F00E-098D-40B4-BCEF-7532169EF5C8}"

#Select your database and list
#$connString = "Provider=Microsoft.ACE.OLEDB.12.0;WSS;IMEX=2;RetrieveIds=Yes; DATABASE=$db;LIST=$list;"
#$spConn = new-object System.Data.OleDb.OleDbConnection($connString)
#$spConn.open()
#$qry="Select * from list"
#$cmd = new-object System.Data.OleDb.OleDbCommand($qry,$spConn)
#$adapter = new-object System.Data.OleDb.OleDbDataAdapter($cmd)
#$table = new-object System.Data.dataTable
#$adapter.fill($table) > $null

$path = "\\lounaswps01\idrive\d907ats\vandyke"
$exportpath = "E:\"
$exportfile = "msi_idrive.csv"
$msi = @()
$msipath = @()
$i = 0

#Gather list of .msi's on I:\ drive
write-host "Gathering list of .msi files on " -nonewline; write-host $path -foregroundcolor yellow
$msi = get-childitem $path -filter *.msi -recurse

for ($msi[$i]; $i -lt $msi.length; $i++) {
      $msipath = $msi[$i].fullname
}

write-host "Exporting results to " -nonewline; write-host $exportpath$exportfile -foregroundcolor yellow
$msi | select name,fullname | export-csv -notypeinformation $exportpath$exportfile
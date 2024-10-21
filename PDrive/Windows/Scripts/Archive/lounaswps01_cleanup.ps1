#Do not show errors and continue
$ErrorActionPreference = "SilentlyContinue"

#Create the empty arrays
$cert = @()
$dir = @()
$dirlength = @()
$dirsum = @()
$dirsize = @()
$table = @()

#Set the variables
$i = 0
$n = 0
$date = get-date -uformat "%m%d%Y_%I%M%S%p"
$path = "\\lounaswps01\pdrive\workarea\Cleanup\"
$file = "P_Drive_Cleanup_$date.html"

write-host "--------------------------------------------------" -foregroundcolor cyan -backgroundcolor black
write-host "This script queries the ATS Certification Request site for all " -foregroundcolor cyan -nonewline;
write-host "approved, obsolete, " -foregroundcolor yellow -nonewline;
write-host "and" -foregroundcolor cyan -nonewline;
write-host " canceled" -foregroundcolor yellow -nonewline;
write-host " certifications and matches their CR# to the path on P:\d907ats. The CR#, CR Status, Product Title, and size of the folder are then exported to a HTML report located here: " -foregroundcolor cyan -nonewline;
write-host "$path" -foregroundcolor yellow
write-host "--------------------------------------------------" -foregroundcolor cyan -backgroundcolor black
write-host ""
write-host "Gathering list of certifications from SharePoint..." -foregroundcolor cyan -backgroundcolor black
write-host ""

#Root of your sharepoint site
$db = "http://workspaces.humana.com/sites/atsdocdb/"
#List GUID, obtained by exporting the list to Excel and checking the connection settings
$list = "{78E4F00E-098D-40B4-BCEF-7532169EF5C8}"

#Select your database and list
$connString = "Provider=Microsoft.ACE.OLEDB.12.0;WSS;IMEX=2;RetrieveIds=Yes; DATABASE=$db;LIST=$list;"
$spConn = new-object System.Data.OleDb.OleDbConnection($connString)
$spConn.open()
$qry="Select * from list"
$cmd = new-object System.Data.OleDb.OleDbCommand($qry,$spConn)
$adapter = new-object System.Data.OleDb.OleDbDataAdapter($cmd)
$table = new-object System.Data.dataTable
$adapter.fill($table) > $null
$list = $table | where{(($_.status -eq "approved") -or ($_.status -eq "obsolete") -or ($_.status -eq "Canceled"))} | select id,"product title",status
$list | convertto-csv -notypeinformation | out-file $path\temp.csv
$list = import-csv $path"temp.csv"

write-host "Calculating size of certification folders..." -foregroundcolor cyan -backgroundcolor black

#Populate the arrays
for ($list[$i]; $i -lt $list.length; $i++) {
    $cert += ($list[$i].id)
    write-host "Current certification: " -foregroundcolor cyan -nonewline; write-host $cert[$i]
    $dir += "\\lounaswps01\pdrive\d907ats\" + $cert[$i]
    write-host "Current directory: " -foregroundcolor cyan -nonewline; write-host $dir[$i]
    write-host "Current directory size: " -foregroundcolor cyan -nonewline;
    $dirlength += (Get-ChildItem $dir[$i] -recurse | Measure-Object -property length -sum)
    $dirsum += ($dirlength[$i].sum / 1MB)
    $dirsize += "{0:N1}" -f $dirsum[$i] + " MB"
    write-host $dirsize[$i]
    if ((test-path $dir[$i]) -ne $true) {write-host "Directory does not exist!" -foregroundcolor red}
    write-host ""
    $list[$i] | add-member -type NoteProperty -name Path -value $dir[$i]
    $list[$i] | add-member -type NoteProperty -name Size -value $dirsize[$i]
}

write-host "Creating HTML report..." -foregroundcolor cyan -backgroundcolor black

#Add the html header formatting
$header = "<style> BODY{font-size:3 ;font-family:calibri;} TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;} TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:#0099FF} TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:lightblue} </style>"

#Convert the array to HTML, apply formatting, and save to file
$list | convertto-html -head $header | out-file $path$file

#Display results file path to user
write-host ""
write-host "Results have been exported to: " -foregroundcolor cyan -backgroundcolor black -nonewline; write-host $path$file -foregroundcolor yellow -backgroundcolor black
write-host ""

remove-item $path"temp.csv" -force

write-host "Exiting..." -foregroundcolor cyan -backgroundcolor black
start-sleep -seconds 15
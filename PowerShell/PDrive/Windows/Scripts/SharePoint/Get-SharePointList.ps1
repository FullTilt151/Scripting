if ([IntPtr]::size -eq 4) {
    #Root of your sharepoint site
    $db = "http://connect.humana.com/sites/Windows10/"
    #CIT: "http://teams.humana.com/sites/clientit/"
    #Win10: http://connect.humana.com/sites/Windows10/"

    #List GUID, obtained by exporting the list to Excel and checking the connection settings
    $list = "{FAE9E391-B82B-43A3-88DA-508032077B07}"
    #CIT hardware list: "{0B03DEB6-01C4-419E-8541-22C2DA7D6175}"
    #Win10; {FAE9E391-B82B-43A3-88DA-508032077B07}

    #Select your database and list
    $connString = "Provider=Microsoft.ACE.OLEDB.12.0;WSS;IMEX=2;RetrieveIds=Yes; DATABASE=$db;LIST=$list;"
    $spConn = new-object System.Data.OleDb.OleDbConnection($connString)
    $spConn.open() # Error? Install AccessDatabaseEngine2007.exe
    $qry="Select * from list"
    $cmd = new-object System.Data.OleDb.OleDbCommand($qry,$spConn)
    $adapter = new-object System.Data.OleDb.OleDbDataAdapter($cmd)
    $table = new-object System.Data.dataTable
    $adapter.fill($table) > $null
    $table
    
    #$table | Sort-Object "Type of hardware" | Format-Table "Device Name", "Device Status", "Type of Hardware" -AutoSize
    $spconn.Close()
} else {
    Write-Error "Please use PowerShell x86"
}
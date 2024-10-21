if ([IntPtr]::size -eq 4) {
    #Root of your sharepoint site
    #$db = "http://teams.humana.com/sites/atsdocdb/"
    $db = "http://teams.humana.com/sites/clientit/"
        
    #List GUID, obtained by exporting the list to Excel and checking the connection settings
    #$list = "{79F3CD8B-ACAA-4182-8583-B7867067876F}"
    $list = "{0B03DEB6-01C4-419E-8541-22C2DA7D6175}"
        
    #Select your database and list
    $connString = "Provider=Microsoft.ACE.OLEDB.12.0;WSS;IMEX=2;RetrieveIds=Yes;DATABASE=$db;LIST=$list;"
    $spConn = new-object System.Data.OleDb.OleDbConnection($connString)
    $spConn.open()
    $qry="Select * from list"
    #$qry="Select * from list WHERE [Install Type] = 'Security Update'"
    $cmd = new-object System.Data.OleDb.OleDbCommand($qry,$spConn)
    $cmd.CommandTimeout = 360
    $adapter = new-object System.Data.OleDb.OleDbDataAdapter($cmd)
    $table = new-object System.Data.dataTable
    $adapter.fill($table) > $null
    #$table
    
    <#
    $table | Select-Object ID, "Vendor Name", "Product Name", "Product Version", Client/Server, `
                               "Number of devices/users", Priority, "Priority Justification", "Software Category", `
                               "Install Type", "Software Type", "Date Software will be available", "Date Software Required", `
                               "Business Owner", "IT Sponsor", TeamID, "Installation Method", "Status"
    #>
    $spconn.Close()
} else {
    Write-Error "Please use PowerShell x86"
}
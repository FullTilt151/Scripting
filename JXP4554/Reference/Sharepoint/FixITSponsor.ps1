# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2011
# 
# NAME: FixITSponsor.ps1
# 
# AUTHOR: Humana User , Humana Inc.
# DATE  : 5/7/2012
# 
# COMMENT: 
# 
# ==============================================================================================

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

#Populate the arrays
for ($list[$i]; $i -lt $list.length; $i++) {
    $cert += ($list[$i].id)
    write-host "Current certification: " -foregroundcolor cyan -nonewline; write-host $cert[$i]
    $dir += "I:\d907ats\" + $cert[$i]
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


$server = "PCTRACKERPROD"
$instance = "PCTRACKER"
$query = "select * from userinfo where name like '%tooley%Alan%'"

$connection = new-object system.data.sqlclient.sqlconnection(“Data Source=$server;Initial Catalog=$instance;Integrated Security=SSPI;”);
    
$adapter = new-object system.data.sqlclient.sqldataadapter ($query, $connection)
$set = new-object system.data.dataset

$adapter.Fill($set)

$table = new-object system.data.datatable
$table = $set.Tables[0]

#return table
$table | ft -AutoSize

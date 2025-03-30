[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.smo")
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")

$wmi = New-Object ('Microsoft.SQLServer.Management.Smo.Wmi.ManagedComputer') "$env:computername"

# Disabled Named Pipes on the Instance
$wmi.ServerInstances["SQLEXPRESS"].ServerProtocols["Np"].IsEnabled

# Disable Named Pipes
$wmi.ClientProtocols["np"].IsEnabled = $false
$wmi.ClientProtocols["np"].Alter()
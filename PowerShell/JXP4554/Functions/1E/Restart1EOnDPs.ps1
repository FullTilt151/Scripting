"grbappwps09","louappwps614","louappwps615","louappwps616","louappwps868","louappwps869","louappwps870","louappwps871" |
foreach {
    write-host "Connecting to $_"
    $Service=Get-WmiObject -Class Win32_Service -ComputerName $_ -Filter "Name='NomadBranch'"
    Write-Host "Stopping 1E Nomad Branch"
    $Service.StopService()
   }

"grbappwps09","louappwps614","louappwps615","louappwps616","louappwps868","louappwps869","louappwps870","louappwps871" |
foreach {
    write-host "Connecting to $_"
    $Service=Get-WmiObject -Class Win32_Service -ComputerName $_ -Filter "Name='NomadBranch'"
    Write-Host "Starting 1E Nomad Branch"
    $Service.StartService()
   }
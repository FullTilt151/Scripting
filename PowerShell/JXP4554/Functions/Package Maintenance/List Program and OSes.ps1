$Server = 'LOUAPPWPTS872'
$Site = (Get-WmiObject SMS_ProviderLocation -Namespace root\sms -ComputerName $server).NamespacePath.split("_")[1]

$package_query = Get-WmiObject -Namespace "Root\sms\Site_$Site" -Class SMS_Package -ComputerName $Server
 
foreach ($item in $package_query) {
    Write-Host "+++++++++++++++++++++++++++++++++++++"
    Write-Host "Package ID:     "  $item.PackageID
    Write-Host "Package Name:   "  $item.Name
 
    $program_query = Get-WmiObject -Namespace "Root\sms\Site_$Site" -Class SMS_Program -ComputerName $Server -filter "PackageID='$($item.PackageID)'"
    foreach ($obj in $program_query) {
        Write-Host "Program Name:   " $obj.ProgramName
        if (($obj.ProgramFlags -band [MATH]::Pow(2, 27)) -ne 0) {
            Write-Host "OS:              This program can run on any platform"
        }
        Else {
            Write-Host $obj.ProgarmFlags
            $SupportedPlatforms = Get-WmiObject -Namespace "root\sms\site_$Site" -Class SMS_OS_Details -ComputerName $Server 
            foreach ($SupportedPlatform in $SupportedPlatforms) {
                # Using the __PATH property, obtain a direct reference to the instance
                $SupportedPlatform = [wmi]"$($SupportedPlatform.__PATH)"
 
                # Iterate over each update CI_ID in the Updates array
                foreach ($Platform in $SupportedPlatform.OSName) {
                    # Get a reference to the update we're working with, based on its CI_ID
                    $Platform = Get-WmiObject -Namespace "root\sms\Site_$Site" -ComputerName $Server -Class SMS_SupportedPlatforms
                    Write-Host -Object "Support Platform ($($SupportedPlatform.OSName))"
                }
            }
 
            Write-Host "OS:             " + $SupportedPlatform.SupportedOperatingSystems(0).Name
        }
        Write-Host "+++++++++++++++++++++++++++++++++++++"
    }
}

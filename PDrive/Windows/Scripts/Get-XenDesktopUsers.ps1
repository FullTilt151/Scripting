$date = Get-Date -UFormat %m%d%Y

# Start a pssession to the XDD server
New-PSSession -ComputerName LOUXDCWAGX1S001 -Name XDDQAGet

# Run the XDD broker commands within the session
Invoke-Command -Session (Get-PSSession -Name XDDQAGet) -ScriptBlock {
    $date = Get-Date -UFormat %m%d%Y

    Add-PSSnapin citrix*
    $Machines = Get-BrokerMachine -MaxRecordCount 10000
    $Machines |
    ForEach-Object {
        $DesktopGroup = $_.DesktopGroupName
        $WKID = $_.HostedMachineName
        $_.AssociatedUserNames | 
        ForEach-Object {
            $User = Get-BrokerUser -Name $_
            "$DesktopGroup,$WKID,$($User.Name),$($User.FullName)" | out-file d:\temp\XDDQA-win10users-$date.csv -Append
        }
    }
}

# Kill the pssession
Get-PSSession -Name XDDQAGet | Remove-PSSession
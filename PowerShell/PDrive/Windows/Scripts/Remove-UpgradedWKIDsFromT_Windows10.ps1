Import-Module ActiveDirectory

$RemovedWKIDs = @()

Get-ADGroupMember -Identity T_Windows10 -Partition 'DC=humad,DC=com' -Recursive -Server LOUADMWPS02.humad.com | 
ForEach-Object {
    $WKID = Get-ADObject -Identity $_ -Properties OperatingSystem -Partition 'DC=humad,DC=com' -Server LOUADMWPS02.humad.com
    
    if ($WKID.OperatingSystem -eq 'Windows 10 Enterprise') {
        Remove-ADGroupMember -Identity T_Windows10 -Members $WKID -Confirm:$false -Partition 'DC=humad,DC=com' -Server LOUADMWPS02.humad.com
        $RemovedWKIDs += "$($WKID.Name) $($WKID.OperatingSystem)"
    }
}

$RemovedWKIDs
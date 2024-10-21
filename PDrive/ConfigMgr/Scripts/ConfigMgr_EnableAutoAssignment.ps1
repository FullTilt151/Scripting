write-host "----------------------------------------------"
write-host "This script checks the ConfigMgr client WMI settings to see if EnableAutoAssignment is false and if so enables it."
write-host "----------------------------------------------"
write-host ""

$autoassignment = (Get-Wmiobject -class SMS_Client -namespace 'ROOT\CCM').EnableAutoAssignment
write-host "EnableAutoAssignment is $autoassignment"
if ($autoassignment){
    write-host "Enabling Auto Assignment..."
    
} else {
    write-host "Exiting..."
    start-sleep -seconds 5
}


$a.EnableAutoAssignment = ${0}
$a.Put()
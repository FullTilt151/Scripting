param ([string]$SMSProviderServer,
[string]$SiteCode
)
#######################################################################################################################
$DesiredValue = 60
$Class_ItemName = "Hardware Inventory Agent" # "Software Inventory Agent" for SINV
$Property_Name = "Hardware Inventory Max Random Delay Minutes" # "Software Inventory Max Random Delay Minutes" for SINV
# NOTE: you have to change BOTH above if switching between HINV and SINV
#######################################################################################################################

$Class_Name = "SMS_SCI_ClientComp"
$EmbeddedProperties = @() #An array containing object type SMS_EmbeddedPropery
$SiteCode = $SiteCode.ToUpper()

#Query the SMS_SCI_ClientComp instances
$ClientComponentSettingInstances = Get-WmiObject -ComputerName $SMSProviderServer -Namespace root\sms\site_$SiteCode -Class $Class_Name -Filter "ItemName='$($Class_ItemName)'" | Where-Object {$_.SiteCode -eq $SiteCode}
foreach($Instance in $ClientComponentSettingInstances){
    foreach($embeddedProp in $Instance.Props){
        $EmbeddedProperty = ([WMICLASS]"\\$($SMSProviderServer)\ROOT\SMS\site_$($SiteCode):SMS_EmbeddedProperty").CreateInstance()
        $EmbeddedProperty.PropertyName = $embeddedProp.PropertyName
        
        if($embeddedProp.PropertyName -eq $Property_Name){
            $CurrentValue = $embeddedProp.Value
            if($CurrentValue -ne $DesiredValue){
                $ChangeIt = $true
                $ForegroundColor = "Yellow"
                $EmbeddedProperty.Value = $DesiredValue
            }else {
                $ChangeIt = $false
                $ForegroundColor = "Green"
                $EmbeddedProperty.Value = $embeddedProp.Value
            }
        }            
        $EmbeddedProperty.Value1 = $embeddedProp.Value1
        $EmbeddedProperty.Value2 = $embeddedProp.Value2
        $EmbeddedProperties += $EmbeddedProperty

    }
    Write-Host "$Property_Name ($($SiteCode)) = $($CurrentValue)" -ForegroundColor $ForegroundColor
    
    if($ChangeIt){
        Write-Host "Changing to $DesiredValue..."
        $Instance.props = $EmbeddedProperties
        [wmi]$Instance.Put() | Out-Null
        $ClientComponentSettingInstances = Get-WmiObject -ComputerName $SMSProviderServer -Namespace root\sms\site_$SiteCode -Class $Class_Name -Filter "ItemName='$($Class_ItemName)'" | Where-Object {$_.SiteCode -eq $SiteCode}
        foreach($Instance in $ClientComponentSettingInstances){
            foreach($embeddedProp in $Instance.Props){
                if($embeddedProp.PropertyName -eq $Property_Name){
                    $CurrentValue = $embeddedProp.Value
                    if($CurrentValue -eq $DesiredValue){
                        Write-Host "Success!" -ForegroundColor "Green"
                    }else {
                        Write-Host "Failed, sorry." -ForegroundColor "Red"
                    }
                }
            }
        }
    }

}

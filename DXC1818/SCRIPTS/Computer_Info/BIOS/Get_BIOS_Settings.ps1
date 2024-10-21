Write-Host "Enter: Dell or Lenovo"
$Action = Read-Host "Select a Manfufacturer"
Switch ($Action)
{
    Lenovo {
        $ComputerName = Read-Host "Please enter the WKID:"
        $WMI = Get-CimInstance -ClassName Lenovo_BiosSetting -Namespace root\wmi -ComputerName $ComputerName 
        $BIOSsettings = New-Object PSObject 
        $BIOSsettings | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $WMI[0].__Server 
        $WMI | ForEach-Object{ 
            if($_.CurrentSetting -ne ""){ 
            $Setting = $_.CurrentSetting -split ',' 
            $BIOSsettings | Add-Member -MemberType NoteProperty -Name $Setting[0] -Value $Setting[1] -Force
            }
        }
        Write-Output $BIOSsettings 
    }
    Dell {
        $ComputerName = Read-Host "Please enter the WKID:"
        $Enumeration = Get-CimInstance -ClassName EnumerationAttribute -Namespace root\dcim\sysman\biosattributes  -ComputerName $ComputerName 
        $Enumeration | Select-Object AttributeName,CurrentValue,PossibleValue
    }
    default {
    'No Action'
    }
} 
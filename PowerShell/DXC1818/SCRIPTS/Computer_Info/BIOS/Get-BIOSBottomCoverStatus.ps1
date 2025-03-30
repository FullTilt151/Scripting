#Get Bottom Cover Setting on BitLocker w/PIN collection WP1065BD
$LOC = Get-Location
If ($LOC.Path -ne "WP1:\") {
    $Drives = Get-PSDrive
    If ($Drives.Name -ne "WP1") {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue # Import the ConfigurationManager.psd1 module 
        Set-Location "WP1:"
    }
    Set-Location "WP1:"
}
$WKIDs = Get-CMCollectionMember -CollectionId WP1065BD | Select-Object -ExpandProperty Name
$WKIDs | ForEach-Object {
    IF (Test-Connection -ComputerName $_ -Count 1 -TimeToLive 120 -Quiet -ErrorAction SilentlyContinue) {
        Invoke-Command -ComputerName $_ -ScriptBlock {
            $IsLPT = Get-CimInstance Win32_Battery
            If ($IsLPT -ne $null) {
                $CMPMDL = Get-CimInstance Win32_ComputerSystemProduct
                If ($CMPMDL.Vendor -like "*LENOVO*") {
                    #Lenovo
                    $SettingList = Get-CimInstance -Namespace root\wmi -Class Lenovo_BiosSetting
                    $BIOSSetting = $SettingList | Where-Object CurrentSetting -Like "BottomCoverTamperDetected*" | Select-Object -ExpandProperty CurrentSetting
                    Write-Host "$env:COMPUTERNAME,$BIOSSetting" -ForegroundColor DarkCyan 
                }
                If ($CMPMDL.Vendor -like "*Dell*") {
                    #Dell
                    $Enumeration = Get-CimInstance -Namespace root\dcim\sysman\biosattributes -ClassName EnumerationAttribute
                    $BIOSSetting = $Enumeration | Where-Object AttributeName -eq "ChasIntrusion" | Select-Object AttributeName,CurrentValue
                    Write-Host "$env:COMPUTERNAME,$BIOSSetting" -ForegroundColor DarkCyan
                }
            }
        }
    }
    Push-Location "C:"
}
#Name - securewipe.ps1
#Description - Utilizes Microsoft SDelete to clean disk drives to DoD 5220.22-M standards.
#Intended Use - Allows EUT to dispose / donate obsolete computers by wiping all data on the computers disk drive.
#Audience - EUT
#Author - Darren Chinnon
#Last Update Date - 5/4/2021


class wipeCertFormat {
    [string] $User_Name = $UserName
    [string] $WMI_Drive_Serial_Number = $UNIID
    [string] $Drive_Model = $HDProduct
    [string] $UUID = $UUID
    [string] $Computer_Manufacturer = $CompMan
    [string] $Computer_Model = $CompModel
    [string] $Computer_Serial_Number = $ComputerID
    [string] $Original_Computer_Serial = $CustomComputerID
    [string] $BIOS_Password_State = $RSLT
    [string] $Tool_Used = $Tool
    [string] $Start_Time = $StartTime
    [string] $End_Time = $EndTime
    [string] $Wipe_Method_Details = $PatternName
    [string] $Number_of_Passes = $NumPasses
    [string] $Pass_Status = $PassStatus
}

##### Clear BIOS Password ######
#Get BIOS PWD

#Query if PWD is set and clear if it is.
$CMPMDL = Get-CimInstance Win32_ComputerSystemProduct
If ($CMPMDL.Vendor -like "*LENOVO*") {
    $RSLT = Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosPasswordSettings | Select-Object -ExpandProperty PasswordState
    If ($RSLT -eq "2") {
        Write-Host
        Write-Host
        $OldPassword = Read-Host "Please enter the current BIOS password :"
        Write-Host
        Write-Host
        $PasswordSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosPassword
        $PasswordSettings.SetBiosPassword("pap,$OldPassword,,ascii,us")
        Restart-Computer
    }
}
If ($CMPMDL.Vendor -like "*Dell*") {
    Do {
        $PWDQuery = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class PasswordObject
        $RSLT = $PWDQuery | Where-Object NameId -EQ "Admin" | Select-Object -ExpandProperty IsPasswordSet 
        Write-Host
        Write-Host
        $OldPassword = Read-Host "Please enter the current BIOS password :"
        Write-Host
        Write-Host
        $PasswordSettings = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class SecurityInterface
        $Encoder = New-Object System.Text.UTF8Encoding
        $Bytes = $Encoder.GetBytes($OldPassword)
        $PasswordSettings.SetNewPassword(1, $Bytes.Length, $Bytes, "Admin", "$OldPassword", "")
        $PWDQuery = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class PasswordObject
        $RSLT = $PWDQuery | Where-Object NameId -EQ "Admin" | Select-Object -ExpandProperty IsPasswordSet
    } Until ($RSLT -eq "0")
}
If ($CMPMDL.Vendor -like "*HP*") {
    Do {
        $PWDQuery = Get-WmiObject -Namespace root/hp/InstrumentedBIOS -Class HP_BIOSSetting
        $RSLT = ($PWDQuery | Where-Object Name -eq "Setup Password").IsSet
        Write-Host
        Write-Host
        $OldPassword = Read-Host "Please enter the current BIOS password :"
        Write-Host
        Write-Host
        $PasswordSettings = Get-WmiObject -Namespace root/hp/InstrumentedBIOS -Class HP_BIOSSettingInterface
        $PasswordSettings.SetBIOSSetting("Setup Password", "<utf-16/>", "<utf-16/>" + "$OldPassword")
        $PWDQuery = Get-WmiObject -Namespace root/hp/InstrumentedBIOS -Class HP_BIOSSetting
        $RSLT = ($PWDQuery | Where-Object Name -eq "Setup Password").IsSet
    } Until ($RSLT -eq "0")
}


##### Input variables #####
# Results from SDelete process #
## Location of Sdelete Logs ##
$sdeletelog1 = "X:\sdeletelog1.txt"

##### Date and time operation started
####################################################################################################

$StartTime = Get-Date

##### Get UserID #####
####################################################################################################

#Get userid
Write-Host
Write-Host
$UserName = Read-Host "Please enter your USERID:"
Write-Host
Write-Host

##### Get original computer serial number #####
Write-Host  "  ================================================ " -ForegroundColor 'Red'
Write-Host  "   [ Enter the original computers serial number ]  " -ForegroundColor 'Yellow' 
Write-Host  "  ================================================ " -ForegroundColor 'Red'
Write-Host
$CustomComputerID = Read-Host
Write-Host


##### Crypto Erase ######
# Erase the disk using WinMagic SDRecovery (Remove Encryption) #
####################################################################################################
Write-Host
Write-Host Crypto-Erase the drive! -ForegroundColor 'Yellow'
Write-Host
Start-Process -FilePath "x:\SDRecovery\SDRecoveryCmd.exe" -ArgumentList "-erase -d 0"


##### DiskPart ######
# Use DiskPart to Clean the disk #
Start-Process -FilePath "x:\Windows\System32\Diskpart.exe" -ArgumentList "/s X:\sdrecovery\Sdelete\dkptconf.txt" -NoNewWindow -Wait

##### SDelete #####
####################################################################################################
Write-Host
Write-Host Be patient this will take a some time!! -ForegroundColor 'Red'
Write-Host DoD 5220.22-M sanitization -ForegroundColor 'Blue'
Write-Host
Write-Host SDelete start time: -ForegroundColor 'Green'
Get-Date
Start-Process -FilePath "x:\sdrecovery\Sdelete\Sdelete64.exe" -ArgumentList "/accepteula -p 1 -c 0" -NoNewWindow -RedirectStandardOutput X:\sdeletelog1.txt
Wait-Process -Name sdelete64
Write-Host
Write-Host SDelete end time: -ForegroundColor 'Green'
Get-Date
Write-Host

# Sdelete log pass 1
# Verify SDelete wiped the drive #
$opgood1 = Select-String -Path $sdeletelog1 -Pattern 'Disk 0 cleaned.' -CaseSensitive
IF ($opgood1 -ne $null) {
    $opresult1 = "Success"
}
ELSE {
    $opresult1 = "Failed"
}

##### Get hardware information section #####
####################################################################################################

##### Get drive model #####
$HDProduct = (Get-WmiObject Win32_DiskDrive | Select-Object -ExpandProperty Model)

##### Get drive serial number #####
$UNIID = Get-WmiObject MSFT_Disk -Namespace root/Microsoft/Windows/Storage  | Select-Object -ExpandProperty AdapterSerialNumber
IF ($UNIID -eq $null) {
    $UNIID = Get-WmiObject Win32_DiskDrive | Select-Object -ExpandProperty SerialNumber
}

##### Get computer UUID #####
$UUID = (Get-WmiObject Win32_ComputerSystemProduct  | Select-Object -ExpandProperty UUID)

##### Get computer serial number #####
$ComputerID = (Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber)
$CompMan = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
$CompModel = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Model

##### Date and time operation completed #####
####################################################################################################

$EndTime = Get-Date

##### Wipe Method #####
####################################################################################################

$PatternName = "DoD 5220.22-M sanitization of the local hard drive."

##### Secure erase passes #####
# Get how many passes were performed #
####################################################################################################

If (Select-String -Path $sdeletelog1 -Pattern 'Pass 2' -CaseSensitive) {
    $NumPasses = "3"
}
elseif (Select-String -Path $sdeletelog1 -Pattern 'Pass 1' -CaseSensitive) {
    $NumPasses = "2"
}
elseif (Select-String -Path $sdeletelog1 -Pattern 'Pass 0' -CaseSensitive) {
    $NumPasses = "1"
}
else {
    $NumPasses = "0"
}

##### Name of Program  #####
####################################################################################################

$Tool = Get-ChildItem X:\sdrecovery\SDelete\sdelete64.exe | Select-Object -ExpandProperty VersionInfo | Select-Object InternalName, ProductVersion

##### Operation result #####
####################################################################################################

IF ($opresult1 -eq "Success") {
    $PassStatus = "1 drive cleaned - The drive has successfully been sanitized"

    ##### Wipe Certificate #####

    $WipeCert = New-Object wipeCertFormat
    $WipeCert = $WipeCert | Out-String
    $WipeCertAttach = "CERTIFICATE OF SANITATION $WipeCert" | out-file -FilePath "X:\$CustomComputerID.txt"
    $date = Get-Date -UFormat "%m/%d/%y"

    ##### Send Email #####
    Send-MailMessage -To "WipeDrive@humana.com" -from "securewipe@humana.com" -Subject "SecureWipe log: $CustomComputerID - $date" -Body "CERTIFICATE OF SANITATION $WipeCert" -smtpserver "pobox.humana.com" -port 25 -Attachments "X:\$CustomComputerID.txt"

    #OutPut results to screen to notify tech!!
    Write-Host
    Write-Host
    Write-Host "   [ Results of the wipe process ]" -ForegroundColor 'Magenta'
    Write-Host $PassStatus -ForegroundColor 'Green'
    write-host "$NumPasses Passes Completed" -ForegroundColor 'Green'

    #OutPut results to screen to notify tech!!
    Write-Host
    Write-Host
    Write-Host "Verify that the email for this process is in the Inbox!" -ForegroundColor 'Red'
}

ELSE {
    $PassStatus = "0 drive cleaned - Failed to sanitize the drive"

    #OutPut results to screen to notify tech!!
    Write-Host
    Write-Host
    Write-Host "   [ Results of the wipe process ]" -ForegroundColor 'Magenta'
    Write-Host $PassStatus -ForegroundColor 'Red'
    write-host "$NumPasses Passes" -ForegroundColor 'Red'        
}
Write-Host
Write-Host
Read-Host "Press Enter to close"
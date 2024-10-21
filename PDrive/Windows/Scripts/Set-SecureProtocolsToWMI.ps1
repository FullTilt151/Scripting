## Define new class name and date
$NewClassName = 'Win32_SecureProtocols'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("User", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("SecureProtocols", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["User"].Qualifiers.Add("Key", $true)
$newClass.Properties["SecureProtocols"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather your data
$Usertable = @()
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
Get-ChildItem HKU: | foreach {
    if ($_.Name -notin ('HKEY_USERS\.DEFAULT','HKEY_USERS\S-1-5-18','HKEY_USERS\S-1-5-19','HKEY_USERS\S-1-5-20') -and $_.Name -notlike "*_Classes") {
        $UserSID = ($_.Name).Replace('HKEY_USERS\','')
        $SID = New-Object System.Security.Principal.SecurityIdentifier($UserSID) -ErrorAction SilentlyContinue
        $ErrorActionPreference = 'SilentlyContinue'
        $User = $SID.Translate([System.Security.Principal.NTAccount])
        $ErrorActionPreference = 'Continue'
        $Username = $User.Value
        $SecureProtocols = (Get-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\Software\Microsoft\Windows\CurrentVersion\Internet Settings") -Name SecureProtocols -ErrorAction SilentlyContinue).SecureProtocols
        if ($SecureProtocols -ne $null) {
            $usertable += ,@($Username, $SecureProtocols)
        }
    }
}

$usertable += ,@('WinHttp64',(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -Name DefaultSecureProtocols -ErrorAction SilentlyContinue).DefaultSecureProtocols)
$usertable += ,@('WinHttp32',(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -Name DefaultSecureProtocols -ErrorAction SilentlyContinue).DefaultSecureProtocols)
$usertable += ,@('IE64',(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -Name SecureProtocols -ErrorAction SilentlyContinue).SecureProtocols)

$Usertable | 
ForEach-Object {
    ## Set data in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -argument @{
        User = ($_)[0];
        SecureProtocols = ($_)[1];
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"
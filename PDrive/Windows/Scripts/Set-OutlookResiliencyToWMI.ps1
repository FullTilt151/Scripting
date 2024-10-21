## Define new class name and date
$NewClassName = 'Win32_OutlookResiliency'
$Date = Get-Date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("User", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("List", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Property", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Value", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["User"].Qualifiers.Add("Key", $true)
$newClass.Properties["Property"].Qualifiers.Add("Key", $true)
$newClass.Properties["Value"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null


## Gather Outlook add-ons
$Usertable = @()
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
Push-Location HKU:
Get-ChildItem HKU: | ForEach-Object {
    if ($_.Name -notin ('HKEY_USERS\.DEFAULT','HKEY_USERS\S-1-5-18','HKEY_USERS\S-1-5-19','HKEY_USERS\S-1-5-20') -and $_.Name -notlike "*_Classes") {
        $UserSID = ($_.Name).Replace('HKEY_USERS\','')
        $SID = New-Object System.Security.Principal.SecurityIdentifier($UserSID) -ErrorAction SilentlyContinue
        $User = $SID.Translate( [System.Security.Principal.NTAccount])
        $Username = $User.Value
        $ErrorActionPreference = 'SilentlyContinue'
        $CrashingAddinList = Get-Item -Path (($_.Name).Replace('HKEY_USERS','HKU:') + '\Software\Microsoft\Office\16.0\Outlook\Resiliency\CrashingAddinList')
        if ($CrashingAddinList) {
            $CrashingAddinList.Property | ForEach-Object { 
                $Property = (Get-ItemProperty -Path $($CrashingAddinList.Name) -Name $_).GetValue()
                $Value = Get-ItemProperty $CrashingAddinList.Name -Name $_ | Select-Object -ExpandProperty $_
                $Value = [System.Text.Encoding]::UTF8.GetString($Value, 0, $Value.length)
                $Value = $Value -replace '[^a-zA-Z0-9\:\.\/\s\|\\]', ''
                $Value = $Value -replace "`n"," "
                $usertable += ,@($Username, $($CrashingAddinList.PSChildName), $_, $Value)
            }
        }
        $DisabledItems = Get-Item -Path (($_.Name).Replace('HKEY_USERS','HKU:') + '\Software\Microsoft\Office\16.0\Outlook\Resiliency\DisabledItems')
        if ($DisabledItems) {
            $DisabledItems.Property | ForEach-Object { 
                $Property = (Get-ItemProperty -Path $($DisabledItems.Name) -Name $_).GetValue()
                $Value = Get-ItemProperty $DisabledItems.Name -Name $_ | Select-Object -ExpandProperty $_
                $Value = [System.Text.Encoding]::UTF8.GetString($Value, 0, $Value.length)
                $Value = $Value -replace '[^a-zA-Z0-9\:\.\/\s\|\\]', ''
                $Value = $Value -replace "`n"," "
                $usertable += ,@($Username, $($DisabledItems.PSChildName), $_, $Value)
            }
        }
        $DoNotDisableAddinList = Get-Item -Path (($_.Name).Replace('HKEY_USERS','HKU:') + '\Software\Microsoft\Office\16.0\Outlook\Resiliency\DoNotDisableAddinList')
        if ($DoNotDisableAddinList) {
            $DoNotDisableAddinList.Property | ForEach-Object { 
                $Property = (Get-ItemProperty -Path $($DoNotDisableAddinList.Name) -Name $_).GetValue()
                $Value = Get-ItemProperty $DoNotDisableAddinList.Name -Name $_ | Select-Object -ExpandProperty $_
                $usertable += ,@($Username, $($DoNotDisableAddinList.PSChildName), $_, $Value)
            }
        }
        $StartupItems = Get-Item -Path (($_.Name).Replace('HKEY_USERS','HKU:') + '\Software\Microsoft\Office\16.0\Outlook\Resiliency\StartupItems')
        if ($StartupItems) {
            $StartupItems.Property | ForEach-Object { 
                $Property = (Get-ItemProperty -Path $($StartupItems.Name) -Name $_).GetValue()
                $Value = Get-ItemProperty $StartupItems.Name -Name $_ | Select-Object -ExpandProperty $_
                $Value = [System.Text.Encoding]::UTF8.GetString($Value, 0, $Value.length)
                $Value = $Value -replace '[^a-zA-Z0-9\:\.\/\s\|\\]', ''
                $Value = $Value -replace "`n"," "
                $usertable += ,@($Username, $($StartupItems.PSChildName), $_, $Value)
            }
        }
        $ErrorActionPreference = 'Continue'
    }
}

$Usertable | 
ForEach-Object {
    ## Set Outlook add-ons in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        User = ($_[0]);
        List = ($_[1]);
        Property = ($_[2]);
        Value = ($_[3]);
        ScriptLastRan = $Date
	} | Out-Null
}

Pop-Location
Write-Output "Complete"
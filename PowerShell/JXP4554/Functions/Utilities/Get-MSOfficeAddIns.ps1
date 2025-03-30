function Loop-RegKeys($itemKeys) {
    # Loop through they item keys for each office application
    foreach ($itemkey in $itemKeys) {
        foreach($key in $itemkey){
            $parts = $key.Name.split("\")
            $addinApp = $parts[-3]
            $addinRegkeyName = $parts[-1]
            $addinKey = "{0}_{1}" -f $addinApp, $addinRegkeyName

            $addinFriendlyName = [String]$key.GetValue("FriendlyName")
            $addinDescription = [String]$key.GetValue("Description")

            $loadBehavior = [Int]$key.GetValue("LoadBehavior").ToString()
            $addinLoadBehavior = $global:loadBehaviors.Get_Item($loadBehavior)

            $addinLocation = [String]$key.GetValue("Manifest")

            if($addinLocation.length -eq 0){
                #Get the CLID
                $CLSIDkey = Get-ItemProperty "hklm:\software\classes\$($addinRegkeyName)\CLSID" -ErrorAction SilentlyContinue -ErrorVariable clsiderror
                if($clsiderror){
                    #Your guess is as good as mine
                    $addinLocation = "Unknown"
                } else {
                    $CLSID = [String]$CLSIDkey.'(default)'
                    #try Wow6432Node first
                    $locationRegkey = Get-ItemProperty "hklm:\software\classes\Wow6432Node\CLSID\$($CLSID)\InprocServer32" -ErrorAction SilentlyContinue -ErrorVariable wowkeyerror
                    if($wowkeyerror)
                    {
                        $addinLocation = "Unknown"
                    } else {
                        $addinLocation = $locationRegkey.'(default)'
                    }
                }
            }

            $addinProps = @{"FriendlyName" = $addinFriendlyName;
                            "App" = $addinApp;
                            "Description" = $addinDescription;
                            "LoadBehavior" = $addinLoadBehavior;
                            "Location" = $addinLocation;
                            }

            #add/update the hashtable of Office Addins
            if($global:addins.ContainsKey($addinKey)){
                $global:addins.Set_Item($addinKey, $addinProps)
            } else {
                $global:addins.Add($addinKey, $addinProps)
            }
        }
    }
}

function Create-Wmi-Class()
{
    $newClass = New-Object System.Management.ManagementClass("root\cimv2", [String]::Empty, $null);

    $newClass["__CLASS"] = "CM_CUST_MSOfficeAddins"

    $newClass.Qualifiers.Add("Static", $true)
    $newClass.Properties.Add("PluginID", [System.Management.CimType]::String, $false)
    $newClass.Properties["PluginID"].Qualifiers.Add("key", $true)
    $newClass.Properties["PluginID"].Qualifiers.Add("read", $true)
    $newClass.Properties.Add("FriendlyName", [System.Management.CimType]::String, $false)
    $newClass.Properties["FriendlyName"].Qualifiers.Add("read", $true)
    $newClass.Properties.Add("App", [System.Management.CimType]::String, $false)
    $newClass.Properties["App"].Qualifiers.Add("read", $true)
    $newClass.Properties.Add("Description", [System.Management.CimType]::String, $false)
    $newClass.Properties["Description"].Qualifiers.Add("read", $true)
    $newClass.Properties.Add("Location", [System.Management.CimType]::String, $false)
    $newClass.Properties["Location"].Qualifiers.Add("read", $true)
    $newClass.Properties.Add("LoadBehavior", [System.Management.CimType]::String, $false)
    $newClass.Properties["LoadBehavior"].Qualifiers.Add("read", $true)
    $newClass.Put() | out-null
}

$global:loadBehaviors = @{ 0  = "Unloaded, Do not load automatically";
                    1  = "Loaded, Do not load automatically";
                    2  = "Unloaded, Load at startup";
                    3  = "Loaded, Load at startup";
                    8  = "Unloaded, Load on demand";
                    9  = "Loaded, Load on demand";
                    16 = "Loaded, Load first time, then load on demand"
                  }

$global:addins = @{}

# Check whether we already created our custom WMI class on this PC, if not, create it
[void](Get-WMIObject CM_CUST_MSOfficeAddins -ErrorAction SilentlyContinue -ErrorVariable wmiclasserror)

if ($wmiclasserror)
{
    $error.Clear()
    try {
        Create-Wmi-Class
    }
    catch
    {
        write-host $false
        Exit
    }
}

# Retrieve Office Addins keys from HKLM
$itemKeys = Get-ChildItem -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\*\Addins"  -Recurse -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | ? -FilterScript {($_.ValueCount -gt 0)}
if (($itemKeys -ne $null) -and ($itemKeys.Count -ne 0)) {
    Loop-RegKeys($itemKeys)
}

# Retrieve Office Addins keys from HKLM (32-bit on 64-bit machine)
$itemKeys = Get-ChildItem -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Office\*\Addins"  -Recurse -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | ? -FilterScript {($_.ValueCount -gt 0)}
if (($itemKeys -ne $null) -and ($itemKeys.Count -ne 0)) {
    Loop-RegKeys($itemKeys)
}

# Retrieve all domain users' Addins keys from the registry
$itemKeys = Get-ChildItem -Path "Registry::HKEY_USERS\S-1-5-21-*\Software\Microsoft\Office\*\Addins" -Recurse -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | ? -FilterScript {($_.ValueCount -gt 0)}
 if (($itemKeys -ne $null) -and ($itemKeys.Count -ne 0)) {
    Loop-RegKeys($itemKeys)
}

# Clear WMI
Get-WmiObject CM_CUST_MSOfficeAddins | Remove-WmiObject

#Enumerate discovered addins and add them into WMI
foreach($addin in $addins.GetEnumerator()){
    $PluginID = $addin.Name
    $FriendlyName = $addins.Item($PluginID).Item("FriendlyName")
    $App = $addins.Item($PluginID).Item("App")
    $Description = $addins.Item($PluginID).Item("Description")
    $LoadBehavior = $addins.Item($PluginID).Item("LoadBehavior")
    $Location = $addins.Item($PluginID).Item("Location")

    if( ($FriendlyName.Length -eq 0) -and ($Description.Length -eq 0) -and ($Location -eq "Unknown") ){
        #Skip it, probably a bogus record
    } else {
        [void](Set-WmiInstance -Path \\.\root\cimv2:CM_CUST_MSOfficeAddins -Arguments @{PluginID=$PluginID; `
        FriendlyName=$FriendlyName; App=$App; Description=$Description; Location=$Location; LoadBehavior=$LoadBehavior})
    }
}

write-host $true
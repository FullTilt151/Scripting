<#  
.SYNOPSIS  
    Collect potentially relevant settings pertaining to RDWeb
.DESCRIPTION  
    This script was written to address the following data queries
    a. User context sensitive to profile executing the RDP connection (if elevated rights required for any of the below the same elevated user must be the logged in user executing the RDP connection).
    b. Query NTLM registry security keys
    c. Query mstsc version
    d. Query RDP patch kb’s
    e. Query configuration of enabled cipher suites.
    f. Query Internet Zone states for trusted zone, sites and values.
    g. Query proxy configuration (if wpad configurations are being used, download pac file).
    h. Query DNS servers and resolutions for RDWeb DNS objects.
    ####i. WINMTR results for RDP Gateway destination. #### 3rd Party Download
    j. Query installed app suites (anti-virus, desktop security, host based ids, etc).
.NOTES  
    File Name  : Query QR Client Machine.ps1
    Author     : Ryan Peay - Verscend Technologies
    Requires   : PowerShell V2 (Written on Win 7 SP1)
#>

    ###############################################################################################################################
####May need to run the following to allow usage in user context####
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
###############################################################################################################################

#Query LMCompatibilityLevel Registry Value
Try {
    $lmclkey = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name LMCompatibilityLevel -ErrorAction Stop
    $lmcl = $lmclkey.LMCompatibilityLevel
} 
Catch {
    $lmcl = 'No Value Found (Default Assumed of 3)'
}
    
#Query Versions and Elevations
$mstscVer = (Get-Item -Path C:\Windows\System32\mstsc.exe).VersionInfo
$osVer = Get-WmiObject -Class Win32_OperatingSystem

#Query Admin Priviliges
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
If (-not $myWindowsPrincipal.IsInRole($adminRole)) {
    $psAdminRights = "False" }
Else {
    $psAdminRights = "True" }

#Query RDP Patch KB's
$kbList = 'KB,Description,Recommended
KB2574819,"An update is available that adds support for DTLS in Windows 7 SP1 and Windows Server 2008 R2 SP1","Recommended"
KB2830477,"Update for RemoteApp and Desktop Connections feature is available for Windows","Recommended"
KB2857650,"Update that improves the RemoteApp and Desktop Connections features is available for Windows 7","Recommended"
KB2913751,"Smart card redirection in remote sessions fails in a Windows 7 SP1-based RDP 8.1 client","Smart Card Dependant, MS Recommended"
KB2923545,"Update for RDP 8.1 is available for Windows 7 SP1","Recommended"' | ConvertFrom-CSV

$installedKBs = Get-HotFix

$resultKB = @()
ForEach ($kb in $kbList) {
    $arr = New-Object -TypeName PSCustomObject
    $arr | Add-Member -MemberType NoteProperty -Name KB -Value $kb.KB
    $arr | Add-Member -MemberType NoteProperty -Name Description -Value $kb.Description
    $arr | Add-Member -MemberType NoteProperty -Name Recommended -Value $kb.Recommended
    $hotfixDetails = $installedKBs | Where-Object {$_.HotFixID -eq $kb.KB}
    $arr | Add-Member -MemberType NoteProperty -Name InstalledOn -Value $hotfixDetails.InstalledOn
    If ($arr.InstalledOn -eq $null) {
        $arr.InstalledOn = "Missing"
    }
    $resultKB += $arr
}

#Get Network Configuration
$nics = Get-WMIObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq "True"}
$dnsServers = @()
ForEach ($nic in $nics) {
    ForEach ($dnsServer in $nic.DNSServerSearchOrder) {
        If (-not ($dnsServers | Where-Object {$_ -eq $dnsServer}) -eq $dnsServer) {
            $dnsServers += $dnsServer
        }
    }
}
$vtDnsServers = (nslookup -type=NS verscend.com) | select-string "internet address"
ForEach ($vtDnsServer in $vtDnsServers) {
    $dnsServers += ($vtDnsServer.ToString()).split(" = ")[-1]
}

$dnsQueryTargets = 'FQDN,Type
securedr.verscend.com,A
securedr-gw.verscend.com,A' | ConvertFrom-CSV

$ipRegex = [regex]"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b"

$dnsTimeOut = 10
$dnsDebug = $false
#$dnsDebug = $true
If ($dnsDebug -eq $true) {$debugStr = " -debug"}
Else {$debugStr = ""}
$resultDNS = @()
ForEach ($dnsServer in $dnsServers) {
    ForEach ($dnsQueryTarget in $dnsQueryTargets) {
        $dnsQuery = "cmd /c nslookup -type=$($dnsQueryTarget.Type) -timeout=$dnsTimeOut$debugStr $($dnsQueryTarget.FQDN) $dnsServer"
        $allQueries += $dnsQuery
        $nslookupAll = Invoke-Expression $dnsQuery
        $nslookupResults = @()
        $nslookupAll | % {
            If ($_ -match $ipRegex.ToString()) {
                $nslookupResults += $matches[0]
            }            
        }
        $arr = New-Object -TypeName PSCustomObject
        $arr | Add-Member -MemberType NoteProperty -Name NameServer -Value $dnsServer
        $arr | Add-Member -MemberType NoteProperty -Name FQDN -Value $dnsQueryTarget.FQDN
        $arr | Add-Member -MemberType NoteProperty -Name Type -Value $dnsQueryTarget.Type
        $arr | Add-Member -MemberType NoteProperty -Name Response -Value $nslookupResults[-1]
        $resultDNS += $arr
    }
}

#Get SSL Configuration
$sslConf = Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL -Recurse | Where-Object {$_.Property -Contains "Enabled"}
If (-not $sslConf.Count -gt 0) {$sslConf = "No customization for SSL configuration"}

#Get Installed Apps
$hklm = 2147483650
$keys = @('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall')
# Do this, too:
$appData = @()
ForEach ($key in $keys) {
    $wmi = get-wmiobject -list "StdRegProv" -namespace root\default -computername $osver.CSName
    $splitKey = $key.Split("\")
    $fromKey = $splitKey[0]+'\'+$splitKey[1]+'\'+$splitKey[2]
    $SubKeys = $wmi.EnumKey($hklm,$key).sNames
    foreach ($SubKey in $SubKeys) {
        $snames = ($wmi.EnumValues($hklm,"$key\$SubKey")).snames | where {-not [string]::IsNullOrEmpty($_)}
        $Count = $snames.Count
        If ($Count -gt 0) {
            $Props = @{'Computer'=$osver.CSName}
            ForEach ($sname in $snames) {$Props.Add($sname,$wmi.GetStringValue($hklm,"$key\$subkey",$sname).sValue)}
            If ($Props.ContainsKey("DisplayName")) {
                $arr = New-Object -TypeName PSCustomObject
                $arr | Add-Member -MemberType NoteProperty -Name DisplayName -Value $Props.Get_Item("DisplayName")
                $arr | Add-Member -MemberType NoteProperty -Name DisplayVersion -Value $Props.Get_Item("DisplayVersion")
                $arr | Add-Member -MemberType NoteProperty -Name Publisher -Value $Props.Get_Item("Publisher")
                $arr | Add-Member -MemberType NoteProperty -Name InstallDate -Value $Props.Get_Item("InstallDate")
                $arr | Add-Member -MemberType NoteProperty -Name fromKey -Value $fromKey
                $appData += $arr
            }
        }
    }
}

#IE Configurations
$hkcuIeConfig = Get-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings"
$ieSettings = @()
ForEach ($prop in ($hkcuIeConfig | Select -ExpandProperty Property)) {
    $arr = New-Object -TypeName PSCustomObject
    $arr | Add-Member -MemberType NoteProperty -Name ieSetting -Value $prop
    $arr | Add-Member -MemberType NoteProperty -Name Value -Value (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\"$prop).$prop
    $ieSettings += $arr
    }
$ieSettingOutput = @()
ForEach ($ieSetting in $ieSettings) {
    $i = 1
    ForEach ($val in $ieSetting.Value) {
        $arr = New-Object -TypeName PSCustomObject
        $arr | Add-Member -MemberType NoteProperty -Name ieSetting -Value $ieSetting.ieSetting
        $arr | Add-Member -MemberType NoteProperty -Name Item -Value $i
        $arr | Add-Member -MemberType NoteProperty -Name Value -Value $val
        $ieSettingOutput += $arr
        $i++
    }
}

#IE Trusted Zone Configuration
$tzKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2"
$hkcuTzConfig = Get-Item $tzKey
$tzSettings = @()
ForEach ($prop in ($hkcuTzConfig | Select -ExpandProperty Property)) {
    $arr = New-Object -TypeName PSCustomObject
    $arr | Add-Member -MemberType NoteProperty -Name tzSetting -Value $prop
    $arr | Add-Member -MemberType NoteProperty -Name Value -Value (Get-ItemProperty $tzKey).$prop
    $tzSettings += $arr
    }
$tzSettingOutput = @()
ForEach ($tzSetting in $tzSettings) {
    $i = 1
    ForEach ($val in $tzSetting.Value) {
        $arr = New-Object -TypeName PSCustomObject
        $arr | Add-Member -MemberType NoteProperty -Name tzSetting -Value $tzSetting.tzSetting
        $arr | Add-Member -MemberType NoteProperty -Name Item -Value $i
        $arr | Add-Member -MemberType NoteProperty -Name Value -Value $val
        $tzSettingOutPut += $arr
        $i++
    }
}

#IE Trusted Zone Sites
$hkcuTzKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
$hklmOnlyKey = "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings"
$hklmTzKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"

$tzSitesOutput = @()
#HKLM Zones Forced?
Try {
    $hklmOnlyKeyVal = Get-ItemProperty -Path $hklmOnlyKey -Name Security_HKLM_only -ErrorAction Stop
    $hklmOnly = $hklmOnlyKeyVal.Security_HKLM_only
} 
Catch {
    $hklmOnly = 'No Value Found (HKCU Entries will be used)'

}
If ($hklmOnly -eq 1) {
}
#HKLM Zone Locations
$hklmEntries = Get-ChildItem $hklmTzKey -Recurse
ForEach ($site in ($hklmEntries | Where-Object {$_.ValueCount -gt 0})) {
    $eval = $site.Name.Split("\")
    If ($eval.count -gt 9) {
        $tzSite = ($eval[-1]+"."+$eval[-2])
    }
    Else {
        $tzSite = '*.'+$eval[-1]
    }
    ForEach ($val in 0..($site.ValueCount -1)) {
        $prot = $site.Property[$val]
        $arr = New-Object -TypeName PSCustomObject
        $arr | Add-Member -MemberType NoteProperty -Name RegistryHive -Value "HKLM"
        $arr | Add-Member -MemberType NoteProperty -Name Site -Value $tzSite
        $arr | Add-Member -MemberType NoteProperty -Name Protocol -Value $prot
        $arr | Add-Member -MemberType NoteProperty -Name Zone -Value (Get-ItemProperty -path $site.PSPath -Name $site.Property[$val]).$prot
        $tzSitesOutput += $arr
    }
}

#Current User Zone Locations
$hkcuEntries = Get-ChildItem $hkcuTzKey -Recurse
ForEach ($site in ($hkcuEntries | Where-Object {$_.ValueCount -gt 0})) {
    $eval = $site.Name.Split("\")
    If ($eval.count -gt 9) {
        $tzSite = ($eval[-1]+"."+$eval[-2])
    }
    Else {
        $tzSite = '*.'+$eval[-1]
    }
    ForEach ($val in 0..($site.ValueCount -1)) {
        $prot = $site.Property[$val]
        $arr = New-Object -TypeName PSCustomObject
        $arr | Add-Member -MemberType NoteProperty -Name RegistryHive -Value "HKCU"
        $arr | Add-Member -MemberType NoteProperty -Name Site -Value $tzSite
        $arr | Add-Member -MemberType NoteProperty -Name Protocol -Value $prot
        $arr | Add-Member -MemberType NoteProperty -Name Zone -Value (Get-ItemProperty -path $site.PSPath -Name $site.Property[$val]).$prot
        $tzSitesOutput += $arr
    }
}

#Proxy PAC File
Try {
    If (($ieSettingOutput | Where-Object {$_.ieSetting -eq "AutoConfigURL"} -ErrorAction Stop).value.Substring(0,4) -eq "http") {
        $pacUri = ($ieSettingOutput | Where-Object {$_.ieSetting -eq "AutoConfigURL"}).value
        $web = New-Object Net.WebClient
        $pacFile = $web.DownloadString($pacUri)
    }
}
Catch {
    $pacFile = "No PAC Configured"
}

#Output
$executeDate = Get-Date -Format 'yyyy-MM-dd'
$fileName = 'Verscend QR Data Collection - '
$fileName += $executeDate
$fileName += ' - '
$fileName += (Get-Item Env:\COMPUTERNAME).Value
$fileName += '_'
$fileName += (Get-Item Env:\USERNAME).Value
$fileName += '.txt'

$shellFolders = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
$desktop = Get-Item ($shellFolders.Desktop)
$outFile = Join-Path -Path $desktop.FullName -ChildPath $fileName

'###############################################################################################################################
Powershell Administrative Access' | Out-File -FilePath $outFile -Force
$psAdminRights | Out-File -FilePath $outFile -Append

'###############################################################################################################################
LMCompatibilityLevel' | Out-File -FilePath $outFile -Append
$lmcl | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Windows Operating System Version' | Out-File -FilePath $outFile -Append
$osVer | fl Caption, OSArchitecture, Version, ServicePackMajorVersion, ServicePackMinorVersion, BuildNumber | Out-File -FilePath $outFile -Append
'###############################################################################################################################
PowerShell Version' | Out-File -FilePath $outFile -Append
$PSVersionTable | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Microsoft Terminal Services Client Version' | Out-File -FilePath $outFile -Append
$mstscVer | fl | Out-File -FilePath $outFile -Append
'###############################################################################################################################
KB Patch Status' | Out-File -FilePath $outFile -Append
$resultKB | fl KB, Recommended, InstalledOn, Description | Out-File -FilePath $outFile -Append
'###############################################################################################################################
SSL Configuration Details' | Out-File -FilePath $outFile -Append
$sslConf | Out-File -FilePath $outFile -Append
'###############################################################################################################################
DNS Details' | Out-File -FilePath $outFile -Append
$resultDNS | sort FQDN | fl FQDN, Type, NameServer, Response | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Installed Application Details' | Out-File -FilePath $outFile -Append
$appData | sort DisplayName | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Internet Explorer Settings' | Out-File -FilePath $outFile -Append
$ieSettingOutput | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Internet Explorer Trusted Zone Settings' | Out-File -FilePath $outFile -Append
$tzSettingOutput | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Internet Explorer Trusted Zone Sites Settings - HKLM or HKCU' | Out-File -FilePath $outFile -Append
$hklmOnly | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Internet Explorer Trusted Zone Sites' | Out-File -FilePath $outFile -Append
$tzSitesOutput | Sort Site | fl | Out-File -FilePath $outFile -Append
'###############################################################################################################################
Automatic Proxy Configuration File Content' | Out-File -FilePath $outFile -Append
$pacFile | Out-File -FilePath $outFile -Append

Get-Content $outFile

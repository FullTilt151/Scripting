# WKID count
#(Get-ADGroupMember -Identity G_NTLMv2).Count

# List of WKIDs
#$adwkids = Get-ADGroupMember -Identity G_NTLMv2 | Select-Object -ExpandProperty name

$output = @()

Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    #$adwkid = Get-ADComputer -Identity $_
    #Add-ADGroupMember -Identity  "G_NTLMv2" -Members $adwkid -ErrorAction SilentlyContinue -Verbose
       
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $_)
        $RegKey= $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Lsa")
        $output += "$_,$($_ -in $adwkids),$($RegKey.GetValue("lmcompatibilitylevel")),$(Get-ADComputer -Identity $_ | Select-Object -ExpandProperty DistinguishedName)"
    } else {
        $output += "$_,$($_ -in $adwkids),Offline,$(Get-ADComputer -Identity $_ | Select-Object -ExpandProperty DistinguishedName)"
    }
}

$output
#$output | out-file c:\temp\NTLM.txt -Verbose
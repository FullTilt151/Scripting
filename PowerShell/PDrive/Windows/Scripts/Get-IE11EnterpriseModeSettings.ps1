param(
$ComputerName
)
$ErrorActionPreference = 'SilentlyContinue'
$ComputerName | 
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $WKID = $_
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $_)
        $RegKey= $Reg.OpenSubKey("SOFTWARE\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode")
        $SiteList = $RegKey.GetValue("SiteList")
        $RegKeyEdge= $Reg.OpenSubKey("SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\EnterpriseMode")
        $SiteListEdge = $RegKeyEdge.GetValue("SiteList")
        $RegU = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('Users', $_)
        $RegU.GetSubkeyNames() | Where-Object {$_ -notin ('.DEFAULT','S-1-5-18','S-1-5-19','S-1-5-20') -and $_ -notlike '*_Classes'} | 
        ForEach-Object {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier("$_")
            $objUser = $objSID.Translate( [System.Security.Principal.NTAccount]) 
            $RegUKey= $RegU.OpenSubKey("$_\Software\Microsoft\Internet Explorer\Main\EnterpriseMode")
            $wkid
            "IE: $sitelist"
            "Edge: $SiteListEdge"
            "$($objUser.Value) / $($RegUKey.GetValue("CurrentVersion"))"
        }
    } else {
        "$_ Offline"
    }
}
#Get WKIDs from text file. See if they're online.
Get-Content C:\Temp\DPs.txt | ForEach-Object {
	If (Test-Connection $_ -Quiet -Count 1){
	    Write-Output "$_,UP" 
	} Else {
	    Write-Output "$_,Down"
	}
} 

$Comp = 'LOUAPPWPS1646'
Get-ItemProperty "\\$Comp\HKLM\SOFTWARE\1E\NomadBranch\LocalCachePath"
$key = 'HKLM:\SOFTWARE\1E\NomadBranch\LocalCachePath'


$HKLM = [UInt32] "0x80000002"
$WMI_Reg = [WMIClass] "\\LOUAPPWPS1646\root\default:StdRegProv"
$RegSubKeySM = ($HKLM,"Software\1e\Nomadbranch\","LocalCachePath")
$RegValuePFRO = $RegSubKeySM.sValue




#Check remote registry
if(Test-Connection -ComputerName $Computer -Count 1 -Quiet){
	$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $computer)
		if($regKey -ne $null){
			[Microsoft.Win32.RegistryKey]$usersKey = $regKey.OpenSubKey($key, $false)
			$userKeyNames = $usersKey.GetSubKeyNames()
			foreach ($userKeyName in $userKeyNames){
				$userKey = $usersKey.OpenSubKey($userKeyName, $false)
				$packageKeyNames = $userKey.GetSubKeyNames()
				foreach ($packageKeyName in $packageKeyNames){
					$PackageID = $packageKeyName
					$pkgKey = $userKey.OpenSubKey($packageKeyName, $false)
					$guidNames = $pkgKey.GetSubKeyNames()
					foreach ($guidName in $guidNames){
						$guidKey = $pkgKey.OpenSubKey($guidName, $false)
						$pkg_ProgramID[$PackageID] = $guidKey.GetValue("_ProgramID")
						$pkg_RunStartTime[$PackageID] = $guidKey.GetValue("_RunStartTime")
						$pkg_State[$PackageID] = $guidKey.GetValue("_State")
					}
				}
			}



$key = 'SOFTWARE\1E\NomadBranch'
$valuename = 'LocalCachePath'
$computers = Get-Content C:\Temp\DPs.txt
foreach ($computer in $computers) {
	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
	$regkey = $reg.opensubkey($key)
	$regkey.getvalue($valuename)
}
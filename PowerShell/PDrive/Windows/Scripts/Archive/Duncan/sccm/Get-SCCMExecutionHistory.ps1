# ==============================================================================================
# 
# Microsoft PowerShell Source File
# 
# NAME: Get-SCCMExecutionHistory.ps1
# 
# AUTHOR: Duncan Russell
# DATE  : 2/14/2014
# 
# COMMENT: Parses Execution History from registry for the specified computer.
#          [Option] ReturnObjects: Return data as objects so that you can process further
#          [Option] GetPackageNames: Queries sms_package and sms_tasksequencepackage at site
#                                    for package names and matches them up by PackageID.  
#                                    Adds time, depending on how many packages you have on
#                                    the site. Also, could find duplicates in Packages and TS
#                                    since SCCM does not make PackageID unique across types.
#          TODO: Add APP-V
#                Lookup Software Update names
# 
# ==============================================================================================


param(
	[Parameter(Mandatory=$True,HelpMessage="Must specify a computer name.")]
	[string]$Computer,
	[switch]$GetPackageNames,
	[switch]$ReturnObjects
)
$siteServer = "LOUAPPWPS875.rsc.humad.com"
$siteCode = "CAS"

$key = "SOFTWARE\\Microsoft\\SMS\\Mobile Client\\Software Distribution\\Execution History"
$type = [Microsoft.Win32.RegistryHive]::LocalMachine
$pkg_ProgramID = @{}
$pkg_RunStartTime = @{}
$pkg_State = @{}
$smsPackageNames = @{}
$smsTsNames = @{}
$smsPackageManufacturers = @{}
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
			#sort $pkg_RunStartTime
			$pkg_RunStartTime_sorted = @{}
			$pkg_RunStartTime.GetEnumerator() | Sort-Object Value -OutVariable pkg_RunStartTime_sorted | Out-Null
			if($GetPackageNames){
				Get-WmiObject -namespace root\sms\site_$siteCode -class sms_package -computername $siteServer | ForEach-Object {$smsPackageNames[$_.PackageID] = $_.Name;$smsPackageManufacturers[$_.PackageID] = $_.Manufacturer} | Out-Null
				Get-WmiObject -namespace root\sms\site_$siteCode -class sms_tasksequencepackage -computername $siteServer | ForEach-Object {$smsTsNames[$_.PackageID] = $_.Name} | Out-Null
			}
			foreach($package in $pkg_RunStartTime_sorted.GetEnumerator()) {
				$packageName = ""
				$packageManufacturer = ""
				$executionTime = $package.Value
				$PackageID = $package.Name
				$ProgramID = $pkg_ProgramID.Get_Item($package.Name)
				
				$info = @{}				
				$info.ExecutionTime=$executionTime
				$info.PackageID=$PackageID
				$info.ProgramID=$ProgramID
				
				if($GetPackageNames){

					if(($smsPackageNames.ContainsKey($PackageID)) -and ($smsTsNames.ContainsKey($PackageID))){
						#PackageID is in the retrieved list of package names
						$NameMatchType = "CONFLICT"
						$info.NameMatchType = "CONFLICT"
						$packageName = $smsPackageNames.Get_Item($PackageID) + " **OR** " + $smsTsNames.Get_Item($PackageID)
					}
					elseif($smsPackageNames.ContainsKey($PackageID)){
						#PackageID is in the retrieved list of package names
						$NameMatchType = "PKG"
						$info.NameMatchType = "PKG"						
						$packageName = $smsPackageNames.Get_Item($PackageID)
					}
					elseif($smsTsNames.ContainsKey($PackageID)){
						#PackageID is in the retrieved list of package names
						$NameMatchType = "TS"
						$info.NameMatchType = "TS"
						$packageName = $smsTsNames.Get_Item($PackageID)
					}
					else{
						$NameMatchType = "UNKN"
						$info.NameMatchType = "UNKN"
						$packageName = "???"
					}
					
					
					if($smsPackageManufacturers.ContainsKey($PackageID)){
						$packageManufacturer = $smsPackageManufacturers.Get_Item($PackageID)
					}
					
				$info.PkgName=$packageName
				$info.PkgManufacturer=$packageManufacturer
				}

				if($ReturnObjects){
					#output object
					$object = New-Object –TypeName PSObject –Prop $info
					Write-Output $object
				}else{
					if($packageManufacturer -ne ""){
						$packageName = $packageManufacturer + " " + $packageName
					}
					Write-Host ("{0}  {1} " -f $executionTime, $PackageID)  -NoNewline
					if($NameMatchType -eq "CONFLICT"){
						Write-Host -BackgroundColor yellow -ForegroundColor red ("[{0}] {1}" -f $NameMatchType,$packageName) -NoNewline
						Write-Host (":{0}" -f $ProgramID)
						
					}
					else{
						Write-Host ("[{0}] {1}:{2}" -f $NameMatchType,$packageName,$ProgramID)
					}
				}
			}
		}
}

# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2011
# 
# NAME: 
# 
# AUTHOR: Humana User , Humana Inc.
# DATE  : 2/14/2014
# 
# COMMENT: 
# 
# ==============================================================================================

param(
	[string]$subnet
)
$bad = $false
$key = "SOFTWARE\\1E\\NomadBranch\\NMDS"
$type = [Microsoft.Win32.RegistryHive]::LocalMachine
$valueName = "MaximumMegaByte"
#$valueName = "CachePath"
$desiredValue = 61440
Switch -Regex ($subnet){
	'^(\d{1,3}\.){2}\d{1,3}$'{
		[string[]]$octet = $subnet.split(".")

		foreach ($element in $octet) {if([int]$element -gt 255){$bad = $true}}
		if(([int]$octet[0] -eq 0) -or ([int]$octet[0] -eq 255)){$bad = $true}
		if(!$bad){
			write-host "Valid subnet, proceeding..."
			for($i=1; $i -le 255; $i++){
				$address = $subnet + "." + [string]$i
				Write-Host ("Checking {0}..." -f $address)
				if(Test-Connection -ComputerName $address -Count 1 -Quiet){
					Write-Host ("    Connection succeeded to {0}, checking registry key..." -f $address)
					$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $address)
					if($regKey -ne $null){
						$regKey = $regKey.OpenSubKey($key,$true)
						$value = $regKey.GetValue($valueName)
						if($value -ne $desiredValue){
							Write-Host -ForegroundColor yellow ("    Value undesirable, changing...")
							try{
								$regKey.SetValue($valueName, $desiredValue, [Microsoft.Win32.RegistryValueKind]::DWORD)
								Write-Host -ForegroundColor green ("    Changed!")
							}
							catch{
								Write-Host -ForegroundColor red ("    Error changing value, sorry!")
							}
							
						}
						else {
							Write-Host -ForegroundColor green ("    Value is the desired value.")
						}

					}else{Write-Host ("    bad path")}
				}

			}
		}
		else {
			Write-Host -ForegroundColor Red "Bad subnet octet detected, should be values 0-255 (1-255 on first octet)"
		}
	}
	default {
		Write-Host -ForegroundColor Red "Subnet not in correct form, should be nnn.nnn.nnn"
		exit
		
	}
}


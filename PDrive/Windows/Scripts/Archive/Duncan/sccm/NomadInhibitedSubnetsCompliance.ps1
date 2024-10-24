$path = 'HKLM:\SOFTWARE\1E\NomadBranch'
$name = 'NomadInhibitedSubnets'
$desiredValue = '133.17.0.0/16,133.201.0.0/16,193.65.240.0/23,193.65.242.0/23,193.201.14.0/23,193.201.16.0/23,193.201.18.0/23,193.201.20.0/23,193.201.22.0/23,193.201.24.0/23,193.201.10.0/23,193.201.12.0/23,193.193.2.0/23,193.193.1.0/23,10.52.0.0/14,10.60.0.0/14'

if (Test-Path $path) {
	$Key = Get-Item -LiteralPath $Path
	if ($Key.GetValue($name, $null) -ne $null) {
		if((Get-ItemProperty -Path $path -Name $name).$name -eq $desiredValue){
			#compliant
			1
		}
		else{
			#non-compliant
			0
		}
	}
}


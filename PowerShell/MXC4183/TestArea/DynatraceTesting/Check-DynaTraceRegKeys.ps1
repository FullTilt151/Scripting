# Check for Chrome. 

# Check for Edge.
if(Get-AppxPackage -Name Microsoft.MicrosoftEdge){
    $EdgeInstalled = $true
}

if(test-path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'){
    $ChromeInstalled = $true 

    if(Test-Path -path 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist'){
        Write-Host (Get-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist").1 -ForegroundColor Blue
        Write-Host (Get-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist").2 -ForegroundColor Blue
    }

    if(Test-Path -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk'){
        Write-Host (Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy').fetchurl -ForegroundColor Blue
        Write-Host (Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy').adminmode -ForegroundColor Blue
    }

    Get-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty'
    Get-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions'
    Get-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk'
    Get-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy'
}


$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion'
(Get-ItemProperty -Path $key -Name ProgramFilesDir).ProgramFilesDir
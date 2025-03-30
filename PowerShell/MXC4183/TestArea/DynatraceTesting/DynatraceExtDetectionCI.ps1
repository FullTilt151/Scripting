# Detection Script for Chrome and Edge.
$ChromeInstalled = $false
$EdgeInstalled = $false
$Ckey = $false
$Ekey = $false

# Check for Chrome. 
if(test-path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'){
    $ChromeInstalled = $true 
}
# Check for Edge.
if(Get-AppxPackage -Name Microsoft.MicrosoftEdge){
    $EdgeInstalled = $true
}

# If Chrome is installed, check for keys.
if($ChromeInstalled -eq $true){
    #Chrome installed, check for Extension keys.
    if(Test-Path -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk'){
        $Ckey = $true
    }
}       

# If Edge is installed, check for keys.
if($EdgeInstalled -eq $true){
    #Edge installed, check for Extension keys.
    if(Test-Path -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli'){
        $Ekey = $true
    }
}       

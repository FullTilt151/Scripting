# Set this variable to true for the remediation script, false for the detection script

$remediateSL = $false
$remediateAdobe = $false
$remediateFire = $false
$remediateJava = $false 
$regitem1 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight -Name UpdateConsentMode -ErrorAction SilentlyContinue
$regitem2 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight -Name UpdateMode -ErrorAction SilentlyContinue
$regitem3 = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Silverlight -Name UpdateConsentMode -ErrorAction SilentlyContinue
$regitem4 = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Silverlight -Name UpdateMode -ErrorAction SilentlyContinue
$adobeB = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Policies\Adobe\Acrobat Reader" 
$adobeA = Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Adobe\Adobe ARM\Legacy\Reader"
$versionA = Get-ChildItem $adobeA -Name 
$PathA = ($adobeA + "/" + $version + "\Mode")
$versionB = Get-ChildItem $adobeB -Name
$PathB = ($adobeB + "/" + $versionB + "\bUpdater")

#Disable SilverLight Update
if (($regitem1 -ne $null) -or ($regitem2 -ne $null)) {
    Write-Output '32bit'
} else {
    $remediate =$true
} 

if (($regitem3 -ne $null) -or ($regitem4 -ne $null)) {
    Write-Output '64bit'
} else {
    $remediateSL =$true
}
   
#Disable Adobe Update
if (($adobeB -ne 0) -or ($adobeA -ne 0)) {
    Write-Output 'Not Compliant'
} else {
    $remediateadobe = $true
}

if(Test-Path "C:\Program Files (x86)\Mozilla Firefox" -IsValid) {
    Write-Output 'Firefox Path Exist'
} else {
    $remediateAdobe = $true
}

#Disable Java Update
if(Test-Path (("HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy\EnableJavaUpdate") -eq $false)) {
    Write-Output = $false
} else {
    $remediateJava = $true
}

# Put code here to determine if item is compliant #if the item is not compliant, be sure to run the lines below 

Write-Output $false 

#remediate

if($remediateSL = $true) {
    Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight -Name UpdateConsentMode -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Silverlight -Name UpdateMode -Value 2 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Silverlight -Name UpdateConsentMode -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Silverlight -Name UpdateMode -Value 2 -ErrorAction SilentlyContinue
}

if($remediateAdobe = $true) {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Policies\Adobe\Acrobat Reader\2015\FeatureLockDown" -Name bUpdater -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Adobe\Adobe ARM\Legacy\Reader\{AC76BA86-7AD7-FFFF-7B44-AE0F06755100}" -Name Mode -Value 0
}

if($remediateFire = $true) {
    Copy-Item -Path "\\lounaswps01\idrive\D907ATS\10239\install\Files\local-settings.js" -Destination "C:\Program Files (x86)\Mozilla Firefox\defaults\pref"
    Copy-Item -Path "\\lounaswps01\idrive\D907ATS\10239\install\Files\mozilla.cfg" -Destination "C:\Program Files (x86)\Mozilla Firefox"
}

if($remediateJava = $true) {
    New-Item HKLM:\SOFTWARE\WOW6432Node\JavaSoft -Name 'Java Update' -ErrorAction SilentlyContinue
    New-Item 'HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update' -Name 'Policy' -ErrorAction SilentlyContinue
    New-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy' -Name EnableJavaUpdate -PropertyType String -value 0 -ErrorAction SilentlyContinue
} else {     
    Write-Output $true
}
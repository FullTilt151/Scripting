# This script simply compares the current password with what is on the local machine
# The password will not be changed with this script.

# Set Password Version
$pwver = "0115"

function Get-EncryptedData {
# Encrypt password
    param($key,$data)
    $data | ConvertTo-SecureString -key $key |
    ForEach-Object {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
}

function Confirm-PW{
    #Write-host "Confirm PW"
    if ($Compliant -eq $DecryptedText) 
    {
	    #Create-RegKey
        Write-Output 1
    } 
    else 
    {
	    Write-output 0 
	} 
}

function Create-RegKey{
# If the Registry key doesn't exist, let's create it
    #Write-host "Create RegKey"
    New-Item -path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\humana -name PWD -Value "default Value"
    #Write-Host "Reg Key Created"
    Create-RegValue
}

function Create-RegValue{
# If the Registry value doesn't exist, let's make it
    #Write-host "Create RegValue"
    New-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\humana\PWD -Name $pwver -Value (get-date)
    #Write-Host "Reg Key Value Created"
    Compare-PW
}

function Compare-PW {
# Get current PC password
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$env:COMPUTERNAME)
    # Place the current Key and the Encrypted Password where necessary 
    $key = (188,118,129,122,181,71,166,72,84,178,211,145,43,141,148,176,42,85,237,202,44,175,185,14,36,90,132,53,32,255,231,221)
    $encryptedPW = "76492d1116743f0423413b16050a5345MgB8AHQAUwBhACsAbgBiADEAMABCAHMASwBFAHcAQgAvAFUANQB5AFAAeABjAFEAPQA9AHwAMQBjAGQAMgAzAGIAZQBkADYAZgBjADQAOAAxADAAYgBhADYAZQBlADQANQA0AGUAYwBkADkAOQA1ADgAMgAxADcANAA0AGMAMABjAGYANAA2ADcANQA1ADEANgBjADEAYgAzAGEAMgBjADEAZgA1ADgAZgA1AGIANgAwAGMAMwA=" 
	# Get current PC password and test them
    $DecryptedText = Get-EncryptedData -data $encryptedPW -key $key
    $Compliant = $obj.ValidateCredentials('administrator',$DecryptedText) 
    # Compare the two
    Confirm-PW
}

function Confirm-RegKey{
# Confirm that the Registry Key exists
    #Write-host "Confirm RegKey"
    #if ((get-itemproperty HKLM:\SOFTWARE\humana).pwd -ne $null)
    if ((Test-Path HKLM:\SOFTWARE\humana\PWD)) 
        {
        #write-host "Reg Key Found"
        Confirm-RegValue
        }
        else
        {
        #write-host "No Reg Key Found"
        Create-RegKey
        }
}

function Confirm-RegValue{
#Confirm that the Registry value is current
    #Write-host "Confirm RegValue"
    if((get-itemproperty HKLM:\SOFTWARE\humana\PWD).$pwver -ne $null)
        {
        #write-host "Reg Key Found"
        Compare-PW
        }
        else
        {
        #Write-Host "No Reg Key Found"
        #Compare-PW
        Create-RegValue
        }
}

# Begin the flowchart
Confirm-RegKey
# This script simply compares the current password with what is on the local machine
# The password will not be changed with this script.

# Set Password Version
$pwver = "0314a"

function Get-EncryptedData {
# Encrypt password
    param($key,$data)
    $data | ConvertTo-SecureString -key $key |
    ForEach-Object {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
}

function Confirm-PW{
    #Write-host "Confirm PW"
    if ($Compliant -eq $DecryptedText.TrimStart("System.Windows.Forms.TextBox, Text: "))
    {
	    #Create-RegKey
        Write-Output "1"
    }
    else
    {
	    Write-output "0"
	}
}

function Create-RegKey{
# If the Registry key doesn't exist, let's create it
    #Write-host "Create RegKey"
    reg add HKLM\Software\Humana\PWD /f
    #New-Item -path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\humana -name PWD -Value "default Value"
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
    $key = (207,221,213,162,66,222,167,84,70,138,43,243,7,252,12,9,59,56,4,193,102,230,237,215,105,101,190,46,126,56,192,151)
    $encryptedPW = "76492d1116743f0423413b16050a5345MgB8AFcAcwBlAHYAOABtADYAQgArAG8AZgB2AEEAWgB1AHcAZQBGADEAQgBmAHcAPQA9AHwAYgAxADMAMgA4ADgAMgAzAGEANQBiADEAZAAyAGEAMAA5ADAANgA5ADYAYwBjADkANAA4ADQAZAAyAGEAYwBkADQAMgBlAGYAMgA3ADQAMABlADEANgAwAGQAYgA2AGMAMgAxAGQAYwA3ADYANwA0ADEAMwBkAGMAYQAxAGQAOQAzAGUAMQA5ADgANwA0AGIAMAA1ADEAYwBkADQAYgBiAGUAZAA4ADAAYwBiAGUAZQBhAGEAYQAyADYAZgAxAGQANQBhAGEANgA3ADMAOQA0ADcANgBjADAAMAAzAGIANABhAGMAMwAxADMAOQAwADgAMwA4ADQANQBmAGQAMwA0ADMAYwAwAGIAMgA4ADkAMwBiADkANQA0ADcAMAA1ADAAMQBiADcAMgA3ADQAMABmAGEANABhADIANQBhADcANgA3AGMAYgBkAGYAZQA0AGQAYgA5ADUANABmADkAMgA3AGMANgBiAGIAYwBmADkAMAA4ADUAZQAwADcANABkADYA"
	# Get current PC password and test them
    $DecryptedText = Get-EncryptedData -data $encryptedPW -key $key
    $Compliant = $obj.ValidateCredentials('administrator',$DecryptedText.TrimStart("System.Windows.Forms.TextBox, Text: "))
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
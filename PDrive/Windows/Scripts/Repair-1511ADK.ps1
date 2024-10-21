<#
 .SYNOPSIS
Repair Windows 1511 ADK

.DESCRIPTION
Will install Microsoft KB3143760 fix against the Windows 10 1511 ADK (Build 10520)
Required for 

.NOTES
Copyright Keith Garner, All rights reserved. Permissive use license.

.LINK
https://support.microsoft.com/en-us/kb/3143760

.EXAMPLE
.\Repair-1511ADK.ps1 -verbose -ImagePath 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\en-us\winpe.wim'
Patch a single file.

.EXAMPLE
get-childitem 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\*.wim' -recurse | % { .\Repair-1511ADK.ps1 -verbose $_.FullName }
Patch ALL WinPE files in the ADK

#>

[CmdletBinding()]
param( 
    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string] $ImagePath
)

######################################################

$ErrorActionPreference = 'Stop'
$uri = 'http://hotfixv4.microsoft.com/Configuration%20Manager/nosp/Win10ADK_Hotfix_KB3143760/6.0.10586.163/free/490343_ENU_x64_zip.exe'
$tempfiles = @( 
    "$env:temp\490343_ENU_x64.zip",
    "$env:temp\Win10ADK-Hotfix-KB3143760.exe",
    "$env:temp\schema-x64.dat",
    "$env:temp\schema-x86.dat",
    "$env:temp\AclFile" )

remove-item -path $TempFiles -ErrorAction SilentlyContinue

######################################################
Write-verbose "Verify ImagePath"
######################################################


if ( -not ( test-path $ImagePath ) ) { throw [System.IO.FileNotFoundException] "$ImagePath not found." }
$ImageItem = Get-WindowsImage -imagepath $ImagePath -index 1 
$ImageItem | out-string | write-verbose
if ( $ImageItem | Where-Object Version -ne '10.0.10586.0' ) { throw "$ImagePath wim not Build 1511" }


######################################################
write-verbose "Download Path File locally"
######################################################

Invoke-WebRequest -Uri $uri -OutFile "$env:temp\490343_ENU_x64.zip"

write-verbose "extract Zip contents (Pass1)"

$Shell = new-object -com shell.application
$Shell.NameSpace("$env:temp\490343_ENU_x64.zip").items() | foreach-object { $Shell.NameSpace( $env:temp ).CopyHere($_) }
if ( -not ( test-path "$env:temp\Win10ADK-Hotfix-KB3143760.exe" ) ) { throw "Extract failure (Pass1)" }

write-verbose "extract Exe contents (Pass2)"
& $env:temp\Win10ADK-Hotfix-KB3143760.exe /T:$env:temp /q | out-null
if ( -not ( test-path "$env:temp\schema-x64.dat" ) ) { throw "Extract failure (Pass2)" }


######################################################
write-verbose "Mount WinPE"
######################################################

$PEMount = New-Item -ItemType Directory -Path "$env:temp\$([System.Guid]::NewGuid())" | 
    Select-Object -ExpandProperty FullName
Mount-WindowsImage -ImagePath $ImagePath -index 1 -path $PEMount |Write-Verbose

######################################################
write-verbose "Save schema.dat state"
######################################################

& icacls $PEMount\Windows\System32\schema.dat /save "$env:temp\AclFile" | write-verbose

######################################################
write-verbose "Update the Schema.dat file"
######################################################

& takeown /F $PEMount\Windows\System32\schema.dat /A | write-verbose
& icacls $PEMount\Windows\System32\schema.dat /grant "BUILTIN\Administrators:(F)" | write-verbose

######################################################
write-verbose "Copy the DAT file"
######################################################

if ( $ImageItem | where-object Architecture -eq 9 ) 
{
    copy-item -path  "$env:temp\schema-x64.dat" -Destination $PEMount\Windows\System32\schema.dat
}
elseif ( $ImageItem | where-object Architecture -eq 0 )
{
    copy-item -path "$env:temp\schema-x86.dat" -Destination $PEMount\Windows\System32\schema.dat
}
else
{
    write-warning "Architecture type not found for $ImagePath"
}

######################################################
write-verbose "Reset permissions and ownership"
######################################################

icacls $PEMount\Windows\System32\schema.dat /setowner "NT SERVICE\TrustedInstaller" | write-verbose
icacls $PEMount\Windows\System32\ /restore "$env:temp\AclFile" | write-verbose

######################################################
write-verbose "DisMount WinPE"
######################################################

Dismount-WindowsImage -Path $PEMount -Save | write-verbose
$PEMount = Remove-Item -Path $PEMount -ErrorAction SilentlyContinue

######################################################
write-verbose "Clean"
######################################################

remove-item -path $TempFiles -ErrorAction SilentlyContinue


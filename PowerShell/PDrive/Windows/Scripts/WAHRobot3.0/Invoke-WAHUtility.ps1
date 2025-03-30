<#
.Synopsis
   Humana Work At Home troubleshooting script for IT
.DESCRIPTION
   Humana Work At Home troubleshooting script for IT. This script provides real-time data around a WAH users network connection and workstation configuration. `
   The following items are tested or provided in this script:
    -Basic system and network information
    -Run PingPlotter to analyze latency
    -Run a Speedtest
    -Check Bandwidth
    -Check Latency
    -Check Big 5 compliance locally
.INPUTS
   -InstallOnly
   Do not actually run the script, only verify it is installed

   -PingPlotter
   Run PingPlotter no matter the connection

   -SendEmail
   Verifies the account running the utility has Outlook configured with a profile, then opens a new message, attaches the logs from the`
   last 24 hours, and prompts the user to send the message
.OUTPUTS
   Script transcript - c:\temp\WAHUtility_<date>.log
   Full script log and all output

   PintPlotter charts - c:\temp\PingPlotter
   Charts saved each time PingPlotter runs

   Archived logs - c:\temp\WAHUtilityArchive_<date>.zip
.EXAMPLE
   Invoke-WAHUtility.ps1
   This example runs the utility with the default settings
.EXAMPLE
   Invoke-WAHUtility.ps1 -InstallOnly
   This example runs the utility, but only installs it. It does not run any diagnostics.
.EXAMPLE
   Invoke-WAHUtility.ps1 -Uninstall
   This example uninstalls the utility. It does not run any diagnostics.
.EXAMPLE
   Invoke-WAHUtility.ps1 -PingPlotter
   This example runs the utility and forces PingPlotter to run despite the determined connection
.EXAMPLE
   Invoke-WAHUtility.ps1 -PingPlotter -SendEmail
   This example runs the utility and forces PingPlotter to run despite the determined connection. It also prompts to send an email with the logs attached.
#>

#requires -version 3

param(
    [switch]$InstallOnly,
    [switch]$Uninstall,
    [switch]$PingPlotter,
    [switch]$SendEmail
)

$date = Get-Date -format yyyyMMdd-hhmmsstt
$version = '3.0'

Start-Transcript -Path "c:\temp\WAHUtility_$date.log"

Write-Output "##### WAH Utility Started #####`n"

Write-Output "##### Verify script location #####"
$loc = (Get-Location).Path
Write-Output "Current location: $($loc)"

Write-Output "`n##### Verifying Install #####"

$admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

function InstallWAHUtility {
    if ($admin) {
        Write-Output "Copying install files..."
        New-Item -Path C:\humscript -Name WAHUtility -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Copy-Item -Path .\* -Destination C:\humscript\WAHUtility -Recurse -Force
    
        Write-Output "Copying desktop icon to Public desktop..."
        Copy-Item -Path .\Robot.ico -Destination C:\windows\System32 -Recurse -Force -ErrorAction SilentlyContinue
        
        Copy-Item -Path .\"Humana WAH Utility.lnk" -Destination C:\Users\Public\Desktop -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Output "Creating start menu folder and copying icons..."
        New-Item -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs' -Name 'Humana WAH Utility' -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        Copy-Item -Path .\"Humana WAH Utility.lnk" -Destination 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Humana WAH Utility' -Force -ErrorAction SilentlyContinue
        Copy-Item -Path .\"Humana WAH Utility - Email.lnk" -Destination 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Humana WAH Utility' -Force -ErrorAction SilentlyContinue
        Copy-Item -Path .\"Humana WAH Utility - PingPlotter.lnk" -Destination 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Humana WAH Utility' -Force -ErrorAction SilentlyContinue

        Write-Output "Branding registry..."
        New-Item HKLM:\Software\Humana\WAHUtility -Force | Out-Null
        Set-ItemProperty HKLM:\Software\Humana\WAHUtility -Name 'Version' -Value $version -Force | Out-Null
        Set-ItemProperty HKLM:\Software\Humana\WAHUtility -Name 'Installed' -Value $date -Force | Out-Null
        
    }
    Get-ChildItem C:\humscript\WAHUtility -include *.tmp -Hidden | ForEach-Object ($_) {Remove-Item $_.fullname -ErrorAction SilentlyContinue}
}

function UninstallWAHUtility {
    if ($admin) {
        Write-Output 'Removing Humscript files...'
        Remove-Item "C:\Humscript\WAHUtility" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Output 'Removing Start Menu files...'
        Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Humana WAH Utility" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Output 'Removing shortcut files...'
        Remove-Item 'C:\windows\System32\Robot.ico' -Force -ErrorAction SilentlyContinue
        Remove-Item 'C:\Users\Public\Desktop\Humana WAH Utility.lnk' -Force -ErrorAction SilentlyContinue

        Write-Output 'Removing registry tracking information...'
        Remove-Item HKLM:\SOFTWARE\humana\WAHUtility -Force -ErrorAction SilentlyContinue
    }
}

if ((Get-Location).Path -ne "c:\humscript\WAHUtility" -and !$Uninstall) {
    Write-Output "Not running from c:\humscripts\WAHUtility, installing..."
    InstallWAHUtility
    Write-Output "Install Complete!"
} elseif ($Uninstall -and !$InstallOnly) {
    Write-Output 'Uninstalling WAH Utility...'
    UninstallWAHUtility
    Write-Output 'Uninstall Complete!'
} else {
    Write-Output "Already installed!"
}

if (!$InstallOnly -and !$Uninstall) {
    Write-Output "`n##### NIC Information #####"
    $info = Get-WmiObject win32_networkadapterconfiguration -Filter "IPEnabled = 'true'"
    write-output "`nDescription:" $info.Description
    write-output "`nIP Address:" $info.IPAddress
    write-output "`nDHCP Server:" $info.DHCPServer
    write-output "`nDNS Server:"
    $info.DNSServerSearchOrder
    write-output "`nDNS Suffix:" 
    $info.DNSDomainSuffixSearchOrder
    write-output "`nMAC Address:" $info.MACAddress

    $ips = $info.IPAddress

    function ConnectionVerification {
        Write-Output "`n##### Connection Verification #####"

        if ((($ips -like "133.17*").Count -gt 0 -or ($ips -like "10.94*").Count -gt 0) -and (Get-Process -Name arr_exe -ErrorAction SilentlyContinue)) {
            Write-Output "Connected via Array!"
            $Connection = "Array"
        } elseif ($ips -like "10.52*" -or $ips -like "10.53*" -or $ips -like "10.54*" -or $ips -like "10.55*" -or $ips -like "10.60*" -or $ips -like "10.61*" -or $ips -like "10.62*" -or $ips -like "10.63*" ) {
            Write-Output "Connected via Aruba!"
            $Connection = "Aruba"
        } elseif (Test-Connection -count 1 LOUNASWPS08.rsc.humad.com -ErrorAction SilentlyContinue) {
            Write-Output "Connected internally to Humana!"
            $Connection = "OnNetwork"
        } elseif (Test-Connection -count 1 google.com -ErrorAction SilentlyContinue) {
            Write-Output "Connected, but off network!"
            $Connection = "OffNetwork"
        } else {
            Write-Output "No connection detected!"
            $Connection = "None"
        }
    }

    ConnectionVerification

    if ($Connection -eq "Array" -or $Connection -eq "Aruba" -or $Connection -eq "OnNetwork") {
        Write-Output "`n##### Internal Ping test via DNS #####"
        Test-Connection -Count 1 LOUNASWPS08.rsc.humad.com -Verbose -ErrorAction SilentlyContinue | Format-Table Address, Ipv4Address, ResponseTime -AutoSize

        Write-Output "`n##### Internal Ping test via IP #####"
        Test-Connection -Count 1 193.91.192.23 -Verbose -ErrorAction SilentlyContinue | Format-Table Address, Ipv4Address, ResponseTime -AutoSize
    }

    function BandwidthTest {
        $URL = "http://rasweb.humana.com/myvpn/10MB.jpg"
        #$URL = "http://ipv4.download.thinkbroadband.com/50MB.zip"
        
        $WebClient = New-Object System.Net.WebClient
        $BandwidthResults = @()
        $i = 0

        for ($i=0; $i -lt 6; $i++) {
            $ErrorActionPreference = "SilentlyContinue"
            $Bandwidth = "{0:N2}" -f ((10/(Measure-Command {
                $WebClient.DownloadFile( $url, $path )
            }).TotalSeconds)*8)
            $ErrorActionPreference = "Continue"
            $BandwidthResults += $Bandwidth
        }

        Write-Output "`n##### Bandwidth Results #####"

        $BandwidthResults

        Write-Output "`n##### Average Bandwidth Speed #####"

        "{0:N2}" -f ($BandwidthResults | Measure-Object -Average | Select-Object -ExpandProperty Average) + " Mbps"

        Write-Output "`n WARNING: Bandwidth results may not be completely accurate!"
    }

    function PingPlotter {
        Set-Location C:\humscript\WAHUtility\PingPlotter
        Write-Output "Starting PingPlotter trace..."
        & C:\humscript\WAHUtility\PingPlotter\PingPlotter.exe HumanaWAH.pp2 /trace:205.145.64.64
        Write-Output "Waiting for PingPlotter to finish..."
        start-sleep -Seconds 15
        $i = 0
        while ((Get-Process -Name PingPlotter -ErrorAction SilentlyContinue) -and $i -lt 65) {
            Start-Sleep -Seconds 5
            $i++
        }
        if ((Get-Process -Name PingPlotter -ErrorAction SilentlyContinue)) {
            Write-Output "Closing PingPlotter..."
            Stop-Process -Name PingPlotter -Force -ErrorAction SilentlyContinue
        }
        Set-Location $loc
    }

    function ArchiveAndEmail {
        Write-Output "`n##### Archiving Logs #####"

        New-Item -Path c:\temp\WAHUtilityTempArchive -ItemType directory -ErrorAction SilentlyContinue | Out-Null
        Get-ChildItem C:\temp\WAHUtility*.log | Where-Object {$_.LastWriteTime -gt (Get-Date).AddHours(-24)} | ForEach-Object {Copy-Item $_ c:\temp\WAHUtilityTempArchive}
        Get-ChildItem C:\temp\PingPlotter\* | Where-Object {$_.LastWriteTime -gt (Get-Date).AddHours(-24)} | ForEach-Object {Copy-Item $_ c:\temp\WAHUtilityTempArchive}

        Write-Output "Compressing logs..."
        $source = "C:\temp\WAHUtilityTempArchive"
        $destination = "C:\temp\WAHUtilityArchive_$date.zip"
        
        Add-Type -assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($source, $destination)
        if (Test-Path $destination -ErrorAction SilentlyContinue) {
            Write-Output "Saved archive to: " $destination
        }
        Write-Output "Cleaning up archive..."
        Remove-Item c:\temp\WAHUtilityTempArchive -Recurse -Force -ErrorAction SilentlyContinue

        if ((get-childitem $env:AppData\..\Local\Microsoft\Outlook\*.ost -ErrorAction SilentlyContinue) -ne $null) {
            Write-Output "`n##### Emailing Archive #####"

            $Outlook = New-Object -com Outlook.Application

            $mail = $Outlook.CreateItem(0)

            $mail.subject = �WAH Utility Diagnostics�
            $mail.body = �Automated email from the WAH Utility�

            $attachmentfile = $destination
            $attachment = new-object System.Net.Mail.Attachment $attachmentfile
            $mail.Attachments.Add($attachmentfile)

            Write-Output "Opening email for user..."
            $mail.Display()
        } else {
            Write-Output "No email profile found!"
        }
    }

    function Big5Compliance {
        Write-Output "`n##### Big 5 Compliance #####"
        Write-Output "Checking DG..."
        Write-Output "DG Status: $((Get-ItemProperty HKLM:\SOFTWARE\VDG -Name Status -ErrorAction SilentlyContinue).Status)"
        Write-Output "Checking McAfee services..."
        Write-Output "McAfee Framework: $((Get-Service -Name McAfeeFramework -ErrorAction SilentlyContinue).Status)"
        Write-Output "McAfee Agent: $((Get-Service -Name MaSvc -ErrorAction SilentlyContinue).Status)"
        Write-Output "McAfee Agent Common: $((Get-Service -Name MaCmnSvc -ErrorAction SilentlyContinue).Status)"
        Write-Output "McAfee Service Controller: $((Get-Service -Name mfemms -ErrorAction SilentlyContinue).Status)"
        Write-Output "McAfee VTP: $((Get-Service -Name mfevtp -ErrorAction SilentlyContinue).Status)"
        Write-Output "Checking SCCM Service..."
        Write-Output "SCCM Service: $((Get-Service -Name CcmExec -ErrorAction SilentlyContinue).Status)"
        Write-Output "Checking Encryption..."
        Write-Output "WinMagic Service: $((Get-Service -Name "WinMagic SecureDoc Service" -ErrorAction SilentlyContinue).Status)"
        Write-Output "WinMagic Encryption Status: $((Get-ItemProperty HKLM:\SOFTWARE\WinMagic -Name DiskEncrypted -ErrorAction SilentlyContinue).DiskEncrypted)"
        Write-Output "Checking AD Group Policy..."
        $gpr = (gpresult /s $env:computername /SCOPE COMPUTER /Z | Select-String "Last time Group Policy was applied:").ToString()
        Write-Output $gpr
    }

    function ArrayDNSFix {
        Write-Output "`n##### Array DNS Fix #####"
        if (Test-Path C:\Humscript\Array_DNS_Fix\ARRAY_DHCP.vbs -ErrorAction SilentlyContinue) {
            Write-Output "Array DNS Fix found in Array DNS Fix folder, running..."
            & cscript.exe C:\Humscript\Array_DNS_Fix\ARRAY_DHCP.vbs
        } elseif (Test-Path C:\humscript\WKID\ARRAY_DHCP.vbs -ErrorAction SilentlyContinue) {
            Write-Output "Array DNS Fix found in WKID folder, running..."
            & cscript.exe C:\humscript\WKID\ARRAY_DHCP.vbs
        } else {
            Write-Output "Array DNS Fix not found!"
        }
    }

    if ($Connection -eq "Aruba" -or $Connection -eq "Offnetwork" -or $Connection -eq "OnNetwork" -or $Connection -eq "None") {
        #ArrayDNSFix
    }

    if ($Connection -eq "None") {
        Write-Output "Releasing IP address"
        & ipconfig /release
        Write-Output "Renewing IP address"
        & ipconfig /renew
    }

    Big5Compliance

    if ($Connection -eq "OffNetwork" -or $PingPlotter) {
        Write-Output "`nRunning Bandwidth test..."
        BandwidthTest
        Write-Output "`n##### PingPlotter Trace #####"
        PingPlotter
    } else {
        Write-Output "Not running PingPlotter..."
    }

    if ($SendEmail) {
        ArchiveAndEmail
    }
}
Write-Output "`n##### WAH Utility Complete #####"

Stop-Transcript
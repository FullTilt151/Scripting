<#
This script can be used as a Configuration Item (CI) on 1E PXE Lite Local. 
If 1E PXE Lite Local is installed, it will get the logs directory and
check the last few lines of the PXELiteServer.log for the Unlicensed
message. If found, it will attempt to relicense with the supplied
$PXELiteLicenseKey (update your key after the 1E Disclaimer below). 
This script is assuming that 1E PXE Lite Local is installed in default directory C:\Program Files (x86)\1E\PXE Lite\Server

Integer return values:
 0 = compliant (true)
 1 = non-compliant (1E PXE Lite Local is installed and unlicensed in logs, but
     falied to re-license AND start the service). If the service is
     disabled then this will happen. (false)

1E Ltd Copyright 2019
Disclaimer:                                                                                                                
                                                                                                                       
 Your use of this script is at your sole risk. This script is provided "as-is", without any warranty, whether express or implied, of accuracy, 
completeness, fitness for a particular purpose, title or non-infringement, and is not supported or guaranteed by 1E. 1E shall not be liable for any damages you may sustain by using this script, whether direct, 
indirect, special, incidental or consequential, even if it has been advised of the possibility of such damages. 
#>

$PXELiteLicenseKey = "HUMPXE3-5UN2-187J-8W56-AQK8"

$PXERegPath = "HKLM:\SOFTWARE\WOW6432Node\1E\PXELiteServer"

if($PXERegPath -ne $null){
    $PXEExe = "cmd /c ""C:\Program Files (x86)\1E\PXE Lite\Server\PXELiteServer.exe"" -relicense=$PXELiteLicenseKey"
    $PXELogFile = (Get-ItemProperty $PXERegPath).LogFileName
    $LogContent = Get-Content $PXELogFile | Select-Object -Last 30
    if($LogContent -match 'PXELiteServer30 license error. Expired'){

        # Remediate

        # Run the relicense command
        Invoke-Expression $PXEExe
        
        # start service
        Start-Service PXELiteServer
        Start-Sleep -Seconds 10

        #check the service status
        if( (Get-Service PXELiteServer).status -eq 'Running'){
            # Service is running now
            return $true #write-host 0
        } else{
            # Could not remediate, requires manual intervention
            return $false #write-host 1
        }
    }
    else {
        # Service not in unlicensed status
        return $true #write-host 0
    }

} else {
    # PXE not found in registry
    return $true #write-host 0
}

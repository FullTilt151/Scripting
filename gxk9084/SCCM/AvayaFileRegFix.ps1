#########################################################################
#   <powershell.exe -executionpolicy bypass .\<thisscriptname>.ps1>     #
#########################################################################

#-Pre-Installation Calls
function Pre-Inst {
    $null
}

#-Application name, no spaces
$APPN = "AvayaFileRegistrationFix_1.0"
#Example, $APPN = "Adobe_Reader_11.1"

<#Do not Modify---#>$MSILines = @()<#---Do not Modify#>

#-MSI,MST Lines (add lines as needed...)
#$MSILines += "AE910.msi,custom.mst"
#$MSILines += "WorkFiles.msi,WorkFiles.mst"
#$MSILines += "example3.msi"
#$MSILines += "example4.msp"

#-Post-Installation Calls
function Post-Inst {
    $R17 = 'C:\Program Files (x86)\Avaya\CMS Supervisor R17\sReg.bat'
    $R18 = 'C:\Program Files (x86)\Avaya\CMS Supervisor R18\sReg.bat'
    $R19 = 'C:\Program Files (x86)\Avaya\CMS Supervisor R19\sReg.bat'

    if (Test-Path $R17) {
        "Running $R17" | Out-File $PSLogfile -Append
        "" | Out-File $PSLogfile -Append
        $output = & $R17
        if ($output.length -eq 22) {
            New-Item C:\temp\sRegBatSuccess.txt
        } 
    }
    elseif (Test-Path $R18) {
        "Running $R18" | Out-File $PSLogfile -Append
        "" | Out-File $PSLogfile -Append
        $output = & $R18
        if ($output.length -eq 22) {
            New-Item C:\temp\sRegBatSuccess.txt
        } 
    }
    elseif (Test-Path $R19) {
        "Running $R19" | Out-File $PSLogfile -Append
        "" | Out-File $PSLogfile -Append
        $output = & $R19
        if ($output.length -eq 22) {
            New-Item C:\temp\sRegBatSuccess.txt
        }
    } 
}

    
    

#-Determine and set path to this script.
$ScriptLocation = $MyInvocation.Mycommand.Path
$ScriptPath = Split-Path $ScriptLocation
Set-Location $ScriptPath
$CurrDate = (Get-Date)

#-PackageID and Logfile
$Logfile = "C:\temp\Software_Install_Logs\$APPN.log"
$PSLogfile = "C:\temp\Software_Install_Logs\Install-$APPN.log"
if (!(Test-Path -Path "$Env:Windir\temp\Software_Install_Logs")) {
    new-item C:\temp\Software_Install_Logs -itemtype directory
}

#-Start Logfiles
"" | Out-File $Logfile -Append
"$Currdate $APPN initiated." | Out-File $Logfile -Force
"" | Out-File $PSLogfile -Append
"$Currdate $APPN initiated." | Out-File $PSLogfile -Force

#-Logic
$Process = $True
Try {
    "Processes Pre-Install Commands..." | Out-File $PSLogFile -Append
    $flgPreInst = 0
    Pre-Inst
}
Catch {
    [System.Exception]
    "System Exception found." | Out-File $PSLogFile -Append
    $error[0].Exception.GetType().FullName | Out-File $PSLogFile -Append
    $error[0].Exception.Message | Out-File $PSLogFile -Append
    $flgPreInst = 1 ; continue
   
}
Finally {
    if ($flgPreInst -eq 0) {
        "Pre-Install Commands Completed Successfully" | Out-File $PSLogFile -Append 
    }
    else {
        "Pre-Install Commands Completed with Errors" | Out-File $PSLogFile -Append
    }
}

foreach ( $Line in $MSILines ) {

    $Split = $Line.Split(",")
    $MSI = $Split[0]
    $MST = $Split[1]

    #-CommandLine and Arguments
    $CMDLine = "msiexec.exe"
    if ($MSI -like "*.msp") {
        if ($MSI -like "example?.msp") {
            "Example File Ignored" | Out-File $PSLogfile -Append
            $CMDArgs = $MSI
            $Process = !$True 
        }
        else {
            $CMDArgs = "/update $MSI /qb /norestart ALLUSERS=1 /L*V+ $Logfile" 
        }
    }
    elseif ($MSI -like "example?.msi" -or $null) {
        "Example File Ignored" | Out-File $PSLogfile -Append
        $CMDArgs = $MSI
        $Process = !$True 
    }
    elseif ($MST -eq $NULL) {
        $CMDArgs = "/i $MSI /qb /norestart ALLUSERS=1 /L*V+ $Logfile" 
    }
    else {
        $CMDArgs = "/i $MSI TRANSFORMS=$MST /qb /norestart ALLUSERS=1 /L*V+ $Logfile" 
    }

    #-Process CommandLine
    if ($process -eq $true) {
        $CMD = Start-Process $CMDLine -ArgumentList $CMDArgs -Wait -PassThru
        $ErrCode = $CMD.ExitCode
    }
    else { $ErrCode = 0 }

    #-WriteLog
    "Processing Command Line:" | Out-File $PSLogfile -Append
    "" | Out-File $PSLogfile -Append
    "$CMDLine $CMDArgs" | Out-File $PSLogfile -Append
    "" | Out-File $PSLogfile -Append
    If ($ErrCode -eq 0) {
        "Install completed successfully" | Out-File $PSLogfile -Append
        "" | Out-File $PSLogfile -Append
    }
    else {
        "Package closed with an exitcode of $ErrCode" | Out-File $PSLogfile -Append
        "" | Out-File $PSLogfile -Append
        "" | Out-File $PSLogfile -Append
        $ExitCode1 = $true
    }
}
#-Post-Install Commands Lines
Try {
    "Processes Post-Install Commands..." | Out-File $PSLogFile -Append
    $flgPreInst = 0
    Post-Inst
}
Catch {
    [System.Exception]
    "System Exception found." | Out-File $PSLogFile -Append
    $error[0].Exception.GetType().FullName | Out-File $PSLogFile -Append
    $error[0].Exception.Message | Out-File $PSLogFile -Append
    $flgPreInst = 1 ; continue
   
}
Finally {
    if ($flgPreInst -eq 0) {
        "Post-Install Commands Completed Successfully" | Out-File $PSLogFile -Append 
    }
    else {
        "Post-Install Commands Completed with Errors" | Out-File $PSLogFile -Append
    }
}

#-Disply Logfile to Host on Exit
$DispPSLogfile = Get-Content $PSLogfile
$DispPSLogfile
if ($exitcode1 -eq $true) {
    Exit 1 
}
else {
    Exit
}
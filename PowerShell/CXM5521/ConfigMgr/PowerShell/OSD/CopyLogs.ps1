<#
    Humana CopyLogs
    Used in task ConfigMgr Task sequences to copy logs to the SLShare.
    Uses the Network Access Account to authenticate to the SLShare ('_SMSTSReserved1-000', and '_SMSTSReserved2-000' variables)
    If the machine is NOT a VM, and the computer name does not end in the serial number, a Computer_Name_Mismatch.log file is generated in the SMSTSLog directory
#>
if (-not (Test-Connection -ComputerName LOUNASWPS08 -ErrorAction SilentlyContinue)) {
    Write-Output 'Failed to ping LOUNASWPS08'
    exit
}

#region Create TSEnvironment
try {
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
}
catch {
    Write-Output 'Failed to establish Microsoft.SMS.TSEnvironment ComObject'
    exit 1
}
#endregion Create TSEnvironment

try {
    #region define and determine variables
    $SerialNumber = (Get-WmiObject -Query "SELECT SerialNumber FROM Win32_Bios").SerialNumber
    $TimeStamp = Get-Date -Format "yyyy-MM-dd_HH.mm"
    $OSDComputerName = $TSEnvironment.Value('OSDComputerName')
    $SMSTSInWinPE = $TSEnvironment.Value("_SMSTSInWinPE")
    $LogSharePath = $TSEnvironment.Value("SLSHARE")
    $NaaUser = $TSEnvironment.Value("_SMSTSReserved1-000")
    $NaaPW = $TSEnvironment.Value("_SMSTSReserved2-000")
    $IsVM = $TSEnvironment.Value("IsVM")
    $AllStepsSucceeded = $TSEnvironment.Value('AllStepsSucceeded')
    if ([string]::IsNullOrWhiteSpace($AllStepsSucceeded)) {
        $AllStepsSucceeded = $false
    }

    # Store a temporary path to store log files prior to zipping if needed
    $TSLogTemp = Join-Path -Path $env:Temp -ChildPath TSLogTemp

    #region determine log paths to gather
    $SMSTSLogPath = $TSEnvironment.Value("_SMSTSLogPath")

    # generate an array of sourcelogpaths to copy logs from based on whether the machine is in WinPE or not
    $SourceLogPaths = switch ($SMSTSInWinPE) {
        $true {
            # grab logs from the _SMSTSLogPath TSEnvironment Variable location
            $SMSTSLogPath
            # attempt to find the NomadBranch log files
            $DiskDrives = (Get-WmiObject -Query "SELECT DeviceId FROM Win32_LogicalDisk WHERE DriveType = 3").DeviceID
            foreach ($Drive in $DiskDrives) {
                (Resolve-Path -Path "$Drive\_SMSTaskSequence\NomadBranch\LogFiles" -ErrorAction SilentlyContinue).Path
            }
        }
        $false {
            "$env:SystemDrive\Windows\CCM\Logs", "$env:SystemDrive\Windows\Logs\DISM"
        }
    }
    #endregion determine log paths to gather


    Write-Output "Determined machine [IsVM = '$IsVM']"
    switch ($IsVM) {
        $false {
            if (-not $OSDComputerName.EndsWith($SerialNumber)) {
                # if the machine is a phsyical machine, we validate that the computer name ends in the serial number, if not, drop a log file indicating the mismatch
                New-Item -Path $SMSTSLogPath -Name 'Computer_Name_Mismatch.log' -ItemType File -Value "[Expected = '*$SerialNumber'] [Actual = '$OSDComputerName]"
            }
        }
    }
    Write-Output "[OSDComputerName = '$OSDComputerName'] [SMSTSInWinPE = '$SMSTSInWinPE'] [AllStepsSucceeded = '$AllStepsSucceeded'] [LogSharePath = '$LogSharePath']"
    #endregion define and determine variables

    #region functions
    function Authenticate {
        param(
            [string]$UNCPath = $(Throw "An UNCPath must be specified"),
            [string]$User,
            [string]$PW
        )

        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "net.exe"
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = "USE $($UNCPath) /USER:$($User) $($PW)"
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $p.WaitForExit()
    }

    function ZipFiles {
        param(
            [string]$ZipFileName,
            [string]$SourceDir
        )

        Add-Type -Assembly System.IO.Compression.FileSystem
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
        [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDir, $ZipFileName, $compressionLevel, $false)
    }
    #endregion functions

    #region define parameters for copy commands
    $CopyParams = @{
        Verbose     = $true
        Force       = $true
        ErrorAction = 'SilentlyContinue'
        Recurse     = $true
        Filter      = '*.log'
    }

    $CopyToShareParams = @{
        Destination = "$LogSharePath\$OSDComputerName\$TimeStamp\"
    }

    $CopyToTempParams = @{
        Destination = $TSLogTemp
    }
    #endregion define parameters for copy commands

    #region create necessary directories and copy logs
    try {
        # Catch Error if already authenticated
        Authenticate -UNCPath $LogSharePath -User $NaaUser -PW $NaaPW
    }
    catch {
    }

    if (Test-Path -Path $LogSharePath) {
        #region dump all safe Task sequence variables to a file
        # add variables to this array that you don't want to dump to the log file
        $ExcludeVariables = @('_OSDOAF', '_SMSTSReserved', '_SMSTSTaskSequence', 'Webservice_URI', 'Webservice_Secret')
        $TSVarLogFileName = [string]::Format("TSVariables-{0}.log", $TimeStamp)
        $TSVarlogFileFullName = Join-Path -Path $SMSTSLogPath -ChildPath $TSVarLogFileName

        # loop through all variables in TSEnvironment, if the variable name doesn't match one in the ExcludeVariables array it will be dumped to the log file
        foreach ($TSVar in $TSEnvironment.GetVariables()) {
            if ($null -eq ($ExcludeVariables | Where-Object { $_ -match $TSVar })) {
                "$TSVar = $($TSEnvironment.Value($TSVar))" | Out-File -FilePath $TSVarlogFileFullName -Append -Force
            }
        }
        #endregion dump all safe Task sequence variables to a file

        switch ($AllStepsSucceeded) {
            $true {
                # if all steps succeeded, we will zip the files
                if (-not (Test-Path -Path $TSLogTemp)) {
                    # create a temp directory to copy all logs into
                    New-Item -Path $env:Temp -Name TSLogTemp -ItemType Directory -Force -ErrorAction Stop
                }
                foreach ($LogPath in $SourceLogPaths) {
                    # copy all files into the newly created temp directory
                    Copy-Item -Path $LogPath @CopyToTempParams @CopyParams
                }

                $ComputerSubFolder = Join-Path -Path $LogSharePath -ChildPath $OSDComputerName
                Test-Path -Path $LogSharePath -Verbose
                Test-Path -Path $ComputerSubFolder -Verbose
                if (-not (Test-Path -Path $ComputerSubFolder)) {
                    $null = New-Item -Path $LogSharePath -Name $OSDComputerName -ItemType Directory -Force -ErrorAction Stop
                }

                # zip files and delete temp directory
                $ZipFileName = Join-Path -Path $ComputerSubFolder -ChildPath [string]::Format('{0}.zip', $TimeStamp)
                ZipFiles -ZipFileName $ZipFileName -SourceDir $TSLogTemp
                Remove-Item -Path $TSLogTemp -Recurse -Force
            }
            $false {
                # if all steps did not succeed, we will create datetime stamped folder and copy the .log files directly, no zipping
                $null = New-Item -Path $LogSharePath -Name "$OSDComputerName\$TimeStamp" -ItemType Directory -Force -ErrorAction Stop
                foreach ($LogPath in $SourceLogPaths) {
                    Copy-Item -Path $LogPath @CopyToShareParams @CopyParams
                }
            }
        }
    }
    #endregion create necessary directories and copy logs
}
catch {
    Write-Output "Error: $($_.Exception.Message)"
    exit 1
}
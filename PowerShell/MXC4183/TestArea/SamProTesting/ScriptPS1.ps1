#This is the main ps1 file, we noticed working with Jake. Trying to find where the creds are coming from.

Param([string]$computer, [string]$script, [boolean]$useCred, [boolean]$isMid, [boolean]$isDiscovery, [boolean]$debug, [boolean]$logInfo, [boolean]$skipTest, [boolean]$executeRemote, [boolean]$copyScriptToTarget)

 

$global:AutomaticVariables = Get-Variable

 

# translate powershell_param_ environment variables to normal variables
if(Test-Path Env:SNCExecuteRemoteVars){
    $remoteVarsVariable = Get-ChildItem -Path Env:SNCExecuteRemoteVars 2> $null
}
if ($remoteVarsVariable) {
    $paramNamesString = $remoteVarsVariable.Value
    $paramNames = ($paramNamesString -split ",")
    $paramNames = $paramNames | ForEach-Object {"Env:$_"}
    $vars = Get-ChildItem -Path $paramNames

 

    Foreach ($var in $vars) {
        $name = $var.Name
        $value = $var.Value
        Set-Variable -Name $name -Value $value -Scope Global
    }
}

 

$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$midScriptDirectory = $executingScriptDirectory -replace "\\[\w]*$", ""
$global:logInfo=$logInfo

 

import-module "$executingScriptDirectory\Credentials"  -DisableNameChecking
import-module "$executingScriptDirectory\WMIFetch"
import-module "$executingScriptDirectory\XMLUtil"
import-module "$executingScriptDirectory\LaunchProc"
import-module "$executingScriptDirectory\Get-PEB"
import-module "$executingScriptDirectory\DiagnosticsUtil" -DisableNameChecking
import-module "$executingScriptDirectory\PSRemoteSession" -Global
import-module "$executingScriptDirectory\WinRMAPI\ExecuteRemote\ExecuteRemote"

 

# Copy the environment variables to the params
if (test-path env:\SNCUser) {
    $Private:userProtected = $env:SNCUser
    $Private:passwordProtected = $env:SNCPass
    $env:SNCUser=''
    $env:SNCPass=''
    $global:encryptedVars=$env:SNCEncryptedVars
}

 

# Debugging information ...
SNCLog-PowershellVersion
SNCLog-EnvironmentVars
SNCLog-ParameterInfo @("Executing PSScript.ps1", $computer, $script, $useCred, $isMid, $isDiscovery)

 

# This part exposes any arguments that are in addition to the parameters to the current scope
for ($i = 0; $i -lt $args.count; $i += 2) {
    $value = ''
    if ($i + 1 -lt $args.count) {
        $value = $args[$i + 1]
    }
    if ($value -eq $null) {
        new-variable -name $args[$i] -value $null
    } elseif ($value.getType().Name -eq "Boolean") {
        if ($value) {
            new-variable -name $args[$i] -value $true
        } else {
            new-variable -name $args[$i] -value $false
        }
    } else {
        new-variable -name $args[$i] -value $value
    }

 

    remove-variable -name value
}

 

# This part attempts to access the target system, just to see if we have access - if using credentials, it tries to figure out
# the appropriate credential checking mechanism by looking for a $credType in the argument list - if it is not set, assume
# WMI
if($credType -eq $null) {
  if(test-path env:\SNC_credType) {
    $credType=$env:SNC_credType
  }
}

 

$cred = $null
if ($credType -eq $null) {
    SNCLog-DebugInfo "`t`$credType is undefined, defaulting to WMI"
    $credType = "WMI"
}

 

$credTestFunc = "testCredential" + $credType
$noCredTestFunc = "testNoCredentialAccess" + $credType

 

#
# This part checks to see if the target host is the mid and if the usecred variable is set to true.  If both are correct the testCredentialGetCred is called in the 
# credentials.psm1 module.
#
if($isMid -and $useCred) {
    $credType = "GetCred"
    $credTestFunc = "testCredential" + $credType
} 
try {
    if ($useCred) {
        if ($skipTest) {
            $cred = getCredential $Private:userProtected $Private:passwordProtected
        }
        else {
            $cred = & $credTestFunc -computer $computer -user $Private:userProtected -password $Private:passwordProtected -debug $debug
        }
    } else {
        & $noCredTestFunc -computer $computer -debug $debug
    }
} catch [System.Exception] {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2;
}

 

# make $computer and $cred globally available
$global:computer = $computer
$global:cred = $cred

 

# This part actually sets up to run the real script
# Format the result in XML for the payload parser - if asked for
if (!$isDiscovery) {
    write-host "<powershell>"
    write-host "<output>"
}

 

# We will attempt to capture any available HRESULT
$hresult = $null
# Run the script file passed in and attempt to catch any exception in the script content 
# so the error will be reported on stderr
try {
     $ErrorActionPreference = 'Stop'
    # Copy ALL the SNC_* environment variables to PowerShell variables, don't burden users with knowing about environment variable magic
    dir env: | ForEach-Object {
        if ($_.name.StartsWith("SNC_")) {
             # Force it so that we do not get the name clash. It won't overwrite any read-only variable (http://technet.microsoft.com/en-us/library/hh849913.aspx)
             New-Variable -name $_.name.Replace("SNC_", "") -value $_.value -Force  
        }
    }

 

    # Show all the variables available (debugging info)
    SNCLog-Variables

 

    if (!$isMid -and $executeRemote) {
        executeRemote -computer $computer -filePath $script -wmi $true -cred $cred -copyScriptToTarget:$copyScriptToTarget
    } else {
        & $script
    }
} catch [System.UnauthorizedAccessException] {
    # If the credential passed the credential check for logging into the target system, but doesn't have rights to commit
    # the changes (for example: The user can log into AD but cannot create new account), we want to try the next credential. 
    if ($useCred) { 
        exit 1;
    } else {
        exit 3; // MID Server service user
    }
} catch [System.Exception] {
    [Console]::Error.WriteLine($_.Exception.Message)
    if ($_.Exception.ErrorCode) {           # Attempt to read HRESULT provided by an ExternalException
        $hresult = $_.Exception.ErrorCode
    } elseif ($_.Exception.HResult) {      # Attempt to read HRESULT provided by an Exception
        $hresult = $_.Exception.HResult
    }
    if ($hresult) {
        [Console]::Error.WriteLine("HRESULT: [" + $hresult + "]")
    }
    if ($debug) {
        [Console]::Error.WriteLine("`r`n Stack Trace: " + $_.Exception.StackTrace)
    }
    if ($isMid) {
         if($useCred) {
         exit 1
        } else {
         exit 4
        }
    } else {
        exit 4
    }
} finally {
    if (!$isDiscovery) {
        write-host "</output>"
        if ($hresult) {
            write-host "<hresult>$hresult</hresult>"
        }
        write-host "</powershell>"
    }
}
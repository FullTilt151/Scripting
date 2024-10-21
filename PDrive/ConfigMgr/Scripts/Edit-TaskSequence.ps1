#$taskSequenceName = "# Printer install"
$taskSequenceName = "Windows 7 - Standard Build"
$SITESERVER = "LOUAPPWPS875"
$SITECODE = "CAS"

Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1" 
CD "CAS:"
$TaskSequencePackage = Get-CMTaskSequence -Name $taskSequenceName 

# Prepare parameters for "getSequence"
$MethodParams = New-Object "System.Collections.Generic.Dictionary [string, object]"
$MethodParams.Add("TaskSequencePackage", $taskSequencePackage)

# Get the sequence
$OutParams = $taskSequencePackage.ConnectionManager.ExecuteMethod("SMS_TaskSequencePackage", "getSequence", $methodParams)
$TaskSequence = $outParams.GetSingleItem("TaskSequence")

# Create a new step
$NewTsStep = ([WMICLASS]"\\$($SITESERVER)\ROOT\SMS\SITE_$($SITECODE):SMS_TaskSequence_RunCommandLineAction").CreateInstance()

$NewTsStep = $taskSequencePackage.ConnectionManager.CreateEmbeddedObjectInstance("SMS_TaskSequence_RunCommandLineAction")

$NewTsStep.CommandLine = "cmd / c echo 'hello world' >> test.txt" 
$NewTsStep.Description = "Custom Description"
$NewTsStep.Name = "My new Step"

# Get array of SMS_TaskSequence_Steps
$TaskSequenceSteps = $taskSequence.GetArrayItems("Steps")
if ($taskSequenceSteps -eq $null) {
    # New array
} else {
    $TaskSequenceSteps.Add($NewTsStep);
}

# Save array
$TaskSequence.SetArrayItems("Steps", $taskSequenceSteps);

# Prepare parameters for "SetSequence"
$MethodParams = New-Object "System.Collections.Generic.Dictionary [string, object]"
$MethodParams.Add("TaskSequence", $taskSequence)
$MethodParams.Add("TaskSequencePackage", $taskSequencePackage)

# Get the sequence 
$OutParams = $taskSequencePackage.ConnectionManager.ExecuteMethod("SMS_TaskSequencePackage", "SetSequence", $methodParams)
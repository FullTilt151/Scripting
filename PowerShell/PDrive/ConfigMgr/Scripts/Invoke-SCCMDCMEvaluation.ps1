param (
    [Parameter(Mandatory=$true, HelpMessage="Computer Name",ValueFromPipeline=$true)]
    $ComputerName,
    [Parameter(Mandatory=$true)]
    $Baseline
)

"$ComputerName - $Baseline"
$Baselines = Get-CimInstance -ComputerName $ComputerName -Namespace root\ccm\dcm -ClassName SMS_DesiredConfiguration -Filter "DisplayName = '$Baseline'"
$Baselines | ForEach-Object { 
    #([wmiclass]"\\$ComputerName\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version)
    $arguments = @{
        Name = $_.Name
        Version = $_.Version
    }
    Invoke-CimMethod -ComputerName $ComputerName -Namespace root\ccm\dcm -ClassName SMS_DesiredConfiguration -MethodName TriggerEvaluation -Arguments $arguments
}
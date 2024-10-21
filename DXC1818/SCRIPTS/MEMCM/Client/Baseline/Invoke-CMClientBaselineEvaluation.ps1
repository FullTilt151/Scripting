[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$Computer = Get-Content -Path $InputPath
ForEach ($Computer in $Computers) {
    if (Test-Connection -ComputerName $Computer -Count 2 -ErrorAction SilentlyContinue) {
        # Get a list of baseline objects assigned to the remote computer
        Write-Output "Attempting to get Configuration Baselines for $Computer"
        $Baselines = Get-CimInstance -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration

        # For each (%) baseline object, call SMS_DesiredConfiguration.TriggerEvaluation, passing in the Name and Version as params
        foreach ($Baseline in $Baselines) {
            Write-Output "Triggering configuration baseline evaluation $($Baseline.DisplayName, $Baseline.Version) on $Computer"
            ([wmiclass]"\\$Computer\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($Baseline.Name, $Baseline.Version) 
        }
    }
}
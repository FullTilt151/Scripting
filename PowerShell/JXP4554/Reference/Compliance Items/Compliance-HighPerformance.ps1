Try
{
	$Remediate=$false
	$Compliant=$false
    $HighPerf = powercfg -l | ForEach-Object{if($_.contains("High performance")) {$_.split()[3]}}
    $CurrPlan = $(powercfg -getactivescheme).split()[3]
    if ($CurrPlan -eq $HighPerf)
		{
			$Compliant = $true
		}
	else
		{
			if($Remediate){powercfg -setactive $HighPerf}
		}
	Return $Compliant
}
Catch
{
    Write-Warning -Message "Unable to set power plan to high performance"
	Return $Compliant
}
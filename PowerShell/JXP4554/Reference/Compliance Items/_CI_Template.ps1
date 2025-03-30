#Set this variable to true for the remediation script, false for the detection script
$remediate = $false

#Put code here to determine if item is compliant

#if the item is not compliant, be sure to run the lines below
Write-Output $false
if($remediate) 
{
	#if it is not, put the code here to fix it
}
else #We are compliant!!! Shout it to the world!
{
    Write-Output $true
} 

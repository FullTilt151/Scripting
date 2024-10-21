
param (
	[Parameter(Mandatory=$true,HelpMessage="Computer")] [string]$computer,
	[string]$Date
)

$computer

$i = 0
$hash = @{}
Switch -Regex (Get-Content -Path "\\$computer\c$\windows\ccm\Logs\NomadBranch.lo*")
{'^.*Nomad Branch event Evt_StartedCopy.*Feb .*' {$evalline = $switch.current
                                $evalline
                                $evalline | Out-File c:\temp\longeval.txt -Append
                                $hash.Add($i, $evalline)
                                $i += 1
                                }

}


#$hash

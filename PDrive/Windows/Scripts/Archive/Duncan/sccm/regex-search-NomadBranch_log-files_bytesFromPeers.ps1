
param (
	[Parameter(HelpMessage="Computer")] [string]$computer
)

#Nomad Branch event Evt_StartedCopy
$computer

$i = 0
$hash = @{}
Switch -Regex (Get-Content -Path "\\$computer\c$\windows\ccm\Logs\NomadBranch.lo*")
{'^.*Bytes from Peer.*Jan 31.*' {$evalline = $switch.current
                                $evalline
                                $evalline | Out-File c:\temp\longeval.txt -Append
                                $hash.Add($i, $evalline)
                                $i += 1
                                }

}


#$hash
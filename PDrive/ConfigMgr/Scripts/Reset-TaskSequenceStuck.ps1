param(
    [parameter(Mandatory=$true)]
    $ComputerName
)

if (Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction SilentlyContinue) {
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        $ccmExecutionRequestEx = Get-WmiObject -Namespace ROOT\CCM\SoftMgmtAgent –Class CCM_ExecutionRequestEx | Where-Object {$_.ProgramID -eq '*'}
        If ($ccmExecutionRequestEx -ne $null) {
            $ccmExecutionRequestEx
            $ccmExecutionRequestEx | Remove-WmiObject
            #Start-Process sc.exe -ArgumentList "config smstsmgr depend= winmgmt/ccmexec" -Wait
            Restart-Service -Name CcmExec -Force
        }
    }
} else {
    Write-Output "$ComputerName is offline"
}
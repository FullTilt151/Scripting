[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ServerURL
)

$File = 'C:\ProgramData\Verint\DPA\Data\PcMonConfig.ini'

if (Test-Path -Path $File) {
    # Stop Verint services
    'Dcuapp',
    'svstr',
    'Verint.DPA.DCUBrowserService',
    'Verint.DPA.DCUWindowsService',
    'mspvdx',
    'DPAWow64' |
    ForEach-Object {
        Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue
    }

    $ConfigContent = Get-Content $File
    $ConfigServer = $ConfigContent | Select-String 'ConfigurationServer='
    $ConfigServerURL = $ConfigServer.ToString().Split('=')[1]
    if ($ConfigServerURL -ne $ServerURL) {
        $ConfigContent -replace "$($ConfigServer.ToString())","ConfigurationServer=$ServerURL" | Set-Content $File -Force
        Write-Output "Replacing ConfigurationServer with $ServerURL"
    }
    $DataContent = Get-Content $File
    $DataServer = $DataContent | Select-String 'DataServer='
    $DataServerURL = $DataServer.ToString().Split('=')[1]
    if ($DataServerURL -ne $ServerURL) {
        $DataContent -replace "$($DataServer.ToString())","DataServer=$ServerURL" | Set-Content $File -Force
        Write-Output "Replacing DataServer with $ServerURL"
    }
    $TraceFileContent = Get-Content $File
    $TraceFileServer = $TraceFileContent | Select-String 'TraceFileServer='
    $TraceFileServerURL = $TraceFileServer.ToString().Split('=')[1]
    if ($TraceFileServerURL -ne $ServerURL) {
        $TraceFileContent -replace "$($TraceFileServer.ToString())","TraceFileServer=$ServerURL" | Set-Content $File -Force
        Write-Output "Replacing TraceFileServer with $ServerURL"
    }
    $ISContent = Get-Content $File
    $ISServer = $ISContent | Select-String 'IS_Server='
    $ISServerURL = $ISServer.ToString().Split('=')[1]
    if ($ISServerURL -ne $ServerURL) {
        $ISContent -replace "$($ISServer.ToString())","IS_Server=$ServerURL" | Set-Content $File -Force
        Write-Output "Replacing IS_Server with $ServerURL"
    }

    # Restart Verint services
    & 'C:\Program Files\Verint\DPA\Client\mspvdx.exe'
    Start-Service -DisplayName 'DPA Data Transfer Service' -ErrorAction SilentlyContinue
    Start-Service -DisplayName 'DPA Browser Service' -ErrorAction SilentlyContinue
} else {
    Write-Output 'Verint not installed, exiting.'
}
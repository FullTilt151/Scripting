param (
[Parameter(Mandatory=$true)]
[ValidateSet('DMS','SDC','MSO','GB','PR')]
[String]$Server,
[Switch]$CopyAgentFile
)

switch ($Server) {
    DMS { $ServersList = 'verint_DMS_Phone_System1:29522,verint_DMS_Phone_System2:29522' }
    SDC { $ServersList = 'verint_Simpsonville_Phone_system1:29522,verint_Simpsonville_Phone_system2:29522' }
    MSO { $ServersList = 'verint_MSO_Phone_System1:29522,verint_MSO_Phone_System2:29522' }
    PR  { $ServersList = 'verint_Puerto_Rico_Phone_System1:29522,verint_Simpsonville_Phone_system1:29522' }
    GB  { $ServersList = 'verint_Green_Bay_Phone_System1:29522,verint_Green_Bay_Phone_System2:29522' }
}

$Path = 'HKLM:\SOFTWARE\WOW6432Node\Witness Systems\eQuality Agent\Capture\CurrentVersion'

if ($null -ne $(Get-Item -Path $Path -ErrorAction SilentlyContinue)) {
    $CurrentSetting = (Get-ItemProperty -Path $Path -Name IntegrationServicesServersList -ErrorAction SilentlyContinue).IntegrationServicesServersList

    if ($CurrentSetting -ne $ServersList) {
        Set-ItemProperty -Path $Path -Name IntegrationServicesServersList -Value $ServersList -Force
    }
}

if($CopyAgentFile) {
    $AgentPath = 'C:\CaptureService\Screen Capture Module\'
    if (Test-Path $AgentPath) {
        Copy-Item -Path .\agent.wss -Destination $AgentPath -Force
    }
}
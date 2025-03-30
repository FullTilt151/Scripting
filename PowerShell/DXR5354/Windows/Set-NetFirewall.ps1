param(
[string]$WKID
)

if (Test-Connection -ComputerName $WKID -Count 1 -ErrorAction SilentlyContinue) {
    Invoke-Command -ComputerName $WKID -ScriptBlock {
        #New-NetFirewallRule -DisplayName 'zScaler zApp - ZSATray.exe' -Enabled True -Profile Any -Action Allow -Direction Outbound -Program '%ProgramFiles%\Zscaler\ZSATray\ZSATray.exe'
        #New-NetFirewallRule -DisplayName 'zScaler zApp - ZSATunnel.exe' -Enabled True -Profile Any -Action Allow -Direction Outbound -Program '%ProgramFiles%\Zscaler\ZSATunnel\ZSATunnel.exe'
        New-NetFirewallRule -DisplayName 'zScaler zApp - ZSATunnel.exe' -Enabled True -Profile Any -Action Allow -Direction Inbound -Program '%ProgramFiles%\Zscaler\ZSATunnel\ZSATunnel.exe'
        #New-NetFirewallRule -DisplayName 'zScaler zApp - ZSAUpdater.exe' -Enabled True -Profile Any -Action Allow -Direction Outbound -Program '%ProgramFiles%\Zscaler\ZSAUpdater\ZSAUpdater.exe'
        #New-NetFirewallRule -DisplayName 'zScaler zApp - ZSAService.exe' -Enabled True -Profile Any -Action Allow -Direction Outbound -Program '%ProgramFiles%\Zscaler\ZSAService\ZSAService.exe'
        #New-NetFirewallRule -DisplayName 'zScaler zApp - zscalerappupdater.exe' -Enabled True -Profile Any -Action Allow -Direction Outbound -Program '%ProgramFiles%\Zscaler\Updater\zscalerappupdater.exe'
        #New-NetFirewallRule -DisplayName 'zScaler zApp - 443' -Enabled True -Profile Any -Action Allow -Direction Outbound -LocalPort 443 -Protocol TCP


        New-NetFirewallRule -DisplayName 'Avaya One-X' -Enabled True -Profile Domain -Action Allow -Direction Inbound -Program '%ProgramFiles(x86)%\Avaya\Avaya one-X Agent\OneXAgentUI.exe' -Protocol Any
New-NetFirewallRule -DisplayName 'Avaya One-X - SparkEmulator' -Enabled True -Profile Domain -Action Allow -Direction Inbound -Program '%ProgramFiles(x86)%\Avaya\Avaya one-X Agent\SparkEmulator.exe' -Protocol Any

New-NetFirewallRule -DisplayName 'Avaya One-X' -Enabled True -Profile Domain -Action Allow -Direction Outbound -Program '%ProgramFiles(x86)%\Avaya\Avaya one-X Agent\OneXAgentUI.exe' -Protocol Any
New-NetFirewallRule -DisplayName 'Avaya One-X - SparkEmulator' -Enabled True -Profile Domain -Action Allow -Direction Outbound -Program '%ProgramFiles(x86)%\Avaya\Avaya one-X Agent\SparkEmulator.exe' -Protocol Any

New-NetFirewallRule -DisplayName 'Avaya One-X - SparkEmulator' -Enabled True -Profile Domain -Action Allow -Direction Inbound -RemoteAddress 193.111.33.200 -Protocol Any
New-NetFirewallRule -DisplayName 'Avaya One-X - SparkEmulator' -Enabled True -Profile Domain -Action Allow -Direction Outbound -RemoteAddress 193.111.33.200 -Protocol Any

<#
Protocol ruled based on port/IP
193.111.33.200

tcp-udp bi-directional eq 1719
tcp-udp bi-directional eq 1720
tcp bi-directional eq 13926
tcp bi-directional range 61440  61444
udp bi-directional range 2048  65535
tcp bi-directional eq 1024
tcp bi-directional eq www
tcp bi-directional eq http
tcp bi-directional range 49300  49309
#>
    }
}
#This will check the PSADT log for deferrals. Only problem is, you need to know which app log to look at.
$servers = Get-Content C:\temp\servers.txt
ForEach($server in $servers){
    $found = Get-Content -Path \\$server\c$\temp\Software_Install_logs\Verint_DesktopApplicationClient_15.2.5.433_EN_01_PSAppDeployToolkit_Install.log -ErrorAction SilentlyContinue | Select-String -Pattern "Installation deferred by the user." 
    if($found){
        Write-host "$server deferred."
    }else{
        If (Test-Connection $server -Quiet -Count 2){
            Write-host "$server did not defer and is online, dig a little deeper."
        } Else {
            Write-Host "$server is offline." -ForegroundColor Red
        }
        
    }
}

$servers = Get-Content C:\temp\servers.txt
ForEach($server in $servers){
    Get-ChildItem -Path \\$server\c$\temp\Software_Install_logs\ -Recurse | Select-String -Pattern "Installation deferred by the user." -List | Select Path
    #Get-Content -Path \\$server\c$\temp\Software_Install_logs\* -Filter *_EN_01_PSAppDeployToolkit_Install.log | Select-String -Pattern "Installation deferred by the user." -List
}
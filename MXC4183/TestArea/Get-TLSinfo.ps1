$key10Client = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client'
$key10Server = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server'
$key11Client = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client'
$key11Server = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server'
$key12Client = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
$key12Server = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
$keyDisabledByDefault = 'DisabledByDefault'
$keyEnabled = 'Enabled'
$SMSSitereg = 'SOFTWARE\Microsoft\SMS\Mobile Client'
$SiteCode = 'AssignedSiteCode'

$servers = Get-Content C:\Temp\tls.txt
$ErrorActionPreference = 'silentlycontinue'
foreach($server in $servers) 
{
    If (Test-Connection -ComputerName $server -count 1 -ErrorAction SilentlyContinue){

    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $server)
    Write-Host $server
    $regkey = $reg.opensubkey($SMSSitereg)
    Write-Host Site $regkey.getvalue($SiteCode)
    
    #1.0 Client
	$regkey = $reg.opensubkey($key10Client)
	Write-Host 1.0 Client DisabledByDefault $regkey.getvalue($keyDisabledByDefault)
    $regkey = $reg.opensubkey($key10Client)
	Write-Host 1.0 Client 'Enabled' $regkey.getvalue($keyEnabled)
    
    #1.0 Server
    $regkey = $reg.opensubkey($key10Server)
	Write-Host 1.0 Server DisabledByDefault $regkey.getvalue($keyDisabledByDefault)
    $regkey = $reg.opensubkey($key10Server)
	Write-Host 1.0 Server Enabled $regkey.getvalue($keyEnabled)

    #1.1 Client
	$regkey = $reg.opensubkey($key11Client)
	Write-Host 1.1 Client DisabledByDefault $regkey.getvalue($keyDisabledByDefault)
    $regkey = $reg.opensubkey($key11Client)
	Write-Host 1.1 Client 'Enabled' $regkey.getvalue($keyEnabled)
    
    #1.1 Server
    $regkey = $reg.opensubkey($key11Server)
	Write-Host 1.1 Server DisabledByDefault $regkey.getvalue($keyDisabledByDefault)
    $regkey = $reg.opensubkey($key11Server)
	Write-Host 1.1 Server Enabled $regkey.getvalue($keyEnabled)

    #1.2 Client
	$regkey = $reg.opensubkey($key12Client)
	Write-Host 1.2 Client DisabledByDefault $regkey.getvalue($keyDisabledByDefault)
    $regkey = $reg.opensubkey($key12Client)
	Write-Host 1.2 Client 'Enabled' $regkey.getvalue($keyEnabled)
    
    #1.2 Server
    $regkey = $reg.opensubkey($key12Server)
	Write-Host 1.2 Server DisabledByDefault $regkey.getvalue($keyDisabledByDefault)
    $regkey = $reg.opensubkey($key12Server)
	Write-Host 1.2 Server Enabled $regkey.getvalue($keyEnabled)
    }
}




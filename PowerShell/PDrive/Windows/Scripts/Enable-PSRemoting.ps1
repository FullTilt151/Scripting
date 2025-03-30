param(
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-connection $_})] 
    [string]$wkid
)

foreach ($comp in $wkid) {
    \\lounaswps08\pdrive\Dept907.CIT\Windows\Software\SysInternalsSuite\PsTools\psexec.exe -accepteula \\$comp -h -d powershell.exe "enable-psremoting -force"
}
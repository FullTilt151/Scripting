# minimum required SQL Native Client version to ensure TLS1.2 compatability according to Microsoft Docs (https://docs.microsoft.com/en-us/sccm/core/plan-design/security/enable-tls-1-2)
[version]$Minimum_NativeClient = '11.0.7001.0'

try {
    $NativeClient = Get-ItemProperty -Path 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Native Client 11.0\CurrentVersion'
    [version]$CurrentVersion = $NativeClient | Select-Object -ExpandProperty Version

    [bool]($CurrentVersion -ge $Minimum_NativeClient)
}
catch {
    $false
}
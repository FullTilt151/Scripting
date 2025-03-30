Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
Set-Location WP1:

Get-CMSoftwareUpdatePoint | Select-Object -ExpandProperty NetworkOSPath | 
ForEach-Object {
    Invoke-Command -ComputerName $($_).replace('\\','') -ScriptBlock {
        "$env:COMPUTERNAME // ContentDir: $($(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup' -Name ContentDir -ErrorAction SilentlyContinue).ContentDir) // DB: $($(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup' -Name SqlServerName -ErrorAction SilentlyContinue).SqlServerName)`
        SusNativeCommon.dll: $(Get-ItemProperty C:\Windows\System32\SusNativeCommon.dll | Select-Object -ExpandProperty LastWriteTime)`
        .NET $((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Version).Version)"
    }
}
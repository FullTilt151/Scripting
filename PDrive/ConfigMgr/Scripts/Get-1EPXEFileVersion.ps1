Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    if(Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        write-output "$_ $(Get-ItemProperty "\\$_\c$\Program Files (x86)\1E\PXE Lite\Server\PXELiteServer.exe" -ErrorAction SilentlyContinue | select -ExpandProperty VersionInfo | select -ExpandProperty FileVersion) //// bootmgfw.efi exists: $(test-path "\\$_\c$\ProgramData\1E\PXELite\TftpRoot\boot\x64\bootmgfw.efi")"
    } else {
        Write-Output "$_ offline"
    }
}
workflow precache-workflow {
    Clear-Variable WKIDName -ErrorAction SilentlyContinue
    $WKIDName = Get-Content "C:\Automate\NomadBranch\Precache\Computers.txt"
    foreach -parallel ($WKID in $WKIDName) {  
      
        IF (Test-Connection -ComputerName $WKID -Count 2 -Quiet ) {
            $IPAdd = Resolve-DnsName $WKID | Select-Object -ExpandProperty IPAddress
            $ActualHost = Resolve-DnsName $IPAdd | Select-Object -ExpandProperty NameHost
        }
        IF ("$WKID.humad.com" -eq $ActualHost) {
            $PKG = InlineScript { Invoke-Command -ComputerName $Using:WKID { Get-ChildItem -Path C:\ProgramData\1E\NomadBranch\WP10033F*.Lsz | Select-Object -ExpandProperty Name } }
            IF ($PKG -eq $null) {
                Write-Output "$WKID, No package"
                InlineScript { Invoke-Command -ComputerName $Using:WKID { & cmd.exe /c "C:\Program Files\1E\NomadBranch\NomadBranch.exe" '-precache' } }
            }
            Else {
                Write-Output "$WKID, $PKG"
            }
        }
        Else {
            Write-Output "$WKID, Offline"
        }
    }
}
precache-workflow 
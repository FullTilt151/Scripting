get-content C:\temp\wkids.txt | ForEach-Object {
    Invoke-Command -ComputerName $_ -ScriptBlock {
        "$($_) - SecurityLayer=$(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name SecurityLayer | Select-Object -ExpandProperty SecurityLayer)"
    }    
}
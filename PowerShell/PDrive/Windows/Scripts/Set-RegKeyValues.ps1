$key = "HKLM:\software\microsoft\sms\Mobile Client\Software Distribution"
$cache = (Get-Item $key).GetValueNames()

ForEach ($item in $cache) {
    $path = Get-ItemProperty -Path $key -Name $item | Select-Object -ExpandProperty $item
    if ($path -like 'E:\*') {
        #Set-ItemProperty -Path $key -Name $item -Value $path.Replace("E:\", "F:\")
        write-host $item" - "$path
    }
}

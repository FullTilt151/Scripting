function setSmstsLocationMps() {
    $fileLocation = "x:\smstslocationmps.txt"

    Invoke-WMIMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c x:\sms\bin\x64\tsenv2.exe get SMSTSLocationMPs > $($fileLocation)" | Out-Null
    if(Test-Path($fileLocation)){
        [string]$line = (Get-Content $fileLocation)
               
        $line = ($line.ToLower()).Replace("smstslocationmps=","")
        $mps = $line.Split("*")        
        $mpsnew = @()
        $mps | ForEach-Object {if($_ -imatch "http\:"){$mpsnew += $_} }
        $mpsnew = $mpsnew -join "*"

        Invoke-WMIMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c x:\sms\bin\x64\tsenv2.exe set SMSTSLocationMPs=$($mpsnew)" | Out-Null

        remove-item $fileLocation
    }

}
setSmstsLocationMps
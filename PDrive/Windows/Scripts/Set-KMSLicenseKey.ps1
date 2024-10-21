Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        "$_ online"
        e:\software\SysinternalsSuite\PsExec.exe -accepteula \\$_ cscript.exe c:\windows\system32\slmgr.vbs -ipk NPPR9-FWDCX-D2C8J-H872K-2YT43
        e:\software\SysinternalsSuite\PsExec.exe -accepteula \\$_ cscript.exe c:\windows\system32\slmgr.vbs -ato
    } else {
        "$_ offline"
    }
}


Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $_
        Get-WmiObject softwarelicensingproduct -ComputerName $_ -Property Description, LicenseStatus -Filter "Description = 'Windows(R) Operating System, VOLUME_KMS_W10 channel'" | ft -AutoSize Description, LicenseStatus
    } else {
        "$_ offline"
    }
}
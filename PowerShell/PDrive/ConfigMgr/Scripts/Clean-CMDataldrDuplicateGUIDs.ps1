$startTime = Get-Date
$ConfigMgrBoxPath = "d:\Program Files\Microsoft Configuration Manager\inboxes\auth\dataldr.box\process\"
Get-ChildItem -Path $ConfigMgrBoxPath -Filter *.MIF -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { 
    $MIF = Get-Content -ReadCount 1 -TotalCount 6 -Path $_.FullName -ErrorAction SilentlyContinue
    $GUID = ($MIF | Select-String "//UniqueID<" -ErrorAction SilentlyContinue).ToString().Replace('//UniqueID<','').Replace('>','')
    if ($GUID -in ('GUID:37EC6E09-F50E-4B31-9C9D-1953556A646A','GUID:4ECDD826-CA2B-4E8E-AF23-C74B779EBCD5','GUID:00F1ABDC-3A3F-46FD-9D86-B637D66DD54C')) {
        "$($_.FullName),$(($MIF | Select-String -Pattern "//KeyAttribute<NetBIOS\sName><(?<ComputerName>.*)>").Matches.Groups[1].Value),$(($MIF | Select-String "//UniqueID<" -ErrorAction Stop).ToString().Replace('//UniqueID<','').Replace('>',''))"
        Move-Item $_.FullName -Destination 'D:\Program Files\Microsoft Configuration Manager\inboxes\auth\dataldr.box\duplicateGUIDmifs' -Force -ErrorAction SilentlyContinue
    }
} #| out-file -FilePath "d:\temp\dataldr_output.txt"

do {
    $ConfigMgrBoxPath = "d:\Program Files\Microsoft Configuration Manager\inboxes\auth\dataldr.box\"
    Get-ChildItem -Path $ConfigMgrBoxPath -Filter *.MIF -Force -ErrorAction SilentlyContinue | ForEach-Object { 
        $MIF = Get-Content -ReadCount 1 -TotalCount 6 -Path $_.FullName -ErrorAction SilentlyContinue
        $GUID = ($MIF | Select-String "//UniqueID<" -ErrorAction SilentlyContinue).ToString().Replace('//UniqueID<','').Replace('>','')
        if ($GUID -in ('GUID:37EC6E09-F50E-4B31-9C9D-1953556A646A','GUID:4ECDD826-CA2B-4E8E-AF23-C74B779EBCD5','GUID:00F1ABDC-3A3F-46FD-9D86-B637D66DD54C')) {
            "$($_.FullName),$(($MIF | Select-String -Pattern "//KeyAttribute<NetBIOS\sName><(?<ComputerName>.*)>" -ErrorAction Stop).Matches.Groups[1].Value),$(($MIF | Select-String "//UniqueID<").ToString().Replace('//UniqueID<','').Replace('>',''))"
            Move-Item $_.FullName -Destination 'D:\Program Files\Microsoft Configuration Manager\inboxes\auth\dataldr.box\duplicateGUIDmifs' -Force -ErrorAction SilentlyContinue
        }
    } #| out-file -FilePath "d:\temp\dataldr_output.txt"
} while ((New-TimeSpan -Start $startTime -End $(Get-Date)).Minutes -lt 10)
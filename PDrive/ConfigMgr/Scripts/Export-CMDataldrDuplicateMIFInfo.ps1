$startTime = Get-Date
$ConfigMgrBoxPath = "D:\Program Files\Microsoft Configuration Manager\inboxes\auth\dataldr.box"
Get-ChildItem -Path $ConfigMgrBoxPath -Filter *.MIF -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { 
    $MIF = Get-Content -ReadCount 1 -TotalCount 6 -Path $_.FullName -ErrorAction SilentlyContinue
    $GUID = ($MIF | Select-String "//UniqueID<" -ErrorAction SilentlyContinue).ToString().Replace('//UniqueID<','').Replace('>','')
    if ($GUID -in ('GUID:D0B6A372-80C0-491B-9AF2-0465E853C284','GUID:DA1C41D3-5652-466E-ACC3-2F2277CA602E','GUID:82E11D11-9667-421C-88CB-807729CEE3AF')) {
        "$($_.FullName),$(($MIF | Select-String -Pattern "//KeyAttribute<NetBIOS\sName><(?<ComputerName>.*)>").Matches.Groups[1].Value),$(($MIF | Select-String "//UniqueID<" -ErrorAction Stop).ToString().Replace('//UniqueID<','').Replace('>','')),$($_.LastWriteTime)"
        #Move-Item $_.FullName -Destination 'D:\Program Files\Microsoft Configuration Manager\inboxes\auth\dataldr.box\duplicateGUIDmifs' -Force -ErrorAction SilentlyContinue
    }
} #| out-file -FilePath "d:\temp\dataldr_output.txt"
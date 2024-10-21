$wkids = "WKMJ01KSUB","WKMJ01KU7R","WKMJ01KSVA","WKMJ01KSVB","WKMJ01KU8F","WKMJ01KU8R","WKMJ01KSUD","WKMJ01KU7W","WKMJ01KSVN","WKMJ01KSVG","WKMJ01KSV8","WKMJ01KSU8"

$wkids | % {
    $_; 
    if (Test-Connection -ComputerName $_ -Count 1) {
        #Get-ChildItem "\\$_\c$\ProgramData\Intelligent Response Agent" -Filter *.log -Force | Copy-Item -Destination "C:\temp\Mandiant\$_" -Force
    }
}
#Read CRs
$CRs = Get-Content -Path 'C:\temp\crs.txt'
$string = "http://k2workspace.humana.com/Runtime/Runtime/Form/SCDD.RequestEditForm/?pRequestId="

foreach ($CR in $CRs){
    start msedge $string$CR
}

$string = "yahoo.com"

start msedge $string


    start msedge /new-tab yahoo.com

start msedge:$string$CR
start msedge --new-tab:$string$CR
start msedge --new-tab:$string$CR
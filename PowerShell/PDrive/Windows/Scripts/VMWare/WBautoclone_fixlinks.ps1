function fix-qe2 {

import-csv $VMList_File | ForEach-Object {

    $CloneName = $_.CloneName

    copy-item -path "\\$cloneName\c$\users\axr8678\desktop\QE2*" -Destination "\\$cloneName\c$\users\public\desktop"
       Write-Host "Fixing shortcuts on $cloneName"
  }
  }
$VMList_File = "C:\temp\winbatch_fix.csv"

fix-qe2
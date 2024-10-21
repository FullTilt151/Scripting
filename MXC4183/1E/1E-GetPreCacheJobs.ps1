#Get all pre-cached jobs from AE
Get-PreCachingJobs -ActiveEfficiencyUrl http://ActiveEfficiency.humana.com/ActiveEfficiency

#Get pre-cache job by packageID
Get-PreCachingJobs -ActiveEfficiencyUrl http://ActiveEfficiency.humana.com/ActiveEfficiency | Where-Object {$_.ContentID -eq "WP100337"}
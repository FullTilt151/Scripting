$remedy = $true
#Connect to Resource Manager COM Object
$resman = new-object -ComObject "UIResource.UIResourceMgr"
$cacheInfo=$resman.GetCacheInfo()

#Enum Cache elements and remove CAS00118 if there.
$element = $cacheinfo.GetCacheElements()  | Where-Object {$_.ContentID -eq 'CAS00118'}
$nomadCache = (Get-ItemProperty -Path HKLM:\SOFTWARE\1E\NomadBranch -Name LocalCachePath -ErrorAction SilentlyContinue).LocalCachePath
if($nomadCache)
{
    $nomadResults = Get-ChildItem -Path $nomadCache | Where-Object {$_.Name -match 'CAS00118'}
    if($nomadResults.Count -gt 0){$existsInNomad = $true}
    else{$existsInNomad = $false}
}
else
{
    $existsInNomad = $false
}
if($element -or $existsInNomad)
{
    Write-Output $false
    if($remedy)
    {
		$count = 0
		do
		{
			if($element)
            {
			    $cacheInfo.DeleteCacheElement($element.CacheElementID)
			    $element = $cacheinfo.GetCacheElements()  | Where-Object {$_.ContentID -eq 'CAS00118'}
            }
			$count++
		} while($count -lt 5 -and $element.ContentID -ne 'CAS00118')
		#clear nomad cache if exists
		$cacheCleaner = 'C:\Program Files\1E\NomadBranch\CacheCleaner.exe'
		$cleanerParameters = '-DeleteAll -Force=9'
		if(Test-path -Path $cacheCleaner)
		{
			$results = Start-Process -FilePath $cacheCleaner -ArgumentList $cleanerParameters -Wait -PassThru -WindowStyle Hidden
		}
        #Verify it is gone
        if($existsInNomad)
        {
            foreach($nomadResult in $nomadResults)
            {
                if($nomadResult.PSIsContainer) # It's a directory, delete!
                {
                    Remove-Item -Path $nomadResult.FullName -Recurse -Force
                }
                else # It's a file, delete
                {
                    Remove-Item -Path $nomadResult.FullName -Force
                } 
            }
        }
	}
}
else
{
    Write-Output $true
}
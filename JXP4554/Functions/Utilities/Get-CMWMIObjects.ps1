<#
From Greg Hindman gahind@microsoft.com
#>
function CountWMIObjects
{
    param ([string]$nameSpace)
    Write-Host "." -NoNewline
    if ($nameSpace -like "root\ccm*")
    {
        $objects = Get-WmiObject -Namespace $nameSpace -List
        foreach ($object in $objects)
        {
            $instances = Get-WmiObject -Namespace $nameSpace -Class $object.Name -ErrorAction SilentlyContinue
            $instanceLine = "{0}({1})" -f $object.Name, $instances.count
            $entryName = "{0}:{1}" -f $nameSpace, $object.Name
            $global:AllInstances.Add($entryName, $instances.Count)
            $count += $instances.Count
        }
        $namespaceLine = "{0} ({1} classes, {2} instances)" -f $nameSpace, $objects.count, $count
    }
    else
    {
        $objects = @(0)
    }

    $global:TotalObjects += $objects.Count
    $subs = Get-WmiObject -Namespace $nameSpace __NAMESPACE | Sort-Object

    if($subs -ne $null)
    {
        $subs | ForEach-Object { CountWMIObjects "$nameSpace\$($_.Name)"}
    }
}

#Main script
[int]$global:TotalObjects = 0
[hashtable]$global:AllInstances = @{}
$OutputFile = "c:\Temp\SCCMClasses.csv"

#Run test
CountWMIObjects "root"

#export to csv
$path = $OutputFile
$global:AllInstances.GetEnumerator() | sort value -Descending | Export-Csv $path -NoTypeInformation
Write-Host ""
Write-Host "SCCM Instances Found: "$global:TotalObjects
Write-Host "Output File: $path"
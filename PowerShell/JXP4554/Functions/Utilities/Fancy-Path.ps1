<#
.SYNOPSIS
	This script fixes path issues

.DESCRIPTION
	This script contacts the SCCM database, errors if it's not able to. If it does, it will
    then check if any of the inventoried paths exist, and if they do, it will add it to the path statement.

.LINK
	http://configman-notes.com

.NOTES
	Author:	Jim Parris
	Email:	Jim@ConfigMan-Notes
	Date:	1/11/2017
	PSVer:	2.0/3.0
#>

Function Get-DatabaseData {
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$query   
    )

    $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = 'Data Source=LOUSQLWPS606;Initial Catalog=CM_WP1; User Id=FancyPath;Password=fancypath'
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    $dataset = New-Object -TypeName System.Data.DataSet
    try {
        $adapter.Fill($dataset)  | Out-Null
    }

    catch {
        exit 10000
    }
    $connection.close()
    return $dataset.Tables[0]
}

$query = "SELECT DISTINCT entry0 [Path]
FROM   v_gs_path_custom
ORDER  BY path"
$Paths = Get-DatabaseData $query
$newPath = New-Object System.Collections.ArrayList
foreach ($Path in $Paths.Path) {
    #Remove any leading spaces
    if ($Path -match '^\s') {
        $Path = $Path -replace '^\s', ''
    }
    #Make sure it's valid
    if ($Path -match '^%') {
        #Check if environment variable
        if ($Path -match '^%\w*%[:\\]' -and $Path -notmatch 'java') {
            #### Add logic to validate environment variable
            #Find out what/if the variable exists
            $envvar = $path -replace '^%(\w*)%.*', '$1'
            $envvarOnSys = Get-ChildItem env: | Where-Object {$_.Name -eq $envvar}
            if ($envvarOnSys) {
                #Get actual path
                $actualPath = $envvarOnSys.Value + $Path -replace '%\w*%(.*)', '$1'
                #Check if path exists
                if (Test-Path -Path $actualPath) {
                    #add path
                    $newPath.Add($Path.ToLower()) | Out-Null
                }
            }
        }
    }
    elseif ($Path -match '^[c-fC-F]:\\' -and $Path -notmatch '\|' -and $Path.Length -gt 3 -and $Path -notmatch 'java') {
        #Write-Output "Checking $Path"
        if (Test-Path $Path) {
            if ((Get-ChildItem $Path -File | Measure-Object).count -gt 0) {
                $newPath.Add($Path.ToLower()) | Out-Null
            }
        }
    }
}

#Cleanup
#Remove trailing \
for ($x = 0; $x -lt $newPath.Count; $X++) {
    if ($newPath[$x] -match '\\$') {$newPath[$x] = $newPath[$x] -replace '\\$', ''}
}

#Remove file paths
$x = 0
Do {
    if ($newPath[$x] -match '\.exe$') {$newPath.RemoveAt($x)}
    else {$x++}
}
While ($x -lt $newPath.Count)

#Remove 8.3 name when full name exists
$x = 0
Do {
    $isChanged = $false
    if ($newPath[$x] -match '~') {
        $fullPath = (Get-Item -LiteralPath $newPath[$x]).FullName
        for ($y = $x + 1; $y -lt $newPath.Count; $y++) {
            if ($newPath[$y] -eq $fullPath) {
                $newPath.Remove($newPath[$x])
                $x--
                break
            }
        }
    }
    $x++
}
while ($x -lt $newPath.Count)

#remove unnecessary paths
$x = 0
Do {
    if ($newPath[$x] -eq 'c:\temp' -or $newPath[$x] -eq 'c:\program files(x86)' -or $newPath[$x] -eq 'c:\program files' -or $newPath[$x] -eq 'c:\programdata\chocolatey\bin') {
        $newPath.RemoveAt($x)
    }
    else {
        $x++
    }
}
While ($x -lt $newPath.Count)

#Remove Duplicates
$x = 0
do {
    $isChanged = $false
    for ($y = $x + 1; $y -lt $newPath.Count; $y++) {
        if ($newPath[$x] -eq $newPath[$y]) {
            $newPath.Removeat($x)
            $isChanged = $true
        }
    }
    if ($isChanged -eq $false) {$x++}
}
While ($x -lt $newPath.Count - 1)

#Remove explicit path when Environment variable works
$x = 0
do {
    if ($newPath[$x] -match '^%\w*%[:\\]') {
        #determine the actual path
        $envvar = $newPath[$x] -replace '^%(\w*)%.*', '$1'
        $envvarOnSys = Get-ChildItem env: | Where-Object {$_.Name -eq $envvar}
        $actualPath = $envvarOnSys.Value + $newPath[$x] -replace '%\w*%(.*)', '$1'
        #Look for any other entries
        for ($y = 0; $y -lt $newPath.Count; $y++) {
            if ($y -ne $x -and $actualPath -eq $newPath[$y]) {
                $newPath.RemoveAt($y)
            }
        }
    }
    $x++
}
while ($x -lt $newPath.Count)

#Now we break of important paths to make sure they are at the begining of the list
#Make sure SQL Paths are ordered by newest version before oldest
$sqlPath = New-Object System.Collections.ArrayList
$sqlHash = @{}
$x = $newPath.Count
do {
    if ($newPath[$x] -match 'microsoft sql server') {
        $newPath[$x] -match '(microsoft sql server\\)(\d+)' | Out-Null
        $num = $Matches[2]
        if ($num -eq $null) {$num = 1}
        $sqlHash[[Int32]$num] += [Array]$newPath[$x]
        $newPath.RemoveAt($x) | Out-Null
        $x++
    }
    $x--
}
While ($x -gt 0)

foreach ($key in $sqlHash.GetEnumerator() | Sort-Object -Descending -Property Name) {
    $sqlPath += [Array]$key.Value
}

#Get C:\Windows paths
$winPath = New-Object System.Collections.ArrayList
$x = 0
Do {
    if ($newPath[$x] -match 'c:\\windows') {
        $winPath.add($newPath[$x]) | Out-Null
        $newPath.RemoveAt($x) | Out-Null
    }
    else {
        $x++
    }
}
While ($x -lt $newPath.Count)

#Finally, put it together
$newPath = $winPath + $sqlPath + $newPath
$finalPath = ''
foreach ($Path in $newPath) {
    if ($finalPath.Length -eq 0) {$finalPath = $Path}
    elseif ($finalPath.Length + $Path.Length -lt 4096) {$finalPath = "$finalPath;$Path"}
}

$oldPath = (Get-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH).Path
$fileName = "C:\Temp\OldPath$(Get-Date -Format yyyyMMdHHmmss).log"
$oldPath | Out-File -FilePath $fileName -Encoding ascii
Set-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH –Value $finalPath
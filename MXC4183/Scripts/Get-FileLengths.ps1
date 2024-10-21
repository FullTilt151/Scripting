<#
.SYNOPSIS
	This script will check file lenths for packages. 
.DESCRIPTION
	This script will check file lenths for packages. 
.PARAMETER PkgID
	This is the package ID you want to check.
.PARAMETER Drive
	This is the UNC path to where the folder exists.
.EXAMPLE
    Get-FileLength -Site WP1 -PkgID 69869
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('I','P')]
    [string]$Drive = $Drive,
    [Parameter(Mandatory=$true)]
    [string]$CR = $CR
)
$DriveLetter = switch ($Drive) {
    I { '\\lounaswps08\idrive\d907ats' }
    P { '\\lounaswps08\pdrive\d907ats' }
}

if(Test-Path -Path "$DriveLetter\$CR"){
    $pathToScan = "$DriveLetter\$CR\install\Files"  # The path to scan and the the lengths for (sub-directories will be scanned as well).
    $outputFilePath = "C:\temp\PathLengths.txt" # This must be a file in a directory that exists and does not require admin rights to write to.
    $writeToConsoleAsWell = $true   # Writing to the console will be much slower.

    # Open a new file stream (nice and fast) and write all the paths and their lengths to it.
    $outputFileDirectory = Split-Path $outputFilePath -Parent
    if (!(Test-Path $outputFileDirectory)) { New-Item $outputFileDirectory -ItemType Directory }
    $stream = New-Object System.IO.StreamWriter($outputFilePath, $false)
    Get-ChildItem -Path $pathToScan -Recurse -Force | Select-Object -Property FullName, @{Name="FullNameLength";Expression={($_.FullName.Length)}} | Sort-Object -Property FullNameLength -Descending | ForEach-Object {
        $filePath = $_.FullName
        $length = $_.FullNameLength
        $string = "$length : $filePath"

        # Write to the Console.
        if ($writeToConsoleAsWell) { Write-Host $string }

        #Write to the file.
        $stream.WriteLine($string)
    }
    $stream.Close()
}
else {
    Write-Host "$DriveLetter\$CR does not exist."
}
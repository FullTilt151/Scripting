function Delete-OldVersions
{
    Param
    (
    [Parameter (Mandatory = $true)]
    $FilePath
    )
    $Files = Get-ChildItem -Path $FilePath -File
    for($x = 0;$x -lt $Files.count;$x++)
    {
        for($y = 0;$y -lt $Files.count - 1;$y++)
        {
            if ($y -ne $x)
            {
                #if ($Files[$x].ToString().substring(0,8) -eq $Files[$y].ToString().substring(0,8))
                $i = $Files[$x].Name -replace '(.*)\..*.tar', '$1'
                $j = $Files[$y].Name -replace '(.*)\..*.tar', '$1'
                if ($i -eq $j)
                {
                    [int]$a = $Files[$x] -replace '.*\.(.*).tar', '$1'
                    [int]$b = $Files[$y] -replace '.*\.(.*).tar', '$1'
                    if ($a -gt $b)
                    {
                        if (Test-Path $Files[$y].FullName)
                        {
                            New-LogEntry "Deleting $($Files[$y].FullName)" 1 $ScriptName
                            Remove-Item -Path $Files[$y].FullName
                        }
                    }
                    else
                    {
                        if (Test-Path $Files[$x].FullName)
                        {
                            New-LogEntry "Deleting $($Files[$x].FullName)" 1 $ScriptName
                            Remove-Item -Path $Files[$x].FullName
                        }
                    }
                }
            }
        }
    }
}

Function New-LogEntry {
    # Writes to the log file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,

        [Parameter(Position=1,Mandatory=$true)]
        [INT32] $type,

        [Parameter(Position=2,Mandatory=$true)]
        [STRING] $component
        )

        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Global:LogFile -Append -Encoding ascii
}

$ScriptName = $MyInvocation.MyCommand.Name
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = 'C:\Temp\' + $LogFile + '.log'

New-LogEntry "Starting - $ScriptName" 1 $ScriptName

if (Test-Path HKLM:\SOFTWARE\1E\NomadBranch)
{
    $LocalCachePath = Get-ItemProperty HKLM:\Software\1E\NomadBranch -Name LocalCachePath
    $TarPath = $LocalCachePath.LocalCachePath + 'LSZFILES\TarFiles'
    if (Test-Path $TarPath)
    {
        Delete-OldVersions $TarPath
    }
}

New-LogEntry "Finished" 1 $ScriptName
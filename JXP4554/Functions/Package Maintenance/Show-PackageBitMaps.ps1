import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

Function New-LogEntry {
    # Writes to the log file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,
        
        [Parameter(Position=1,Mandatory=$false)]
        [INT32] $type = 1,

        [Parameter(Position=2,Mandatory=$false)]
        [STRING] $component = $ScriptName
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
$Server = 'LOUAPPWTS872'
$Site = $(Get-WmiObject -ComputerName $Server -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode
$hash = @{
    cimsession = New-CimSession -ComputerName $Server
    NameSpace = "Root\SMS\Site_$($Site)" 
    ErrorAction = 'Stop'
} 

Set-Location "$($site):"

New-LogEntry "Starting $(Get-Date) | Site - $Site | Server - $Server"

#Get list of packages
New-LogEntry 'Getting Packages'
$Packages = Get-CMPackage 

New-LogEntry 'Starting processing of packages'

foreach ($Package in $Packages)
{
    $BitMap = ''
    for ($i=31;$i -ge 0;$i--)
    {
        if($Package.PkgFlags -band ([math]::pow(2,$i)))
        {$BitMap = $BitMap +'1'}
        else
        {$BitMap =$BitMap +'0'}

    }
    $Entry = "$($Package.PackageID)  - $BitMap"
    New-LogEntry $Entry
}
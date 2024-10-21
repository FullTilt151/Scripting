[CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$False,ValueFromPipeline=$true,HelpMessage="The target computer name")]
            [ValidateScript({Test-Connection -ComputerName $_ -Count 2})]
            $ComputerName = $env:COMPUTERNAME,
        [Parameter(ParameterSetName='Default',Mandatory=$True)]
            [int]$Days = 90,
        [Parameter(ParameterSetName='Default',Mandatory=$False)]
            [ValidateSet("*","Agent","AU","AUCLNT","CDM","Content Download","Content Install","CMPRESS","COMAPI","DRIVER","DTASTOR","DWNLDMGR","DnldMgr","EEHNDLER","EP","HANDLER","IdleTmr","MISC","OFFLSNC","PASRER","Pre-Deployment Check","PT","RebootNotify","REPORT","SERVICE","SETUP","SHUTDWN","SLS","Software Synchronization","WS","WUREDIR","WUWEB","WuTask")]
            [string]$Component,
        [Parameter(ParameterSetName='Default',Mandatory=$False)]
            [string]$Text = "",
        [Parameter(ParameterSetName='byGroup',Mandatory=$False)]
            [ValidateSet("Component","Date")]
            $GroupBy
        )

if (!$Component)
    {$Component = "*"}
if (!$Days)
    {$Days = 90}

$Days --
$DateF = (Get-date).AddDays(-$Days) | get-date -Format yyyy-MM-dd

$Command = {
param($DateF,$Component,$Text,$GroupBy)
$log = Get-Content $env:windir\windowsupdate.log | ConvertTo-Xml -NoTypeInformation 
$result = $log.Objects.Object | where {$_ -match "`t$Component`t" -and $_ -gt $DateF -and $_ -match "$text"} | ForEach {
    $Count = $_.Split("`t").Count
    New-Object -TypeName PSObject -Property @{
        Date = $_.Split("`t") | Select -Index 0
        Time = $_.Split("`t") | Select -Index 1
        Component = $_.Split("`t") | select -Index ($count -2)
        Details = $_.Split("`t") | select -Index ($count -1)
        }
    }
if ($GroupBy -eq "Component")
    {$Result.Component | Group-Object -NoElement}
if ($GroupBy -eq "Date")
    {$Result.Date | Group-Object -NoElement}
if (!$GroupBy)
    {$Result}
}

if ($ComputerName -eq $env:COMPUTERNAME)
    {Invoke-Command -ArgumentList $DateF,$Component,$Text,$GroupBy -ScriptBlock $Command}
Else {
    If ($GroupBy)
        {Invoke-Command -ComputerName $ComputerName -ArgumentList $DateF,$Component,$Text,$GroupBy -ScriptBlock $Command | Select Count,Name}
    If (!$GroupBy)
        {Invoke-Command -ComputerName $ComputerName -ArgumentList $DateF,$Component,$Text,$GroupBy -ScriptBlock $Command | Select Date,Time,Component,Details}
    }
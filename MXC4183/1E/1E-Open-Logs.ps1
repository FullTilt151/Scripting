<#
.SYNOPSIS
    This is a 'One-Click' script to open 1E logs.
.DESCRIPTION
    This script opens the important logs for the 1E product you choose.
.PARAMETER 1Eenvironment.
    This is the 1E environment you specify to read the appropriate log
.PARAMETER 1EProduct
    This is the 1E product you specify to read the appropriate logs.
.EXAMPLE
     
.LINK
	https://mike-cook.com/
.NOTES
	FileName:    Open1ELogs
	Author:      Mike Cook
	Contact:     Mike@mike-cook.com
	Created:     11/16/18
	Updated:     11/16/18
	Version:     1.0.0
#>

[CmdletBinding()]

PARAM (
    [Parameter(Mandatory=$true, HelpMessage = "Which environment are we running this on?")]
    [ValidateSet('MT1','WQ1','WP1')]
    [string]$Env,
    [Parameter(Mandatory=$true, HelpMessage = "Which 1E Product?")]
    [ValidateSet('Shopping','AC','AE')]
    [string]$Product
)

switch($Env)
{
    'MT1' {$server = 'LOUAPPWTS1047'}
    'WQ1' {$server = 'LOUAPPWQS1043'}
    'WP1' {$server = 'LOUAPPWPS1662'}
}

$1eLogPath = "C$\Programdata\1E"
#Open appropriate logs.
#MT1.
If ($Env -eq "MT1"){
    If($Product -eq "Shopping"){cmtrace "\\$server\$1eLogPath\Shopping\shopping.log" , "\\LOUAPPWTS1140\$1eLogPath\Shopping.Receiver\v5.3.100\Shopping.Receiver.log" , "\\$server\$1eLogPath\ShoppingCentral\ShoppingCentral.log", "\\$server\$1eLogPath\ShoppingAPI\ShoppingAPI.log"}
    Elseif($Product -eq "AC"){cmtrace "\\$server\$1eLogPath\AppClarity\AppClarity.Servicehost.log" , "\\$server\$1eLogPath\AppClarity\AppClarity.Catalog.UpdateService.log" , "\\$server\$1eLogPath\AppClarity\AppClarity.Servicehost.ConsoleService.log"}
    elseif($Product -eq "AE"){cmtrace "\\$server\$1eLogPath\ActiveEfficiency\Scout.log" , "\\$server\$1eLogPath\ActiveEfficiency\Service.log" , "\\$server\$1eLogPath\ActiveEfficiency\DailyScheduledTask.log" , "\\$server\$1eLogPath\ActiveEfficiency\webservice.log"}
}
#WQ1.
If ($Env -eq "WQ1"){
    If($Product -eq "Shopping"){cmtrace "\\$server\$1eLogPath\Shopping\shopping.log" , "\\LOUAPPWTS1140\$1eLogPath\Shopping.Receiver\v5.3.100\Shopping.Receiver.log" , "\\$server\$1eLogPath\ShoppingCentral\ShoppingCentral.log", "\\$server\$1eLogPath\ShoppingAPI\ShoppingAPI.log"}
    Elseif($Product -eq "AC"){cmtrace "\\$server\$1eLogPath\AppClarity\AppClarity.Servicehost.log" , "\\$server\$1eLogPath\AppClarity\AppClarity.Catalog.UpdateService.log" , "\\$server\$1eLogPath\AppClarity\AppClarity.Servicehost.ConsoleService.log"}
    elseif($Product -eq "AE"){cmtrace "\\$server\$1eLogPath\ActiveEfficiency\Scout.log" , "\\$server\$1eLogPath\ActiveEfficiency\Service.log" , "\\$server\$1eLogPath\ActiveEfficiency\DailyScheduledTask.log" , "\\$server\$1eLogPath\ActiveEfficiency\webservice.log"}
}
#WP1.
If ($Env -eq "WP1"){
    If($Product -eq "Shopping"){cmtrace "\\$server\$1eLogPath\Shopping\shopping.log" , "\\LOUAPPWTS1140\$1eLogPath\Shopping.Receiver\v5.3.100\Shopping.Receiver.log" , "\\$server\$1eLogPath\ShoppingCentral\ShoppingCentral.log", "\\$server\$1eLogPath\ShoppingAPI\ShoppingAPI.log"}
    Elseif($Product -eq "AC"){cmtrace "\\$server\$1eLogPath\AppClarity\AppClarity.Servicehost.log" , "\\$server\$1eLogPath\AppClarity\AppClarity.Catalog.UpdateService.log" , "\\$server\$1eLogPath\AppClarity\AppClarity.Servicehost.ConsoleService.log"}
    elseif($Product -eq "AE"){cmtrace "\\$server\$1eLogPath\ActiveEfficiency\Scout.log" , "\\$server\$1eLogPath\ActiveEfficiency\Service.log" , "\\$server\$1eLogPath\ActiveEfficiency\DailyScheduledTask.log" , "\\$server\$1eLogPath\ActiveEfficiency\webservice.log"}
}
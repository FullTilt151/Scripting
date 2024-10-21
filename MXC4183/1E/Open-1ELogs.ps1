<#
.SYNOPSIS
 
.DESCRIPTION
    This script opens the important logs for the 1E product you choose.

.PARAMETER 1Eenvironment.
    This is the 1E environment you specify to read the appropriate logs.

.PARAMETER 1EProduct
    This is the 1E product you specify to read the appropriate logs.
 
.EXAMPLE
     
.LINK
	

.NOTES
	FileName:    Open1ELogs
	Author:      Mike Cook
	Contact:     mcook9@humana.com
	Created:     2016-03-22
	Updated:     2016-03-22
	Version:     1.0.0
#>

	[CmdletBinding()]
	
PARAM
(
    [Parameter(Mandatory=$true)]
    #[ValidateSet('MT1', 'WQ1', 'WP1')]
    [String]$1Eenvironment,
    
	[Parameter(Mandatory=$true)]
    #[ValidateSet('Shopping', 'AppClarity', 'ActiveEfficiency')]
    [String]$1EProduct
)

switch ($1Eenvironment){
    'MT1' {$1Eserver = 'LOUAPPWTS1047'} 
    'WQ1' {$1Eserver = 'LOUAPPWQS1043'}
    'WP1' {$1Eserver = 'LOUAPPWPS1662'}
}

# Open appropriate logs.

    #MT1 env.
    If (($1Eenvironment = 'MT1') -and ($1EProduct = 'Shopping'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\Shopping\shopping.log" , '\\LOUAPPWTS1140\C$\ProgramData\1E\Shopping.Receiver\v5.3.100\Shopping.Receiver.log' , "\\$1Eserver\C$\ProgramData\1E\Shopping\ShoppingCentral.log"}

    If (($1Eenvironment = 'MT1') -and ($1EProduct = 'AppClarity'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Servicehost.log" , "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Catalog.UpdateService.log" , "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Servicehost.log"}

    If (($1Eenvironment = 'MT1') -and ($1EProduct = 'ActiveEfficiency'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\Scout.log" , "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\Service.log" , "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\DailyScheduledTask.log"}

    #WQ1 env.
    If (($1Eenvironment = 'WQ1') -and ($1EProduct = 'Shopping'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\Shopping\shopping.log" , '\\LOUAPPWQS1151\C$\ProgramData\1E\Shopping.Receiver\v5.3.100\Shopping.Receiver.log' , "\\$1Eserver\C$\ProgramData\1E\Shopping\ShoppingCentral.log"}

    If (($1Eenvironment = 'WQ1') -and ($1EProduct = 'AppClarity'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Servicehost.log" , "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Catalog.UpdateService.log" , "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Servicehost.log"}

    If (($1Eenvironment = 'WQ1') -and ($1EProduct = 'ActiveEfficiency'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\Scout.log" , "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\Service.log" , "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\DailyScheduledTask.log"}

    #WP1 env.
    If (($1Eenvironment = 'WP1') -and ($1EProduct = 'Shopping'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\Shopping\shopping.log" , '\\LOUAPPWPS1662\C$\ProgramData\1E\Shopping.Receiver\v5.3.100\Shopping.Receiver.log' , "\\$1Eserver\C$\ProgramData\1E\Shopping\ShoppingCentral.log"}

    If (($1Eenvironment = 'WP1') -and ($1EProduct = 'AppClarity'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Servicehost.log" , "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Catalog.UpdateService.log" , "\\$1Eserver\C$\ProgramData\1E\AppClarity\AppClarity.Servicehost.log"}

    If (($1Eenvironment = 'WP1') -and ($1EProduct = 'ActiveEfficiency'))
        {cmtrace "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\Scout.log" , "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\Service.log" , "\\$1Eserver\C$\ProgramData\1E\ActiveEfficiency\DailyScheduledTask.log"}
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('Nomad','Shopping')]
	[string]$Module
)

$Module = switch ($Module){
    Shopping { -reconfigure Module.Shopping.Enabled=true Module.Shopping.ShoppingCentralUrl=http://appshop.humana.com/Shopping/ -restart }
    Nomad { -reconfigure Module.Nomad.Enabled=true -restart}
}

#& "C:\Program Files\1E\Client\1E.Client.exe" $module

write-host $Module


Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%Visual C++ 2010%'"
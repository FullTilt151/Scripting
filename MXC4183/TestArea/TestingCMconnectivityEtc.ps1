Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')


$test = ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')

$test1 = ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5))

Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,38) + '\ConfigurationManager.psd1')

$test3 = $env:SMS_ADMIN_UI_PATH

$product_code = 'ABCD1234-11-12-2013'
$date_created = $product_code.SubString($product_code.Length-10)

$site = 'WQ1'
$Server = 'LOUAPPWTS1140'
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Set-Location $Site":"
#
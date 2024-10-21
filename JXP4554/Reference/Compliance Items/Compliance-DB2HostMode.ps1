#Scan C:\ProgramData\IBM\DB2\???\cfg\db2dsdriver.cfg file for port="446"
$Remediate = $false
$Compliant = $false

#Path for the config file
$strFolderPath = "$($env:ProgramData)\IBM\DB2\"

$objSubFolders = Get-ChildItem -Path $strFolderPath | Where-Object {$_.PSiSContainer}
foreach($objSubFolder in $objSubFolders)
{
    $strFilePath = $strFolderPath + $objSubFolder + '\cfg\db2dsdriver.cfg'
    if(Test-Path $strFilePath)
    {
        $strContent = Get-Content $strFilePath
        foreach($strLine in $strContent)
        {
            if($strLine -match 'port.*=.*"446"' ) {$Compliant = $true}
        }
    }
}

Write-Host $Compliant
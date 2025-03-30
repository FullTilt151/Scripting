$OSVersion = '19042'

#Remove 20H2 resources from T_Windows10IPU
$GRP = Get-ADGroup T_Windows10IPU -Properties Members
$Computer = $GRP.Members | Get-ADComputer | Sort-Object Name | Select-Object -ExpandProperty Name
$Computer.count
$Computer |
ForEach-Object {
    $Build = Get-ADComputer -Identity $_ -Properties * | Select-Object -ExpandProperty OperatingSystemVersion -ErrorAction SilentlyContinue
    $split = $Build -split ' '
    $var1 = $split[0]
    $var2 = $split[1]
    $string =  $var2 -replace '[()]',''
    #Write-Host "$_ $string" -ForegroundColor Magenta
    IF ($OSVersion -eq "$string") {
        #Write-Host "$_ $string" -ForegroundColor Yellow
        Remove-ADGroupMember -Identity T_Windows10IPU -Members $_$ -Confirm:$false 
    }
}

#Get compliant resources in WP1087BB
$LOC = Get-Location
If ($LOC.Path -ne "WP1:\") {
    $Drives = Get-PSDrive
    If ($Drives.Name -ne "WP1") {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue # Import the ConfigurationManager.psd1 module 
        Set-Location "WP1:"
    }
    Set-Location "WP1:"
}
Clear-Variable -Name Computer
$WKIDs = Get-CMCollectionMember -CollectionId WP1087BB | Select-Object -ExpandProperty Name
$WKIDs.count
$GRP = Get-ADGroup T_Windows10IPU -Properties Members
$Computer = $GRP.Members | Get-ADComputer | Sort-Object Name | Select-Object -ExpandProperty Name
$Computer.count

#Get difference of members in T_Windows10IPU and WP1087BB
$Adds = Compare-Object -ReferenceObject $Computer -DifferenceObject $WKIDs -PassThru
$Adds.count

#Add compliant resources to T_Windows10IPU
$Adds | ForEach-Object {Add-ADGroupMember -Identity T_Windows10IPU -Members $_$}
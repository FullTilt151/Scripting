param (
    [Parameter(Mandatory = $true)]
    $OSVersion  
    ) 

$date = Get-Date -Format MMddyyyy
#$Computer = Get-ADGroupMember -Identity T_Windows10IPU | Sort-Object Name | Select-Object -ExpandProperty Name
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
    IF ($OSVersion -le "$string") {
        IF (!(Test-Path -Path "\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Remove-ADGroupMember\Completed")) {
            New-Item -Path "\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Remove-ADGroupMember" -Name 'Completed' -ItemType "directory"
        }
    Write-Host "$_ $string" -ForegroundColor Yellow
    Write-Output "Removing - $_ - $Build" >> "\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts\IPU\Tasks\$env:UserName\Remove-ADGroupMember\Completed\Remove_T_Windows10IPU-$date.log"
    Remove-ADGroupMember -Identity T_Windows10IPU -Members $_$ -Confirm:$false 
    }
}
Load-ComboBox $CboDistrictName (Get-ADOrganizationalUnit -Filter '(name -like "*")' -SearchScope OneLevel -SearchBase "OU=Districts,DC=WorldTrade" -ResultPageSize 1000 -properties * | Select Name, description) -DisplayMember name -ValueMember description



function Load-ComboBox 
{
<#
.SYNOPSIS
    This functions helps you load items into a ComboBox.

.DESCRIPTION
    Use this function to dynamically load items into the ComboBox control.

.PARAMETER  ComboBox
    The ComboBox control you want to add items to.

.PARAMETER  Items
    The object or objects you wish to load into the ComboBox's Items collection.

.PARAMETER  DisplayMember
    Indicates the property to display for the items in this control.
    
.PARAMETER  Append
    Adds the item(s) to the ComboBox without clearing the Items collection.
#>
    
Param 
(
    [Parameter(Mandatory=$true)]
    [System.Windows.Forms.ComboBox]$ComboBox,
    [Parameter(Mandatory=$true)]$Items,
    [Parameter(Mandatory=$false)]
    [string]$DisplayMember,
    [string]$ValueMember,
    [switch]$Append
)

if(-not $Append)
{
    $comboBox.Items.Clear()    
}
    
if($Items -is [Array])
{
    $comboBox.Items.AddRange($Items)
}
else
{
    $comboBox.Items.Add($Items)  
}


$comboBox.ValueMember = "description"
$comboBox.DisplayMember = "name"
}

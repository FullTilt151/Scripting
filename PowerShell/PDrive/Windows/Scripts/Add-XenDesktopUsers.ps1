param(
[Parameter(Mandatory=$true)]
[ValidateScript({Test-Path $_ -ErrorAction silentlycontinue})]
$Userlist,
[Parameter(Mandatory=$true)]
[ValidateSet(“DotNet”,”Java”,”ITI”,"ITSE")]
$Environment
)

# Copy the userlist to the XDD server for local access
Copy-Item -Path $Userlist -Destination \\LOUXDCWAGX1S001\d$\temp\vdi.txt

# Gather the userlist
$adassignments = Get-Content $userlist

# Split the userlist and add all usernames to the AD group
foreach ($adassignment in $adassignments) {
    $user = Get-ADUser -Identity $adassignment.Split(',')[0]
    if ($Environment -eq 'DotNet') {
        Write-Output "Adding $adassignment to V_XDW_VDI_WTS_B..."
        Add-ADGroupMember -Identity  "V_XDW_VDI_WTS_B" -Members $user
    } elseif ($Environment -eq 'Java') {
        Write-Output "Adding $adassignment to V_XDW_VDI_WTS_C..."
        Add-ADGroupMember -Identity  "V_XDW_VDI_WTS_C" -Members $user
    } elseif ($Environment -eq 'ITI') {
        Write-Output "Adding $adassignment to V_XDW_VDI_WTS_A..."
        Add-ADGroupMember -Identity  "V_XDW_VDI_WTS_A" -Members $user
    } elseif ($Environment -eq 'ITSE') {
        Write-Output "Adding $adassignment to V_XDW_W10_VDI_ITSE..."
        Add-ADGroupMember -Identity  "V_XDW_W10_VDI_ITSE" -Members $user
    }
}

# Start a pssession to the XDD server
New-PSSession -ComputerName LOUXDCWAGX1S001 -Name XDDQA

# Run the XDD broker commands within the session
Invoke-Command -Session (Get-PSSession -Name XDDQA) -ScriptBlock {
    # Gather the userlist
    $vdiassignments = Get-Content d:\temp\vdi.txt

    # Import the Citrix PSSnapin
    Add-PSSnapin "Citrix.*" -Verbose
    
    # Split the userlist and assign all usernames the machine
    foreach ($vdiassignment in $vdiassignments) {
        $user = $vdiassignment.Split(',')[0]
        $wkid = $vdiassignment.Split(',')[1]
        Write-Output "Adding $user to $wkid..."
        Add-BrokerUser -Name "HUMAD\$user" -Machine "HUMAD\$wkid"
    }
}

# Kill the pssession
Get-PSSession -Name XDDQA | Remove-PSSession
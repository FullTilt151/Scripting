#Connect to PIM service after installing module from https://www.powershellgallery.com/packages/Microsoft.Azure.ActiveDirectory.PIM.PSModule
if ($PSVersionTable.PSEdition -ne 'Core') {
    #Install-Module -Name Microsoft.Azure.ActiveDirectory.PIM.PSModule
    Install-Module -Name AzureADPreview -Force -AllowClobber
} else {
    #Import-Module -Name Microsoft.Azure.ActiveDirectory.PIM.PSModule -UseWindowsPowerShell
    Import-Module -Name AzureADPreview -UseWindowsPowerShell
}

#Connect-PimService
Connect-AzureAD

# Use to get RoleId for eligible roles to activate
# Get-PrivilegedRoleAssignment
# Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId 56c62bbe-8598-4b85-9e51-1ca753fa50f2

#Add a new line for each role to enable with a RoleId and Reason for each.
Enable-PrivilegedRoleAssignment -RoleId 3a2c62db-5318-420d-8d74-23affee5d9d5 -Reason "Intune"
Enable-PrivilegedRoleAssignment -RoleId 9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3 -Reason "Application Administrator - Register applications in Intune"
Enable-PrivilegedRoleAssignment -RoleId 5d6b6bb7-de71-4623-b4af-96380a352509 -Reason "Security Reader - Read Access to Security Center"
Enable-PrivilegedRoleAssignment -RoleId 4d6ac14f-3453-41d0-bef9-a3e0c569773a -Reason "License Administrator - Needed to manage AAD users and groups"
Enable-PrivilegedRoleAssignment -RoleId 7698a772-787b-4ac8-901f-60d6b08affd2 -Reason "Cloud Device Administrator - Needed to manage Cloud Devices"
Enable-PrivilegedRoleAssignment -RoleId 9f06204d-73c1-4d4c-880a-6edb90606fd8 -Reason "Device Administrator - Needed to manage AAD Joined Intune Managed Devices"
Enable-PrivilegedRoleAssignment -RoleId f023fd81-a637-4b56-95fd-791ac0226033 -Reason "Service Administrator - Needed to manage Support"
Enable-PrivilegedRoleAssignment -RoleId 38a96431-2bdf-4b4c-8b6e-5d3d8abac1a4 -Reason "Desktop Analytics Administrator - Used to manage DA"
Enable-PrivilegedRoleAssignment -RoleId b0f54661-2d74-4c50-afa3-1ec803f12efe -Reason "Billing Administrator - Used to manage MSfB"
Enable-PrivilegedRoleAssignment -RoleId -Reason 'Report Reader - To view M365 Admin Portal'

#Disconnect when finished
Disconnect-PimService
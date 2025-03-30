#Requires -RunAsAdministrator
If ($PSVersionTable.PSEdition -ne 'Desktop') {
    Do {
        Write-Host "Switch to Windows Powershell, this script is non-functional in Core." -ForegroundColor Red -BackgroundColor White
        Start-Sleep -Seconds 2
        Write-Host "Switch to Windows Powershell, this script is non-functional in Core." -ForegroundColor White -BackgroundColor Red
    } Until ($PSVersionTable.PSEdition -ne 'Core')
}
Else {
    #Install AzureADPreview
    If (!(Get-Module | Where-Object { $_.Name -eq 'AzureADPreview' -and $_.Version -ge '2.0.2.138' })) { Install-Module AzureADPreview -Force -AllowClobber }
    # Install msal.ps
    If (!(Get-Module | Where-Object { $_.Name -eq 'PowerShellGet' -and $_.Version -ge '2.2.4.1' })) { Install-Module PowerShellGet -Force -AllowClobber }
    If (!(Get-Package msal.ps)) { Install-Package msal.ps -Force}
}

#Check logged in account (Admin required)
<#If (!($env:USERNAME.EndsWith('s'))) {
    Write-Host 'Not logged in with a "S" account, will try "A".' -ForegroundColor Red -BackgroundColor White
    }
    Else { 
    (!($env:USERNAME.EndsWith('a'))) 
    Write-Host 'Not logged in with an "A" or "S" account.' -ForegroundColor White -BackgroundColor Red
    Write-Host 'The program will terminate after pressing "Enter".' -ForegroundColor Yellow
    pause
    exit 
}
#>

$tenantid = '56c62bbe-8598-4b85-9e51-1ca753fa50f2'
# Get token for MS Graph by prompting for MFA
$MsResponse = Get-MSALToken -Scopes @("https://graph.microsoft.com/.default") -ClientId "1b730954-1685-4b74-9bfd-dac224a7b894" -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Authority "https://login.microsoftonline.com/common" -Interactive -ExtraQueryParameters @{claims = '{"access_token" : {"amr": { "values": ["mfa"] }}}' }
# Get token for AAD Graph
$AadResponse = Get-MSALToken -Scopes @("https://graph.windows.net/.default") -ClientId "1b730954-1685-4b74-9bfd-dac224a7b894" -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Authority "https://login.microsoftonline.com/common"
Connect-AzureAD -AadAccessToken $AadResponse.AccessToken -MsAccessToken $MsResponse.AccessToken -AccountId: "upn" -tenantId: "$tenantId"

$acct = "$env:USERNAME@humana.com"
$userObjectId = (Get-AzureADUser -ObjectId $acct).ObjectId
$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = "Once"
$schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$schedule.EndDateTime = (Get-Date).AddHours(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
#Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $tenantid | Out-GridView

#Add a new line for each role to enable with a RoleDefinitionId and Reason for each.

#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3 -Reason "Application Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId cf1c38e5-3621-4004-a7cb-879624dced7c -Reason "Application Developer"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 9c6df0f2-1e7c-4dc3-b195-66dfbd24aa8f -Reason "Attack Payload Author"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId c430b396-e693-46cc-96f3-db01bf8bb62a -Reason "Attack Simulation Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId c4e39bd9-1100-46d3-8c65-fb160da0071f -Reason "Authentication Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 0526716b-113d-4c15-b2c8-68e3c22b9f80 -Reason "Authentication Policy Administrator"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 9f06204d-73c1-4d4c-880a-6edb90606fd8 -Reason "Azure AD Joined Device Local Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId e3973bdf-4987-49ae-837a-ba8e231c7286 -Reason "Azure DevOps Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 7495fdc4-34c4-4d15-a289-98788ce399fd -Reason "Azure Information Protection Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId aaf43236-0c0d-4d5f-883a-6955382ac081 -Reason "B2C IEF Keyset Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 3edaf663-341e-4475-9f94-5c398ef6c070 -Reason "B2C IEF Policy Administrator"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId b0f54661-2d74-4c50-afa3-1ec803f12efe -Reason "Billing Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 892c5842-a9a6-463a-8041-72aa08ca3cf6 -Reason "Cloud App Security Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 158c047a-c907-4556-b7ef-446551a6b5f7 -Reason "Cloud Application Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 7698a772-787b-4ac8-901f-60d6b08affd2 -Reason "Cloud Device Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 17315797-102d-40b4-93e0-432062caca18 -Reason "Compliance Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId e6d1a23a-da11-4be4-9570-befc86d067a7 -Reason "Compliance Data Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId b1be1c3e-b65d-4f19-8427-f6fa0d97feb9 -Reason "Conditional Access Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 5c4f9dcd-47dc-4cf7-8c9a-9e4207cbfc91 -Reason "Customer LockBox Access Approver"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 38a96431-2bdf-4b4c-8b6e-5d3d8abac1a4 -Reason "Desktop Analytics Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 9c094953-4995-41c8-84c8-3ebb9b32c93f -Reason "Device Join"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 2b499bcd-da44-4968-8aec-78e1674fa64d -Reason "Device Managers"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId d405c6df-0af8-4e3b-95e4-4d06e542189e -Reason "Device Users"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 88d8e3e3-8f55-4a1e-953a-9b9898b8876b -Reason "Directory Readers"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId d29b2b05-8046-44ba-8758-1e26182fcf32 -Reason "Directory Synchronization Accounts"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 9360feb5-f418-4baa-8175-e2a00bac4301 -Reason "Directory Writers"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 8329153b-31d0-4727-b945-745eb3bc5f31 -Reason "Domain Name Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 44367163-eba1-44c3-98af-f5787879f96a -Reason "Dynamics 365 Administrator"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 3f1acade-1e04-4fbc-9b69-f0302cd84aef	-Reason "Edge Administrator"	
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 29232cdf-9323-42fd-ade2-1d097af3e4de -Reason "Exchange Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 31392ffb-586c-42d1-9346-e59415a2cc4e -Reason "Exchange Recipient Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 6e591065-9bad-43ed-90f3-e9424366d2f0 -Reason "External ID User Flow Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 0f971eea-41eb-4569-a71e-57bb8a3eff1e -Reason "External ID User Flow Attribute Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId be2f45a1-457d-42af-a067-6ec1fa63bc45 -Reason "External Identity Provider Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 62e90394-69f5-4237-9190-012177145e10 -Reason "Global Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId f2ef992c-3afb-46b9-b7cf-a126ee74c451 -Reason "Global Reader"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId fdd7a751-b60b-444a-984c-02652fe8fa1c -Reason "Groups Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 95e79109-95c0-4d8e-aee3-d01accf2d47b -Reason "Guest Inviter"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 10dae51f-b6af-4016-8d66-8c2a99b929b3 -Reason "Guest User"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 729827e3-9c14-49f7-bb1b-9608f156bbb8 -Reason "Helpdesk Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 67caf9c2-40d5-4995-a294-0311c4f09086 -Reason "Humana Application Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2 -Reason "Hybrid Identity Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 45d8d3c5-c802-45c6-b32a-1d70b5e1e86e -Reason "Identity Governance Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId eb1f4a8d-243a-41f0-9fbd-c7cdf6c5ef7c -Reason "Insights Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 31e939ad-9672-4796-9c2e-873181342d2d -Reason "Insights Business Leader"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 3a2c62db-5318-420d-8d74-23affee5d9d5 -Reason "Intune Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 74ef975b-6605-40af-a5d2-b9539d836353 -Reason "Kaizala Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId b5a8dcf3-09d5-43a9-a639-8e29ef291470 -Reason "Knowledge Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 744ec460-397e-42ad-a462-8b3f9747a02c -Reason "Knowledge Manager"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 4d6ac14f-3453-41d0-bef9-a3e0c569773a -Reason "License Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId ac16e43d-7b2d-40e0-ac05-243ff356ab5b -Reason "Message Center Privacy Reader"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 790c1fb9-7f7d-4f88-86a1-ef1f95c05c1b -Reason "Message Center Reader"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId d37c8bed-0711-4417-ba38-b4abe66ce4c2 -Reason "Network Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 2b745bdf-0803-4d80-aa65-822c4493daac -Reason "Office Apps Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 4ba39ca4-527c-499a-b93d-d9b492c50246 -Reason "Partner Tier1 Support"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId e00e864a-17c5-4a4b-9c06-f5b95a8d5bd8 -Reason "Partner Tier2 Support"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 966707d0-3269-4727-9be2-8c3a10f19b9d -Reason "Password Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId a9ea8996-122f-4c74-9520-8edcd192826c -Reason "Power BI Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 11648597-926c-4cf3-9c36-bcebb0ba8dcc -Reason "Power Platform Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 644ef478-e28f-4e28-b9dc-3fdde9aa0b1f -Reason "Printer Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId e8cef6f1-e4bd-4ea8-bc07-4b8d950f4477 -Reason "Printer Technician"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 7be44c8a-adaf-4e2a-84d6-ab2649e08a13 -Reason "Privileged Authentication Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId e8611ab8-c189-46e8-94e1-60213ab1f814 -Reason "Privileged Role Administrator"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 4a5d8f65-41da-4de4-8968-e035b65339cf -Reason "Reports Reader"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 2af84b1e-32c8-42b7-82bc-daa82404023b -Reason "Restricted Guest User"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 0964bb5e-9bdb-4d7b-ac29-58e794862a40 -Reason "Search Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 8835291a-918c-4fd7-a9ce-faa49f0cf7d9 -Reason "Search Editor"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 194ae4cb-b126-40b2-bd5b-6091b380977d -Reason "Security Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 5f2222b1-57c3-48ba-8ad5-d4759f1fde6f -Reason "Security Operator"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 5d6b6bb7-de71-4623-b4af-96380a352509 -Reason "Security Reader"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId f023fd81-a637-4b56-95fd-791ac0226033 -Reason "Service Support Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId f28a1f50-f6e7-4571-818b-6a12f2af6b6c -Reason "SharePoint Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 75941009-915a-4869-abe7-691bff18279e -Reason "Skype for Business Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 69091246-20e8-4a56-aa4d-066075b2a7a8 -Reason "Teams Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId baf37b3a-610e-45da-9e62-d9d1e5e8914b -Reason "Teams Communications Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId f70938a0-fc10-4177-9e90-2178f8765737 -Reason "Teams Communications Support Engineer"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId fcf91098-03e3-41a9-b5ba-6f0ec8188a12 -Reason "Teams Communications Support Specialist"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 3d762c5a-1b6c-493f-843e-55a3b42923d4 -Reason "Teams Devices Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 75934031-6c7e-415a-99d7-48dbd49e875e -Reason "Usage Summary Reports Reader"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId a0b1b346-4d3e-4e8b-98f8-753987be4970 -Reason "User"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId fe930be7-5e62-47db-91af-98c3a49a38b1 -Reason "User Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId 32696413-001a-46ae-978c-ce0f6b3620d2 -Reason "Windows Update Deployment Administrator"
#Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -schedule $schedule -SubjectId $userObjectId -Type UserAdd -AssignmentState Active -ResourceId $tenantid -RoleDefinitionId c34f683f-4d5a-4403-affd-6615e00e3a7f -Reason "Workplace Device Join"

#Disconnect when finished
Clear-Variable -Name schedule
Disconnect-AzureAD
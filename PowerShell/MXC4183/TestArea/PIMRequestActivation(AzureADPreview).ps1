$user = Connect-AzureAD -tenantid 56c62bbe-8598-4b85-9e51-1ca753fa50f2

$userObjectId = (Get-AzureADUser -ObjectId $user.Account).ObjectId
$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = "Once"
$schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$schedule.Duration="PT9H"


#Add a new line for each role to enable with a RoleDefinitionId and Reason for each.
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -schedule $schedule -SubjectId $userObjectId -Type 'UserAdd' -AssignmentState 'Active' -ResourceId '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -RoleDefinitionId 3a2c62db-5318-420d-8d74-23affee5d9d5 -Reason "Intune"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -schedule $schedule -SubjectId $userObjectId -Type 'UserAdd' -AssignmentState 'Active' -ResourceId '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -RoleDefinitionId 9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3 -Reason "Application Administrator - Register applications in Intune"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -schedule $schedule -SubjectId $userObjectId -Type 'UserAdd' -AssignmentState 'Active' -ResourceId '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -RoleDefinitionId 5d6b6bb7-de71-4623-b4af-96380a352509 -Reason "Security Reader - Read Access to Security Center"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -schedule $schedule -SubjectId $userObjectId -Type 'UserAdd' -AssignmentState 'Active' -ResourceId '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -RoleDefinitionId 4d6ac14f-3453-41d0-bef9-a3e0c569773a -Reason "License Administrator - Needed to manage AAD users and groups"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -schedule $schedule -SubjectId $userObjectId -Type 'UserAdd' -AssignmentState 'Active' -ResourceId '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -RoleDefinitionId 9f06204d-73c1-4d4c-880a-6edb90606fd8 -Reason "Device Administrator - Needed to manage AAD Joined Intune Managed Devices"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -schedule $schedule -SubjectId $userObjectId -Type 'UserAdd' -AssignmentState 'Active' -ResourceId '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -RoleDefinitionId f023fd81-a637-4b56-95fd-791ac0226033 -Reason "Service Administrator - Needed to manage Support"
Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -schedule $schedule -SubjectId $userObjectId -Type 'UserAdd' -AssignmentState 'Active' -ResourceId '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -RoleDefinitionId 7698a772-787b-4ac8-901f-60d6b08affd2 -Reason "Cloud Device Administrator - Needed to manage Cloud Devices"

#Disconnect when finished
Disconnect-AzureAD
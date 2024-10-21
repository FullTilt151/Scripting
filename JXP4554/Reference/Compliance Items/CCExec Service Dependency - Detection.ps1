# Get Service Details
$service = get-service smstsmgr

# Check ServiceDependedOn Array
if (($service.ServicesDependedOn).name -notcontains "ccmexec")
{
 write-output $false
}
else
{
 write-output $true
}
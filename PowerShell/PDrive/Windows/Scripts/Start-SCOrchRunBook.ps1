param(
$OrchServer = "LOUAPPWPS819.rsc.humad.com",
$RunBookID = "cf481ab8-dfe1-4bd5-80ed-943902acc026",
[Parameter(Mandatory=$true)]
$wkid,
[Parameter(Mandatory=$true)]
$adou
#"OU=Desktops,OU=Computers,OU=LOU,DC=humad,DC=com"
)


$creds = Get-Credential
$url = Get-OrchestratorServiceUrl -server $OrchServer
$runbook = Get-OrchestratorRunbook -serviceurl $url -RunbookId $RunBookID -Credentials $creds
$params = @{"dc868f14-2c1b-475f-ae90-7f66a6b16694" = "$wkid";"bb0d64d5-9a6b-4f6d-9457-73828d0e3a0d" = "$adou"}
$job = Start-OrchestratorRunbook -Runbook $runbook -Parameters $params -Credentials $creds
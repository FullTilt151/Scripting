$uri = 'https://www.yammer.com/api/v1/messages.json'
$token = '8294686-HBYeHIVeud2GfgNnIoQ' #OAUTH token created by Daniel Ratliff
$headers = @{ "Authorization" = "Bearer " + $token }
$response = Invoke-RestMethod -Method Get -Uri $uri -Header $headers
Write-Output $response
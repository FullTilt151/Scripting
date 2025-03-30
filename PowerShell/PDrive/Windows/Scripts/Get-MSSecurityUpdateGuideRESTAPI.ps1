#Api-Key
$ApiKey = 'c537264554634c0192d64d828de429b6'

#Get the Updates as XML
Invoke-RestMethod -Uri 'https://api.msrc.microsoft.com/Updates?api-Version=2016' -ContentType application/xml -Headers @{'Api-Key'="$ApiKey"}

#Get the CVRF with ID 2016-Nov as XML
Invoke-RestMethod -Uri 'https://api.msrc.microsoft.com/cvrf/2016-Nov?api-Version=2016' -ContentType application/xml -Headers @{'Api-Key'="$ApiKey"}
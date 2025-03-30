
# Get collections from admin service
Measure-Command{Invoke-RestMethod -Method 'Get' -Uri 'https://louappwps1658.rsc.humad.com/AdminService/wmi/SMS_Collection' -UseDefaultCredentials}


(Invoke-RestMethod -Method 'Get' -Uri 'https://louappwqs1151.rsc.humad.com/AdminService/wmi/SMS_Collection' -UseDefaultCredentials).value.objectpath

$SamPro[1]
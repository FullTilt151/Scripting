$WKID = 'DSIPXEWPW24'
Enter-PSSession -ComputerName $WKID
$Install = '\\lounaswps08\idrive\d907ats\66808\install\Deploy-Application.ps1 -Installtype pxe'   
$Uninstall = '\\lounaswps08\idrive\d907ats\66808\install\Deploy-Application.ps1 -deploymenttype uninstall'   
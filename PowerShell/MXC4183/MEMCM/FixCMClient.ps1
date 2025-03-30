#Get server names from text file.
Get-Content C:\Temp\Servers.txt | ForEach-Object {
	If (Test-Connection $_ -Quiet -Count 1){
	    Write-Output "$_,UP"
	} Else {
	    Write-Output "$_,Down"
	}
}

#Delete SMSCFG.ini file.

#Delete SMS certificates.

#Restart SMS_Exec service.

Restart-Computer -ComputerName DSIPXEWPW61, DSIPXEWPW40, DSIPXEWPW49, DSIPXEWPW13


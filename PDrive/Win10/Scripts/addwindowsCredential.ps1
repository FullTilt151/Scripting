<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages 
#>


Function Add-OSCCredential
{
	$target = Read-Host "Internet or network address"
	$userName = Read-Host "UserName"
	$Password = Read-Host "Password" -AsSecureString
	If($target -and $userName)
	{
		If($Password)
		{
			[string]$result = cmdkey /add:$target /user:$userName /pass:$Password
		}
		Else
		{
			[string]$result = cmdkey /add:$target /user:$userName 
		}
		If($result -match "The command line parameters are incorrect")
		{
			Write-Error "Failed to add Windows Credential to Windows vault."
		}
		ElseIf($result -match "CMDKEY: Credential added successfully")
		{
			Write-Host "Credential added successfully."
		}
	}
	Else
	{
		Write-Error "Internet(network address) or username can not be empty,please try again."
		Add-OSCCredential
	}
	
}

Add-OSCCredential
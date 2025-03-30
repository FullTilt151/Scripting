Set adminManager = WScript.CreateObject("Microsoft.ApplicationHost.WritableAdminManager") 
adminManager.CommitPath = "MACHINE/WEBROOT/APPHOST" 
Set windowsAuthenticationSection = adminManager.GetAdminSection("system.webServer/security/authentication/windowsAuthentication", "MACHINE/WEBROOT/APPHOST/Default Web Site") 

windowsAuthenticationSection.Properties.Item("authPersistNonNTLM").Value = True
adminManager.CommitChanges()

set windowsAuthenticationSection = nothing
set adminManager = nothing

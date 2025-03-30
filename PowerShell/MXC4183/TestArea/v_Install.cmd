SET PK=<replace with your licensekey>
SET SVCPWD=<replace with your Service Password>
REM ------------------------------------------------
REM start shoppping installation
REM ------------------------------------------------
msiexec /i ShoppingCentral.msi ACTIVE_DIRECTORY_SERVER= ^
InstallDir="" ^
ADMINACCOUNT="" ^
AESERVERNAME= ^
DATABASENAME=Shopping2 ^
IISHOSTHEADER= ^
INSTALLTYPE=COMPLETE ^
LICENSEMGRACCOUNT="" ^
PIDKEY=%PK% ^
RECEIVERACCOUNT="" ^
REPORTSACCOUNT="" ^
SHOPPINGCONSOLEADMINUSERS="" ^
SHOPPINGCONSOLESMSUSERS="" ^
SHOPPINGCONSOLEUSERS="" ^
SHOPPINGURLPREFIX=http:// ^
SMTP_SERVER_NAME= ^
SQLSERVER=LOUAPPWQS513.rsc.humad.com ^
SMSPROVIDERLOCATION= ^
SVCPASSWORD=%SVCPWD% ^
SVCUSER= ^
USEGLOBALCATALOG= /l*v %TEMP%\v_Install.log

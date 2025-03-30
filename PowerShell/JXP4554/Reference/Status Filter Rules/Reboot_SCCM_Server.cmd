@echo off

sc query W3SVC
if %errorlevel% EQU 0 (
	iisreset /stop

	if exist f:\IISLogs\W3SVC1 (
		del f:\IISLogs\W3SVC1\*.log
	)
	if exist C:\inetpub\logs\LogFiles\W3SVC1 (
		del C:\inetpub\logs\LogFiles\W3SVC1\*.log
	)

	if exist C:\inetpub\logs\FailedReqLogFiles (
		del C:\inetpub\logs\FailedReqLogFiles\*.log
	)

) else (
	echo.IIS not found
)

sc query SMS_EXECUTIVE
if %errorlevel% EQU 0 (
	net stop SMS_EXECUTIVE
) else (
	echo.cannot find SMS_EXECUTIVE
)
shutdown -r -f -t 00
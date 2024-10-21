cd c:\windows\system32
xcopy /y "\\cscdtsinf\dts\software\scripts\delprof\delprof.exe" c:\windows\system32 /c
delprof /q /i /d:30
"\\cscdtsinf\dts\Software\Freely Installable\ATF-Cleaner\atf-cleaner.exe"
"\\cscsccmpri\software_Packages\SWD BGInfo 4.16\Install.EXE"
del /f /q c:\deploy
del /f /q c:\dell
del /f /q c:\drivers
del /f /q c:\Intel
del /f /q c:\Receive
del /f /q c:\Office2k3
del /f /q "c:\Documents and Settings\Default User\Start Menu\Programs\Outlook Express.lnk"
del /f /q "c:\Documents and Settings\Default User\Start Menu\Programs\Remote Assistance.lnk"
del /f /q "c:\Documents and Settings\Default User\Start Menu\Programs\Dell Accessories"
del /f /q "c:\Documents and Settings\All Users\Start Menu\Windows Update.lnk"
del /f /q "c:\Documents and Settings\All Users\Start Menu\Set Program Access and Defaults.lnk"
del /f /q c:\DST
del /f /q c:\VNCTEMP
del /f /q "C:\Documents and Settings\All Users\Start Menu\Programs\Games"
wmic useraccount where name='jhdesktop' call rename name='Administrator'
wmic useraccount where name='admin' call rename name='Administrator'
net user admin /delete
net user jhdesktop /delete
net user rps /delete
net user dts /delete
net user n01979 /delete
net user a /delete
net user alan.elliot /delete
net user bill /delete
net user ccarne /delete
net user ccarner /delete
net user colleen.carner /delete
net user eric /delete
net user jh /delete
net user jhhs /delete
net user jhsmh /delete
net user template /delete
net user user /delete
net user x /delete
net user z /delete
net stop sharedaccess
sc config sharedaccess start= disabled
compmgmt.msc
pause
net localgroup administrators nurs1ng carevue nursemgr jhhs "domain users" colleen.carner richard.woodward winxplocaladmins everyone /delete
\\cscdtsinf\dts\software\scripts\run_cleanup.bat
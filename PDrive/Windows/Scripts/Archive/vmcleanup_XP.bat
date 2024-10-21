rem Starts defragmentation on C: with HIGH priority and verbose output
start /high defrag.exe c: -f -v
rem Updated group policy for user and computer
gpupdate /force
rem Updates McAfee VirusScan Definitions
"c:\Program Files\McAfee\VirusScan Enterprise\mcupdate.exe" /update
rem Runs PatchMeNow
c:\humscript\patch\pmn.exe
rem Delete all temp files
del %temp%\* /f /q
del c:\windows\temp\* /f /q
del c:\temp\* /f /q
rem Map P:\ and I:\ drives
net use P: /delete
net use I: /delete
net use P: \\lounaswps01\pdrive /persistent:yes
net use I: \\lounaswps01\idrive /persistent:yes
rem Restart the VM after 15 minutes
shutdown -r -t 900
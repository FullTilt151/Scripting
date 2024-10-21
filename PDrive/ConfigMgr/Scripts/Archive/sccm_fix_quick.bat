@echo off
echo Uninstalling SCCM client
echo -----
\\cscsccmpri\client\ccmsetup.exe /uninstall
echo ***Resetting WMI!***
echo -----
@echo off
net stop swihpwmi
net stop hpqwmiex
net stop iaantmon
net stop dcpsysmgrsvc
net stop smmanager
net stop evteng
net stop s24eventmonitor
net stop ccmexec
net stop sharedaccess
net stop winmgmt
c:
cd c:\windows\system32\wbem
rd /S /Q repository
regsvr32 /s %systemroot%\system32\scecli.dll
regsvr32 /s %systemroot%\system32\userenv.dll
mofcomp cimwin32.mof
mofcomp cimwin32.mfl
mofcomp rsop.mof
mofcomp rsop.mfl
for /f %%s in ('dir /b /s *.dll') do regsvr32 /s %%s
for /f %%s in ('dir /b *.mof') do mofcomp %%s
for /f %%s in ('dir /b *.mfl') do mofcomp %%s
mofcomp exwmi.mof
mofcomp -n:root\cimv2\applications\exchange wbemcons.mof
mofcomp -n:root\cimv2\applications\exchange smtpcons.mof
mofcomp exmgmt.mof
echo Reinstalling latest SCCM client from CSCSCCMPRI
echo -----
start /high \\cscsccmpri\client\ccmsetup.exe
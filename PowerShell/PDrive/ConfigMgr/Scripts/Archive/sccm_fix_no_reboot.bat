echo -----
echo SCCM Non-Client Fix script starting...
echo -----
hostname
REG ADD HKLM\Software\Microsoft\PCHealth\ErrorReporting /t REG_DWORD /v DoReport /d 0 /f
secedit /configure /db %temp%\temp.db /cfg "%systemroot%\security\templates\setup security.inf
\\cscsccmpri\client\ccmsetup.exe /uninstall
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
echo -----
echo Script complete!
echo -----
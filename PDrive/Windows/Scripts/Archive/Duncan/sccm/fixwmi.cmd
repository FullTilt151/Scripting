IF NOT EXIST "%windir%\SysWOW64\WBEM\mofcomp.exe" (
IF EXIST "%windir%\System32\WBEM\mofcomp.exe" (
cd /d "%windir%\System32\WBEM"
FOR /F %%s in ('dir /b /s *.dll') do %windir%\System32\regsvr32 /s %%s
Net stop /y winmgmt
FOR /F %%s in ('dir /b *.mof *.mfl') do mofcomp %%s
Net start winmgmt
)
)

IF EXIST "%windir%\SysWOW64\CCM\ccmrepair.exe" (
"%windir%\SysWOW64\CCM\ccmrepair.exe"
)


IF EXIST "%windir%\System32\CCM\ccmrepair.exe" (
"%windir%\System32\CCM\ccmrepair.exe"
)

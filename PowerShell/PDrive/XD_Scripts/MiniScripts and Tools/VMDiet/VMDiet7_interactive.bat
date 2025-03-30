cls
@echo off
echo Batch file for reducing used hard drive space on VM's
echo May be used on any windows 7 machine that the user has 
echo administrative privileges.
echo.
echo.
echo.
set /p node=What is the machine name?:
echo The targeted machine `%node%' will begin to be processed.
echo Extraneous services will be disabled, CAF will be enabled.
echo Patch cache and temporary files will be removed.
echo Windows service pack and windows KB update caches will be removed.
echo Hidden migration folder $hf_mig$ and update installers will be compressed.
echo.
ECHO Deleting Temporary Files
FOR /d %%$ IN (\\%node%\c$\Windows\temp\*) DO RD /s /q "%%$"
ERASE \\%node%\c$\Windows\temp\*.* /s/q/f

FOR /f "tokens=*" %%g IN ('dir /ad /b "\\%node%\c$\Users\*.*"') DO (
	attrib -r -h -s -a /S /D "\\%node%\c$\Users\%%g\AppData\Local\Temp\*.*"
	FOR /d %%$ IN ("\\%node%\c$\Users\%%g\AppData\Local\Temp\*") DO RD /s /q "%%$"
	ERASE "\\%node%\c$\Users\%%g\AppData\Local\Temp\*.*" /s/q/f
)

ERASE \\%node%\c$\RECYCLER\*.* /s/q/f

ERASE "\\%node%\c$\Windows\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files\*.*" /s/q/f
ERASE "\\%node%\c$\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\*.*" /s/q/f
ERASE "\\%node%\c$\Windows\Microsoft.NET\Framework64\v2.0.50727\Temporary ASP.NET Files\*.*" /s/q/f
ERASE "\\%node%\c$\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*.*" /s/q/f

ECHO Compressing Installer Directories
compact /c /s:"\\%node%\c$\Windows\*.log" /a /i /f
compact /c /s:"\\%node%\c$\Intervoice\Tomcat\logs" /a /i /f
compact /c /s:"\\%node%\c$\Program Files\Sqllib\Tools\*.phd" /a /i /f
compact /c /s:"\\%node%\c$\Program Files\Microsoft SQL Server\100\Setup Bootstrap\Log" /a /i /f
compact /c /s:"\\%node%\c$\Windows\Installer" /a /i /f
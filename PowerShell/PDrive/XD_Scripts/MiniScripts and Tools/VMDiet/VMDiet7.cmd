@CLS
@ECHO OFF

ECHO The targeted machine '%ComputerName%' will begin to be processed.
ECHO Patch cache and temporary files will be removed.
ECHO Update installers will be compressed.
ECHO:

pause

ECHO:
ECHO Deleting Temporary Files
FOR /d %%$ IN (C:\Windows\temp\*) DO RD /s /q "%%$"
ERASE C:\Windows\temp\*.* /s/q/f

FOR /f "tokens=*" %%g IN ('dir /ad /b "C:\Users\*.*"') DO (
	attrib -r -h -s -a /S /D "C:\Users\%%g\AppData\Local\Temp\*.*"
	FOR /d %%$ IN ("C:\Users\%%g\AppData\Local\Temp\*") DO RD /s /q "%%$"
	ERASE "C:\Users\%%g\AppData\Local\Temp\*.*" /s/q/f
)

ERASE C:\RECYCLER\*.* /s/q/f

ERASE "C:\Windows\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files\*.*" /s/q/f
ERASE "C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\*.*" /s/q/f
ERASE "C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Temporary ASP.NET Files\*.*" /s/q/f
ERASE "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*.*" /s/q/f

ECHO Compressing Installer Directories
compact /c /s:"C:\Windows\*.log" /a /i /f
compact /c /s:"C:\Intervoice\Tomcat\logs" /a /i /f
compact /c /s:"C:\Program Files\Sqllib\Tools\*.phd" /a /i /f
compact /c /s:"C:\Program Files\Microsoft SQL Server\100\Setup Bootstrap\Log" /a /i /f
compact /c /s:"C:\Windows\Installer" /a /i /f
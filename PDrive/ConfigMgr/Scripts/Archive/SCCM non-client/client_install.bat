FOR /F "tokens=1 delims=\n" %%G IN (computers.txt) DO remcom \\%%G "\\cscdtsinf\dts\software\Freely Installable\SCCM\Client\ccmsetup.exe" 1>>status.txt 2>>error.txt
pause
FOR /F "tokens=1 delims=\n" %%G IN (computers.txt) DO remcom \\%%G start /min /high \\cscdtsinf\dts\software\scripts\SCCM\sccm_fix_no_reboot.bat 1>>status.txt 2>>error.txt
pause
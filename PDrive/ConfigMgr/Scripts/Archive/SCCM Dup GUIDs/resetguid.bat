FOR /F "tokens=1 delims=\n" %%G IN (computers.txt) DO xcopy ResetSCCMUniqueID.exe \\%%G\c$ /v /c /y 1>>status.txt 2>>error.txt
FOR /F "tokens=1 delims=\n" %%G IN (computers.txt) DO remcom \\%%G "C:\ResetSCCMUniqueID.exe" 1>>status.txt 2>>error.txt
pause
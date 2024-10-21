FOR /F "tokens=1 delims=\n" %%G IN (computers.txt) DO if exist "\\%%G\c$\windows\system32\ccm" (echo "%%G has client") 1>>status.txt else (echo "No client") 1>>status.txt
pause
 $username = Read-Host -Prompt "Input Username"
runas /user:$username "C:\Program Files\Internet Explorer\iexplore.exe http:\\myaccess.humana.com"  
#Standard remote install when file is local
Invoke-Command -ComputerName <WKID> -ScriptBlock { 
    Start-Process <path to MSI/EXE> -ArgumentList '/quiet /L*V "C:\temp\<somelog>.log"' -Wait
}


Start-Transcript -Path ".\results.txt"
foreach($Server in 'LOUAPPWQS1020.RSC.HUMAD.COM','LOUAPPWQS1021.RSC.HUMAD.COM','LOUAPPWQS1022.RSC.HUMAD.COM'){
    FOREACH($Port in '80','443','10123'){
        Test-NetConnection -ComputerName $Server -Port $port
    }
} 
Stop-Transcript
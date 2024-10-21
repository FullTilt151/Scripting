$mysession = New-PSSession -ComputerName SIMCMVWPL02S01.ts.humad.com

invoke-command -Session $mysession -ScriptBlock {d:\scripts\Check_Status.ps1 -DesktopName LOUXDWTSSA0002 -DDC71 LOUXDDWPS01}
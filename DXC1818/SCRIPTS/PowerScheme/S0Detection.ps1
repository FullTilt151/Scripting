#$WKID = 'WKPF230RGP'
$WKIDS = Get-Content -Path C:\CIS_Temp\WKIDs.txt
Foreach ($WKID In $WKIDS) {
    IF (Test-Connection -ComputerName $WKID -Count 1 -TimeToLive 120) {
        Invoke-Command -ComputerName $WKID -ScriptBlock {
            IF (powercfg /a | Select-String -Pattern "Network Connected") {
                Write-Output 'Dell/HP/Lenovo/MSFT Surface Modern system, use Balanced Power Scheme'
                powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
                cmd /c "powercfg /setdcvalueindex  381b4222-f694-41f0-9685-ff5bb260df2e 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 0"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 1"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 1"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 900"
                cmd /c "powercfg /setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 1"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 2"
                cmd /c "powercfg /setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 0"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 75"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 70"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 25"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 0"
                cmd /c "powercfg /setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 2"
                $Build = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber
                If ($Build -lt '19042') {
                    New-Item -Path "HKLM:\Software\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" -Force -ErrorAction SilentlyContinue    
                    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" -Name ACSettingIndex -Value 1 -Force
                    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" -Name DCSettingIndex -Value 1 -Force
                }
            }
            Else {
                Write-Output 'Legacy system, use Humana Settings Power Scheme'
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 0"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 1"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 1"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 900"
                cmd /c "powercfg /setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 1"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 2"
                cmd /c "powercfg /setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 0"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 75"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 70"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 25"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 0"
                cmd /c "powercfg /setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 2"
                cmd /c powercfg /changename 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c "Humana Settings"
                cmd /c powercfg /S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            }
            cmd /c "powercfg /H Off"
            cmd /c "powercfg /change disk-timeout-ac 0"
            cmd /c "powercfg /change standby-timeout-ac 0"
        }
    }
}
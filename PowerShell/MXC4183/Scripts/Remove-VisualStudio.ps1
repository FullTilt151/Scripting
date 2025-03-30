# This snippet removes Visual Studio
# Remove 2017 Ent.
if($Version -eq 'VS2017Ent'){
    if(Get-InstalledApplication -Name 'Visual Studio Enterprise 2017'){
        $Name = 'Visual Studio Enterprise 2017'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise"' -ErrorAction SilentlyContinue
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise"' -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $17EntKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Know delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17EntKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17EntKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\15.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'

        }
    }
}

# Remove 2017 Pro.
if($Version -eq 'VS2017Pro'){
    if(Get-InstalledApplication -Name 'Visual Studio Professional 2017'){
        $Name = 'Visual Studio Professional 2017'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional"' -ErrorAction SilentlyContinue
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional"' -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $17ProKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Know delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17ProKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17ProKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\15.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'

        }
    }
}
# Remove 2019 Ent.
if($Version -eq 'VS2019Ent'){
    if(Get-InstalledApplication -Name 'Visual Studio Enterprise 2019'){
        $Name = 'Visual Studio Enterprise 2019'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise"'
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise" -Recurse -Force -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $19EntKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Know delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19EntKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19EntKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\16.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
        }
    }
}

# Remove 2019 Pro.
if($Version -eq 'VS2019Pro'){
    if(Get-InstalledApplication -Name 'Visual Studio Professional 2019'){
        $Name = 'Visual Studio Professional 2019'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional"'
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional" -Recurse -Force -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $19ProKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Now delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19ProKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19ProKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\16.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
        }
    }
}

# Remove 2022 Enterprise.
if($Version -eq 'VS2022Ent'){
    if(Get-InstalledApplication -Name 'Visual Studio Enterprise 2022'){
        $Name = 'Visual Studio Enterprise 2022'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files\Microsoft Visual Studio\2022\Enterprise"'
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio\2022\Enterprise" -Recurse -Force -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $22Key = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Now delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$22Key" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$22Key" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\17.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'

        }
    }
}

# Nuke them all from orbit. Only way to be sure.
if($Version -eq 'Nuke'){
    Write-Log -Message "Nuclear option selected! Scanning for and removing Visual Studio!" -Source 'Removal' -LogType 'CMTrace'
    # 2017 Ent
    if(Get-InstalledApplication -Name 'Visual Studio Enterprise 2017'){
        $Name = 'Visual Studio Enterprise 2017'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise"' -ErrorAction SilentlyContinue
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise"' -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $17EntKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Know delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17EntKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17EntKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\15.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'

        }
    }
    elseif(Get-InstalledApplication -Name 'Visual Studio Professional 2017'){
        $Name = 'Visual Studio Professional 2017'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional"' -ErrorAction SilentlyContinue
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional"' -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $17ProKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Know delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17ProKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$17ProKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\15.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
        }
    }
    elseif(Get-InstalledApplication -Name 'Visual Studio Enterprise 2019'){
        $Name = 'Visual Studio Enterprise 2019'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise"' -ErrorAction SilentlyContinue
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise"' -ErrorAction SilentlyContinue
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise" -Recurse -Force -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $19EntKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Know delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19EntKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19EntKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\16.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
        }
    }
    elseif(Get-InstalledApplication -Name 'Visual Studio Professional 2019'){
        $Name = 'Visual Studio Professional 2019'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional"'
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional" -Recurse -Force -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $19ProKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Now delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19ProKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19ProKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\16.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
        }
    }
    elseif(Get-InstalledApplication -Name 'Visual Studio Enterprise 2022'){
        $Name = 'Visual Studio Enterprise 2022'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files\Microsoft Visual Studio\2022\Enterprise"'
            Write-Log -Message "Removing $Name" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio\2022\Enterprise" -Recurse -Force -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $22Key = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Now delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$22Key" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$22Key" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\17.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
        }
    }
    elseif(Get-InstalledApplication -Name 'Visual Studio Community 2019'){
        $Name = 'Visual Studio Community 2019'
        Write-Log -Message "$Name found! Attempting removal." -Source 'Removal' -LogType 'CMTrace'
        if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'){
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"' -ErrorAction SilentlyContinue
            Execute-Process -Path 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe' -Parameters 'uninstall --quiet --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"' -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" -Recurse -Force -ErrorAction SilentlyContinue
            # Search registry for auto generated key.
            Write-Log -Message "Searching registry for $Name auto generated key" -Source 'Removal' -LogType 'CMTrace'
            $19ComKey = (Get-ChildItem -Path 'HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\' | Get-ItemProperty | Where-Object {$_.DisplayName -match "$Name"}).PSChildName 
            # Now delete found key
            Write-Log -Message "Removing HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19ComKey" -Source 'Removal' -LogType 'CMTrace'
            Remove-Item "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$19ComKey" -Force -ErrorAction SilentlyContinue
            Remove-item "HKLM:SOFTWARE\WOW6432Node\Microsoft\VisualStudio\16.0\Setup" -Force -ErrorAction SilentlyContinue
            Write-Log -Message "Removal of $Name complete." -Source 'Removal' -LogType 'CMTrace'
        }
    }
else{
        Write-Log -Message "Nuclear option didn't find anything to remove." -Source 'Removal' -LogType 'CMTrace'
    }
}

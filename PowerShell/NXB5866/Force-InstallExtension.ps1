# Detection Script for Chrome and Edge.
$ChromeInstalled = $false
$EdgeInstalled = $false

# Check for Chrome. 
if(test-path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'){
    $ChromeInstalled = $true 
}

# Check for Edge.
if(Get-AppxPackage -Name Microsoft.MicrosoftEdge){
    $EdgeInstalled = $true
}
# Adding a 2nd Edge detection method. Some users Shopped for it. Assuming that's why it's not .appx
if (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "Microsoft Edge"}){
    $EdgeInstalled = $true
}
# If Chrome is installed, check for keys, create if not found. Set keys variable for CI.
if($ChromeInstalled -eq $true){
    #Chrome installed, check for Extension keys.
    if(Test-Path -path 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist'){
        #EIF key present, check for values and set variables
        if(Get-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -name "2" -ErrorAction SilentlyContinue){
            
        }else{
            New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "2" -Value "ioojdegpcpikaipagfngjlpolhakofkp;file://lounaswps08/idrive/Dept907.CIT/windows/Packages/BrowserExtensions/WorkIQ_Extension/ioojdegpcpikaipagfngjlpolhakofkp/6.8.3.1407_0/workiq-update.xml"

        }
    }else{
    New-Item -Path 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist'
    New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "3" -Value "ioojdegpcpikaipagfngjlpolhakofkp;file://lounaswps08/idrive/Dept907.CIT/windows/Packages/BrowserExtensions/WorkIQ_Extension/ioojdegpcpikaipagfngjlpolhakofkp/6.8.3.1407_0/workiq-update.xml"
    }
}
 #End Chrome section.

# Edge installed. Check for keys, create if not found. Set keys variable for CI
if($EdgeInstalled -eq $true){
    # Check for Edge extension key. If present, check values.
   if(test-path -path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\ExtensionInstallForcelist'){
       # Extension key there, check values.
       if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\ExtensionInstallForcelist' -name "2" -ErrorAction SilentlyContinue){
                 
        }else{  
            New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\ExtensionInstallForcelist' -Name "2" -Value "ioojdegpcpikaipagfngjlpolhakofkp;file://lounaswps08/idrive/Dept907.CIT/windows/Packages/BrowserExtensions/WorkIQ_Extension/ioojdegpcpikaipagfngjlpolhakofkp/6.8.3.1407_0/workiq-update.xml"
        }      
    }else{
        New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge\ExtensionInstallForcelist' -name "2" -Value "ioojdegpcpikaipagfngjlpolhakofkp;file://lounaswps08/idrive/Dept907.CIT/windows/Packages/BrowserExtensions/WorkIQ_Extension/ioojdegpcpikaipagfngjlpolhakofkp/6.8.3.1407_0/workiq-update.xml"
    }
   
        
} 
# End Edge section
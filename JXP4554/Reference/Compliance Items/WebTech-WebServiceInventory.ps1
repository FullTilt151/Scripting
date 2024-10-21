#####################################################################
# WebTech - Larry Glenn
# Version: v3
#####################################################################

#Grab timestamp
$dtStarted = [DateTime]::Now

## Define new class name and date
$NewClassName = 'Win32_WebServers_Custom'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
#WebServer - Basic Info
$newClass.Properties.Add("webservername", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("webserverpath", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("webserverversion", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("webserverpatch", [System.Management.CimType]::String, $false)
#Process Info
$newClass.Properties.Add("processcaption", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("processexecutablepath", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("processcommandline", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("localports", [System.Management.CimType]::String, $false)
#Misc
$newClass.Properties.Add("computername", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("os", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("notes", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)

$newClass.Properties["webservername"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null


#Get Computername
Try {$Computername = $env:ComputerName} Catch {$Computername = "Unknown"}

#Get OS
Try {$OS = (Get-WmiObject -class Win32_OperatingSystem).Caption} Catch {$OS = "Unknown"}
#[System.Environment]::OSVersion.Version.ToString()


#------------------------------------------------------------------------------------------------------------------------
function Get-NetworkStatistics 
{ 
    $properties = ‘Protocol’,’LocalAddress’,’LocalPort’ 
    $properties += ‘RemoteAddress’,’RemotePort’,’State’,’ProcessName’,’PID’ 

    netstat -ano | Select-String -Pattern ‘\s+(TCP|UDP)’ | ForEach-Object { 

        $item = $_.line.split(” “,[System.StringSplitOptions]::RemoveEmptyEntries) 

        if($item[1] -notmatch ‘^\[::’) 
        {            
            if (($la = $item[1] -as [ipaddress]).AddressFamily -eq ‘InterNetworkV6’) 
            { 
               $localAddress = $la.IPAddressToString 
               $localPort = $item[1].split(‘\]:’)[-1] 
            } 
            else 
            { 
                $localAddress = $item[1].split(‘:’)[0] 
                $localPort = $item[1].split(‘:’)[-1] 
            }  

            if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq ‘InterNetworkV6’) 
            { 
               $remoteAddress = $ra.IPAddressToString 
               $remotePort = $item[2].split(‘\]:’)[-1] 
            } 
            else 
            { 
               $remoteAddress = $item[2].split(‘:’)[0] 
               $remotePort = $item[2].split(‘:’)[-1] 
            }  

            New-Object PSObject -Property @{ 
                PID = $item[-1] 
                ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress =$remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq ‘tcp’) {$item[3]} else {$null} 
            } | Select-Object -Property $properties 
        } 
    } 
} 

#------------------------------------------------------------------------------------------------------------------------

## Check for IIS - using the registry and file version info
Try
{
    if ((Test-Path -Path HKLM:\Software\Microsoft\InetStp) -eq $true)
    {
        $regPath = Get-ItemProperty -Path HKLM:\Software\Microsoft\InetStp
        #$regPath.InstallPath
        #$regPath.MajorVersion
        #$regPath.MinorVersion

        $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$($regPath.InstallPath)\inetinfo.exe")
        #$versionInfo.ProductVersion

        #Insert to WMI
        Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
            #WebServer - Basic Info
            webservername = "IIS";
            webserverpath = $regPath.InstallPath
            webserverversion = $versionInfo.ProductVersion;
            webserverpatch = "";

            #Process Info
            processcaption = "";
            processexecutablepath = "";
            processcommandline = "";
            localports = "Check in IIS - netstat shows System listening";

            #Misc
            computername = $Computername;
            os = $OS;
            notes = "";
            ScriptLastRan = $Date

            } | Out-Null
    }
}
Catch {}


## Check for apache and java servers using running processes
$weblogiccount = 0
$webspherecount = 0
$apachecount = 0
$tomcatcount = 0
$jbosscount = 0
$javacount = 0

Try
{
    $selectedProcesses = Get-WmiObject -class Win32_Process | WHERE CommandLine -match "java|httpd|tomcat|wlsvcX64.exe|wasservice.exe"
    foreach ($process in $selectedProcesses)
    {
        $technology = ""
        $webservername = ""
        $webserverpath = ""
        $webserverversion = ""
        $webserverpatch = ""        
        $processcaption = ""
        $processexecutablepath = ""
        $processcommandline = ""
        $localports = ""
        $notes = ""
	    $pathonly = ""

        if($process.CommandLine -match "httpd.exe")
        {
            $apachecount++

            $technology = "Apache HTTP ($apachecount)"

            #Try to get Apache version info - from executable path
            try
            {
                $processexecutablepath = $process.ExecutablePath           # Pull out: {path to} httpd.exe
                if ($processexecutablepath.ToLower().EndsWith("httpd.exe") -eq $true)
                {
                    if(Test-Path -Path $processexecutablepath)
                    { 
                        $myargs = "-version"
                        $output = & cmd /c $processexecutablepath $myargs 2`>`&1

                        $find = [regex]"Server version:[\s]*([a-zA-Z0-9./\s]*[a-zA-Z0-9()]*)"
                        $match = $find.Match($output)                              # Pull out: Server version: Apache/2.4.35 (Win64)
                        $webserverversion = $match.Groups[1].Value                      # Pull out: Apache/2.4.35 (Win64)
                    }
                    else
                    {
                        $notes += "httpd.exe not found at: $processexecutablepath"
                    }
                }
            }
            catch{}

            #Try to get Apache  info - from command line
            try
            {
                $processcommandline = $process.CommandLine

                $webserverpath = $processcommandline

                $webserverpatch = $webserverversion
            }
            catch{}
        }

        elseif ($process.CommandLine -match "weblogic|wlsvcX64.exe")
        {
            $weblogiccount++

            $technology = "WebLogic ($weblogiccount)"

            if ($process.CommandLine -match "-Dweblogic.Name=AdminServer") {$technology = "WebLogic - AdminServer ($weblogiccount)"}


            #Try to get java version info - from executable path
            try
            {
                $processexecutablepath = $process.ExecutablePath           # Pull out: C:\PROGRA~1\Java\JDK18~1.0_1\bin\java.exe
                if ($processexecutablepath.ToLower().EndsWith("java.exe") -eq $true)
                {
                    $myargs = "-version"
                    $output = & cmd /c $processexecutablepath $myargs 2`>`&1

                    $find = [regex]"java version ""[\s]*([0-9._]*)"""
                    $match = $find.Match($output)                              # Pull out: java version "x.x.x"
                    #$javaversion = $match.Groups[1].Value                      # Pull out: x.x.x
                    $notes += $processexecutablepath + " - " + $match.Value + "`r`n"
                }
            }
            catch{}

            #Try to get WebLogic version info - from command line - using opatch
            try
            {
                $processcommandline = $process.CommandLine
                $find = [regex]"-Dweblogic.home=([a-zA-Z0-9_:\\]*)"              # Pull out: -Dweblogic.home=D:\Oracle\Middleware\Oracle_Home\wlserver\server
                $match = $find.Match($processcommandline)
                $pathonly = $match.Groups[1].Value                               # Pull out: D:\Oracle\Middleware\Oracle_Home\wlserver\server

                $webserverpath = $pathonly

                $registry_path = $pathonly.Replace("\wlserver\server", "") + "\inventory\registry.xml"                 # Pull out: D:\Oracle\Middleware\Oracle_Home\inventory\registry.xml
                if(Test-Path -Path $registry_path)
                {                  
                    $content = [IO.File]::ReadAllText($registry_path)                  # <distribution status="installed" name="WebLogic Server" version="12.2.1.1.0">

                    $find = [regex]"<distribution status=""installed"" name=""WebLogic Server"" version=""([0-9.]*)"
                    $match = $find.Match($content)                              # Pull out: <distribution status="installed" name="WebLogic Server" version="12.2.1.1.0">
                    $webserverversion = $match.Groups[1].Value                 # Pull out: 12.2.1.1.0
                }
            }
            catch{}

            #Try to get WebLogic patch info - from command line - using opatch
            try
            {
                $processcommandline = $process.CommandLine
                $find = [regex]"-Dweblogic.home=([a-zA-Z0-9_:\\]*)"              # Pull out: -Dweblogic.home=D:\Oracle\Middleware\Oracle_Home\wlserver\server
                $match = $find.Match($processcommandline)
                $pathonly = $match.Groups[1].Value                               # Pull out: D:\Oracle\Middleware\Oracle_Home\wlserver\server

                $webserverpath = $pathonly

                $opatch_path = $pathonly.Replace("\wlserver\server", "") + "\Opatch\opatch.bat"
                if(Test-Path -Path $opatch_path)
                { 
                    #$myargs = "lspatches"
                    #$output = & cmd /c $opatch_path $myargs 2`>`&1                   # Run: D:\Oracle\Middleware\Oracle_Home\OPatch\opatch.bat lspatches

                    #$webserverpatch = ""
                    #foreach ($line in $output)
                    #{
                    #    $webserverpatch += $line + "`r`n"
                    #}

                    $myargs = "lsinventory"
                    $output = & cmd /c $opatch_path $myargs 2`>`&1                   # Run: D:\Oracle\Middleware\Oracle_Home\OPatch\opatch.bat lsinventory

                    $webserverpatch = ""
                    foreach ($line in $output)
                    {
                        if ($line.StartsWith("OPatch detects the Middleware Home as") -or $line.StartsWith("Lsinventory Output file location"))
                        {
                            $webserverpatch += $line + "`r`n"
                        }
                        if ($line.Contains("applied on"))
                        {
                            $webserverpatch +="------------------" + "`r`n"
                        }
                        if ($line.StartsWith("Patch") -or $line.StartsWith("Unique Patch ID:"))
                        {
                            $webserverpatch += $line + "`r`n"
                        }
                    }
                }
                else
                {
                    $webserverpatch = "opatch.bat not found at: $opatch_path"
                }
            }
            catch{}

        }

        elseif($process.CommandLine -match "wasservice.exe")
        {
            $webspherecount++

            $technology = "WebSphere - wasservice.exe ($webspherecount)"

            #Try to get WebSphere version info - from executable path
            try
            {
                $processexecutablepath = $process.ExecutablePath
                $find = [regex]"([a-zA-Z0-9_:\\]*)wasservice.exe"          # Pull out: D:\IBM\Websphere\bin\wasservice.exe
                $match = $find.Match($processexecutablepath)
                $pathonly = $match.Groups[1].Value                         # Pull out: D:\IBM\Websphere\bin\

                $webserverpath = $pathonly

                $output = & "$($pathonly)versionInfo.bat"                  # Run: D:\IBM\Websphere\bin\versionInfo.bat

                $find = [regex]"IBM WebSphere Application Server Version[\s]*([0-9.]*)"
                $match = $find.Match($output)                              # Pull out: Version               8.5.5.13
                $webserverversion = $match.Groups[1].Value                 # Pull out: 8.5.5.13

                $find = [regex]"Package[\s]*([a-zA-Z0-9_\.]*)"
                $match = $find.Match($output)                              # Pull out:  Package               com.ibm.websphere.BASE.v85_8.5.5013.20180112_1418
                $webserverpatch = $match.Groups[1].Value                   # Pull out:  com.ibm.websphere.BASE.v85_8.5.5013.20180112_1418
            }
            catch{}
        }

        elseif($process.CommandLine -match "websphere")
        {
            $webspherecount++

            $technology = "WebSphere - websphere ($webspherecount)"

            #Try to get java version info - from executable path
            try
            {
                $processexecutablepath = $process.ExecutablePath           # Pull out: D:\IBM\Websphere\java\bin\java.exe
                if ($processexecutablepath.ToLower().EndsWith("java.exe") -eq $true)
                {
                    $myargs = "-version"
                    $output = & cmd /c $processexecutablepath $myargs 2`>`&1

                    $find = [regex]"java version ""[\s]*([0-9._]*)"""
                    $match = $find.Match($output)                              # Pull out: java version "1.6.0"
                    #$javaversion = $match.Groups[1].Value                      # Pull out: 1.6.0
                    $notes += $processexecutablepath + " - " + $match.Value + "`r`n"
                }
            }
            catch{}

            #Try to get WebSphere version info - from command line
            try
            {
                $processcommandline = $process.CommandLine
                $find = [regex]"-Dosgi.install.area=([a-zA-Z0-9_:\\]*)"          # Pull out: -Dosgi.install.area=D:\IBM\Websphere
                $match = $find.Match($processcommandline)
                $pathonly = $match.Groups[1].Value                               # Pull out: D:\IBM\Websphere

                $webserverpath = $pathonly

                $output = & "$($pathonly)\bin\versionInfo.bat"                   # Run: D:\IBM\Websphere\bin\versionInfo.bat              

                $find = [regex]"IBM WebSphere Application Server Version[\s]*([0-9.]*)"
                $match = $find.Match($output)                              # Pull out: Version               8.5.5.13
                $webserverversion = $match.Groups[1].Value                 # Pull out: 8.5.5.13

                $find = [regex]"Package[\s]*([a-zA-Z0-9_\.]*)"
                $match = $find.Match($output)                              # Pull out:  Package               com.ibm.websphere.BASE.v85_8.5.5013.20180112_1418
                $webserverpatch = $match.Groups[1].Value                   # Pull out:  com.ibm.websphere.BASE.v85_8.5.5013.20180112_1418
            }
            catch{}
        }

        elseif($process.CommandLine -match "tomcat")
        {
            $tomcatcount++

            $technology = "TomCat ($tomcatcount)"

            #Try to get java version info - from executable path
            try
            {
                $processexecutablepath = $process.ExecutablePath           # Pull out: C:\PROGRA~1\Java\JDK18~1.0_1\bin\java.exe
                if ($processexecutablepath.ToLower().EndsWith("java.exe") -eq $true)
                {
                    $myargs = "-version"
                    $output = & cmd /c $processexecutablepath $myargs 2`>`&1

                    $find = [regex]"java version ""[\s]*([0-9._]*)"""
                    $match = $find.Match($output)                              # Pull out: java version "x.x.x"
                    #$javaversion = $match.Groups[1].Value                      # Pull out: x.x.x
                    $notes += $processexecutablepath + " - " + $match.Value + "`r`n"
                }
            }
            catch{}

            #Try to get Tomcat version info - from command line
            try
            {
                $processcommandline = $process.CommandLine

		        # Try to find the path based on a quoted ("") Dcatalina.home value
		        if ($pathonly -eq "")
		        {
	                $find = [regex]"-Dcatalina.home=""([a-zA-Z0-9_:\\]*)"              # Pull out: -Dcatalina.home="C:\Temp\tomcat8080"
	                $match = $find.Match($processcommandline)
	                $pathonly = $match.Groups[1].Value                               # Pull out: C:\Temp\tomcat8080
		        }

		        # Try to find the path based on an unquoted Dcatalina.home value
		        if ($pathonly -eq "")
		        {
	                $find = [regex]"-Dcatalina.home=([a-zA-Z0-9_:\\]*)"              # Pull out: -Dcatalina.home=C:\Temp\tomcat8080
	                $match = $find.Match($processcommandline)
	                $pathonly = $match.Groups[1].Value                               # Pull out: C:\Temp\tomcat8080
		        }

		        # Try to find the path based on an EXE path using "\bin\tomcat"
		        if ($pathonly -eq "")
		        {
	                if ($processcommandline.ToLower().Contains("\bin\tomcat"))
	                {
	                    $pathonly = $processcommandline.Substring(0,$processcommandline.ToLower().IndexOf("\bin\tomcat"))
	                    $pathonly = $pathonly.Trim('"')
	                }
		        }

		        # Try to find the path based on an EXE path using "\bin\"
		        if ($pathonly -eq "")
		        {
	                if ($processcommandline.ToLower().Contains("\bin\"))
	                {
	                    $pathonly = $processcommandline.Substring(0,$processcommandline.ToLower().IndexOf("\bin\"))
	                    $pathonly = $pathonly.Trim('"')
	                }
		        }

                $webserverpath = $pathonly

                $catalina_path = $pathonly + "\lib\catalina.jar"
                if(Test-Path -Path $catalina_path)
                { 
                    $notes += "Catalina jar: $catalina_path" + "`r`n"

                    $myargs = "-cp", $catalina_path, "org.apache.catalina.util.ServerInfo"
                    if ($processexecutablepath.EndsWith("java.exe"))
                    {
                        $output = & cmd /c "$processexecutablepath" $myargs 2`>`&1                   # Run: java.exe -cp C:\Temp\tomcat8080\lib\catalina.jar org.apache.catalina.util.ServerInfo
                    }
                    else
                    {
                        $output = & cmd /c "java.exe" $myargs 2`>`&1                                # Run: java.exe -cp C:\Temp\tomcat8080\lib\catalina.jar org.apache.catalina.util.ServerInfo
                    }

                    $find = [regex]"Server version:[\s]*([a-zA-Z/\s]*[0-9.]*)"
                    $match = $find.Match($output)                              # Pull out: Server version: Apache Tomcat/7.0.27
                    $webserverversion = $match.Groups[1].Value                 # Pull out: Apache Tomcat/7.0.27

                    $find = [regex]"Server number:[\s]*([0-9.]*)"
                    $match = $find.Match($output)                              # Pull out: Server number: 7.0.27.0
                    $webserverpatch = $match.Groups[1].Value                   # Pull out: 7.0.27.0
                }
                else
                {
                    $webserverversion = "catalina.jar not found at: $catalina_path"
                    $webserverpatch = "catalina.jar not found at: $catalina_path"
                }
            }
            catch{}

        }

        elseif($process.CommandLine -match "jboss")
        {
            $jbosscount++

            $technology = "JBoss ($jbosscount)"

            #Try to get java version info - from executable path
            try
            {
                $processexecutablepath = $process.ExecutablePath           # Pull out: C:\Program Files\Java\jdk1.8.0_141\bin\java.exe
                if ($processexecutablepath.ToLower().EndsWith("java.exe") -eq $true)
                {
                    $myargs = "-version"
                    $output = & cmd /c $processexecutablepath $myargs 2`>`&1

                    $find = [regex]"java version ""[\s]*([0-9._]*)"""
                    $match = $find.Match($output)                              # Pull out: java version "x.x.x"
                    #$javaversion = $match.Groups[1].Value                      # Pull out: x.x.x
                    $notes += $processexecutablepath + " - " + $match.Value + "`r`n"
                }
            }
            catch{}

            #Try to get JBoss version info - from command line
            try
            {
                $processcommandline = $process.CommandLine

		        # Try to find the path based on a quoted ("") Djboss.home value
		        if ($pathonly -eq "")
		        {
                    $find = [regex]"-Djboss.home.dir=""([-.a-zA-Z0-9_:\\]*)"              # Pull out: -Djboss.home.dir="D:\temp\jboss-as-7.1.1.Final\jboss-as-7.1.1.Final"
                    $match = $find.Match($processcommandline)
                    $pathonly = $match.Groups[1].Value                               # Pull out: D:\temp\jboss-as-7.1.1.Final\jboss-as-7.1.1.Final
		        }

		        # Try to find the path based on an unquoted Dcatalina.home value
		        if ($pathonly -eq "")
		        {
                    $find = [regex]"-Djboss.home.dir=([-.a-zA-Z0-9_:\\]*)"              # Pull out: -Djboss.home.dir=D:\temp\jboss-as-7.1.1.Final\jboss-as-7.1.1.Final
                    $match = $find.Match($processcommandline)
                    $pathonly = $match.Groups[1].Value                               # Pull out: D:\temp\jboss-as-7.1.1.Final\jboss-as-7.1.1.Final
		        }

		        # Try to find the path based on an EXE path using "\bin\jboss"
		        if ($pathonly -eq "")
		        {
	                if ($processcommandline.ToLower().Contains("\bin\jboss"))
	                {
	                    $pathonly = $processcommandline.Substring(0,$processcommandline.ToLower().IndexOf("\bin\jboss"))
	                    $pathonly = $pathonly.Trim('"')
	                }
		        }

		        # Try to find the path based on an EXE path using "\bin\"
		        if ($pathonly -eq "")
		        {
	                if ($processcommandline.ToLower().Contains("\bin\"))
	                {
	                    $pathonly = $processcommandline.Substring(0,$processcommandline.ToLower().IndexOf("\bin\"))
	                    $pathonly = $pathonly.Trim('"')
	                }
		        }

                $webserverpath = $pathonly
                
                $jboss_startup_batch_path = $pathonly + "\bin\standalone.bat"       # Run:   "D:\temp\jboss-as-7.1.1.Final\jboss-as-7.1.1.Final\bin\standalone.bat"
                if(Test-Path -Path $jboss_startup_batch_path)
                { 
                    $env:nopause="true"                                              # This was set so the DOS prompt wouldn't hang on a 'pause' command
                    $myargs = "--version"
                    $output = & cmd /c $jboss_startup_batch_path $myargs 2`>`&1

                    $webserverversion = ""
                    foreach ($line in $output)
                    {
                        if ($line.StartsWith("JBoss AS"))
                        {
                            $webserverversion += $line + "`r`n"
                        }
                    }

                    $webserverpatch = $webserverversion
                }
                else
                {
                    $webserverversion = "standalone.bat not found at: $jboss_startup_batch_path"
                    $webserverpatch = "standalone.bat not found at: $jboss_startup_batch_path"
                }
            }
            catch{}

        }

        elseif($process.CommandLine -match "java.exe")
        {
            $javacount++

            $technology = "Other Java Process ($javacount)"

            #Try to get java version info - from executable path
            try
            {
                $processexecutablepath = $process.ExecutablePath           # Pull out: {path to} java.exe
                if ($processexecutablepath.ToLower().EndsWith("java.exe") -eq $true)
                {
                    $myargs = "-version"
                    $output = & cmd /c $processexecutablepath $myargs 2`>`&1

                    $find = [regex]"java version ""[\s]*([0-9._]*)"""
                    $match = $find.Match($output)                              # Pull out: java version "x.x.x"
                    #$javaversion = $match.Groups[1].Value                      # Pull out: x.x.x
                    $notes += $processexecutablepath + " - " + $match.Value + "`r`n"
                }
            }
            catch{}
            
        }


        #If we got a match, write this info to WMI/SCCM so it can be searched and reported against
        Try
        {
            if ($technology.Length -gt 0)
            {
                # Try to get local ports listening for each process
                $netstatinfo = Get-NetworkStatistics
                foreach ($port in $netstatinfo | Where-Object {$_.PID -eq $($process.ProcessId) -and $_.State -eq "LISTENING"})
                {
                    $localports += $port.LocalPort + "`r`n"
                }


                # Get other process information
                $processcaption = $process.Caption
                $processexecutablepath = $process.ExecutablePath
                $processcommandline = $process.CommandLine 

                # Print out info - debug
                #$technology                
                #$processcaption
                #$processexecutablepath
                #$processcommandline    
                #Write-Host "-----"

                #Insert to WMI
                Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
                    #WebServer - Basic Info
                    webservername = $($technology);
                    webserverpath = $webserverpath
                    webserverversion = $webserverversion;
                    webserverpatch = $webserverpatch;

                    #Process Info
                    processcaption = $processcaption;
                    processexecutablepath = $processexecutablepath;
                    processcommandline = $processcommandline;
                    localports = $localports;

                    #Misc
                    computername = $Computername;
                    os = $OS;
                    notes = $notes;
                    ScriptLastRan = $Date

                    } | Out-Null

            }
        }
        Catch {}

    }
}
Catch {}

Write-Output $True
#Write-Host "Time took: $(([DateTime]::Now - $dtStarted).TotalSeconds) seconds"


#-----------------------------------------------------------------------------------------------------------------------
#- Notes
#-----------------------------------------------------------------------------------------------------------------------


# To fix, remove class
#    $NewClassName = 'Win32_WebServers_Custom'
#    Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# To view:
#   Get-WmiObject -Class Win32_WebServers_Custom -Namespace root/cimv2

# Online Regex Helper
# https://regex101.com/
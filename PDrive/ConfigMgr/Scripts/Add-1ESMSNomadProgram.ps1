############################
#
# Description: This script will connect to a ConfigMgr site and add programs to an existing package for OSD Deployments
# Author: Daniel Ratliff
# Date: 4/18/13
# 
############################

$server = "LOUAPPWPS875"
$site = "CAS"
$prgflags = 135308288

write-host ""
write-host "Connected to server: " -nonewline; write-host $server -foregroundcolor cyan
write-host "Connected to site: " -nonewline; write-host $site -foreground cyan
write-host ""
write-host "Querying the site server for packages and programs..." -foregroundcolor yellow

$packages = Get-WmiObject SMS_Package -computername $server -Namespace root\SMS\site_$site
$programs = Get-WmiObject SMS_Program -computername $server -Namespace root\SMS\site_$site
$taskseqs = Get-WmiObject SMS_TaskSequencePackage -ComputerName $server -Namespace root\sms\site_$site -property Name,PackageID | select-object Name,PackageID

function choice {
    write-host ""
    write-host "#####################################################"
    write-host "1" -foregroundcolor cyan -nonewline;write-host " - List all Packages"
    write-host "2" -foregroundcolor cyan -nonewline;write-host " - Add SMSNomad program to a package"
    write-host "3" -foregroundcolor cyan -nonewline;write-host " - Add OSD program to a package"
    write-host "4" -ForegroundColor cyan -NoNewline;write-host " - Capitalize all programs on a package"
    write-host "5" -ForegroundColor cyan -NoNewline;write-host " - Reference software packages for a Task Sequence"
    write-host "6" -ForegroundColor cyan -NoNewline;write-host " - Exit"
    write-host "#####################################################"
    write-host ""
    write-host "Enter your choice: " -foregroundcolor cyan -nonewline;
    $choice = read-host
    write-host ""
    switch ($choice) {
        1 {
            $packages| select manufacturer, name, version, packageid | sort manufacturer,name
            choice
        }
        2 {
            write-host "Enter your Package ID to modify: " -foregroundcolor cyan -nonewline;
            $pkgid = Read-host
            $pkgmfg = ($packages | where {$_.packageid -eq $pkgid}).Manufacturer
            $pkgname = ($packages | where {$_.packageid -eq $pkgid}).Name
            $pkgversion = ($packages | where {$_.packageid -eq $pkgid}).Version
            write-host ""
            write-host "You chose: " -foregroundcolor cyan -nonewline; write-host $pkgid
            write-host "Package Title: " -foregroundcolor cyan -nonewline;write-host $pkgmfg" "$pkgname" "$pkgversion
            $copyprog = $programs | where {$_.packageid -eq $pkgid} | select ProgramName,CommandLine
            $copyprog
            if ($copyprog.count -eq 0) {
                write-host "No programs found!"-foregroundcolor red
                start-sleep -seconds 3
            } elseif ($copyprog.count -eq 1) {
                $cmdline = ($programs | where {$_.packageid -eq $pkgid}).commandline
                if ($cmdline -like "*.vbs*") {
                    $cmdline = "cscript " + $cmdline
                }
                $arguments = @{
                    PackageID = $pkgID;
                    ProgramFlags = $prgflags;
                    ProgramName = "HUMINST-SMSNomad";
                    CommandLine = "SMSNomad.exe " + $cmdline;
                    Duration = 120
                }
            } elseif ($copyprog.count -gt 1) {
                write-host ""
                write-host "Please type the ProgramName to copy: " -foregroundcolor cyan -nonewline;
                $progchoice = read-host
                $cmdline = ($programs | where {$_.packageid -eq $pkgid -and $progchoice -eq $_.programname}).commandline
                if ($cmdline -eq "*.vbs*") {
                    $cmdline = "cscript " + $cmdline
                }
                $arguments = @{
                    PackageID = $pkgID;
                    ProgramFlags = $prgflags;
                    ProgramName = "HUMINST-SMSNomad";
                    CommandLine = "SMSNomad.exe " + $cmdline;
                    Duration = 120
                }
            }
            write-host ""
            write-host "Adding SMSNomad program to package"$pkgid"..." -foregroundcolor green
            Set-wmiinstance SMS_Program -arguments $arguments -computername $server -namespace root\SMS\site_$site
            choice
            }
        3 {
            write-host "Enter your Package ID to modify: " -foregroundcolor cyan -nonewline;
            $pkgid = Read-host
            $pkgmfg = ($packages | where {$_.packageid -eq $pkgid}).Manufacturer
            $pkgname = ($packages | where {$_.packageid -eq $pkgid}).Name
            $pkgversion = ($packages | where {$_.packageid -eq $pkgid}).Version
            write-host ""
            write-host "You chose: " -foregroundcolor cyan -nonewline; write-host $pkgid
            write-host "Package Title: " -foregroundcolor cyan -nonewline;write-host $pkgmfg" "$pkgname" "$pkgversion
            $copyprog = $programs | where {$_.packageid -eq $pkgid} | select ProgramName,CommandLine
            $copyprog
            if ($copyprog.count -eq 0) {
                write-host "No programs found!"-foregroundcolor red
                start-sleep -seconds 3
            } elseif ($copyprog.count -eq 1) {
                $cmdline = ($programs | where {$_.packageid -eq $pkgid}).commandline
                if ($cmdline -like "*.vbs*") {
                    $cmdline = "cscript " + $cmdline
                }
                $arguments = @{
                    PackageID = $pkgID;
                    ProgramFlags = $prgflags;
                    ProgramName = "HUMINST-OSD";
                    CommandLine = $cmdline;
                    Duration = 120
                }
            } elseif ($copyprog.count -gt 1) {
                write-host ""
                write-host "Please type the ProgramName to copy: " -foregroundcolor cyan -nonewline;
                $progchoice = read-host
                $cmdline = ($programs | where {$_.packageid -eq $pkgid -and $progchoice -eq $_.programname}).commandline
                if ($cmdline -like "*.vbs*") {
                    $cmdline = "cscript " + $cmdline
                }
                $arguments = @{
                    PackageID = $pkgID;
                    ProgramFlags = $prgflags;
                    ProgramName = "HUMINST-OSD";
                    CommandLine = $cmdline;
                    Duration = 120
                }
            }
            write-host ""
            write-host "Adding OSD program to package"$pkgid"..." -foregroundcolor green
            Set-wmiinstance SMS_Program -arguments $arguments -computername $server -namespace root\SMS\site_$site
            choice
            }
        4 {
            write-host "Enter your Package ID to modify: " -foregroundcolor cyan -nonewline;
            $pkgid = Read-host
            $pkgmfg = ($packages | where {$_.packageid -eq $pkgid}).Manufacturer
            $pkgname = ($packages | where {$_.packageid -eq $pkgid}).Name
            $pkgversion = ($packages | where {$_.packageid -eq $pkgid}).Version
            write-host ""
            write-host "You chose: " -foregroundcolor cyan -nonewline; write-host $pkgid
            write-host "Package Title: " -foregroundcolor cyan -nonewline;write-host $pkgmfg" "$pkgname" "$pkgversion
            $programs | where {$_.packageid -eq $pkgid} | select ProgramName,CommandLine
            write-host "`n"
            $capprogs = $programs | where {$_.packageid -eq $pkgid}
            if ($capprogs.count -eq 0) {
                write-host "No programs found!"-foregroundcolor red
                start-sleep -seconds 3
            } elseif ($capprogs.count -ge 1) {
                foreach ($prog in $capprogs) {
                    $progname = $prog.programname
                    write-host "Old Program Name: $progname"
                    $newprogname = $progname.toupper()
                    write-host "New Program Name: $newprogname"
                    $prog.ProgramName = $newprogname
                    write-host "Program: "$prog.programname
                    $prog.psbase.put()
                }
            }
            choice
        }
        5 {
            $taskseqs
            write-host ""
            write-host "Enter your Task Sequence ID to modify: " -ForegroundColor cyan -NoNewline;
            $tsid = Read-Host
            $softpkgs = Get-WmiObject -ComputerName $server -Namespace root\sms\site_$site -class sms_tasksequencepackagereference | where {$_.packageid -eq $tsid -and $_.objecttype -eq 0}
            $softpkgs | select-object ObjectName,ObjectID | Sort-Object ObjectName
            choice
        }
        6 {
            write-host "Goodbye!" -ForegroundColor cyan
            start-sleep -seconds 3
            exit
        }
        default { 
            write-host "Invalid Choice. Try again. " -foregroundcolor red
            start-sleep -seconds 2
            choice
        }
    }
}

choice
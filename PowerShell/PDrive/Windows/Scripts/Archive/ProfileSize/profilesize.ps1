#--------------------------------------------
# Humana ProfileSize 1.0
# OS Platform: Windows XP, Windows 7 
# PoSH Platform: 3.0
# This script will parse the users directories and return the ...
#
# Date: 03/28/2013
# Author: Daniel Ratliff
# Team: Client Innovation Technologies
#--------------------------------------------

$erroractionpreference = "silentlycontinue"
$os = (get-wmiobject win32_operatingsystem).caption

if ($os.contains("Windows XP")) {
    write-host ""
    write-host "Operating System is " -nonewline; write-host "Windows XP" -foregroundcolor green
    write-host ""
    $userroot = "c:\documents and settings"
    
} elseif ($os.contains("Windows 7")) {
    write-host ""
    write-host "Operating System is " -nonewline; write-host "Windows 7" -foregroundcolor green
    write-host ""
    $userroot = "c:\users"
    $users = get-childitem $userroot -force -directory
    foreach ($user in $users) {
        $userdir = $user.fullname
        write-host "User directory: " -foregroundcolor cyan -nonewline; write-host $userdir
        write-host "Total directory size: " -foregroundcolor cyan -nonewline;
        $dirlength = (Get-ChildItem $userdir -recurse -force | Measure-Object -property length -sum)
        $dirsum = ($dirlength.sum / 1MB)
        $dirsize = "{0:N1}" -f $dirsum + " MB"
        write-host $dirsize
        write-host ""
        if ($dirsize -ne "0.0 MB") {
            $subfolder = get-childitem $userdir -force -directory
            foreach ($folder in $subfolder) {
                write-host "Sub directory: "  -nonewline; write-host $folder.fullname
                write-host "Sub directory size: " -nonewline;
                $subdirlength = (Get-ChildItem $folder -recurse -force | Measure-Object -property length -sum)
                $subdirsum = ($subdirlength.sum / 1MB)
                $subdirsize = "{0:N1}" -f $subdirsum + " MB"
                write-host $subdirsize
            }
        }
        write-host "-----------------"
    }
} else {
    write-host ""
    write-host "***Operating system cannot be determined!***" -foregroundcolor red
    write-host "Exiting..."
    start-sleep -seconds 5
}
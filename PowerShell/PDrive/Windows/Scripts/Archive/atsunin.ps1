#--------------------------------
#
# Humana Inc
#
# Title: ATS PowerShell Uninstallation template
#
# Author: Daniel Ratliff
# Create Date: 11/28/2011
#
#--------------------------------

#set error preference
$erroractionpreference = "Continue"

#set variables
$filepath = ""
$arguments = ""

#Start uninstallation
Start-Process -FilePath $filepath -ArgumentList $arguments -Wait -verbose:$true
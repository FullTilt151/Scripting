#--------------------------------
#
# Humana Inc
#
# Title: ATS PowerShell Installation template
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

#Start installation
Start-Process -FilePath $filepath -ArgumentList $arguments -Wait -verbose:$true
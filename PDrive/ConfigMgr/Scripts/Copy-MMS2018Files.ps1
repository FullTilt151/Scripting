﻿##############################################
#                                            #
# File:     Copymms2018Files.ps1             #
# Author:   Duncan Russell                   #
#           http://www.sysadmintechnotes.com #
# Edited:   Andrew Johnson                   #
#           http://www.andrewj.net           #
#           Evan Yeung                       #
#           http://www.forevanyeung.com      #
#           Chris Kibble                     #
#           http://www.christopherkibble.com #
#           Jon Warnken                      #
#           http://www.mrbodean.net          #
#                                            #
##############################################

$baseLocation = '\\wkmj059g4b\shared\Documentation'
Clear-Host
Add-Type -AssemblyName System.Web
$web = Invoke-WebRequest 'https://mms2018.sched.com/login' -SessionVariable mms
$c = $host.UI.PromptForCredential('Sched Credentials', 'Enter Credentials', '', '')
$form = $web.Forms[1]
$form.fields['username'] = $c.UserName
$form.fields['password'] = $c.GetNetworkCredential().Password
"Logging in..."

$mmsHome = Invoke-WebRequest 'https://mms2018.sched.org/' -WebSession $mms

$htmlDate = $mmsHome.ParsedHtml.IHTMLDocument3_GetElementById('sched-sidebar-filters-dates')
$htmlPopoverBody = $htmlDate.getElementsByClassName('popover')
$htmlDateList = $htmlPopoverBody[0].getElementsByTagName('li')

$MMSDates = @()
$htmlDateList | ForEach-Object { 
    out-null -InputObject  $($_.innerHTML -match "\d{4}-\d{2}-\d{2}")
    $MMSDates += $matches[0]
}

$web = Invoke-WebRequest 'https://mms2018.sched.com/login' -WebSession $mms -Method POST -Body $form.Fields
if(-Not ($web.InputFields.FindByName("login"))) {
    ForEach ($Date in $MMSDates) {
        "Checking day '{0}' for downloads" -f $Date

        $sched = Invoke-WebRequest -Uri $("https://mms2018.sched.org/" + $Date + "/list/descriptions") -WebSession $mms
        $links = $sched.Links

        $eventsIndex = @()
        $links | ForEach-Object { if(($_.href -like "*/event/*") -and ($_.innerText -notlike "here")) { 
            $eventsIndex += (, ($links.IndexOf($_), $_.innerText))
        } }

        $i = 0
        While($i -lt $eventsIndex.Count) {
            $eventTitle = $eventsIndex[$i][1]
            $eventTitle = $eventTitle -replace "[^A-Za-z0-9-_. ]", ""
            $eventTitle = $eventTitle.Trim()
            $eventTitle = $eventTitle -replace "\W+", "_"

            $links[$eventsIndex[$i][0]..$(if($i -eq $eventsIndex.Count - 1) {$links.Count-1} else {$eventsIndex[$i+1][0]})] | ForEach-Object { 
                if($_.href -like "*hosted_files*") { 
                    $downloadPath = $baseLocation + '\mms2018\' + $Date + '\' + $eventTitle
                    $filename = $_.href
                    $filename = $filename.substring(40)
                    
                    # Replace HTTP Encoding Characters (e.g. %20) with the proper equivalent.
                    $filename = [System.Web.HttpUtility]::UrlDecode($filename)
                    
                    # Replace non-standard characters
                    $filename = $filename -replace "[^A-Za-z0-9\.\-_ ]", ""
                                        
                    $outputFilePath = $downloadPath + '\' + $filename

                    # Reduce Total Path to 255 characters.
                    $outputFilePathLen = $outputFilePath.Length

                    If($outputFilePathLen -ge 255) { 
                        $fileExt = [System.IO.Path]::GetExtension($outputFilePath)
                        $newFileName = $outputFilePath.Substring(0,$($outputFilePathLen - $fileExt.Length))
                        $newFileName = $newFileName.Substring(0, $(255 - $fileExt.Length)).trim()
                        $newFileName = "$newFileName$fileExt"
                        $outputFilePath = $newFileName
                    }

                    if((Test-Path -Path $($downloadPath)) -eq $false) { New-Item -ItemType Directory -Force -Path $downloadPath | Out-Null }
                    if((Test-Path -Path $outputFilePath) -eq $false)
                    {
                        "...attempting to download '{0}'" -f $filename
                        Invoke-WebRequest -Uri $_.href -OutFile $outputfilepath -WebSession $mms
                        Unblock-File $outputFilePath
                    }
                } 
            }

            $i++
        }
    }
} else {
    "Login failed. Exiting script."
}

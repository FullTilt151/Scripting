param ([string]$ObjectId,
[int]$FeatureType
)

############################################
#
# Change for your own environment
#
$SiteCode = "CAS"
$SiteServer = "LOUAPPWPS875"
#
############################################

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#region Constants

#Feature types:
$FeatureTypes = @()
$FeatureTypes += "Unknown"
$FeatureTypes += "Application"
$FeatureTypes += "Program"
$FeatureTypes += "Invalid"
$FeatureTypes += "Invalid"
$FeatureTypes += "Software Update"
$FeatureTypes += "Invalid"
$FeatureTypes += "Task Sequence"

$OfferTypes = @("Required", "Not Used", "Available")

#endregion

#region Functions

function ConvertDateString([string]$DateTimeString){
    $format = "yyyyMMddHHmm"
    $return = [datetime]::ParseExact(([string]($DateTimeString.Substring(0,12))), $format, $null).ToString()
    return $return
}

#endregion

#SUG
#SELECT * FROM SMS_updateGroupAssignment WHERE AssignedUpdateGroup = ##SUB:CI_ID##

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects

$lblDeploymentType = New-Object System.Windows.Forms.Label
$label9 = New-Object System.Windows.Forms.Label
$lblSoftwareID = New-Object System.Windows.Forms.Label
$btnApprove = New-Object System.Windows.Forms.Button
$label18 = New-Object System.Windows.Forms.Label
$dtpDeploymentTime = New-Object System.Windows.Forms.DateTimePicker
$dtpAvailableTime = New-Object System.Windows.Forms.DateTimePicker
$lblNumberOfTargets = New-Object System.Windows.Forms.Label
$lblCollectionID = New-Object System.Windows.Forms.Label
$label13 = New-Object System.Windows.Forms.Label
$lblCollectionName = New-Object System.Windows.Forms.Label
$lblSoftwareSize = New-Object System.Windows.Forms.Label
$lblSoftwareType = New-Object System.Windows.Forms.Label
$lblSoftwareName = New-Object System.Windows.Forms.Label
$label8 = New-Object System.Windows.Forms.Label
$label7 = New-Object System.Windows.Forms.Label
$label6 = New-Object System.Windows.Forms.Label
$label5 = New-Object System.Windows.Forms.Label
$label4 = New-Object System.Windows.Forms.Label
$label3 = New-Object System.Windows.Forms.Label
$label2 = New-Object System.Windows.Forms.Label
$label1 = New-Object System.Windows.Forms.Label
$btnClose = New-Object System.Windows.Forms.Button
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#region form events
#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$btnClose_OnClick= 
{
    $form1.Close()
}

$btnApprove_OnClick= 
{
    $newAvailableTime = [datetime]($dtpAvailableTime.Value)
    $newDeploymentTime = [datetime]($dtpDeploymentTime.Value)
    if($newAvailableTime -ge $newDeploymentTime){
        [void][System.Windows.Forms.MessageBox]::Show("Deployment time must be later than available time." , "Validation Error")
        return $null
    }
    if($newAvailableTime -le (([datetime](get-date)).AddDays(-1)) ) {
        [void][System.Windows.Forms.MessageBox]::Show("Available time cannot be later than current time minus one day" , "Validation Error")
        return $null
    }

    #It is valid, get a login for approval
    $cred = Get-credential -Message "Please authenticate to approve this required deployment:"
    if($cred -eq $null){
        return $null
    }

    try{
    [string]$newAvailableTime = $newAvailableTime.ToString("yyyyMMddHHmmss") + ".000000+***"
    [string]$newDeploymentTime = $newDeploymentTime.ToString("yyyyMMddHHmmss") + ".000000+***"

    $ScheduleTime = ([WMIClass] "\\$SiteServer\root\sms\site_$($SiteCode)`:SMS_ST_NonRecurring").CreateInstance() 
    $ScheduleTime.DayDuration = 0
    $ScheduleTime.HourDuration = 0
    $ScheduleTime.MinuteDuration = 0
    $ScheduleTime.IsGMT = "false"
    $ScheduleTime.StartTime = $newDeploymentTime
    
    $newAdvertisement = ([WMIClass] "\\$SiteServer\root\sms\site_$($SiteCode)`:SMS_Advertisement").CreateInstance() 
    $newAdvertisement.AdvertFlags = $advertisement.AdvertFlags
    $newAdvertisement.AdvertisementName = $advertisement.AdvertisementName
    $newAdvertisement.CollectionID = $advertisement.CollectionID
    $newAdvertisement.PackageID = $advertisement.PackageID
    $newAdvertisement.AssignedSchedule = $ScheduleTime
    $newAdvertisement.DeviceFlags = $advertisement.DeviceFlags
    $newAdvertisement.ProgramName = $advertisement.ProgramName
    $newAdvertisement.RemoteClientFlags = $advertisement.RemoteClientFlags
    $newAdvertisement.PresentTime = $newAvailableTime
    $newAdvertisement.SourceSite = $advertisement.SourceSite
    $newAdvertisement.TimeFlags = $advertisement.TimeFlags
    $newAdvertisement.Comment = "$($advertisement.Comment)`r`nApproved by: $($cred.UserName.ToUpper())"

    # Apply Advertisement
    [wmi]$advCreated = $newAdvertisement.put()

    $newAdvertisementID = $advCreated.AdvertisementID
    [void][System.Windows.Forms.MessageBox]::Show("Required deployment created.`nNew DeploymentID: $($newAdvertisementID)" , "Success")
    }
    catch [system.exception]
    {
        $Error[0] | fl * -Force -OutVariable errorText
        [void][System.Windows.Forms.MessageBox]::Show("Failed to create deployment.`nI am really sorry about that.`nError: $($errorText)" , "Error")
        return $null
    }
    $advertisement.Delete()
    $form1.Close()

}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#endregion

#region Generated Form Code
$form1 = New-Object System.Windows.Forms.Form
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 526
$System_Drawing_Size.Width = 805
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.Text = "Deployment Approval"

$lblDeploymentType.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 241
$System_Drawing_Point.Y = 409
$lblDeploymentType.Location = $System_Drawing_Point
$lblDeploymentType.Name = "lblDeploymentType"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 167
$lblDeploymentType.Size = $System_Drawing_Size
$lblDeploymentType.TabIndex = 28
$lblDeploymentType.Text = "Avail/Req"

$form1.Controls.Add($lblDeploymentType)

$label9.DataBindings.DefaultDataSourceUpdateMode = 0
$label9.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 86
$System_Drawing_Point.Y = 409
$label9.Location = $System_Drawing_Point
$label9.Name = "label9"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 114
$label9.Size = $System_Drawing_Size
$label9.TabIndex = 27
$label9.Text = "Deploy Type:"
$label9.TextAlign = 4

$form1.Controls.Add($label9)

$lblSoftwareID.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 241
$System_Drawing_Point.Y = 116
$lblSoftwareID.Location = $System_Drawing_Point
$lblSoftwareID.Name = "lblSoftwareID"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 314
$lblSoftwareID.Size = $System_Drawing_Size
$lblSoftwareID.TabIndex = 22
$lblSoftwareID.Text = "Software ID"

$form1.Controls.Add($lblSoftwareID)

$btnApprove.BackColor = [System.Drawing.Color]::FromArgb(255,0,128,0)

$btnApprove.DataBindings.DefaultDataSourceUpdateMode = 0
$btnApprove.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",13.8,1,3,1)
$btnApprove.ForeColor = [System.Drawing.Color]::FromArgb(255,0,255,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 264
$System_Drawing_Point.Y = 475
$btnApprove.Location = $System_Drawing_Point
$btnApprove.Name = "btnApprove"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 39
$System_Drawing_Size.Width = 235
$btnApprove.Size = $System_Drawing_Size
$btnApprove.TabIndex = 21
$btnApprove.Text = "Approve"
$btnApprove.UseVisualStyleBackColor = $False
$btnApprove.add_Click($btnApprove_OnClick)

$form1.Controls.Add($btnApprove)

$label18.DataBindings.DefaultDataSourceUpdateMode = 0
$label18.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 117
$label18.Location = $System_Drawing_Point
$label18.Name = "label18"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 115
$label18.Size = $System_Drawing_Size
$label18.TabIndex = 20
$label18.Text = "Software ID:"
$label18.TextAlign = 4

$form1.Controls.Add($label18)

$dtpDeploymentTime.CustomFormat = "MM/dd/yyyy HH:mm"
$dtpDeploymentTime.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 369
$dtpDeploymentTime.Location = $System_Drawing_Point
$dtpDeploymentTime.Name = "dtpDeploymentTime"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 168
$dtpDeploymentTime.Size = $System_Drawing_Size
$dtpDeploymentTime.TabIndex = 19

$form1.Controls.Add($dtpDeploymentTime)

$dtpAvailableTime.CustomFormat = "MM/dd/yyyy HH:mm"
$dtpAvailableTime.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 332
$dtpAvailableTime.Location = $System_Drawing_Point
$dtpAvailableTime.Name = "dtpAvailableTime"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 168
$dtpAvailableTime.Size = $System_Drawing_Size
$dtpAvailableTime.TabIndex = 18

$form1.Controls.Add($dtpAvailableTime)

$lblNumberOfTargets.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 293
$lblNumberOfTargets.Location = $System_Drawing_Point
$lblNumberOfTargets.Name = "lblNumberOfTargets"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblNumberOfTargets.Size = $System_Drawing_Size
$lblNumberOfTargets.TabIndex = 15
$lblNumberOfTargets.Text = "Collection Total"

$form1.Controls.Add($lblNumberOfTargets)

$lblCollectionID.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 259
$lblCollectionID.Location = $System_Drawing_Point
$lblCollectionID.Name = "lblCollectionID"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblCollectionID.Size = $System_Drawing_Size
$lblCollectionID.TabIndex = 14
$lblCollectionID.Text = "CollectionID"

$form1.Controls.Add($lblCollectionID)

$label13.DataBindings.DefaultDataSourceUpdateMode = 0
$label13.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 259
$label13.Location = $System_Drawing_Point
$label13.Name = "label13"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 116
$label13.Size = $System_Drawing_Size
$label13.TabIndex = 13
$label13.Text = "Collection ID:"
$label13.TextAlign = 4

$form1.Controls.Add($label13)

$lblCollectionName.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 221
$lblCollectionName.Location = $System_Drawing_Point
$lblCollectionName.Name = "lblCollectionName"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 529
$lblCollectionName.Size = $System_Drawing_Size
$lblCollectionName.TabIndex = 12
$lblCollectionName.Text = "Collection Name"

$form1.Controls.Add($lblCollectionName)

$lblSoftwareSize.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 186
$lblSoftwareSize.Location = $System_Drawing_Point
$lblSoftwareSize.Name = "lblSoftwareSize"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblSoftwareSize.Size = $System_Drawing_Size
$lblSoftwareSize.TabIndex = 11
$lblSoftwareSize.Text = "Software Size"

$form1.Controls.Add($lblSoftwareSize)

$lblSoftwareType.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 149
$lblSoftwareType.Location = $System_Drawing_Point
$lblSoftwareType.Name = "lblSoftwareType"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblSoftwareType.Size = $System_Drawing_Size
$lblSoftwareType.TabIndex = 10
$lblSoftwareType.Text = "Software Type"

$form1.Controls.Add($lblSoftwareType)

$lblSoftwareName.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 240
$System_Drawing_Point.Y = 84
$lblSoftwareName.Location = $System_Drawing_Point
$lblSoftwareName.Name = "lblSoftwareName"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 529
$lblSoftwareName.Size = $System_Drawing_Size
$lblSoftwareName.TabIndex = 9
$lblSoftwareName.Text = "Software Name"

$form1.Controls.Add($lblSoftwareName)

$label8.DataBindings.DefaultDataSourceUpdateMode = 0
$label8.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 187
$label8.Location = $System_Drawing_Point
$label8.Name = "label8"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 117
$label8.Size = $System_Drawing_Size
$label8.TabIndex = 8
$label8.Text = "Software Size:"
$label8.TextAlign = 4

$form1.Controls.Add($label8)

$label7.DataBindings.DefaultDataSourceUpdateMode = 0
$label7.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 369
$label7.Location = $System_Drawing_Point
$label7.Name = "label7"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 118
$label7.Size = $System_Drawing_Size
$label7.TabIndex = 7
$label7.Text = "Deploy Time:"
$label7.TextAlign = 4

$form1.Controls.Add($label7)

$label6.DataBindings.DefaultDataSourceUpdateMode = 0
$label6.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 332
$label6.Location = $System_Drawing_Point
$label6.Name = "label6"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 119
$label6.Size = $System_Drawing_Size
$label6.TabIndex = 6
$label6.Text = "Available Time:"
$label6.TextAlign = 4

$form1.Controls.Add($label6)

$label5.DataBindings.DefaultDataSourceUpdateMode = 0
$label5.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 293
$label5.Location = $System_Drawing_Point
$label5.Name = "label5"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 120
$label5.Size = $System_Drawing_Size
$label5.TabIndex = 5
$label5.Text = "# of Targets:"
$label5.TextAlign = 4

$form1.Controls.Add($label5)

$label4.DataBindings.DefaultDataSourceUpdateMode = 0
$label4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 222
$label4.Location = $System_Drawing_Point
$label4.Name = "label4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 121
$label4.Size = $System_Drawing_Size
$label4.TabIndex = 4
$label4.Text = "Collection:"
$label4.TextAlign = 4

$form1.Controls.Add($label4)

$label3.DataBindings.DefaultDataSourceUpdateMode = 0
$label3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 79
$System_Drawing_Point.Y = 150
$label3.Location = $System_Drawing_Point
$label3.Name = "label3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 121
$label3.Size = $System_Drawing_Size
$label3.TabIndex = 3
$label3.Text = "Software Type:"
$label3.TextAlign = 4

$form1.Controls.Add($label3)

$label2.DataBindings.DefaultDataSourceUpdateMode = 0
$label2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 48
$System_Drawing_Point.Y = 84
$label2.Location = $System_Drawing_Point
$label2.Name = "label2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 152
$label2.Size = $System_Drawing_Size
$label2.TabIndex = 2
$label2.Text = "Software Name:"
$label2.TextAlign = 4

$form1.Controls.Add($label2)

$label1.DataBindings.DefaultDataSourceUpdateMode = 0
$label1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",16.2,1,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 302
$System_Drawing_Point.Y = 9
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 46
$System_Drawing_Size.Width = 305
$label1.Size = $System_Drawing_Size
$label1.TabIndex = 1
$label1.Text = "Deployment Appoval"

$form1.Controls.Add($label1)


$btnClose.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 602
$System_Drawing_Point.Y = 475
$btnClose.Location = $System_Drawing_Point
$btnClose.Name = "btnClose"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 39
$System_Drawing_Size.Width = 82
$btnClose.Size = $System_Drawing_Size
$btnClose.TabIndex = 0
$btnClose.Text = "Close"
$btnClose.UseVisualStyleBackColor = $True
$btnClose.add_Click($btnClose_OnClick)

$form1.Controls.Add($btnClose)

#endregion Generated Form Code

#region Gather deployment info

$feature = [string]$FeatureTypes[$FeatureType]

$deploymentID = $ObjectId
$deploymentSummary = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_deploymentsummary -Filter "deploymentid = '$deploymentID'"
$collectionID = $deploymentSummary.CollectionID
#$numberTargeted = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "select ResourceID from SMS_CM_RES_COLL_$($collectionID)" | Measure-Object).count
$numberTargeted = (Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($collectionID)'" | Measure-Object).count
$collectionName = $deploymentSummary.CollectionName
$softwareName = $deploymentSummary.SoftwareName
$availableTime = ConvertDateString -DateTimeString "$($deploymentSummary.DeploymentTime)"

$advertisement = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_advertisement -Filter "advertisementid = '$deploymentID'"
$deploymentOfferType = $OfferTypes[$($advertisement.OfferType)]
$IsAvailableEnforced = [bool]($advertisement.PresentTimeEnabled)
$adv1 = [wmi]"$($advertisement.__PATH)"
$deployAssignmentDates = @()
$schedTokens = $adv1.AssignedSchedule
foreach($sched in $schedTokens) {
    $deployAssignmentDates += ([string]$sched.StartTime).Substring(0,12)
}
$deployAssignmentDates | Sort-Object -OutVariable deployAssignmentDates | Out-Null
if($deploymentOfferType -eq "Required"){
    $deploymentTime = ConvertDateString -DateTimeString "$($deployAssignmentDates[0])"
} else {
    $deploymentTime = $availableTime
}
#Gather deployed object information based on what was deployed
switch ($feature)
    {
        "Program" {
            $packageID = $deploymentSummary.PackageID
            $package = Get-WmiObject -ComputerName $SiteServer -Namespace "root\sms\site_$SiteCode" -class sms_package -Filter "packageid = '$packageID'"
            $packageSize = "$([math]::Round(($package.PackageSize / 1024), 1)) MB"
        }
        "Application" {}
        "Software Update" {}
        "Task Sequence" {}
    }

#endregion

#region Set form values


$dtpAvailableTime.Format = [windows.forms.datetimepickerFormat]::custom 
$dtpAvailableTime.CustomFormat = "MM/dd/yyyy HH:mm" 

$dtpDeploymentTime.Format = [windows.forms.datetimepickerFormat]::custom 
$dtpDeploymentTime.CustomFormat = "MM/dd/yyyy HH:mm" 

$form1.MinimizeBox = $False
$form1.MaximizeBox = $False
$form1.StartPosition = "CenterScreen"
$form1.TopMost = $True

$lblSoftwareName.Text = $softwareName
$lblSoftwareID.Text = $packageID #TODO: fix for TS and such?
$lblSoftwareType.Text = $feature
$lblSoftwareSize.Text = $packageSize
$lblCollectionName.Text = $collectionName
$lblCollectionID.Text = $collectionID
$lblNumberOfTargets.Text = $numberTargeted
$dtpAvailableTime.Value = $availableTime
$dtpDeploymentTime.Value = $deploymentTime
$lblDeploymentType.Text = $deploymentOfferType

if($deploymentOfferType -eq "Required"){
    $btnApprove.Enabled = $False
    $btnApprove.Visible = $False
    $dtpAvailableTime.Enabled = $False
    $dtpDeploymentTime.Enabled = $False
}
#endregion

#region Show the form
#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null
#endregion

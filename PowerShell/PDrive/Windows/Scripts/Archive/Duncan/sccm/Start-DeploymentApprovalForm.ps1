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

#region Import the Assemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
#Will load ConfigrationManager.psd1 in the code block $DeploymentInfoScriptBlock (so the form will be visible first)

#endregion

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

#hash table with bit flag definitions
$flags = @{
	IMMEDIATE = "0x00000020";
	ONSYSTEMSTARTUP = "0x00000100";
	ONUSERLOGON = "0x00000200";
	ONUSERLOGOFF = "0x00000400";
	WINDOWS_CE = "0x00008000";
	ENABLE_PEER_CACHING = "0x00010000";
	DONOT_FALLBACK = "0x00020000";
	ENABLE_TS_FROM_CD_AND_PXE = "0x00040000";
	OVERRIDE_SERVICE_WINDOWS = "0x00100000";
	REBOOT_OUTSIDE_OF_SERVICE_WINDOWS = "0x00200000";
	WAKE_ON_LAN_ENABLED = "0x00400000";
	SHOW_PROGRESS = "0x00800000";
	NO_DISPLAY = "0x02000000";
	ONSLOWNET = "0x04000000";                  
}

$remoteClientFlags = @{
	BATTERY_POWER = "0x00000001";
	RUN_FROM_CD	= "0x00000002";
	DOWNLOAD_FROM_CD = "0x00000004";
	RUN_FROM_LOCAL_DISPPOINT = "0x00000008";
	DOWNLOAD_FROM_LOCAL_DISPPOINT = "0x00000010";
	DONT_RUN_NO_LOCAL_DISPPOINT = "0x00000020";
	DOWNLOAD_FROM_REMOTE_DISPPOINT = "0x00000040";
	RUN_FROM_REMOTE_DISPPOINT = "0x00000080";
	DOWNLOAD_ON_DEMAND_FROM_LOCAL_DP = "0x00000100";
	DOWNLOAD_ON_DEMAND_FROM_REMOTE_DP = "0x00000200";
	BALLOON_REMINDERS_REQUIRED = "0x00000400";
	RERUN_ALWAYS = "0x00000800";
	RERUN_NEVER = "0x00001000";
	RERUN_IF_FAILED = "0x00002000";
	RERUN_IF_SUCCEEDED = "0x00004000";
	PERSIST_ON_WRITE_FILTER_DEVICES	 = "0x00008000";
	DONT_FALLBACK = "0x00020000";
	DP_ALLOW_METERED_NETWORK = "0x00040000";
}

$RerunBehaviors = @{
    RERUN_ALWAYS = "Always rerun program";
    RERUN_NEVER = "Never rerun deployed program";
    RERUN_IF_FAILED = "Rerun if failed previous attempt";
    RERUN_IF_SUCCEEDED = "Rerun if succeeded on previous attempt";

}

$FastDPOptions = @{
    RUN_FROM_LOCAL_DISPPOINT = "Run program from distribution point";
    DOWNLOAD_FROM_LOCAL_DISPPOINT = "Download content from distribution point and run locally"
}

$SlowDPOptions = @{
    DOWNLOAD_FROM_REMOTE_DISPPOINT = "Download content from distribution point and run locally";
    DONT_RUN_NO_LOCAL_DISPPOINT = "Do not run program"
}

$SlowDPOptionsWithRunFromDP = @{
    DOWNLOAD_FROM_REMOTE_DISPPOINT = "Download content from distribution point and run locally";
    DONT_RUN_NO_LOCAL_DISPPOINT = "Do not run program";
    RUN_FROM_REMOTE_DISPPOINT = "Run Program from distribution point"
}

#endregion

#region Functions

function Get-BitFlagsSet($FlagsProp,$BitFlagHashTable)
{   
    $ReturnHashTable = @{}
    $BitFlagHashTable.Keys | ForEach-Object { if (($FlagsProp -band $BitFlagHashTable.Item($_)) -ne 0 ){$ReturnHashTable.Add($($_),$true)}else{$ReturnHashTable.Add($($_),$false)}}
    $ReturnHashTable
}

function Set-BitFlagForControl($IsControlEnabled, $BitFlagHashTable, $KeyName, $CurrentValue){
    if($IsControlEnabled){
        $CurrentValue = $CurrentValue -bor $BitFlagHashTable.Item($KeyName)
    } elseif($CurrentValue -band $BitFlagHashTable.Item($KeyName)) {
        $CurrentValue = ($CurrentValue -bxor $BitFlagHashTable.Item($KeyName))
    }
    return $CurrentValue
}

function IsBitFlagSet($BitFlagHashTable, $KeyName, $CurrentValue){
    if($CurrentValue -band $BitFlagHashTable.Item($KeyName)){
        return $True
    } else {
        return $False
    }
}

function ConvertDateString([string]$DateTimeString){
    if($DateTimeString -ne $null){
        $format = "yyyyMMddHHmm"
        $return = [datetime]::ParseExact(([string]($DateTimeString.Substring(0,12))), $format, $null).ToString()
    } else {
        $return = (Get-Date -Format $format).ToString()
    }
    return $return
}

#endregion

#SUG
#SELECT * FROM SMS_updateGroupAssignment WHERE AssignedUpdateGroup = ##SUB:CI_ID##


#region Gather deployment info and set form values
$DeploymentInfoScriptBlock= 
{

$tabControl1.Visible = $False
$btnApprove.Visible = $False
$btnClose.Visible = $False

#Import the ConfigurationManager.psd1 file
$Env:SMS_ADMIN_UI_PATH -match '(.*\\bin)' | Out-Null
$ConfigMgrModule = "$($matches[1])\ConfigurationManager.psd1"
if(Test-Path $ConfigMgrModule){
    Import-Module $ConfigMgrModule
    if((Get-PSDrive -PSProvider CMSite -Name $SiteCode -ErrorAction Ignore).count -eq 0){
        #Throw error, cannot find Site Code as PSProvider
        [void][System.Windows.Forms.MessageBox]::Show("Failed to find $($SiteCode) as a PSProvider, cannot continue." , "Error")
    } else{
        [void][System.Windows.Forms.MessageBox]::Show("Found PSProvider for $($SiteCode) successfully." , "Success")
    }

} else {
    #Throw error, cannot find module
}


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
$currentAdvertFlags = $advertisement.AdvertFlags
$currentRemoteClientFlags = $advertisement.RemoteClientFlags
#Get-BitFlagsSet -FlagsProp $advertisement.AdvertFlags -BitFlagHashTable $flags

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




$dtpAvailableTime.Format = [windows.forms.datetimepickerFormat]::custom 
$dtpAvailableTime.CustomFormat = "MM/dd/yyyy HH:mm" 

$dtpDeploymentTime.Format = [windows.forms.datetimepickerFormat]::custom 
$dtpDeploymentTime.CustomFormat = "MM/dd/yyyy HH:mm" 

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


#RemoteClientFlags
#$cbMetered.Checked = (IsBitFlagSet -BitFlagHashTable $remoteClientFlags -KeyName "DP_ALLOW_METERED_NETWORK" -CurrentValue $currentRemoteClientFlags)
$cbWriteFilterPersist.Checked = (IsBitFlagSet -BitFlagHashTable $remoteClientFlags -KeyName "PERSIST_ON_WRITE_FILTER_DEVICES" -CurrentValue $currentRemoteClientFlags)

   
#AdvertFlags
$cbIndependent.Checked = (-Not ( IsBitFlagSet -BitFlagHashTable $flags -KeyName "NO_DISPLAY" -CurrentValue $currentAdvertFlags ))
$cbMaintenanceInstall.Checked = ( IsBitFlagSet -BitFlagHashTable $flags -KeyName "OVERRIDE_SERVICE_WINDOWS" -CurrentValue $currentAdvertFlags )
$cbMaintenanceReboot.Checked = ( IsBitFlagSet -BitFlagHashTable $flags -KeyName "REBOOT_OUTSIDE_OF_SERVICE_WINDOWS" -CurrentValue $currentAdvertFlags )    
#$cbPeerCaching.Checked = (IsBitFlagSet -BitFlagHashTable $flags -KeyName "ENABLE_PEER_CACHING" -CurrentValue $currentAdvertFlags)
$cbFallback.Checked = (-Not ( IsBitFlagSet -BitFlagHashTable $flags -KeyName "DONOT_FALLBACK" -CurrentValue $currentAdvertFlags ))

$comboItems = @()
$i = 0
$SelectedIndex = 2
foreach($behavior in ($RerunBehaviors.GetEnumerator() | Sort-Object Value)){
    $object = new-object Object
    $object | add-member NoteProperty key $behavior.Key
    $object | add-member NoteProperty display $behavior.Value
    $comboItems += $object
    if(IsBitFlagSet -BitFlagHashTable $remoteClientFlags -KeyName $($behavior.Key) -CurrentValue $currentRemoteClientFlags){
        $SelectedIndex = $i
    }
    $i++
}
$comboRerunBehavior.Items.AddRange($comboItems)
$comboRerunBehavior.ValueMember = "key"
$comboRerunBehavior.DisplayMember = "display"
$comboRerunBehavior.SelectedIndex = $SelectedIndex


$comboItems = @()
$i = 0
$SelectedIndex = 1
foreach($choice in ($FastDPOptions.GetEnumerator() | Sort-Object Value -Descending) ){
    $object = new-object Object
    $object | add-member NoteProperty key $choice.Key
    $object | add-member NoteProperty display $choice.Value
    $comboItems += $object
    if(IsBitFlagSet -BitFlagHashTable $remoteClientFlags -KeyName $($choice.Key) -CurrentValue $currentRemoteClientFlags){
        $SelectedIndex = $i
    }
    $i++
}
$comboFastNetwork.Items.AddRange($comboItems)
$comboFastNetwork.ValueMember = "key"
$comboFastNetwork.DisplayMember = "display"
$comboFastNetwork.SelectedIndex = $SelectedIndex


$cbMetered.Visible = $False
$cbPeerCaching.Visible = $False

if($deploymentOfferType -eq "Required"){
    $btnApprove.Enabled = $False
    $btnApprove.Visible = $False
    $dtpAvailableTime.Enabled = $False
    $dtpDeploymentTime.Enabled = $False
    $comboRerunBehavior.Enabled = $False
    $tbChangeOrder.Enabled = $False
    $cbWOL.Enabled = $False
    $cbMetered.Enabled = $False
    $cbMaintenanceInstall.Enabled = $False
    $cbMaintenanceReboot.Enabled = $False
    $cbIndependent.Enabled = $False
    $cbWriteFilterPersist.Enabled = $False
    $comboFastNetwork.Enabled = $False
    $comboSlowNetwork.Enabled = $False
    $cbPeerCaching.Enabled = $False
    $cbFallback.Enabled = $False
    $desc = $advertisement.Comment
    $pattern = "Change Order\:<?>"
    #[void][System.Windows.Forms.MessageBox]::Show("Comment.`n$($desc)" , "Success")

} else {
    $lblAvailableMessage.Visible = $True
}
$tabControl1.Visible = $True
$btnApprove.Visible = $True
$btnClose.Visible = $True
$pictureBoxSpinningWheel.Visible = $False
$labelLoading.Visible = $False
}
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$tabControl1 = New-Object System.Windows.Forms.TabControl
$tabDeploymentInfo = New-Object System.Windows.Forms.TabPage
$tbChangeOrder = New-Object System.Windows.Forms.TextBox
$label17 = New-Object System.Windows.Forms.Label
$comboRerunBehavior = New-Object System.Windows.Forms.ComboBox
$label11 = New-Object System.Windows.Forms.Label
$lblAvailableMessage = New-Object System.Windows.Forms.Label
$label2 = New-Object System.Windows.Forms.Label
$lblDeploymentType = New-Object System.Windows.Forms.Label
$lblSoftwareName = New-Object System.Windows.Forms.Label
$label9 = New-Object System.Windows.Forms.Label
$label18 = New-Object System.Windows.Forms.Label
$lblSoftwareID = New-Object System.Windows.Forms.Label
$dtpDeploymentTime = New-Object System.Windows.Forms.DateTimePicker
$label3 = New-Object System.Windows.Forms.Label
$label7 = New-Object System.Windows.Forms.Label
$dtpAvailableTime = New-Object System.Windows.Forms.DateTimePicker
$lblSoftwareType = New-Object System.Windows.Forms.Label
$lblNumberOfTargets = New-Object System.Windows.Forms.Label
$label6 = New-Object System.Windows.Forms.Label
$label8 = New-Object System.Windows.Forms.Label
$lblCollectionID = New-Object System.Windows.Forms.Label
$lblSoftwareSize = New-Object System.Windows.Forms.Label
$label5 = New-Object System.Windows.Forms.Label
$label13 = New-Object System.Windows.Forms.Label
$label4 = New-Object System.Windows.Forms.Label
$lblCollectionName = New-Object System.Windows.Forms.Label
$tabAdditionalProps = New-Object System.Windows.Forms.TabPage
$cbWriteFilterPersist = New-Object System.Windows.Forms.CheckBox
$label14 = New-Object System.Windows.Forms.Label
$cbMaintenanceReboot = New-Object System.Windows.Forms.CheckBox
$cbMaintenanceInstall = New-Object System.Windows.Forms.CheckBox
$label12 = New-Object System.Windows.Forms.Label
$cbIndependent = New-Object System.Windows.Forms.CheckBox
$label10 = New-Object System.Windows.Forms.Label
$cbPredeploy = New-Object System.Windows.Forms.CheckBox
$cbMetered = New-Object System.Windows.Forms.CheckBox
$cbWOL = New-Object System.Windows.Forms.CheckBox
$tabDP = New-Object System.Windows.Forms.TabPage
$cbFallback = New-Object System.Windows.Forms.CheckBox
$cbPeerCaching = New-Object System.Windows.Forms.CheckBox
$comboSlowNetwork = New-Object System.Windows.Forms.ComboBox
$label16 = New-Object System.Windows.Forms.Label
$label15 = New-Object System.Windows.Forms.Label
$comboFastNetwork = New-Object System.Windows.Forms.ComboBox
$btnApprove = New-Object System.Windows.Forms.Button
$label1 = New-Object System.Windows.Forms.Label
$btnClose = New-Object System.Windows.Forms.Button
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
$labelLoading = New-Object System.Windows.Forms.Label
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

$comboFastNetwork_OnChange={
    #[void][System.Windows.Forms.MessageBox]::Show("$($comboFastNetwork.SelectedItem.Key)" , "Fast Check")
    if($comboSlowNetwork.Items.Count -gt 0){
        $currentSlowDPOptionSelected = $comboFastNetwork.SelectedItem.Key
        $firstTimeSlowDPOptionRun = $False
        $comboSlowNetwork.Items.Clear()
    } else {
        $firstTimeSlowDPOptionRun = $True
    }

    
    if($comboFastNetwork.SelectedItem.Key -eq "RUN_FROM_LOCAL_DISPPOINT"){
        $mySlowDPOptions = $SlowDPOptionsWithRunFromDP.Clone()
    } else {
        $mySlowDPOptions = $SlowDPOptions.Clone()
    }
    
    $comboItems = @()
    $i = 0
    $SelectedIndex = 1
    foreach($choice in ($mySlowDPOptions.GetEnumerator() | Sort-Object Value) ){
        $object = new-object Object
        $object | add-member NoteProperty key $choice.Key
        $object | add-member NoteProperty display $choice.Value
        $comboItems += $object
        if((IsBitFlagSet -BitFlagHashTable $remoteClientFlags -KeyName $($choice.Key) -CurrentValue $currentRemoteClientFlags) -and $firstTimeSlowDPOptionRun){
            $SelectedIndex = $i
        } elseif($choice.Key -eq $currentSlowDPOptionSelected){
            $SelectedIndex = $i
        }
        $i++
    }
    $comboSlowNetwork.Items.AddRange($comboItems)
    $comboSlowNetwork.ValueMember = "key"
    $comboSlowNetwork.DisplayMember = "display"
    $comboSlowNetwork.SelectedIndex = $SelectedIndex
}

$btnApprove_OnClick= 
{

    $IsNewOneCreated = $False
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
    $newAdvertisement.AdvertisementName = $advertisement.AdvertisementName
    $newAdvertisement.CollectionID = $advertisement.CollectionID
    $newAdvertisement.PackageID = $advertisement.PackageID
    $newAdvertisement.AssignedSchedule = $ScheduleTime
    $newAdvertisement.DeviceFlags = $advertisement.DeviceFlags
    $newAdvertisement.ProgramName = $advertisement.ProgramName
    
    $newAdvertisement.PresentTime = $newAvailableTime
    $newAdvertisement.SourceSite = $advertisement.SourceSite
    $newAdvertisement.TimeFlags = $advertisement.TimeFlags
    $newAdvertisement.Comment = "$($advertisement.Comment)`r`n`Change Order:$($tbChangeOrder.Text)`r`nApproved by: $($cred.UserName.ToUpper())"

    #Calculate and set the advertFlags and remoteClientFlags
    $currentAdvertFlags = $advertisement.AdvertFlags
    $currentRemoteClientFlags = $advertisement.RemoteClientFlags

    #RemoteClientFlags
    foreach($behavior in ($RerunBehaviors.GetEnumerator() | Sort-Object Value)){
        $currentRemoteClientFlags = ( Set-BitFlagForControl -IsControlEnabled ($behavior.Key -eq $comboRerunBehavior.SelectedItem.Key) -BitFlagHashTable $remoteClientFlags -KeyName $($behavior.Key) -CurrentValue $currentRemoteClientFlags )
    }
    $currentRemoteClientFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbMetered.Checked) -BitFlagHashTable $remoteClientFlags -KeyName "DP_ALLOW_METERED_NETWORK" -CurrentValue $currentRemoteClientFlags )    
    $currentRemoteClientFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbWriteFilterPersist.Checked) -BitFlagHashTable $remoteClientFlags -KeyName "PERSIST_ON_WRITE_FILTER_DEVICES" -CurrentValue $currentRemoteClientFlags )    
    foreach($behavior in ($FastDPOptions.GetEnumerator() | Sort-Object Value)){
        $currentRemoteClientFlags = ( Set-BitFlagForControl -IsControlEnabled ($behavior.Key -eq $comboFastNetwork.SelectedItem.Key) -BitFlagHashTable $remoteClientFlags -KeyName $($behavior.Key) -CurrentValue $currentRemoteClientFlags )
    }
    foreach($behavior in ($SlowDPOptions.GetEnumerator() | Sort-Object Value)){
        $currentRemoteClientFlags = ( Set-BitFlagForControl -IsControlEnabled ($behavior.Key -eq $comboSlowNetwork.SelectedItem.Key) -BitFlagHashTable $remoteClientFlags -KeyName $($behavior.Key) -CurrentValue $currentRemoteClientFlags )
    }
    
    #AdvertFlags
    $currentAdvertFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbWOL.Checked) -BitFlagHashTable $flags -KeyName "WAKE_ON_LAN_ENABLED" -CurrentValue $currentAdvertFlags )
    $currentAdvertFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbIndependent.Checked -eq $False) -BitFlagHashTable $flags -KeyName "NO_DISPLAY" -CurrentValue $currentAdvertFlags )
    $currentAdvertFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbMaintenanceInstall.Checked) -BitFlagHashTable $flags -KeyName "OVERRIDE_SERVICE_WINDOWS" -CurrentValue $currentAdvertFlags )
    $currentAdvertFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbMaintenanceReboot.Checked) -BitFlagHashTable $flags -KeyName "REBOOT_OUTSIDE_OF_SERVICE_WINDOWS" -CurrentValue $currentAdvertFlags )    
    #$currentAdvertFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbPeerCaching.Checked) -BitFlagHashTable $flags -KeyName "ENABLE_PEER_CACHING" -CurrentValue $currentAdvertFlags )    
    $currentAdvertFlags = ( Set-BitFlagForControl -IsControlEnabled $False -BitFlagHashTable $flags -KeyName "ENABLE_PEER_CACHING" -CurrentValue $currentAdvertFlags )    
    $currentAdvertFlags = ( Set-BitFlagForControl -IsControlEnabled ($cbFallback.Checked -eq $False) -BitFlagHashTable $flags -KeyName "DONOT_FALLBACK" -CurrentValue $currentAdvertFlags )

    $newAdvertisement.AdvertFlags = $currentAdvertFlags
    $newAdvertisement.RemoteClientFlags = $currentRemoteClientFlags

    # Apply Advertisement
    #[wmi]$advCreated = $newAdvertisement.put()
    cd "$($SiteCode):"


    $newAdvertisementID = $advCreated.AdvertisementID
    [void][System.Windows.Forms.MessageBox]::Show("Required deployment created.`nNew DeploymentID: $($newAdvertisementID)" , "Success")
    $IsNewOneCreated = $True
    }
    catch [system.exception]
    {
        $Error[0] | fl * -Force -OutVariable errorText
        [void][System.Windows.Forms.MessageBox]::Show("Failed to create deployment.`nI am really sorry about that. Perhaps you don't have rights to create a deployment?`nError: $($errorText)" , "Error")
        return $null
    }
    if($IsNewOneCreated){
        $advertisement.Delete()
        $form1.Close()
    }

}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#endregion

#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 568
$System_Drawing_Size.Width = 805
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.Text = "Deployment Approval"
$form1.add_Shown($DeploymentInfoScriptBlock)

$tabControl1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 35
$System_Drawing_Point.Y = 47
$tabControl1.Location = $System_Drawing_Point
$tabControl1.Name = "tabControl1"
$tabControl1.SelectedIndex = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 457
$System_Drawing_Size.Width = 711
$tabControl1.Size = $System_Drawing_Size
$tabControl1.TabIndex = 29

$form1.Controls.Add($tabControl1)
$tabDeploymentInfo.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 4
$System_Drawing_Point.Y = 22
$tabDeploymentInfo.Location = $System_Drawing_Point
$tabDeploymentInfo.Name = "tabDeploymentInfo"
$System_Windows_Forms_Padding = New-Object System.Windows.Forms.Padding
$System_Windows_Forms_Padding.All = 3
$System_Windows_Forms_Padding.Bottom = 3
$System_Windows_Forms_Padding.Left = 3
$System_Windows_Forms_Padding.Right = 3
$System_Windows_Forms_Padding.Top = 3
$tabDeploymentInfo.Padding = $System_Windows_Forms_Padding
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 431
$System_Drawing_Size.Width = 703
$tabDeploymentInfo.Size = $System_Drawing_Size
$tabDeploymentInfo.TabIndex = 0
$tabDeploymentInfo.Text = "Deployment Info"
$tabDeploymentInfo.UseVisualStyleBackColor = $True

$tabControl1.Controls.Add($tabDeploymentInfo)
$tbChangeOrder.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 392
$tbChangeOrder.Location = $System_Drawing_Point
$tbChangeOrder.Name = "tbChangeOrder"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 160
$tbChangeOrder.Size = $System_Drawing_Size
$tbChangeOrder.TabIndex = 33

$tabDeploymentInfo.Controls.Add($tbChangeOrder)

$label17.DataBindings.DefaultDataSourceUpdateMode = 0
$label17.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,5,3,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 15
$System_Drawing_Point.Y = 392
$label17.Location = $System_Drawing_Point
$label17.Name = "label17"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 149
$label17.Size = $System_Drawing_Size
$label17.TabIndex = 32
$label17.Text = "SD Change Order #:"
$label17.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label17)

$comboRerunBehavior.DataBindings.DefaultDataSourceUpdateMode = 0
$comboRerunBehavior.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 354
$comboRerunBehavior.Location = $System_Drawing_Point
$comboRerunBehavior.Name = "comboRerunBehavior"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 383
$comboRerunBehavior.Size = $System_Drawing_Size
$comboRerunBehavior.TabIndex = 31

$tabDeploymentInfo.Controls.Add($comboRerunBehavior)

$label11.DataBindings.DefaultDataSourceUpdateMode = 0
$label11.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 14
$System_Drawing_Point.Y = 357
$label11.Location = $System_Drawing_Point
$label11.Name = "label11"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 151
$label11.Size = $System_Drawing_Size
$label11.TabIndex = 30
$label11.Text = "Rerun Behavior:"
$label11.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label11)

$lblAvailableMessage.DataBindings.DefaultDataSourceUpdateMode = 0
$lblAvailableMessage.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,3,3,1)
$lblAvailableMessage.ForeColor = [System.Drawing.Color]::FromArgb(255,128,128,128)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 202
$System_Drawing_Point.Y = 315
$lblAvailableMessage.Location = $System_Drawing_Point
$lblAvailableMessage.Name = "lblAvailableMessage"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 313
$lblAvailableMessage.Size = $System_Drawing_Size
$lblAvailableMessage.TabIndex = 29
$lblAvailableMessage.Text = "(Approving this will make it a Required Deployment)"
$lblAvailableMessage.Visible = $False

$tabDeploymentInfo.Controls.Add($lblAvailableMessage)

$label2.DataBindings.DefaultDataSourceUpdateMode = 0
$label2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 14
$System_Drawing_Point.Y = 3
$label2.Location = $System_Drawing_Point
$label2.Name = "label2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 152
$label2.Size = $System_Drawing_Size
$label2.TabIndex = 2
$label2.Text = "Software Name:"
$label2.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label2)

$lblDeploymentType.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 202
$System_Drawing_Point.Y = 291
$lblDeploymentType.Location = $System_Drawing_Point
$lblDeploymentType.Name = "lblDeploymentType"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 167
$lblDeploymentType.Size = $System_Drawing_Size
$lblDeploymentType.TabIndex = 28
$lblDeploymentType.Text = "Avail/Req"

$tabDeploymentInfo.Controls.Add($lblDeploymentType)

$lblSoftwareName.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 202
$System_Drawing_Point.Y = 6
$lblSoftwareName.Location = $System_Drawing_Point
$lblSoftwareName.Name = "lblSoftwareName"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 471
$lblSoftwareName.Size = $System_Drawing_Size
$lblSoftwareName.TabIndex = 9
$lblSoftwareName.Text = "Software Name"

$tabDeploymentInfo.Controls.Add($lblSoftwareName)

$label9.DataBindings.DefaultDataSourceUpdateMode = 0
$label9.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 15
$System_Drawing_Point.Y = 292
$label9.Location = $System_Drawing_Point
$label9.Name = "label9"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 61
$System_Drawing_Size.Width = 155
$label9.Size = $System_Drawing_Size
$label9.TabIndex = 27
$label9.Text = "Current Deployment Type:"
$label9.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label9)

$label18.DataBindings.DefaultDataSourceUpdateMode = 0
$label18.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 51
$System_Drawing_Point.Y = 31
$label18.Location = $System_Drawing_Point
$label18.Name = "label18"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 115
$label18.Size = $System_Drawing_Size
$label18.TabIndex = 20
$label18.Text = "Software ID:"
$label18.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label18)

$lblSoftwareID.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 31
$lblSoftwareID.Location = $System_Drawing_Point
$lblSoftwareID.Name = "lblSoftwareID"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 314
$lblSoftwareID.Size = $System_Drawing_Size
$lblSoftwareID.TabIndex = 22
$lblSoftwareID.Text = "Software ID"

$tabDeploymentInfo.Controls.Add($lblSoftwareID)

$dtpDeploymentTime.CustomFormat = "MM/dd/yyyy HH:mm"
$dtpDeploymentTime.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 258
$dtpDeploymentTime.Location = $System_Drawing_Point
$dtpDeploymentTime.Name = "dtpDeploymentTime"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 168
$dtpDeploymentTime.Size = $System_Drawing_Size
$dtpDeploymentTime.TabIndex = 19

$tabDeploymentInfo.Controls.Add($dtpDeploymentTime)

$label3.DataBindings.DefaultDataSourceUpdateMode = 0
$label3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 45
$System_Drawing_Point.Y = 59
$label3.Location = $System_Drawing_Point
$label3.Name = "label3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 121
$label3.Size = $System_Drawing_Size
$label3.TabIndex = 3
$label3.Text = "Software Type:"
$label3.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label3)

$label7.DataBindings.DefaultDataSourceUpdateMode = 0
$label7.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 52
$System_Drawing_Point.Y = 258
$label7.Location = $System_Drawing_Point
$label7.Name = "label7"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 118
$label7.Size = $System_Drawing_Size
$label7.TabIndex = 7
$label7.Text = "Deploy Time:"
$label7.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label7)

$dtpAvailableTime.CustomFormat = "MM/dd/yyyy HH:mm"
$dtpAvailableTime.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 217
$dtpAvailableTime.Location = $System_Drawing_Point
$dtpAvailableTime.Name = "dtpAvailableTime"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 168
$dtpAvailableTime.Size = $System_Drawing_Size
$dtpAvailableTime.TabIndex = 18

$tabDeploymentInfo.Controls.Add($dtpAvailableTime)

$lblSoftwareType.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 202
$System_Drawing_Point.Y = 59
$lblSoftwareType.Location = $System_Drawing_Point
$lblSoftwareType.Name = "lblSoftwareType"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblSoftwareType.Size = $System_Drawing_Size
$lblSoftwareType.TabIndex = 10
$lblSoftwareType.Text = "Software Type"

$tabDeploymentInfo.Controls.Add($lblSoftwareType)

$lblNumberOfTargets.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 183
$lblNumberOfTargets.Location = $System_Drawing_Point
$lblNumberOfTargets.Name = "lblNumberOfTargets"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblNumberOfTargets.Size = $System_Drawing_Size
$lblNumberOfTargets.TabIndex = 15
$lblNumberOfTargets.Text = "Collection Total"

$tabDeploymentInfo.Controls.Add($lblNumberOfTargets)

$label6.DataBindings.DefaultDataSourceUpdateMode = 0
$label6.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 51
$System_Drawing_Point.Y = 217
$label6.Location = $System_Drawing_Point
$label6.Name = "label6"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 119
$label6.Size = $System_Drawing_Size
$label6.TabIndex = 6
$label6.Text = "Available Time:"
$label6.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label6)

$label8.DataBindings.DefaultDataSourceUpdateMode = 0
$label8.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 49
$System_Drawing_Point.Y = 89
$label8.Location = $System_Drawing_Point
$label8.Name = "label8"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 117
$label8.Size = $System_Drawing_Size
$label8.TabIndex = 8
$label8.Text = "Software Size:"
$label8.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label8)

$lblCollectionID.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 151
$lblCollectionID.Location = $System_Drawing_Point
$lblCollectionID.Name = "lblCollectionID"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblCollectionID.Size = $System_Drawing_Size
$lblCollectionID.TabIndex = 14
$lblCollectionID.Text = "CollectionID"

$tabDeploymentInfo.Controls.Add($lblCollectionID)

$lblSoftwareSize.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 89
$lblSoftwareSize.Location = $System_Drawing_Point
$lblSoftwareSize.Name = "lblSoftwareSize"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 232
$lblSoftwareSize.Size = $System_Drawing_Size
$lblSoftwareSize.TabIndex = 11
$lblSoftwareSize.Text = "Software Size"

$tabDeploymentInfo.Controls.Add($lblSoftwareSize)

$label5.DataBindings.DefaultDataSourceUpdateMode = 0
$label5.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 46
$System_Drawing_Point.Y = 183
$label5.Location = $System_Drawing_Point
$label5.Name = "label5"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 120
$label5.Size = $System_Drawing_Size
$label5.TabIndex = 5
$label5.Text = "# of Targets:"
$label5.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label5)

$label13.DataBindings.DefaultDataSourceUpdateMode = 0
$label13.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 50
$System_Drawing_Point.Y = 151
$label13.Location = $System_Drawing_Point
$label13.Name = "label13"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 116
$label13.Size = $System_Drawing_Size
$label13.TabIndex = 13
$label13.Text = "Collection ID:"
$label13.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label13)

$label4.DataBindings.DefaultDataSourceUpdateMode = 0
$label4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 45
$System_Drawing_Point.Y = 118
$label4.Location = $System_Drawing_Point
$label4.Name = "label4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 121
$label4.Size = $System_Drawing_Size
$label4.TabIndex = 4
$label4.Text = "Collection:"
$label4.TextAlign = 4

$tabDeploymentInfo.Controls.Add($label4)

$lblCollectionName.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 201
$System_Drawing_Point.Y = 118
$lblCollectionName.Location = $System_Drawing_Point
$lblCollectionName.Name = "lblCollectionName"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 529
$lblCollectionName.Size = $System_Drawing_Size
$lblCollectionName.TabIndex = 12
$lblCollectionName.Text = "Collection Name"

$tabDeploymentInfo.Controls.Add($lblCollectionName)


$tabAdditionalProps.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 4
$System_Drawing_Point.Y = 22
$tabAdditionalProps.Location = $System_Drawing_Point
$tabAdditionalProps.Name = "tabAdditionalProps"
$System_Windows_Forms_Padding = New-Object System.Windows.Forms.Padding
$System_Windows_Forms_Padding.All = 3
$System_Windows_Forms_Padding.Bottom = 3
$System_Windows_Forms_Padding.Left = 3
$System_Windows_Forms_Padding.Right = 3
$System_Windows_Forms_Padding.Top = 3
$tabAdditionalProps.Padding = $System_Windows_Forms_Padding
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 396
$System_Drawing_Size.Width = 703
$tabAdditionalProps.Size = $System_Drawing_Size
$tabAdditionalProps.TabIndex = 1
$tabAdditionalProps.Text = "Additional Options"
$tabAdditionalProps.UseVisualStyleBackColor = $True

$tabControl1.Controls.Add($tabAdditionalProps)

$cbWriteFilterPersist.Checked = $True
$cbWriteFilterPersist.CheckState = 1
$cbWriteFilterPersist.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 328
$cbWriteFilterPersist.Location = $System_Drawing_Point
$cbWriteFilterPersist.Name = "cbWriteFilterPersist"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 595
$cbWriteFilterPersist.Size = $System_Drawing_Size
$cbWriteFilterPersist.TabIndex = 9
$cbWriteFilterPersist.Text = "Commit changes at deadline or during a maintenance window (requires restarts)"
$cbWriteFilterPersist.UseVisualStyleBackColor = $True

$tabAdditionalProps.Controls.Add($cbWriteFilterPersist)

$label14.DataBindings.DefaultDataSourceUpdateMode = 0
$label14.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 301
$label14.Location = $System_Drawing_Point
$label14.Name = "label14"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 402
$label14.Size = $System_Drawing_Size
$label14.TabIndex = 8
$label14.Text = "Write filter handling for Windows Embedded devices:"

$tabAdditionalProps.Controls.Add($label14)


$cbMaintenanceReboot.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 261
$cbMaintenanceReboot.Location = $System_Drawing_Point
$cbMaintenanceReboot.Name = "cbMaintenanceReboot"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 381
$cbMaintenanceReboot.Size = $System_Drawing_Size
$cbMaintenanceReboot.TabIndex = 7
$cbMaintenanceReboot.Text = "System restart (if required to complete the installation)"
$cbMaintenanceReboot.UseVisualStyleBackColor = $True

$tabAdditionalProps.Controls.Add($cbMaintenanceReboot)


$cbMaintenanceInstall.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 230
$cbMaintenanceInstall.Location = $System_Drawing_Point
$cbMaintenanceInstall.Name = "cbMaintenanceInstall"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 172
$cbMaintenanceInstall.Size = $System_Drawing_Size
$cbMaintenanceInstall.TabIndex = 6
$cbMaintenanceInstall.Text = "Software installation"
$cbMaintenanceInstall.UseVisualStyleBackColor = $True

$tabAdditionalProps.Controls.Add($cbMaintenanceInstall)

$label12.DataBindings.DefaultDataSourceUpdateMode = 0
$label12.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 203
$label12.Location = $System_Drawing_Point
$label12.Name = "label12"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 296
$label12.Size = $System_Drawing_Size
$label12.TabIndex = 5
$label12.Text = "Allow outside of maintenance window:"

$tabAdditionalProps.Controls.Add($label12)


$cbIndependent.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 156
$cbIndependent.Location = $System_Drawing_Point
$cbIndependent.Name = "cbIndependent"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 417
$cbIndependent.Size = $System_Drawing_Size
$cbIndependent.TabIndex = 4
$cbIndependent.Text = "Allow users to run the program independently of assignments"
$cbIndependent.UseVisualStyleBackColor = $True

$tabAdditionalProps.Controls.Add($cbIndependent)

$label10.DataBindings.DefaultDataSourceUpdateMode = 0
$label10.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 129
$label10.Location = $System_Drawing_Point
$label10.Name = "label10"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 163
$label10.Size = $System_Drawing_Size
$label10.TabIndex = 3
$label10.Text = "Notification Settings:"

$tabAdditionalProps.Controls.Add($label10)


$cbPredeploy.DataBindings.DefaultDataSourceUpdateMode = 0
$cbPredeploy.Enabled = $False

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 16
$cbPredeploy.Location = $System_Drawing_Point
$cbPredeploy.Name = "cbPredeploy"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 337
$cbPredeploy.Size = $System_Drawing_Size
$cbPredeploy.TabIndex = 2
$cbPredeploy.Text = "Pre-deploy software to the user''s primary device"
$cbPredeploy.UseVisualStyleBackColor = $True

$tabAdditionalProps.Controls.Add($cbPredeploy)


$cbMetered.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 67
$cbMetered.Location = $System_Drawing_Point
$cbMetered.Name = "cbMetered"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 45
$System_Drawing_Size.Width = 511
$cbMetered.Size = $System_Drawing_Size
$cbMetered.TabIndex = 1
$cbMetered.Text = "Allow clients on a metered Internet connection to download content after the installation deadline, which might incur additional costs."
$cbMetered.TextAlign = 256
$cbMetered.UseVisualStyleBackColor = $True

$tabAdditionalProps.Controls.Add($cbMetered)


$cbWOL.Checked = $True
$cbWOL.CheckState = 1
$cbWOL.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 46
$cbWOL.Location = $System_Drawing_Point
$cbWOL.Name = "cbWOL"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 184
$cbWOL.Size = $System_Drawing_Size
$cbWOL.TabIndex = 0
$cbWOL.Text = "Send wake-up packets"
$cbWOL.UseVisualStyleBackColor = $True

$tabAdditionalProps.Controls.Add($cbWOL)


$tabDP.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 4
$System_Drawing_Point.Y = 22
$tabDP.Location = $System_Drawing_Point
$tabDP.Name = "tabDP"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 396
$System_Drawing_Size.Width = 703
$tabDP.Size = $System_Drawing_Size
$tabDP.TabIndex = 2
$tabDP.Text = "Distribution Points"
$tabDP.UseVisualStyleBackColor = $True

$tabControl1.Controls.Add($tabDP)

$cbFallback.Checked = $True
$cbFallback.CheckState = 1
$cbFallback.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 300
$cbFallback.Location = $System_Drawing_Point
$cbFallback.Name = "cbFallback"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 466
$cbFallback.Size = $System_Drawing_Size
$cbFallback.TabIndex = 5
$cbFallback.Text = "Allow clients to use a fallback source location for content"
$cbFallback.UseVisualStyleBackColor = $True

$tabDP.Controls.Add($cbFallback)


$cbPeerCaching.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 220
$cbPeerCaching.Location = $System_Drawing_Point
$cbPeerCaching.Name = "cbPeerCaching"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 45
$System_Drawing_Size.Width = 466
$cbPeerCaching.Size = $System_Drawing_Size
$cbPeerCaching.TabIndex = 4
$cbPeerCaching.Text = "Allow clients to share content with other clients on the same subnet (Windows BranchCache)"
$cbPeerCaching.UseVisualStyleBackColor = $True

$tabDP.Controls.Add($cbPeerCaching)

$comboSlowNetwork.DataBindings.DefaultDataSourceUpdateMode = 0
$comboSlowNetwork.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 149
$comboSlowNetwork.Location = $System_Drawing_Point
$comboSlowNetwork.Name = "comboSlowNetwork"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 466
$comboSlowNetwork.Size = $System_Drawing_Size
$comboSlowNetwork.TabIndex = 3

$tabDP.Controls.Add($comboSlowNetwork)

$label16.DataBindings.DefaultDataSourceUpdateMode = 0
$label16.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 122
$label16.Location = $System_Drawing_Point
$label16.Name = "label16"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 336
$label16.Size = $System_Drawing_Size
$label16.TabIndex = 2
$label16.Text = "Slow network boundary deployment options:"

$tabDP.Controls.Add($label16)

$label15.DataBindings.DefaultDataSourceUpdateMode = 0
$label15.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",7.8,5,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 33
$label15.Location = $System_Drawing_Point
$label15.Name = "label15"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 336
$label15.Size = $System_Drawing_Size
$label15.TabIndex = 1
$label15.Text = "Fast network boundary deployment options:"

$tabDP.Controls.Add($label15)

$comboFastNetwork.DataBindings.DefaultDataSourceUpdateMode = 0
$comboFastNetwork.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 59
$comboFastNetwork.Location = $System_Drawing_Point
$comboFastNetwork.Name = "comboFastNetwork"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 466
$comboFastNetwork.Size = $System_Drawing_Size
$comboFastNetwork.TabIndex = 0
$comboFastNetwork.add_SelectedIndexChanged($comboFastNetwork_OnChange)

$tabDP.Controls.Add($comboFastNetwork)


$btnApprove.BackColor = [System.Drawing.Color]::FromArgb(255,0,128,0)

$btnApprove.DataBindings.DefaultDataSourceUpdateMode = 0
$btnApprove.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",13.8,1,3,1)
$btnApprove.ForeColor = [System.Drawing.Color]::FromArgb(255,0,255,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 264
$System_Drawing_Point.Y = 510
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
$System_Drawing_Point.Y = 510
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

$pictureBoxSpinningWheel = New-Object System.Windows.Forms.PictureBox
$pictureBoxSpinningWheel.DataBindings.DefaultDataSourceUpdateMode = 0
#$env:SMS_ADMIN_UI_PATH
$pictureBoxSpinningWheel.Image = [System.Drawing.Image]::FromFile('c:\data\sccm\scripts\spinning-wheel.gif')

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 350
$System_Drawing_Point.Y = 240
$pictureBoxSpinningWheel.Location = $System_Drawing_Point
$pictureBoxSpinningWheel.Name = "pictureBoxSpinningWheel"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 60
$System_Drawing_Size.Width = 60
$pictureBoxSpinningWheel.Size = $System_Drawing_Size
$pictureBoxSpinningWheel.TabIndex = 1
$pictureBoxSpinningWheel.TabStop = $False

$form1.Controls.Add($pictureBoxSpinningWheel)

$labelLoading.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 330
$System_Drawing_Point.Y = 210
$labelLoading.Location = $System_Drawing_Point
$labelLoading.Name = "labelLoading"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 163
$labelLoading.Size = $System_Drawing_Size
$labelLoading.TabIndex = 3
$labelLoading.Text = "Loading, please wait..."

$form1.Controls.Add($labelLoading)

#endregion Generated Form Code

#region Show the form

$form1.MinimizeBox = $False
$form1.MaximizeBox = $False
$form1.StartPosition = "CenterScreen"
$form1.TopMost = $True

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null
#endregion

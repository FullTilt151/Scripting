function Show-PullPCData_psf {

	#Import the Assemblies used to build the GUI
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
    
    Install-Module ImportExcel -Scope CurrentUser -Force

	#Form Objects
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$MainFrm = New-Object 'System.Windows.Forms.Form'
	$ResultLbl = New-Object 'System.Windows.Forms.Label'
	$labelSwapType = New-Object 'System.Windows.Forms.Label'
	$SwapLst = New-Object 'System.Windows.Forms.ComboBox'
	$SubmitTxt = New-Object 'System.Windows.Forms.Button'
	$PushTxt = New-Object 'System.Windows.Forms.Button'
	$NewTxt = New-Object 'System.Windows.Forms.Button'
    $MassUploadBtn = New-Object 'System.Windows.Forms.Button'
	$labelShippingAddress = New-Object 'System.Windows.Forms.Label'
	$labelConnectionType = New-Object 'System.Windows.Forms.Label'
	$labelWorkstationID = New-Object 'System.Windows.Forms.Label'
	$labelTargetWorkstationID = New-Object 'System.Windows.Forms.Label'
	$ConnectionLst = New-Object 'System.Windows.Forms.ComboBox'
	$AddressTxt = New-Object 'System.Windows.Forms.TextBox'
	$WkidTxt = New-Object 'System.Windows.Forms.TextBox'
	$Wkid2Txt = New-Object 'System.Windows.Forms.TextBox'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	
    # Main form loads
	$MainFrm_Load={

		# Outputs message to user inside CMD window behind GUI
		Write-Host "!!!Pre-Requisites!!!"
        Write-Host "!!!Must be connected to HUMAD domain!!!"
		Write-Host "!!!Office 365 must be installed and licensed!!!"
		Write-Host "!!!SQL Management Studio must be installed!!!"
        

        # Copy tools we need locally
		Copy-Item "\\grbnaswps05\DSI\R_DSI\Nathan_K\psexec.exe" -Destination "C:\Temp" -Recurse
		Copy-Item "\\grbnaswps05\DSI\R_DSI\Nathan_K\psexec64.exe" -Destination "C:\Temp" -Recurse
		Copy-Item "\\grbnaswps05\DSI\R_DSI\Nathan_K\strings2.xlsm" -Destination "C:\Temp" -Recurse
		
		# Loads the SQL Server Management Objects (SMO)  
		[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
		
        # Declare and setup SQL connection objects
        $global:SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
        $global:SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
        $global:SqlCmd = New-Object System.Data.SqlClient.SqlCommand 
        $global:SqlConnection.ConnectionString = "Server=CMWPDB; Database=CM_WP1; Integrated Security = True;"

	}
	
    # Function to initialise the query the SQL Connection object will pass to the database
    function InitSql 
    {
        param ($Query)
		# Assign the SQL Query string to the CommandText property of SqlCmd Object
        $global:SqlCmd.CommandText = $Query 

		# Pass out connection string to the Connection property of the SqlCmd Object
		$global:SqlCmd.Connection = $SqlConnection 
		
		# Pass the constructed SqlCmd Object to the SQL Adapter Object
		$global:SqlAdapter.SelectCommand = $SqlCmd 
    }

    # Overloaded Function to import data from Excel
    function Import-Excel
    {
      param (
        [string]$FileName,
        [string]$WorksheetName,
        [bool]$DisplayProgress = $true
      )

      if ($FileName -eq "") {
        throw "Please provide path to the Excel file"
        Exit
      }

      if (-not (Test-Path $FileName)) {
        throw "Path '$FileName' does not exist."
        exit
      }

      $FileName = Resolve-Path $FileName
      $excel = New-Object -com "Excel.Application"
      $excel.Visible = $false
      $workbook = $excel.workbooks.open($FileName)

      if (-not $WorksheetName) {
        Write-Warning "Defaulting to the first worksheet in workbook."
        $sheet = $workbook.ActiveSheet
      } else {
        $sheet = $workbook.Sheets.Item($WorksheetName)
      }
  
      if (-not $sheet)
      {
        throw "Unable to open worksheet $WorksheetName"
        exit
      }
  
      $sheetName = $sheet.Name
      $columns = $sheet.UsedRange.Columns.Count
      $lines = $sheet.UsedRange.Rows.Count
  
      Write-Warning "Worksheet $sheetName contains $columns columns and $lines lines of data"
  
      $fields = @()
  
      for ($column = 1; $column -le $columns; $column ++) {
        $fieldName = $sheet.Cells.Item.Invoke(1, $column).Value2
        if ($fieldName -eq $null) {
          $fieldName = "Column" + $column.ToString()
        }
        $fields += $fieldName
      }
  
      $line = 2
  
  
      for ($line = 2; $line -le $lines; $line ++) {
        $values = New-Object object[] $columns
        for ($column = 1; $column -le $columns; $column++) {
          $values[$column - 1] = $sheet.Cells.Item.Invoke($line, $column).Value2
        }  
  
        $row = New-Object psobject
        $fields | foreach-object -begin {$i = 0} -process {
          $row | Add-Member -MemberType noteproperty -Name $fields[$i] -Value $values[$i]; $i++
        }
        $row
        $percents = [math]::round((($line/$lines) * 100), 0)
        if ($DisplayProgress) {
          Write-Progress -Activity:"Importing from Excel file $FileName" -Status:"Imported $line of total $lines lines ($percents%)" -PercentComplete:$percents
        }
      }
      $workbook.Close()
      $excel.Quit()
    }

    # Function pulls data about the old computer
    function PullPCData
    {
        param($DisplayName, $UserID, $EmailAddress, $hostname, $Address, $Connection, $NumOfMonitors, $MonitorConnections, $Monitor1Make, $Monitor1Connection, $Monitor2Make, $Monitor2Connection, $Monitor3Make, $Monitor3Connection, $PTO)

        $ResultLbl.Text = ""

        # Check to make sure the Workstation ID entered is at least 7 characters
		If ($hostname.Length -lt 5)
		{
			Write-Host "Workstation ID entered does not have enough characters"
			$ResultLbl.Text = "Workstation ID entered does not have enough characters"
			Return
		}
        
        # Collect Resource ID/Machine ID based off the Hostname entered
        $DataSet = New-Object System.Data.DataSet
		$Query = "SELECT resourceid FROM v_r_system WHERE Netbios_name0 ='$hostname'" 
        InitSql($Query) 
		$global:SqlAdapter.Fill($DataSet)
		$SQLResourceID = $DataSet.Tables[0].Rows[0]["ResourceID"]
        
        # Check if a value has been passed to UserID variable
        If ($UserID.length -eq 0)
        {
            # Assign a new query to gather username, reinitialize the contructed objects
            $DataSet2 = New-Object System.Data.DataSet 
		    $Query = "SELECT User_Name0 FROM v_r_system WHERE Netbios_name0 = '$hostname'" 
		    InitSql($Query) 
		    $global:SqlAdapter.Fill($DataSet2) 
		    $UserID = $DataSet2.Tables[0].Rows[0]["User_Name0"] 
        }

        # Check if value has been passed to DisplayName
        If ($DisplayName.length -eq 0)
        {
            # Leverage Active Directory Services Interface (ADSI) for DisplayName
            $DisplayName = (([adsi]"WinNT://humad/$UserId,user").fullname | Out-String).Trim()
		    $Searcher = [adsisearcher]"(objectClass=user)"
		    $Searcher = [adsisearcher]"(samaccountname=$UserID)"
        }

        # Check if value has been passed to EmailAddress
        If ($EmailAddress.length -eq 0)
        {
            # Collect Email Address using ADSI Object
		    $EmailAddress = ($Searcher.FindOne().Properties.mail | Out-String).Trim() 
        }
        
        # Collect the Model of the current PC
		$DataSet3 = New-Object System.Data.DataSet
		$Query = "SELECT Version0 FROM v_GS_COMPUTER_SYSTEM_PRODUCT WHERE ResourceID = '$SQLResourceID'"
		InitSql($Query)
		$global:SqlAdapter.Fill($DataSet3)
		$Model = ($DataSet3.Tables[0].Rows[0]["Version0"] | Out-String).Trim()
		
        # Collect the Operation System of the current PC
        $DataSet4 = New-Object System.Data.DataSet
		$Query = "SELECT Caption0 FROM v_GS_OPERATING_SYSTEM WHERE ResourceID = '$SQLResourceID'" 
		InitSql($Query)
		$global:SqlAdapter.Fill($DataSet4)
		$OS = ($DataSet4.Tables[0].Rows[0]["Caption0"] | Out-String).Trim()
		
		# Collect the printers on the current PC
        $DataSet5 = New-Object System.Data.DataSet
		$Query = "SELECT Name0, PortName0 FROM v_GS_PRINTER_DEVICE WHERE ResourceID = '$SQLResourceID'"
		InitSql($Query)
		$global:SqlAdapter.Fill($DataSet5)
		$Printers = $DataSet5.Tables[0]

        # Collect the OSD Image Name
        $DataSet8 = New-Object System.Data.DataSet
		$Query = "SELECT ImageName0 FROM v_GS_OSD640 WHERE ResourceID = '$SQLResourceID'"
		InitSql($Query)
		$global:SqlAdapter.Fill($DataSet8)
		$ImageRelease = ($DataSet8.Tables[0].Rows[0]["ImageName0"] | Out-String).Trim()
		$ImageRelease = "Image Release: " + $ImageRelease

        # Collect Connection Type based on last known IP Address
        $Dataset9 = New-Object System.Data.Dataset
        $Query = "SELECT IPAddress0 FROM v_GS_NETWORK_ADAPTER_CONFIGURATION WHERE ResourceID = '$SQLResourceID' AND IPAddress0 IS NOT NULL"
        InitSql($Query)
        $global:SqlAdapter.Fill($Dataset9) | ConvertTo-Csv -NoTypeInformation | Select -Skip 1 | % {$_.Replace('"','')}
        $lastKnownConnection = $DataSet9.Tables[0]
		
		# Collect 64 Bit application list
        $DataSet6 = New-Object System.Data.DataSet
		$Query = "SELECT DisplayName0 FROM v_GS_ADD_REMOVE_PROGRAMS_64 WHERE ResourceID = '$SQLResourceID' AND DisplayName0 IS NOT NULL ORDER BY DisplayName0"
		InitSql($Query)
		$global:SqlAdapter.Fill($DataSet6)
		$SqlApps = $DataSet6.Tables[0] | ConvertTo-Csv -NoTypeInformation | Select -Skip 1 | % {$_.Replace('"','')} # Skip top row, replace any qoutes with white space, strip type info
		[System.Collections.ArrayList]$64Bit = $SqlApps | Where { $_ -ne "" } | ForEach { $_.Replace("  ","") } 
			
		# Collect 32 Bit application list
        $DataSet7 = New-Object System.Data.DataSet
		$Query = "SELECT DisplayName0 FROM v_GS_ADD_REMOVE_PROGRAMS WHERE ResourceID = '$SQLResourceID' AND DisplayName0 IS NOT NULL ORDER BY DisplayName0"
		InitSql($Query)
		$global:SqlAdapter.Fill($DataSet7)
		$SQLApps = $DataSet7.Tables[0] | ConvertTo-Csv -NoTypeInformation | Select -Skip 1 | % {$_.Replace('"','')}
		[System.Collections.ArrayList]$32Bit = $SqlApps | Where { $_ -ne "" } | ForEach { $_.Replace("  ","") }

        If ($NumOfMonitors -eq 0 -Or $NumOfMonitors -eq "")
        {
            # Collect monitor information
            $Dataset10 = New-Object System.Data.DataSet
            $Query = "SELECT MachineID, Manufacturer00, Name00, SerialNumber00 FROM MONITORDETAILS_DATA WHERE MachineID = '$SQLResourceID'"
            InitSql($Query)
		    $global:SqlAdapter.Fill($DataSet10)
            $Monitors = $Dataset10.Tables[0]
        }

        If ($NumOfMonitors -eq 1)
        {
            $Monitors = @($NumOfMonitors, $MonitorConnections, $Monitor1Make, $Monitor1Connection)
        }

        If ($NumOfMonitors -eq 2)
        {
            # Builds an array from the data passed
            $Monitors = @($NumOfMonitors, $MonitorConnections, $Monitor1Make, $Monitor1Connection, $Monitor2Make, $Monitor2Connection)
        }

        If ($NumOfMonitors -eq 3)
        {
            # Builds an array from the data passed
            $Monitors = @($NumOfMonitors, $MonitorConnections, $Monitor1Make, $Monitor1Connection, $Monitor2Make, $Monitor2Connection, $Monitor3Make, $Monitor3Connection)
        }

        # Set Path for 3M and Humana Time Track to variables
        $3MPath = ("\\$hostname\C$\3MHIS" | Out-String).Trim()
		$HumanaTimeTrack = ("\\$hostname\C$\Program Files (x86)\PMTTApplication" | Out-String).Trim()
        $OneDrivePath = ("\\$hostname\C$\Users\$UserID\AppData\Local\Microsoft\OneDrive")
        
        # If the PC is online, check for 3M and Human Time Track
		If (Test-Connection -ComputerName $hostname -Quiet)
		{
			If (Test-Path -Path $3MPath)
			{$3M = "3M Physician Coding and Reimbursement System MRA"}
			
			If (Test-Path -Path $HumanaTimeTrack)
			{$TimeTrack = "Humana Process Metrics Time Tracking 1.6"}
            
            If (Test-Path -Path $OneDrivePath)
            {$OneDrive = "Microsoft OneDrive"}
		}
        Else
        {
            $3M = "Workstation is offline, unable to check for 3M"
			$TimeTrack = "Workstation is offline, unable to check for Humana Process Metrics Time Tracking"
            $OneDrive = "Workstation is offline, unable to check forMicrosoft OneDrive"
        }
		
        # If 32 and 64 bit application arrays are not empty
        If (($32Bit.Count -GT 0) -and ($64Bit.Count -GT 0)) 
        {
            # Remove duplicates from both arrays
		    $32Bit = [System.Collections.ArrayList]$32Bit | Sort | Get-Unique
		    $64Bit = [System.Collections.ArrayList]$64Bit | Sort | Get-Unique

		    # Check for key apps inside the 32 and 64 bit app array
		    If ((Select-String -Pattern "SysTrack" -InputObject $64Bit)-or (Select-String -Pattern "SysTrack" -InputObject $32Bit)){$SysTrack = "Lakeside Software Inc. SysTrack Systems Installation Needed"}
		    If ((Select-String -Pattern "GemPcCCID" -InputObject $64Bit)-or (Select-String -Pattern "GemPcCCID" -InputObject $32Bit)){$Gemalto = "Gemalto & Athena Installation Needed - Install in order from 1 to 6 from: \\grbnaswps05\DSI\R_DSI\Software\GemaltoSmartcard"}
		    If ((Select-String -Pattern "SecureAuthOTP" -InputObject $64Bit)-or (Select-String -Pattern "SecureAuthOTP" -InputObject $32Bit)){$SecureAuth = "SecureAuth OTP Installation Needed - User must install from their account"}
		    If ((Select-String -Pattern "Tableau" -InputObject $64Bit)-or (Select-String -Pattern "Tableau" -InputObject $32Bit)){$SecureAuth = "Tableau Installation - Licensing Required"}
		    If ((Select-String -Pattern "HP Exstream AFP" -InputObject $64Bit)-or (Select-String -Pattern "HP Exstream AFP" -InputObject $32Bit)){$Exstream = "HP Extream AFP Viewer Installation Needed"}
		    If ((Select-String -Pattern "Articulate Storyline" -InputObject $64Bit)-or (Select-String -Pattern "Articulate Storyline" -InputObject $32Bit)){$Articulate = "Articulate Storyline Installation - Licensing Required"}
		    If ((Select-String -Pattern "Maptitude" -InputObject $64Bit)-or (Select-String -Pattern "Maptitude" -InputObject $32Bit)){$Maptitude = "Maptitude Installation - Licensing Required"}
		    If ((Select-String -Pattern "Gatherer" -InputObject $64Bit)-or (Select-String -Pattern "Gatherer" -InputObject $32Bit)){$Gatherer = "OpenConnect Desktop Gather Installation Needed"}
		    If ((Select-String -Pattern "Verint" -InputObject $64Bit)-or (Select-String -Pattern "Verint" -InputObject $32Bit)){$Verint = "Verint DPA Client Installation Needed"}
		    If ((Select-String -Pattern "Guidance Center Manager" -InputObject $64Bit)-or (Select-String -Pattern "Guidance Center Manager" -InputObject $32Bit)){$GCM = "GCM Installation Needed - Install Zebra drivers, Motorolla drivers and then GCM"} 
			If ((Select-String -Pattern "EndNote" -InputObject $64Bit)-or (Select-String -Pattern "EndNote" -InputObject $32Bit)){$EndNote = "EndNote Installation - Licensing Needed"} 

		    # Array list of applications that come installed on the default image
		    $AppsOnImage = [System.Collections.ArrayList]("1E Agent","1E Nomad Branch Admin Extensions","1E NomadBranch x64","1E Shopping Agent","1E Shopping Client Identity","64Bit Client","ABBYY FineReader 9.0 Sprint","Active Directory Authentication Library for SQL Server","Active Setup","Adobe Acrobat Reader DC (2015) MUI","Adobe Flash Player 30 ActiveX","Adobe Flash Player 30 NPAPI","Adobe Flash Player 31 ActiveX","Adobe Flash Player 31 NPAPI","Adobe Flash Player 32 ActiveX","Adobe Flash Player 32 NPAPI","Adobe PDF iFilter 11 for 64-bit platforms","Adobe Reader XI (11.0.23)","Advanced Tiff Editor","Altova XMLSpy? 2013 rel. 2 sp2 (x64) Integration Package","Application Verifier x64 External Package","Array Networks SSL VPN Client 8","Array Networks VpnApp","Array SSL VPN","Benchmark Factory 7.6.1 x64","Benchmark Factory for Databases X64","BeyondTrust Certificate Installer","BeyondTrust PowerBroker Desktops Client for Windows","BeyondTrust PowerBroker Policy Editor","Cardiocom","Cisco WebEx Meetings","Citrix Authentication Manager","Citrix Receiver (HDX Flash Redirection)","Citrix Receiver 4.4 LTSR","Citrix Receiver 4.9","Citrix Receiver Inside","Citrix Receiver","Citrix Receiver(Aero)","Citrix Receiver(DV)","Citrix Receiver(USB)","Citrix Web Helper","ClickOnce Bootstrapper Package for Microsoft .NET Framework","ClickShare Launcher","Client","Code Tester for Oracle 3.1","Configuration Manager Client","Customer Support","Dell Backup Reporter for Oracle 2.0.2","Dell SQL Optimizer for Oracle","Dell Toad Data Modeler","Desktop & Process Analytics Client(x64) - 15.1.0.2038","DiagnosticsHub_CollectionService","DIG_CGVR_51.0","Digital Guardian Agent","Dolby Audio X2 Windows API SDK","Dolby Audio X2 Windows APP","EasyLink Print2Fax","Entity Framework 6.1.3 Tools  for Visual Studio 15","EU Waste Recycling Information","FireEye Endpoint Agent","Fitbit Connect","Fontsmith Condensed FS Me or Humana Sans for PC 3","GDR 5214 for SQL Server 2014 (KB4057120) (64-bit)","GDR 6260 for SQL Server 2012 (KB4057115) (64-bit)","Git version 2.10.0","Google Update Helper","GoTo Opener","GoToMeeting 6.3.0.1468","GoToMeeting 6.3.1468 IT Installer","Herramientas de correcci?n de Microsoft Office 2016: espa?ol","Hitachi ID Login Assistant","Hitachi ID Password Manager Local Reset Extension","Hotfix 4435 for SQL Server 2016 (KB4019916) (64-bit)","Hotfix 6560 for SQL Server 2008 R2 (KB4057113) (64-bit)","Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946040)","Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946308)","Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB946344)","Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB947540)","Hotfix for Microsoft Visual Studio 2007 Tools for Applications - ENU (KB947789)","Humana GearSync 1.5.114","Humana Outlook 2010 Secure Mail Add-In","Humana Perfect Service Wallpapers","IBM Data Server Driver Package - DSv105","IBM Host On-Demand EHLLAPI Bridge 3.0.5","IBM Installation Manager","IBM WebSphere MQ Explorer V8.0","icecap_collection_neutral","icecap_collection_x64","icecap_collectionresources","icecap_collectionresourcesx64","IIS Express Application Compatibility Database for x64","IIS Express Application Compatibility Database for x86","Impact 360 ILA","Impact 360 ScreenRecording","Information Center","Integrated Camera","Intel(R) Chipset Device Software","Intel(R) Management Engine Components","Intel(R) ME UninstallLegacy","Intel(R) Network Connections Drivers","Intel(R) Processor Graphics","Intel(R) Rapid Storage Technology","Intel(R) USB 3.0 eXtensible Host Controller Driver","Intel(R) Wireless Bluetooth(R)(patch version 18.1.1605.3087)","Intel? Trusted Connect Service Client","IntelliTraceProfilerProxy","iServer Office Add-Ins (x64)","IStream Document Manager","Java 8 Update 121 (64-bit)","Java 8 Update 121","Java Auto Updater","Kits Configuration Installer","Lenovo Auto Scroll Utility","Lenovo Communications Utility","Lenovo On Screen Display","Lenovo Power Management Driver","Lexmark MS310 Series v2 Uninstaller","Lexmark MX310 Series Uninstaller","Lexmark Network Twain Scan Driver","Lexmark Printer Software G3 Scan Driver","Lexmark Printer Software G3 XL Print Driver","Lexmark S300-S400 Series","Lexmark S410 Series Uninstaller","Lexmark Scan Center","Lexmark Universal v2 Print Driver","Local Administrator Password Solution","McAfee Agent","McAfee Data Exchange Layer","McAfee Endpoint Security Adaptive Threat Protection","McAfee Endpoint Security Platform","McAfee Endpoint Security Threat Prevention","McAfee VirusScan Enterprise","Media Plugin","Microsoft .NET Core Host - 2.0.5 (x64)","Microsoft .NET Core Host FX Resolver - 2.0.5 (x64)","Microsoft .NET Core Runtime - 2.0.5 (x64)","Microsoft .NET Core SDK - 2.1.4 (x64)","Microsoft .NET CoreRuntime For CoreCon","Microsoft .NET CoreRuntime SDK","Microsoft .NET Framework 3.5 Targeting Pack (enu)","Microsoft .NET Framework 4 Multi-Targeting Pack","Microsoft .NET Framework 4.5 Multi-Targeting Pack","Microsoft .NET Framework 4.5.1 Multi-Targeting Pack (ENU)","Microsoft .NET Framework 4.5.1 Multi-Targeting Pack","Microsoft .NET Framework 4.5.1 SDK","Microsoft .NET Framework 4.5.2 Multi-Targeting Pack (ENU)","Microsoft .NET Framework 4.5.2 Multi-Targeting Pack","Microsoft .NET Framework 4.5.2","Microsoft .NET Framework 4.6 Targeting Pack","Microsoft .NET Framework 4.6.1 SDK","Microsoft .NET Framework 4.6.1 Targeting Pack","Microsoft .NET Framework 4.6.1","Microsoft .NET Framework 4.6.2 SDK","Microsoft .NET Framework 4.6.2 Targeting Pack (ENU)","Microsoft .NET Framework 4.6.2 Targeting Pack","Microsoft .NET Framework 4.7 SDK","Microsoft .NET Framework 4.7 Targeting Pack (ENU)","Microsoft .NET Framework 4.7 Targeting Pack","Microsoft .NET Framework 4.7.1 Doc Redirected Targeting Pack (ENU)","Microsoft .NET Framework 4.7.1 SDK","Microsoft .NET Framework 4.7.1 Targeting Pack","Microsoft .NET Framework 4.7.1","Microsoft .NET Framework Cumulative Intellisense Pack for Visual Studio (ENU)","Microsoft .NET Native SDK","Microsoft Access database engine 2010 (English)","Microsoft Access MUI (English) 2016","Microsoft Access Setup Metadata MUI (English) 2016","Microsoft Analysis Management Objects","Microsoft Analysis Services ADOMD.NET","Microsoft Analysis Services OLE DB Provider","Microsoft Application Error Reporting","Microsoft Application Virtualization (App-V) Client 5.0 Service Pack 2 x64","Microsoft Application Virtualization (App-V) Client 5.0 Service Pack 2","Microsoft Application Virtualization Client en-US Language Pack x64","Microsoft Application Virtualization Desktop Client","Microsoft App-V 5.0 Client UI","Microsoft AS OLE DB Provider for SQL Server 2016","Microsoft ASP.NET Core 2.0.5 Runtime Package Store (x64)","Microsoft ASP.NET Core Module for IIS Express","Microsoft ASP.NET Diagnostic Pack for Visual Studio","Microsoft ASP.NET Web Tools Packages 15.0 - ENU","Microsoft Azure Compute Emulator - v2.9.5.3","Microsoft Azure Libraries for .NET ? v2.9","Microsoft Azure Mobile App SDK V3.0","Microsoft Build Tools 14.0 (amd64)","Microsoft Build Tools 14.0 (x86)","Microsoft Build Tools Language Resources 14.0 (amd64)","Microsoft Build Tools Language Resources 14.0 (x86)","Microsoft DCF MUI (English) 2016","Microsoft Document Explorer 2008","Microsoft Excel MUI (English) 2016","Microsoft Exchange Web Services Managed API 2.1","Microsoft Groove MUI (English) 2016","Microsoft Help Viewer 1.1","Microsoft Help Viewer 2.2","Microsoft Help Viewer 2.3","Microsoft Identity Extensions","Microsoft InfoPath 2013","Microsoft InfoPath MUI (English) 2013","Microsoft InfoPath MUI (English) 2016","Microsoft Lync 2010 Group Chat","Microsoft Lync 2013","Microsoft Lync MUI (English) 2013","Microsoft MPI (7.1.12437.25)","Microsoft NetStandard SDK","Microsoft ODBC Driver 11 for SQL Server","Microsoft ODBC Driver 13 for SQL Server","Microsoft Office 2010 Deployment Kit for App-V","Microsoft Office 64-bit Components 2013","Microsoft Office 64-bit Components 2016","Microsoft Office Access MUI (English) 2010","Microsoft Office Access Setup Metadata MUI (English) 2010","Microsoft Office Excel MUI (English) 2010","Microsoft Office Groove MUI (English) 2010","Microsoft Office InfoPath MUI (English) 2010","Microsoft Office Office 64-bit Components 2010","Microsoft Office OneNote MUI (English) 2010","Microsoft Office OSM MUI (English) 2013","Microsoft Office OSM MUI (English) 2016","Microsoft Office OSM UX MUI (English) 2016","Microsoft Office Outlook MUI (English) 2010","Microsoft Office PowerPoint MUI (English) 2010","Microsoft Office Professional Plus 2010","Microsoft Office Professional Plus 2016","Microsoft Office Proof (English) 2010","Microsoft Office Proof (French) 2010","Microsoft Office Proof (Spanish) 2010","Microsoft Office Proofing (English) 2010","Microsoft Office Proofing (English) 2013","Microsoft Office Proofing (English) 2016","Microsoft Office Proofing Tools 2013 - English","Microsoft Office Proofing Tools 2013 - Espa?ol","Microsoft Office Proofing Tools 2016 - English","Microsoft Office Publisher MUI (English) 2010","Microsoft Office Shared 64-bit MUI (English) 2010","Microsoft Office Shared 64-bit MUI (English) 2013","Microsoft Office Shared 64-bit MUI (English) 2016","Microsoft Office Shared 64-bit Setup Metadata MUI (English) 2010","Microsoft Office Shared 64-bit Setup Metadata MUI (English) 2013","Microsoft Office Shared 64-bit Setup Metadata MUI (English) 2016","Microsoft Office Shared MUI (English) 2010","Microsoft Office Shared MUI (English) 2013","Microsoft Office Shared MUI (English) 2016","Microsoft Office Shared Setup Metadata MUI (English) 2010","Microsoft Office Shared Setup Metadata MUI (English) 2013","Microsoft Office Shared Setup Metadata MUI (English) 2016","Microsoft Office Word MUI (English) 2010","Microsoft OneNote MUI (English) 2016","Microsoft Outlook MUI (English) 2016","Microsoft Policy Platform","Microsoft Portable Library Multi-Targeting Pack Language Pack - enu","Microsoft Portable Library Multi-Targeting Pack","Microsoft PowerPoint MUI (English) 2016","Microsoft Project MUI (English) 2013","Microsoft Publisher MUI (English) 2016","Microsoft Report Viewer 2012 Runtime","Microsoft Report Viewer 2014 Runtime","Microsoft Report Viewer for SQL Server 2016","Microsoft Report Viewer Redistributable 2008 (KB971119)","Microsoft ReportViewer 2010 SP1 Redistributable (KB2549864)","Microsoft Silverlight","Microsoft Skype for Business 2016","Microsoft Skype for Business MUI (English) 2016","Microsoft SQL Server 2005 Backward compatibility","Microsoft SQL Server 2008 Browser","Microsoft SQL Server 2008 Common Files","Microsoft SQL Server 2008 Database Engine Services","Microsoft SQL Server 2008 Database Engine Shared","Microsoft SQL Server 2008 Native Client","Microsoft SQL Server 2008 R2 Books Online","Microsoft SQL Server 2008 R2 Management Objects","Microsoft SQL Server 2008 R2 Native Client","Microsoft SQL Server 2008 R2 Policies","Microsoft SQL Server 2008 R2 Setup (English)","Microsoft SQL Server 2008 RsFx Driver","Microsoft SQL Server 2008 Setup Support Files","Microsoft SQL Server 2008","Microsoft SQL Server 2012 (64-bit)","Microsoft SQL Server 2012 Analysis Management Objects","Microsoft SQL Server 2012 Command Line Utilities","Microsoft SQL Server 2012 Data-Tier App Framework","Microsoft SQL Server 2012 Management Objects  (x64)","Microsoft SQL Server 2012 Management Objects","Microsoft SQL Server 2012 Native Client","Microsoft SQL Server 2012 Policies","Microsoft SQL Server 2012 Setup (English)","Microsoft SQL Server 2012 Transact-SQL Compiler Service","Microsoft SQL Server 2012 Transact-SQL ScriptDom","Microsoft SQL Server 2012 T-SQL Language Service","Microsoft SQL Server 2014 (64-bit)","Microsoft SQL Server 2014 Analysis Management Objects","Microsoft SQL Server 2014 Management Objects","Microsoft SQL Server 2014 Policies","Microsoft SQL Server 2014 Setup (English)","Microsoft SQL Server 2014 Transact-SQL Compiler Service","Microsoft SQL Server 2014 Transact-SQL ScriptDom","Microsoft SQL Server 2016 ADOMD.NET","Microsoft SQL Server 2016 Analysis Management Objects","Microsoft SQL Server 2016 LocalDB","Microsoft SQL Server 2016 Management Objects  (x64)","Microsoft SQL Server 2016 Management Objects","Microsoft SQL Server 2016 Setup (English)","Microsoft SQL Server 2016 T-SQL Language Service","Microsoft SQL Server 2016 T-SQL ScriptDom","Microsoft SQL Server 2017 Policies","Microsoft SQL Server 2017 T-SQL Language Service","Microsoft SQL Server Compact 3.5 SP2 ENU","Microsoft SQL Server Compact 3.5 SP2 Query Tools ENU","Microsoft SQL Server Compact 3.5 SP2 x64 ENU","Microsoft SQL Server Data Tools - enu (14.0.60525.0)","Microsoft SQL Server Data Tools - enu (14.0.61712.050)","Microsoft SQL Server Data Tools - Visual Studio 2015","Microsoft SQL Server Data Tools 2015","Microsoft SQL Server Data-Tier Application Framework (x86)","Microsoft SQL Server Management Studio - 17.3","Microsoft SQL Server System CLR Types (x64)","Microsoft SQL Server System CLR Types","Microsoft SQL Server VSS Writer","Microsoft System CLR Types for SQL Server 2012 (x64)","Microsoft System CLR Types for SQL Server 2012","Microsoft System CLR Types for SQL Server 2014 (x64)","Microsoft System CLR Types for SQL Server 2014","Microsoft System CLR Types for SQL Server 2016","Microsoft System CLR Types for SQL Server 2017","Microsoft UniversalWindowsPlatform SDK","Microsoft Visio MUI (English) 2013","Microsoft Visio MUI (English) 2016","Microsoft Visio Viewer 2013","Microsoft Visio Viewer 2016","Microsoft Visual C++ 2005 Redistributable (x64)","Microsoft Visual C++ 2005 Redistributable","Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.17","Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.4148","Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161","Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.17","Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4148","Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.6161","Microsoft Visual C++ 2010  x64 Redistributable - 10.0.40219","Microsoft Visual C++ 2010  x86 Redistributable - 10.0.40219","Microsoft Visual C++ 2010  x86 Runtime - 10.0.40219","Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.60610","Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.61030","Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.60610","Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.61030","Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.60610","Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030","Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.60610","Microsoft Visual C++ 2012 x64 Minimum Runtime - 11.0.61030","Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.60610","Microsoft Visual C++ 2012 x86 Additional Runtime - 11.0.61030","Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.60610","Microsoft Visual C++ 2012 x86 Minimum Runtime - 11.0.61030","Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005","Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.30501","Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40660","Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005","Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.30501","Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40660","Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.21005","Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40660","Microsoft Visual C++ 2013 x64 Debug Runtime - 12.0.21005","Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.21005","Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40660","Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.21005","Microsoft Visual C++ 2013 x86 Additional Runtime - 12.0.40660","Microsoft Visual C++ 2013 x86 Debug Runtime - 12.0.21005","Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.21005","Microsoft Visual C++ 2013 x86 Minimum Runtime - 12.0.40660","Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.23026","Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.23816","Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.23026","Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.23816","Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.23026","Microsoft Visual C++ 2015 x64 Additional Runtime - 14.0.23816","Microsoft Visual C++ 2015 x64 Debug Runtime - 14.0.23026","Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026","Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23816","Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.23026","Microsoft Visual C++ 2015 x86 Additional Runtime - 14.0.23816","Microsoft Visual C++ 2015 x86 Debug Runtime - 14.0.23026","Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.23026","Microsoft Visual C++ 2015 x86 Minimum Runtime - 14.0.23816","Microsoft Visual C++ 2017 Redistributable (x64) - 14.10.25017","Microsoft Visual C++ 2017 Redistributable (x64) - 14.12.25810","Microsoft Visual C++ 2017 Redistributable (x86) - 14.10.25017","Microsoft Visual C++ 2017 Redistributable (x86) - 14.12.25810","Microsoft Visual C++ 2017 x64 Additional Runtime - 14.10.25017","Microsoft Visual C++ 2017 x64 Additional Runtime - 14.12.25810","Microsoft Visual C++ 2017 x64 Debug Runtime - 14.12.25810","Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.10.25017","Microsoft Visual C++ 2017 x64 Minimum Runtime - 14.12.25810","Microsoft Visual C++ 2017 x86 Additional Runtime - 14.10.25017","Microsoft Visual C++ 2017 x86 Additional Runtime - 14.12.25810","Microsoft Visual C++ 2017 x86 Debug Runtime - 14.12.25810","Microsoft Visual C++ 2017 x86 Minimum Runtime - 14.10.25017","Microsoft Visual C++ 2017 x86 Minimum Runtime - 14.12.25810","Microsoft Visual J# 2.0 Redistributable Package - SE (x64)","Microsoft Visual Studio 2005 Tools for Office Runtime","Microsoft Visual Studio 2008 Shell (integrated mode) - ENU","Microsoft Visual Studio 2008 Team Explorer - ENU Service Pack 1 (KB945140)","Microsoft Visual Studio 2008 Team Explorer - ENU","Microsoft Visual Studio 2010 Shell (Integrated) - ENU","Microsoft Visual Studio 2010 Shell (Isolated) - ENU","Microsoft Visual Studio 2010 Tools for Office Runtime (x64)","Microsoft Visual Studio 2015 Devenv Resources","Microsoft Visual Studio 2015 Devenv","Microsoft Visual Studio 2015 Preparation","Microsoft Visual Studio 2015 Shell (Integrated)","Microsoft Visual Studio 2015 Shell (Isolated) Resources","Microsoft Visual Studio 2015 Shell (Isolated)","Microsoft Visual Studio 2015 Shell (Minimum) Interop Assemblies","Microsoft Visual Studio 2015 Shell (Minimum) Resources","Microsoft Visual Studio 2015 XAML Designer - ENU","Microsoft Visual Studio 2015 XAML Designer","Microsoft Visual Studio Installer","Microsoft Visual Studio Services Hub","Microsoft Visual Studio Setup Configuration","Microsoft Visual Studio Team Foundation Server 2015 Power Tools","Microsoft Visual Studio Team Foundation Server 2017 Office Integration Language Pack (x64) - ENU","Microsoft Visual Studio Tools for Applications 2.0 - ENU","Microsoft Visual Studio Tools for Applications 2015 Design-Time","Microsoft Visual Studio Tools for Applications 2015 Finalizer","Microsoft Visual Studio Tools for Applications 2015 Language Support","Microsoft Visual Studio Tools for Applications 2015 Language Support - ENU Language Pack","Microsoft Visual Studio Tools for Applications 2015 Language Support Finalizer","Microsoft Visual Studio Tools for Applications 2015 x64 Hosting Support","Microsoft Visual Studio Tools for Applications 2015 x86 Hosting Support","Microsoft Visual Studio Tools for Applications 2015","Microsoft Visual Studio Tools for Applications Design-Time 3.0","Microsoft Visual Studio Tools for Applications x86 Runtime 3.0","Microsoft Web Deploy 3.6","Microsoft Windows Communication Foundation Diagnostic Pack for x86","Microsoft Word MUI (English) 2016","Microsoft Workflow Debugger v1.0 for amd64","Microsoft Workflow Debugger v1.0 for x86","Microsoft Workflow Diagnostic Pack for x64","Microsoft WSE 2.0 SP3 Runtime","Microsoft WSE 3.0 Runtime","Mozilla Firefox 45.3.0 ESR (x86 en-US)","Mozilla Firefox 52.0.2 ESR (x86 en-US)","Mozilla Firefox 52.7.3 ESR (x64 en-US)","Mozilla Maintenance Service","MSI Development Tools","MSXML 4.0 SP3 Parser (KB2758694)","MSXML 4.0 SP3 Parser","Network Recording Player","Nuance PDF Create 8","On Screen Display","Online Plug-in","Open XML SDK 2.5 for Microsoft Office","OpenText Print2Fax","Oracle iStream Communicator ActiveX Patch 1.1.0.5","Outils de v?rification linguistique 2013 de Microsoft Office?- Fran?ais","Outils de v?rification linguistique 2016 de Microsoft Office?- Fran?ais","Postman-win64-6.1.4","Power Manager","Prerequisites for SSDT","Python Launcher","Quest Backup Reporter 1.5","Quest Software Toad Data Modeler","Quest Software Toad for MySQL Freeware 6.3","Quest SQL Optimizer for Oracle","Quest Toad Data Modeler (x86)","Realtek High Definition Audio Driver","Recast RCT","RED HIGHLIGHT DON'T INSTALL","Reliability Update for Microsoft .NET Framework 4.5.2 (KB3179930)","Reliability Update for Microsoft .NET Framework 4.6.1 (KB3179949)","RightFax Print Processor x64","RightFax Product Suite - Client","Roslyn Language Services - x86","Scansoft PDF Create","Screen Capture Module","SDK ARM Additions","SDK ARM Redistributables","SDK Debuggers","SecureDoc Disk Encryption (x64) 6.2 SR2","SecureDoc Disk Encryption (x64) 6.5 SR3","SecureDoc Disk Encryption (x64) 7.1SR1","SecureDoc Disk Encryption (x64) 7.1SR4","SecureDoc Disk Encryption (x64) 7.5","Security Update for Microsoft .NET Framework 4.6.1 (KB3136000v2)","Security Update for Microsoft .NET Framework 4.6.1 (KB4014558)","Security Update for Microsoft .NET Framework 4.6.1 (KB4014591)","Security Update for Microsoft .NET Framework 4.6.1 (KB4096237)","Security Update for Microsoft .NET Framework 4.6.1 (KB4344167)","Security Update for Microsoft .NET Framework 4.6.1 (KB4457027)","Security Update for Microsoft .NET Framework 4.7.1 (KB4054183)","Security Update for Microsoft .NET Framework 4.7.1 (KB4096237)","Security Update for Microsoft .NET Framework 4.7.1 (KB4338606)","Security Update for Microsoft .NET Framework 4.7.1 (KB4344167)","Security Update for Microsoft .NET Framework 4.7.1 (KB4457027)","Security Update for Microsoft Access 2010 (KB3114416) 32-Bit Edition","Security Update for Microsoft Access 2016 (KB4018338) 32-Bit Edition","Security Update for Microsoft Excel 2010 (KB4461466) 32-Bit Edition","Security Update for Microsoft Excel 2010 (KB4461577) 32-Bit Edition","Security Update for Microsoft Excel 2010 (KB4462186) 32-Bit Edition","Security Update for Microsoft Excel 2013 (KB4461460) 32-Bit Edition","Security Update for Microsoft Excel 2013 (KB4461559) 32-Bit Edition","Security Update for Microsoft Excel 2013 (KB4461597) 32-Bit Edition","Security Update for Microsoft Excel 2013 (KB4461597) 32-Bit Edition","Security Update for Microsoft Excel 2013 (KB4461597) 32-Bit Edition","Security Update for Microsoft Excel 2016 (KB4461448) 32-Bit Edition","Security Update for Microsoft Excel 2016 (KB4461503) 32-Bit Edition","Security Update for Microsoft InfoPath 2010 (KB3114414) 32-Bit Edition","Security Update for Microsoft InfoPath 2013 (KB3114833) 32-Bit Edition","Security Update for Microsoft InfoPath 2013 (KB3162075) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2553313) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2553332) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2553332) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2553332) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2553332) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2850016) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2880971) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2881029) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2956063) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2956073) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB2956076) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3085528) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3114565) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3114874) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3115120) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3115197) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3115248) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3191908) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3203468) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3213626) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3213631) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB3213636) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4011610) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4018313) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4018313) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4022199) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4022206) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4022208) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4092483) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4461570) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4462174) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4462174) 32-Bit Edition","Security Update for Microsoft Office 2010 (KB4462177) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB2726958) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB2760272) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB2880463) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB2880463) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB2880463) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3039782) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3039794) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3039798) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3054816) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3115153) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3172459) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3172522) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3172522) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3172522) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3172522) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3172522) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3172522) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB3213564) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4011580) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018300) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018300) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018300) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018300) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018300) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018300) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018387) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4022188) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4022189) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4461445) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4462138) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4462138) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4462138) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4462138) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4462138) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4462138) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB2920727) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB3085538) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB3114690) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB3115135) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB3213551) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4011143) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4011574) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4011628) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4022172) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4022176) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4022177) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4022232) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4461437) 32-Bit Edition","Security Update for Microsoft OneNote 2010 (KB3054978) 32-Bit Edition","Security Update for Microsoft OneNote 2010 (KB3114885) 32-Bit Edition","Security Update for Microsoft OneNote 2013 (KB3115256) 32-Bit Edition","Security Update for Microsoft Outlook 2010 (KB4227170) 32-Bit Edition","Security Update for Microsoft Outlook 2010 (KB4461576) 32-Bit Edition","Security Update for Microsoft Outlook 2010 (KB4461623) 32-Bit Edition","Security Update for Microsoft Outlook 2013 (KB4092477) 32-Bit Edition","Security Update for Microsoft Outlook 2013 (KB4461556) 32-Bit Edition","Security Update for Microsoft Outlook 2013 (KB4461595) 32-Bit Edition","Security Update for Microsoft Outlook 2013 (KB4461595) 32-Bit Edition","Security Update for Microsoft Outlook 2013 (KB4461595) 32-Bit Edition","Security Update for Microsoft Outlook 2016 (KB4461440) 32-Bit Edition","Security Update for Microsoft Outlook 2016 (KB4461544) 32-Bit Edition","Security Update for Microsoft PowerPoint 2010 (KB2920812) 32-Bit Edition","Security Update for Microsoft PowerPoint 2010 (KB4092482) 32-Bit Edition","Security Update for Microsoft PowerPoint 2010 (KB4461521) 32-Bit Edition","Security Update for Microsoft PowerPoint 2016 (KB4461434) 32-Bit Edition","Security Update for Microsoft PowerPoint 2016 (KB4461532) 32-Bit Edition","Security Update for Microsoft Project 2013 (KB3101506) 32-Bit Edition","Security Update for Microsoft Project 2013 (KB4461489) 32-Bit Edition","Security Update for Microsoft Project 2016 (KB4461478) 32-Bit Edition","Security Update for Microsoft Publisher 2010 (KB4011186) 32-Bit Edition","Security Update for Microsoft SharePoint Designer 2010 (KB2810069) 32-Bit Edition","Security Update for Microsoft Visio 2010 (KB3114872) 32-Bit Edition","Security Update for Microsoft Visio 2013 (KB3115020) 32-Bit Edition","Security Update for Microsoft Visio Viewer 2010 (KB2999465) 32-Bit Edition","Security Update for Microsoft Word 2010 (KB2965313) 32-Bit Edition","Security Update for Microsoft Word 2010 (KB4092439) 32-Bit Edition","Security Update for Microsoft Word 2010 (KB4461526) 32-Bit Edition","Security Update for Microsoft Word 2010 (KB4461625) 32-Bit Edition","Security Update for Microsoft Word 2010 (KB4461625) 32-Bit Edition","Security Update for Microsoft Word 2010 (KB4461625) 32-Bit Edition","Security Update for Microsoft Word 2010 (KB4461625) 32-Bit Edition","Security Update for Microsoft Word 2013 (KB4461457) 32-Bit Edition","Security Update for Microsoft Word 2013 (KB4461485) 32-Bit Edition","Security Update for Microsoft Word 2013 (KB4461594) 32-Bit Edition","Security Update for Microsoft Word 2016 (KB4461449) 32-Bit Edition","Security Update for Microsoft Word 2016 (KB4461504) 32-Bit Edition","Security Update for Skype for Business 2015 (KB3191937) 32-Bit Edition","Security Update for Skype for Business 2015 (KB3213568) 32-Bit Edition","Security Update for Skype for Business 2015 (KB4022225) 32-Bit Edition","Security Update for Skype for Business 2015 (KB4461487) 32-Bit Edition","Security Update for Skype for Business 2016 (KB4461473) 32-Bit Edition","Self-service Plug-in","Service Pack 1 for Microsoft Office 2013 (KB2817430) 32-Bit Edition","Service Pack 1 for Microsoft Office 2013 (KB2850036) 32-Bit Edition","Service Pack 1 for SQL Server 2008 (KB968369)","Service Pack 1 for SQL Server 2016 (KB3182545) (64-bit)","Service Pack 2 for Microsoft Office 2010 (KB2687455) 32-Bit Edition","Service Pack 2 for Microsoft Office 2010 for Client Applications (KB2687471) 32-Bit Edition","Service Pack 2 for SQL Server 2014 (KB3171021) (64-bit)","Service Pack 3 for SQL Server 2008 R2 (KB2979597) (64-bit)","Service Pack 3 for SQL Server 2012 (KB3072779) (64-bit)","Skype for Business 2016","Slack Machine-Wide Installer","Spotlight on Oracle (64 bit)","sptools_Microsoft.VisualStudio.OfficeDeveloperTools.Msi","sptools_Microsoft.VisualStudio.Vsto.Msi","sptools_Microsoft.VisualStudio.Vsto.Msi.Resources","sptools_Microsoft.VisualStudio.Vsto.Msi.x64","SQL Server 2008 R2 BI Development Studio","SQL Server 2008 R2 Common Files","SQL Server 2008 R2 SP2 Client Tools","SQL Server 2008 R2 SP2 Common Files","SQL Server 2008 R2 SP2 Management Studio","SQL Server 2012 BI Development Studio","SQL Server 2012 Client Tools","SQL Server 2012 Common Files","SQL Server 2012 Documentation Components","SQL Server 2012 Management Studio","SQL Server 2012 SQL Data Quality Common","SQL Server 2014 Client Tools","SQL Server 2014 Common Files","SQL Server 2014 Documentation Components","SQL Server 2016 Batch Parser","SQL Server 2016 Client Tools Extensions","SQL Server 2016 Client Tools","SQL Server 2016 Common Files","SQL Server 2016 Connection Info","SQL Server 2016 Documentation Components","SQL Server 2016 Shared Management Objects Extensions","SQL Server 2016 Shared Management Objects","SQL Server 2016 SQL Diagnostics","SQL Server 2016 XEvent","SQL Server 2017 Batch Parser","SQL Server 2017 Client Tools Extensions","SQL Server 2017 Common Files","SQL Server 2017 Connection Info","SQL Server 2017 DMF","SQL Server 2017 Integration Services Scale Out Management Portal","SQL Server 2017 Management Studio Extensions","SQL Server 2017 Shared Management Objects Extensions","SQL Server 2017 Shared Management Objects","SQL Server 2017 SQL Diagnostics","Sql Server Customer Experience Improvement Program","SQL Server Data Tools Analysis Services","SQL Server Data Tools Reporting Services","SQL Server Integration Services 2012","SQL Server Integration Services 2014","SQL Server Integration Services 2016","SQL Server Integration Services","SQL Server Management Studio for Analysis Services","SQL Server Management Studio for Reporting Services","SSDT","SSMS Post Install Tasks","Stamps.com Address Book Support for ACT! 3.05 - 6.0","Stamps.com Address Book Support for ACT! 7.0 - 13.0","Stamps.com Address Book Support for Common Harmony","Stamps.com Address Book Support for Daytimer Organizer 98","Stamps.com Address Book Support for Intuit QuickBooks 2004-2013","Stamps.com Address Book Support for Lotus Organizer 97","Stamps.com Address Book Support for Microsoft Outlook 97-2013","Stamps.com Address Book Support for Outlook Express","Stamps.com Address Book Support for Schedule Plus 7.x","Stamps.com Address Book Support for Windows Contacts for Vista","Stamps.com Application Support for Corel WordPerfect 8","Stamps.com Application Support for Corel WordPerfect 9","Stamps.com Application Support for Microsoft Outlook 2000-2013","Stamps.com Application Support for Microsoft Word 2000-2013","Stamps.com support for ACT! 3.05 - 6.0","Stamps.com support for ACT! 7.0 - 13.0","Stamps.com support for Corel WordPerfect 8","Stamps.com support for Corel WordPerfect 9","Stamps.com support for Daytimer Organizer 98","Stamps.com support for Harmony","Stamps.com support for Intuit QuickBooks 2004-2013","Stamps.com support for Lotus Organizer 97","Stamps.com support for Microsoft Outlook 2000-2013","Stamps.com support for Microsoft Outlook 97-2013","Stamps.com support for Microsoft Word 2000-2013","Stamps.com support for Outlook Express","Stamps.com support for Schedule Plus 7.x","Stamps.com support for Windows Contacts for Vista","Synaptics Pointing Device Driver","System Center Configuration Manager Console","Systems Management Agent","Team Foundation Server Office Integration 2017","ThinkPad UltraNav Driver","ThinkPad WiFi Radio Control","TITUS Classification (64 bit)","TITUS Classification","Toad for MySQL Freeware 7.5","Tools for .Net 3.5","TypeScript Power Tool","TypeScript SDK","TypeScript Tools for Microsoft Visual Studio 2015 2.2.1.0","Universal CRT Extension SDK","Universal CRT Headers Libraries and Sources","Universal CRT Redistributable","Universal CRT Tools x64","Universal CRT Tools x86","Universal General MIDI DLS Extension SDK","UniversalForwarder","Update for  (KB2504637)","Update for Microsoft .NET Framework 4.5.2 (KB3210139)","Update for Microsoft .NET Framework 4.5.2 (KB4014514)","Update for Microsoft .NET Framework 4.5.2 (KB4014559)","Update for Microsoft .NET Framework 4.5.2 (KB4040977)","Update for Microsoft .NET Framework 4.5.2 (KB4054995)","Update for Microsoft .NET Framework 4.5.2 (KB4096495)","Update for Microsoft .NET Framework 4.5.2 (KB4338417)","Update for Microsoft .NET Framework 4.5.2 (KB4344149)","Update for Microsoft .NET Framework 4.6.1 (KB3210136)","Update for Microsoft .NET Framework 4.6.1 (KB4014511)","Update for Microsoft .NET Framework 4.6.1 (KB4014553)","Update for Microsoft .NET Framework 4.6.1 (KB4040973)","Update for Microsoft .NET Framework 4.6.1 (KB4041778)","Update for Microsoft .NET Framework 4.6.1 (KB4074880)","Update for Microsoft .NET Framework 4.6.1 (KB4096418)","Update for Microsoft .NET Framework 4.6.1 (KB4338420)","Update for Microsoft .NET Framework 4.6.1 (KB4344146)","Update for Microsoft .NET Framework 4.6.1 (KB4457035)","Update for Microsoft .NET Framework 4.6.1 (KB4470640)","Update for Microsoft .NET Framework 4.7.1 (KB4074880)","Update for Microsoft .NET Framework 4.7.1 (KB4096418)","Update for Microsoft .NET Framework 4.7.1 (KB4338420)","Update for Microsoft .NET Framework 4.7.1 (KB4344146)","Update for Microsoft .NET Framework 4.7.1 (KB4457035)","Update for Microsoft .NET Framework 4.7.1 (KB4470640)","Update for Microsoft .NET Framework 4.7.1 (KB4480055)","Update for Microsoft Office 2010 (KB2553092)","Update for Microsoft Office 2010 (KB2760631) 32-Bit Edition","Update for Microsoft Office 2010 (KB3054873) 32-Bit Edition","Update for Microsoft Office 2013 (KB3115156) 32-Bit Edition","Update for Microsoft Office 2016 (KB2910954) 32-Bit Edition","Update for Microsoft Office 2016 (KB2920678) 32-Bit Edition","Update for Microsoft Office 2016 (KB2920684) 32-Bit Edition","Update for Microsoft Office 2016 (KB2920712) 32-Bit Edition","Update for Microsoft Office 2016 (KB2920720) 32-Bit Edition","Update for Microsoft Office 2016 (KB2920724) 32-Bit Edition","Update for Microsoft Office 2016 (KB3114853) 32-Bit Edition","Update for Microsoft Office 2016 (KB3114903) 32-Bit Edition","Update for Microsoft Office 2016 (KB3115081) 32-Bit Edition","Update for Microsoft Office 2016 (KB3115276) 32-Bit Edition","Update for Microsoft Office 2016 (KB3118262) 32-Bit Edition","Update for Microsoft Office 2016 (KB3118263) 32-Bit Edition","Update for Microsoft Office 2016 (KB3118264) 32-Bit Edition","Update for Microsoft Office 2016 (KB3141457) 32-Bit Edition","Update for Microsoft Office 2016 (KB3141506) 32-Bit Edition","Update for Microsoft Office 2016 (KB3178662) 32-Bit Edition","Update for Microsoft Office 2016 (KB3178666) 32-Bit Edition","Update for Microsoft Office 2016 (KB3191864) 32-Bit Edition","Update for Microsoft Office 2016 (KB3191929) 32-Bit Edition","Update for Microsoft Office 2016 (KB3203479) 32-Bit Edition","Update for Microsoft Office 2016 (KB3213650) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011035) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011218) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011225) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011259) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011569) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011630) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011634) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011667) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011669) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011670) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011671) 32-Bit Edition","Update for Microsoft Office 2016 (KB4018371) 32-Bit Edition","Update for Microsoft Office 2016 (KB4022133) 32-Bit Edition","Update for Microsoft Office 2016 (KB4022193) 32-Bit Edition","Update for Microsoft Office 2016 (KB4022215) 32-Bit Edition","Update for Microsoft Office 2016 (KB4022223) 32-Bit Edition","Update for Microsoft Office 2016 (KB4032237) 32-Bit Edition","Update for Microsoft Office 2016 (KB4092449) 32-Bit Edition","Update for Microsoft Office 2016 (KB4461436) 32-Bit Edition","Update for Microsoft Office 2016 (KB4461442) 32-Bit Edition","Update for Microsoft OneDrive for Business (KB4022219) 32-Bit Edition","Update for Microsoft OneNote 2016 (KB4022216) 32-Bit Edition","Update for Microsoft PowerPoint 2016 (KB4011726) 32-Bit Edition","Update for Microsoft Project 2016 (KB4032238) 32-Bit Edition","Update for Microsoft Publisher 2016 (KB3178696) 32-Bit Edition","Update for Microsoft Visio 2016 (KB4011661) 32-Bit Edition","Update for Microsoft Visio 2016 (KB4018325) 32-Bit Edition","Update for Microsoft Visio 2016 (KB4032228) 32-Bit Edition","Update for Microsoft Visual Studio 2015 (KB3095681)","Update for Skype for Business 2016 (KB4032255) 32-Bit Edition","vcpp_crt.redist.clickonce","Visual C++ 2008 IA64 Runtime - (v9.0.30729)","Visual C++ 2008 IA64 Runtime - v9.0.30729.01","Visual C++ 2008 x64 Runtime - (v9.0.30729)","Visual C++ 2008 x64 Runtime - v9.0.30729.01","Visual C++ 2008 x86 Runtime - (v9.0.30729)","Visual C++ 2008 x86 Runtime - v9.0.30729.01","Visual C++ Library CRT Appx Package","Visual C++ Library CRT Appx Resource Package","Visual C++ Library CRT ARM64 Appx Package","Visual C++ Library CRT Desktop Appx Package","Visual F# 4.1 SDK","Visual Studio 2005 Tools for Office Second Edition Runtime","Visual Studio 2010 Prerequisites - English","Visual Studio 2015 Prerequisites - ENU Language Pack","Visual Studio 2015 Prerequisites","Visual Studio Tools for the Office system 3.0 Runtime Service Pack 1 (KB949258)","Visual Studio Tools for the Office system 3.0 Runtime","VLC media player","VoiceRite Client 3.7.53","VoiceRite Desktop Client","VS Immersive Activate Helper","VS JIT Debugger","VS Script Debugging Common","VS WCF Debugging","vs_BlendMsi","vs_clickoncebootstrappermsi","vs_clickoncebootstrappermsires","vs_clickoncesigntoolmsi","vs_codecoveragemsi","vs_codeduitestframeworkmsi","vs_communitymsi","vs_communitymsires","vs_cuitcommoncoremsi","vs_cuitextensionmsi","vs_cuitextensionmsi_x64","vs_devenvmsi","vs_enterprisemsi","vs_filehandler_amd64","vs_filehandler_x86","vs_FileTracker_Singleton","vs_Graphics_Singletonx64","vs_Graphics_Singletonx86","vs_helpconfigmsi","vs_labtestagentdeployermsi","vs_microsofttestmanagermsi","vs_minshellinteropmsi","vs_minshellmsi","vs_minshellmsires","vs_networkemulationmsi_x64","vs_professionalmsi","vs_SQLClickOnceBootstrappermsi","vs_tipsmsi","Vulkan Run Time Libraries 1.0.33.0""Vulkan Run Time Libraries 1.0.65.1","Vulkan Run Time Libraries 1.1.70.1","WinAppDeploy","WinBatch","Windows App Certification Kit Native Components","Windows App Certification Kit SupportedApiList x86","Windows App Certification Kit x64","Windows Desktop Extension SDK Contracts","Windows Desktop Extension SDK","Windows Driver Package - Lexmark Image  (07/27/2012 7.0.0.0)","Windows Driver Package - Lexmark Image(07/27/2012 7.0.0.0)","Windows Driver Package - Lexmark Image(07/27/2012 7.0.0.0)","Windows Driver Package - Lexmark Image(07/27/2012 7.0.0.0)","Windows Driver Package - Lexmark Image(07/27/2012 7.0.0.0)","Windows Driver Package - Lexmark International Image  (04/21/2009 1.1.0.0)","Windows Driver Package - Lexmark International Image(04/21/2009 1.1.0.0)","Windows Driver Package - Lexmark International Printer  (01/28/2016 3.0.0.0)","Windows Driver Package - Lexmark International Printer  (05/01/2013 2.9.0.0)","Windows Driver Package - Lexmark International Printer  (07/27/2012 2.7.0.0)","Windows Driver Package - Lexmark International Printer  (10/01/2009 2.3.4.0)","Windows Driver Package - Lexmark International Printer  (11/01/2009 2.2.1.0)","Windows Driver Package - Lexmark International Printer  (11/01/2009 2.3.1.0)","Windows Driver Package - Lexmark International Printer  (11/01/2009 2.4.1.0)","Windows Driver Package - Lexmark International Printer(05/01/2013 2.9.0.0)","Windows Driver Package - Lexmark International Printer(07/27/2012 2.7.0.0)","Windows Driver Package - Lexmark International Printer(07/27/2012 2.7.0.0)","Windows Driver Package - Lexmark International Printer(07/27/2012 2.7.0.0)","Windows Driver Package - Lexmark International Printer(07/27/2012 2.7.0.0)","Windows Driver Package - Lexmark International Printer(11/01/2009 2.2.1.0)","Windows Driver Package - Lexmark International Printer(11/01/2009 2.3.1.0)","Windows Driver Package - Lexmark International Printer(11/01/2009 2.4.1.0)","Windows IoT Extension SDK Contracts","Windows IoT Extension SDK","Windows IP Over USB","Windows Mobile Extension SDK Contracts","Windows Mobile Extension SDK","Windows Phone SDK 8.0 Assemblies for Visual Studio 2017","Windows SDK AddOn","Windows SDK ARM Desktop Tools","Windows SDK Desktop Headers arm","Windows SDK Desktop Headers arm64","Windows SDK Desktop Headers x64","Windows SDK Desktop Headers x86","Windows SDK Desktop Libs arm","Windows SDK Desktop Libs arm64","Windows SDK Desktop Libs x64","Windows SDK Desktop Libs x86","Windows SDK Desktop Tools arm64","Windows SDK Desktop Tools x64","Windows SDK Desktop Tools x86","Windows SDK DirectX x64 Remote","Windows SDK DirectX x86 Remote","Windows SDK EULA","Windows SDK Facade Windows WinMD Versioned","Windows SDK for Windows Store Apps Contracts","Windows SDK for Windows Store Apps DirectX x64 Remote","Windows SDK for Windows Store Apps DirectX x86 Remote","Windows SDK for Windows Store Apps Headers","Windows SDK for Windows Store Apps Libs","Windows SDK for Windows Store Apps Metadata","Windows SDK for Windows Store Apps Tools","Windows SDK for Windows Store Apps","Windows SDK for Windows Store Managed Apps Libs","Windows SDK Modern Non-Versioned Developer Tools","Windows SDK Modern Versioned Developer Tools","Windows SDK Redistributables","Windows SDK Signing Tools","Windows Simulator - ENU","Windows Simulator","Windows Software Development Kit - Windows 10.0.15063.137","Windows Software Development Kit - Windows 10.0.16299.15","Windows Team Extension SDK Contracts","Windows Team Extension SDK","windows_toolscorepkg","WinRT Intellisense Desktop - en-us","WinRT Intellisense Desktop - Other Languages","WinRT Intellisense IoT - en-us","WinRT Intellisense IoT - Other Languages","WinRT Intellisense Mobile - en-us","WinRT Intellisense PPI - en-us","WinRT Intellisense PPI - Other Languages","WinRT Intellisense UAP - en-us","WinRT Intellisense UAP - Other Languages","WinSCP 5.8.2 beta","Workflow Manager Client 1.0","Workflow Manager Tools 1.0 for Visual Studio","Workstation ID 7.0.6","WPT Redistributables","WPTx64","Xamarin Android SDK Manager","Xamarin PCL Profiles v1.0.9","Xamarin Profiler","Xamarin Remoted iOS Simulator","Xamarin Workbooks and Inspector","rtAudioVideoPlugin","Update for Microsoft .NET Framework 4.7.1 (KB4483451)","Microsoft Visual C++ 2010x64 Redistributable - 10.0.40219","Security Update for Microsoft Excel 2016 (KB4462115) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4018294) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4022162) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4462146) 32-Bit Edition","Security Update for Microsoft Outlook 2016 (KB4461601) 32-Bit Edition","Security Update for Microsoft Word 2016 (KB4461543) 32-Bit Edition","SQL Server vNext CTP2.0 Common Files","SQL Server vNext CTP2.0 Management Studio Extensions","SQL Server vNext CTP2.0 Batch Parser","SQL Server vNext CTP2.0 Client Tools Extensions","SQL Server vNext CTP2.0 Connection Info","SQL Server vNext CTP2.0 DMF","SQL Server vNext CTP2.0 Shared Management Objects","SQL Server vNext CTP2.0 Shared Management Objects Extensions","SQL Server vNext CTP2.0 SQL Diagnostics","SQL Server vNext CTP2.0 XEvent","Security Update for Microsoft Access 2016 (KB4011665) 32-Bit Edition","Security Update for Microsoft Excel 2013 (KB4022191) 32-Bit Edition","Security Update for Microsoft Excel 2016 (KB4022174) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4011253) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4011254) 32-Bit Edition","Security Update for Microsoft Office 2013 (KB4018330) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB3178667) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4011126) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4011237) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4011239) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4011622) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4018319) 32-Bit Edition","Security Update for Microsoft Office 2016 (KB4018328) 32-Bit Edition","Security Update for Microsoft OneNote 2016 (KB3115419) 32-Bit Edition","Security Update for Microsoft Outlook 2013 (KB4022169) 32-Bit Edition","Security Update for Microsoft Outlook 2016 (KB4022160) 32-Bit Edition","Security Update for Microsoft PowerPoint 2016 (KB4011041) 32-Bit Edition","Security Update for Microsoft Project 2016 (KB2920698) 32-Bit Edition","Security Update for Microsoft Publisher 2016 (KB2920680) 32-Bit Edition","Security Update for Microsoft Visio 2016 (KB3115041) 32-Bit Edition","Security Update for Microsoft Word 2016 (KB4018383) 32-Bit Edition","Security Update for Skype for Business 2015 (KB4011179) 32-Bit Edition","Security Update for Skype for Business 2016 (KB4011159) 32-Bit Edition","Update for Microsoft Office 2016 (KB3141509) 32-Bit Edition","Update for Microsoft Office 2016 (KB4011099) 32-Bit Edition", "Security Update for Microsoft .NET Framework 4.5.2 (KB2972216)", "Security Update for Microsoft .NET Framework 4.5.2 (KB2978128)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3023224)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3037581)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3074230)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3074550)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3097996)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3098781)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3122656)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3127229)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3135996v2)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3142033)", "Security Update for Microsoft .NET Framework 4.5.2 (KB3163251)", "Security Update for Microsoft .NET Framework 4.5.2 (KB4095519)", "Security Update for Microsoft .NET Framework 4.5.2 (KB4344173)", "Security Update for Microsoft .NET Framework 4.5.2 (KB4457030)", "Security Update for Microsoft Excel 2010 (KB4462230) 32-Bit Edition", "Security Update for Microsoft Excel 2013 (KB4462209) 32-Bit Edition", "Security Update for Microsoft Office 2010 (KB4462223) 32-Bit Edition", "Security Update for Microsoft Office 2010 (KB4464520) 32-Bit Edition", "Security Update for Microsoft Office 2013 (KB4462204) 32-Bit Edition", "Security Update for Microsoft Office 2013 (KB4464504) 32-Bit Edition", "ThinkRite Voice Desktop Client 4.0.15", "Update for Microsoft .NET Framework 4.5.2 (KB4457038)", "Update for Microsoft .NET Framework 4.5.2 (KB4470637)", "Update for Microsoft .NET Framework 4.5.2 (KB4480059)", "Update for Microsoft .NET Framework 4.5.2 (KB4483455)", "Update for Microsoft Office 2016 (KB2920717) 32-Bit Edition", "Update for Microsoft Office 2016 (KB4461441) 32-Bit Edition", "Update for Microsoft Office 2016 (KB4461477) 32-Bit Edition", "Update for Microsoft Office 2016 (KB4462119) 32-Bit Edition", "Update for Microsoft Office 2016 (KB4462243) 32-Bit Edition", "Update for Microsoft Office 2016 (KB4464538) 32-Bit Edition", "Update for Microsoft Office 2016 (KB4464539) 32-Bit Edition", "Update for Microsoft PowerPoint 2016 (KB4464533) 32-Bit Edition", "Update for Microsoft Project 2016 (KB4464589) 32-Bit Edition", "Update for Microsoft Visio 2016 (KB4462113) 32-Bit Edition", "Security Update for Microsoft Excel 2013 (KB4464565) 32-Bit Edition", "Security Update for Microsoft Excel 2016 (KB4475513) 32-Bit Edition", "Security Update for Microsoft Office 2013 (KB4018375) 32-Bit Edition", "Security Update for Microsoft Office 2013 (KB4464558) 32-Bit Edition", "Security Update for Microsoft Office 2013 (KB4464599) 32-Bit Edition", "Security Update for Microsoft Office 2016 (KB3115103) 32-Bit Edition", "Security Update for Microsoft Office 2016 (KB4461539) 32-Bit Edition", "Security Update for Microsoft Office 2016 (KB4462242) 32-Bit Edition", "Security Update for Microsoft Office 2016 (KB4464534) 32-Bit Edition", "Security Update for Microsoft Office 2016 (KB4475514) 32-Bit Edition", "Security Update for Microsoft Office 2016 (KB4475538) 32-Bit Edition", "Security Update for Microsoft Outlook 2013 (KB4475563) 32-Bit Edition", "Security Update for Microsoft Outlook 2016 (KB4475553) 32-Bit Edition", "Security Update for Microsoft Word 2016 (KB4475540) 32-Bit Edition", "Security Update for Skype for Business 2015 (KB4475519) 32-Bit Edition", "Security Update for Skype for Business 2016 (KB4475545) 32-Bit Edition")
		    
            # Remove Applications that come pre-installed on the image, string updated last on 1/1/2020
            ForEach ($App in $AppsOnImage)
		    {
			    While ($32Bit -Contains $App)
			    {
				    $Index = $32Bit.IndexOf($App, 0)
                    If ($Index = -1) {break}
                    Else {$32Bit.RemoveAt($Index)}
			    }
			    While ($64Bit -Contains $App)
			    {
				    $Index = $64Bit.IndexOf($App, 0)
                    If ($Index = -1) {break}
                    Else {$64Bit.RemoveAt($Index)}
			    }
		    }
		}
        Else
        {
		    Write-Host "Unable to retrieve application data from SCCM Database for " + $Hostname
            Write-Host "Probable Cause: SCCM is not complaint, installed, or has never scanned " + $Hostname
        }

		$Seperator = "----------------------------------------"

        # Builds a String to be used for the Text Document title
		$FileTitle = ($DisplayName + " - " + $Model + " - " + $hostname | Out-String).Trim() 
        
		#Generate Text File on Desktop
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $DisplayName -Encoding ascii -Width 100
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $UserId -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $EmailAddress -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject "Ticket: " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject "Technician: " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Connection -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Address -Encoding ascii -Width 100 -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $PTO -Encoding ascii -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject "Delivered/Shipped: " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject ("Old: " + $hostname + "   " + "New: ") -Encoding ascii -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $WarehouseLocation -Encoding ascii -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject "Old PC Information" -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Seperator -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject ("Model: " + $Model) -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject ("Operating System: " + $OS) -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $ImageRelease -Encoding ascii -Width 100 -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Monitors -Encoding ascii -Width 100 -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $lastKnownConnection -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Printers -Encoding ascii -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject "Special Applications" -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Seperator -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $3M -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $TimeTrack -Encoding ascii -Width 100 -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $OneDrive -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $SysTrack -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Gemalto -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $SecureAuth -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Tableau -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Exstream -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Articulate -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Maptitude -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Gatherer -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Verint -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $GCM -Encoding ascii -WIDTH 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $EndNote -Encoding ascii -Width 100 -Append
        Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject "32 Bit Applications" -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Seperator -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $32Bit -Encoding ascii -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject " " -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject "64 Bit Applications" -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $Seperator -Encoding ascii -Width 100 -Append
		Out-File -FilePath $env:userprofile\Desktop\$FileTitle.txt -InputObject $64Bit -Encoding ascii -Append
		
		# Generate file with all applications from last pull inside of C:\Temp
		Out-File -FilePath C:\Temp\$hostname.txt -InputObject $32Bit -Encoding ascii
		Out-File -FilePath C:\Temp\$hostname.txt -InputObject $64Bit -Encoding ascii -Append
    }

    # Function pushes as missing installations to the new PC
    function PushPCData
    {
        param($hostname, $NewHostname)

        $hostname = $hostname.Trim()
        $NewHostname.Trim()
       
        # Grab a filtered list of applications from stored text file
        $Installations = New-Object System.Collections.ArrayList
		$Installations = Get-Content C:\Temp\$hostname.txt
        
        # Count number of installations in the array list and add on for a blank line at the beginning
        $InstallationCount = $Installations.Count + 1
		
        #Copy and paste programs into Strings2 Excel sheet - Excel 2016 Method
		#$ExcelPath = "C:\Temp\Strings2.xlsm"
		#$Excel = New-Object -ComObject Excel.Application
        #$Excel.DisplayAlerts = $False
		#$Workbook = $Excel.Workbooks.Open($ExcelPath)
		#$Worksheet = $Workbook.Worksheets.Item("Software Search")
		#$Worksheet.Activate()
        #Set-Clipboard -Value $Installations
        #$Worksheet.Range("A2").Select()
        #$Worksheet.Paste() | Out-Null
        #$Range = $Worksheet.Range("C2:C$InstallationCount")
        #$Range.Copy() | Out-Null
		#$InstallPaths = Get-Clipboard
        #$Workbook.Close($True)
		#$Excel.Quit()
        
        # Copy and paste programs into Strings2 Excel sheet - Excel 365 Method
        $Excel = Open-ExcelPackage -Path "C:\Temp\Strings2.xlsm"
        $Excel.DisplayAlerts = $False
        $Worksheet = $Excel.Workbook.Worksheets['Software Search']
        $Worksheet.Select()
        $Installations = Get-Content C:\Temp\$hostname.txt
        Set-Clipboard -Value $Installations
        $Worksheet.Range("A2").Select()
        $Worksheet.Paste() | Out-Null
        $Range = $Worksheet.Range("C2:C$InstallationCount")
        $Range.Copy() | Out-Null
        $InstallPaths = Get-Clipboard
        Close-ExcelPackage $Excel

        #String manipulations - removing any non stand alone single spaces
        $InstallPaths = $InstallPaths| Where { $_ -ne "" } | ForEach { $_.Replace("  ","") }
        $InstallPaths = $InstallPaths | Sort | Get-Unique
		
            #Install packages over the network
		    Out-File -FilePath C:\Temp\Installs_$NewHostname.cmd -InputObject "Net use i: \\grbnaswps05\idrive" -Encoding ascii
            Out-File -FilePath C:\Temp\Installs_$NewHostname.cmd -InputObject "ECHO Installing Applications" -Encoding ascii -Append
		    Out-File -FilePath C:\Temp\Installs_$NewHostname.cmd -InputObject $InstallPaths -Encoding ascii -Append
            Out-File -FilePath C:\Temp\Installs_$NewHostname.cmd -InputObject "ECHO Installations Complete" -Encoding ascii -Append
            Out-File -FilePath C:\Temp\Installs_$NewHostname.cmd -InputObject "Pause" -Encoding ascii -Append

            If (Test-Connection -ComputerName $NewHostName -Quiet)
		    {
                Copy-Item "C:\Temp\Installs_$NewHostname.cmd" "\\$NewHostname\C$\Temp\"
                Write-Host "Installation script copied to C:\Temp of " $Newhostname
            }Else{
                Write-Host $Newhostname " is offline. Unable to pushed Installation Script"
            }
    }

    # Function to update index when different option is selected in List Box
	function Update-ListBox
	{
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ListBox]
			$ListBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[Parameter(Mandatory = $false)]
			[string]$DisplayMember,
			[Parameter(Mandatory = $false)]
			[string]$ValueMember,
			[switch]
			$Append
		)
		
		if (-not $Append)
		{
			$ListBox.Items.Clear()
		}
		
		if ($Items -is [System.Windows.Forms.ListBox+ObjectCollection] -or $Items -is [System.Collections.ICollection])
		{
			$ListBox.Items.AddRange($Items)
		}
		elseif ($Items -is [System.Collections.IEnumerable])
		{
			$ListBox.BeginUpdate()
			foreach ($obj in $Items)
			{
				$ListBox.Items.Add($obj)
			}
			$ListBox.EndUpdate()
		}
		else
		{
			$ListBox.Items.Add($Items)
		}
		
		$ListBox.DisplayMember = $DisplayMember
		$ListBox.ValueMember = $ValueMember
	}
	
    # Function to update index when different option is selected in ComboBox
	function Update-ComboBox
	{
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ComboBox]
			$ComboBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[Parameter(Mandatory = $false)]
			[string]$DisplayMember,
			[Parameter(Mandatory = $false)]
			[string]$ValueMember,
			[switch]
			$Append
		)
		
		if (-not $Append)
		{
			$ComboBox.Items.Clear()
		}
		
		if ($Items -is [Object[]])
		{
			$ComboBox.Items.AddRange($Items)
		}
		elseif ($Items -is [System.Collections.IEnumerable])
		{
			$ComboBox.BeginUpdate()
			foreach ($obj in $Items)
			{
				$ComboBox.Items.Add($obj)
			}
			$ComboBox.EndUpdate()
		}
		else
		{
			$ComboBox.Items.Add($Items)
		}
		
		$ComboBox.DisplayMember = $DisplayMember
		$ComboBox.ValueMember = $ValueMember
	}
	
    # Pull Button is clicked
	$SubmitTxt_Click={
        
        If (($WkidTxt.Text | Out-String).Trim().Length -gt 6)
		{
			 # Invoke the PullPCData Function
            PullPCData -hostname ($WkidTxt.Text | Out-String).Trim() -Connection ($ConnectionLst.Text | Out-String).Trim() -SwapType ($SwapLst.Text | Out-String).Trim() -Address ($AddressTxt.Text | Out-String).Trim() 

            $Wkid2Txt.Enabled = $True
		    $PushTxt.Enabled = $True
		    $WkidTxt.Enabled = $False
		    $SubmitTxt.Enabled = $False
		    $AddressTxt.Enabled = $False
		    $SwapLst.Enabled = $False
		    $ConnectionLst.Enabled = $False
		    $NewTxt.Enabled = $True
            $SubmitTxt.Enabled = $True

		    $ResultLbl.Text = ($WkidTxt.Text | Out-String).Trim() + " Data Pull Complete"
		    Write-Host ($WkidTxt.Text | Out-String).Trim() " Data Pull Complete"
		}
        Else
        {
            Write-Host "Workstation ID is empty or the entered does not have at least 7 characters"
			$ResultLbl.Text = "Workstation ID is empty or the entered does not have at least 7 characters"
			Return
        }
	}
	
	# Push button is clicked
	$PushTxt_Click={

        If (Test-Connection -ComputerName ($Wkid2Txt.Text | Out-String).Trim() -Quiet){
                PushPCData -hostname ($WkidTxt.Text | Out-String).Trim() -NewHostname ($Wkid2Txt.Text | Out-String).Trim()

                $Wkid2Txt.Enabled = $False
		        $PushTxt.Enabled = $False
		        $WkidTxt.Enabled = $True
		        $SubmitTxt.Enabled = $True
		        $AddressTxt.Enabled = $True
		        $SwapLst.Enabled = $True
		        $ConnectionLst.Enabled = $True
		        $NewTxt.Enabled = $False

		        $ResultLbl.Text = "Installation script copied to C:\Temp of " + ($Wkid2Txt.Text | Out-String).Trim()
		        Write-Host "Installation script copied to C:\Temp of " + $($Wkid2Txt.Text | Out-String).Trim()

            }Else{

                $Wkid2Txt.Enabled = $True
		        $PushTxt.Enabled = $True
		        $WkidTxt.Enabled = $False
		        $SubmitTxt.Enabled = $False
		        $AddressTxt.Enabled = $False
		        $SwapLst.Enabled = $False
		        $ConnectionLst.Enabled = $False
		        $NewTxt.Enabled = $True

                $ResultLbl.Text = ($Wkid2Txt.Text | Out-String).Trim() + " is offline. Cannot push installation script to offline PC. Please re-enter Hostname or IP Address"
		        Write-Host ($Wkid2Txt.Text | Out-String).Trim() + " is offline. Cannot push installation script to offline PC. Please re-enter Hostname or IP Address"
		    }
		
	}
	
    # Reset Button Clicked
	$NewTxt_Click={
        $WkidTxt.Text = ""
        $Wkid2Txt.Text = ""
        $AddressTxt.Text = ""
        $WkidTxt.Enabled = $True
        $Wkid2Txt.Enabled = $True
        $ConnectionLst.Enabled = $True
        $SwapLst.Enabled = $True
        $AddressTxt.Enabled = $True
        $SubmitTxt.Enabled = $True
        $NewTxt.Enabled = $True
	}
    
    $MassUploadBtn_Click={

        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $FileBrowser.ShowDialog() | Out-Null
        $MassUploadPath = $FileBrowser.FileName
        $MassUploadArray = Import-Excel $MassUploadPath
        
        $WkidTxt.Enabled = $False
        $Wkid2Txt.Enabled = $False
        $ConnectionLst.Enabled = $False
        $SwapLst.Enabled = $False
        $AddressTxt.Enabled = $False

        ForEach ($Record in $MassUploadArray)
        {
            PullPCData -DisplayName $Record.Name -UserID $Record.Hum_User_ID -EmailAddress $Record.Hum_email -hostname $Record.wkid -Address $Record.Mailing_Address -Connection $Record.Connection -NumOfMonitors $Record.Monitors -Monitor1Make $Record.Monitor_Make -Monitor1Connection $Record.Monitor_Connection -Monitor2Make $Record.Primary_Monitor_Make -Monitor2Connection $Record.Primary_Monitor_Connection -Monitor3Make $Record.Secondary_Monitor_Make -Monitor3Connection $Record.Secondary_Monitor_Connection -PTO $Record.PTO
        }

        $WkidTxt.Enabled = $True
        $Wkid2Txt.Enabled = $True
        $ConnectionLst.Enabled = $True
        $SwapLst.Enabled = $True
        $AddressTxt.Enabled = $True

        $ResultLbl.Text = "Pull of software from Excel complete"
        Write-Host "Pull of software from Excel complete"
    }
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$MainFrm.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$SubmitTxt.remove_Click($SubmitTxt_Click)
			$PushTxt.remove_Click($PushTxt_Click)
			$NewTxt.remove_Click($NewTxt_Click)
			$ConnectionLst.remove_SelectedIndexChanged($ConnectionLst_SelectedIndexChanged)
			$AddressTxt.remove_TextChanged($AddressTxt_TextChanged)
			$WkidTxt.remove_TextChanged($WkidTxt_TextChanged)
			$Wkid2Txt.remove_TextChanged($Wkid2Txt_TextChanged)
			$MainFrm.remove_Load($MainFrm_Load)
			$MainFrm.remove_Load($Form_StateCorrection_Load)
			$MainFrm.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	
	$MainFrm.SuspendLayout()

	# MainFrm
	$MainFrm.Controls.Add($ResultLbl)
	$MainFrm.Controls.Add($labelSwapType)
	$MainFrm.Controls.Add($SwapLst)
	$MainFrm.Controls.Add($SubmitTxt)
	$MainFrm.Controls.Add($labelShippingAddress)
	$MainFrm.Controls.Add($labelConnectionType)
	$MainFrm.Controls.Add($labelWorkstationID)
	$MainFrm.Controls.Add($ConnectionLst)
	$MainFrm.Controls.Add($AddressTxt)
	$MainFrm.Controls.Add($WkidTxt)
	$MainFrm.Controls.Add($labelTargetWorkstationID)
	$MainFrm.Controls.Add($Wkid2Txt)
	$MainFrm.Controls.Add($PushTxt)
	$MainFrm.Controls.Add($NewTxt)
    $MainFrm.Controls.Add($MassUploadBtn)
	$MainFrm.AutoScaleDimensions = '6, 13'
	$MainFrm.AutoScaleMode = 'Font'
	$MainFrm.ClientSize = '300, 350'
	$MainFrm.Margin = '4, 4, 4, 4'
	$MainFrm.Name = 'MainFrm'
	$MainFrm.Text = 'PC App Pull & Push'
	$MainFrm.add_Load($MainFrm_Load)

	#Old Workstation Label
	$labelWorkstationID.Location = '10, 10'
	$labelWorkstationID.Name = 'labelWorkstationID'
	$labelWorkstationID.Size = '110, 20'
	$labelWorkstationID.Text = 'Old Workstation ID:'

    #Old Workstation Texbox
	$WkidTxt.Location = '120, 5'
	$WkidTxt.Name = 'WkidTxt'
	$WkidTxt.Size = '160, 20'
	$WkidTxt.add_TextChanged($WkidTxt_TextChanged)

	#Connection Type Label
	$labelConnectionType.Size = '70, 20'
	$labelConnectionType.Location = '10, 40'
	$labelConnectionType.Name = 'labelConnectionType'
	$labelConnectionType.Text = 'Connection:'
	$labelConnectionType.UseCompatibleTextRendering = $True

    #Connection Type ComboBox
    $ConnectionLst.FormattingEnabled = $True
	[void]$ConnectionLst.Items.Add('In-Office')
	[void]$ConnectionLst.Items.Add('Aruba')
	[void]$ConnectionLst.Items.Add('Cisco AnyConnect')
    [void]$ConnectionLst.Items.Add('ZPA Pilot')
	$ConnectionLst.Location = '90, 40'
	$ConnectionLst.Name = 'ConnectionLst'
	$ConnectionLst.Size = '190, 10'
    $ConnectionLst.SelectedItem = $ConnectionLst.Items[2]
	$ConnectionLst.add_SelectedIndexChanged($ConnectionLst_SelectedIndexChanged)

	#Swap Type Label
	$labelSwapType.AutoSize = $True
	$labelSwapType.Location = '10, 70'
	$labelSwapType.Name = 'labelSwapType'
	$labelSwapType.Size = '70, 20'
	$labelSwapType.Text = 'Swap Type:'
	$labelSwapType.UseCompatibleTextRendering = $True

    #Swap Type List
	$SwapLst.FormattingEnabled = $True
    [void]$SwapLst.Items.Add('FOW')
    [void]$SwapLst.Items.Add('Desktop to Laptop')
	[void]$SwapLst.Items.Add('Obsolete')
	[void]$SwapLst.Items.Add('Break Fix')
	[void]$SwapLst.Items.Add('Marketpoint')
    [void]$SwapLst.Items.Add('YHA')
    [void]$SwapLst.Items.Add('Developer')
	$SwapLst.Location = '90, 70'
	$SwapLst.Name = 'SwapLst'
	$SwapLst.Size = '190, 10'
	$SwapLst.SelectedItem = $SwapLst.Items[2]

	# labelShippingAddress
	$labelShippingAddress.AutoSize = $True
	$labelShippingAddress.Location = '10, 100'
	$labelShippingAddress.Name = 'labelShippingAddress'
	$labelShippingAddress.Size = '95, 20'
	$labelShippingAddress.TabIndex = 8
	$labelShippingAddress.Text = 'Location/Address:'
	$labelShippingAddress.UseCompatibleTextRendering = $True

    # AddressTxt
	$AddressTxt.Name = 'AddressTxt'
	$AddressTxt.Location = New-Object System.Drawing.Size(10, 120)
	$AddressTxt.Size = New-Object System.Drawing.Size(275, 40)
	$AddressTxt.AcceptsReturn = $true
	$AddressTxt.AcceptsTab = $false
	$AddressTxt.Multiline = $true
	$AddressTxt.TabIndex = 4
	$AddressTxt.add_TextChanged($AddressTxt_TextChanged)

    #Pull Old PC Data Button
	$SubmitTxt.Location = '10, 170'
	$SubmitTxt.Name = 'SubmitTxt'
	$SubmitTxt.Size = '135, 30'
	$SubmitTxt.Text = 'Pull Old PC Info'
	$SubmitTxt.UseCompatibleTextRendering = $True
	$SubmitTxt.UseVisualStyleBackColor = $True
	$SubmitTxt.add_Click($SubmitTxt_Click)

    #Mass Upload Button
	$MassUploadBtn.Location = '150, 170'
	$MassUploadBtn.Name = 'MassUploadBtn'
	$MassUploadBtn.Size = '135, 30'
	$MassUploadBtn.Text = 'Mass Pull via XLSX'
	$MassUploadBtn.UseCompatibleTextRendering = $True
	$MassUploadBtn.UseVisualStyleBackColor = $True
	$MassUploadBtn.add_Click($MassUploadBtn_Click)
	
	#New Workstation label
	$labelTargetWorkstationID.Autosize = $True
	$labelTargetWorkstationID.Location = '10, 220'
	$labelTargetWorkstationID.Name = 'labelTargetWorkstationID'
	$labelTargetWorkstationID.Size = '110, 20'
	$labelTargetWorkstationID.Text = 'New Workstation ID:'
	$labelTargetWorkstationID.UseCompatibleTextRendering = $True

	#New Workstation Textbox
	$Wkid2Txt.Location = '120, 215'
	$Wkid2Txt.Name = 'Wkid2Txt'
	$Wkid2Txt.Size = '165, 20'
	$Wkid2Txt.add_TextChanged($Wkid2Txt_TextChanged)
	
	#Push Installations to New PC Button
	$PushTxt.Location = '10, 250'
	$PushTxt.Name = 'PushTxt'
	$PushTxt.Size = '135, 30'
	$PushTxt.Text = 'Push Script to New PC'
	$PushTxt.UseCompatibleTextRendering = $True
	$PushTxt.UseVisualStyleBackColor = $True
	$PushTxt.add_Click($PushTxt_Click)

	#Result Output Label
	$ResultLbl.BorderStyle = 'Fixed3D'
	$ResultLbl.Location = '10, 290'
	$ResultLbl.Name = 'ResultLbl'
	$ResultLbl.Size = '280, 30'
	$ResultLbl.TabIndex = 12
	$ResultLbl.TextAlign = 'MiddleCenter'
	$ResultLbl.UseCompatibleTextRendering = $True

	#Reset Form Button
	$NewTxt.Location = '150, 250'
	$NewTxt.Name = 'NewTxt'
	$NewTxt.Size = '135, 30'
	$NewTxt.TabIndex = 16
	$NewTxt.Text = 'Reset/Clear the Form'
	$NewTxt.UseCompatibleTextRendering = $True
	$NewTxt.UseVisualStyleBackColor = $True
	$NewTxt.add_Click($NewTxt_Click)
	$MainFrm.ResumeLayout()
    
	# Save the initial state of the form
	$InitialFormWindowState = $MainFrm.WindowState

	# Init the OnLoad event to correct the initial state of the form
	$MainFrm.add_Load($Form_StateCorrection_Load)

	# Clean up the control events
	$MainFrm.add_FormClosed($Form_Cleanup_FormClosed)

	# Show the Form
	return $MainFrm.ShowDialog()
}

# Call the form
Show-PullPCData_psf | Out-Null

Function Get-MSIProduct {
    #https://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$Path,
 
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("ProductCode", "ProductVersion", "ProductName", "Manufacturer", "ProductLanguage", "FullVersion")]
        [string]$Property
    )
    Process {
        try {
            # Read property from MSI database
            $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
            $MSIDatabase = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstaller, @($Path.FullName, 0))
            $Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
            $View = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, ($Query))
            $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
            $Record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $View, $null)
            $Value = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, 1)
 
            # Commit database and close view
            $MSIDatabase.GetType().InvokeMember("Commit", "InvokeMethod", $null, $MSIDatabase, $null)
            $View.GetType().InvokeMember("Close", "InvokeMethod", $null, $View, $null)           
            $MSIDatabase = $null
            $View = $null
 
            # Return the value
            return $Value
        } 
        catch {
            Write-Warning -Message $_.Exception.Message ; break
        }
    }
    End {
        # Run garbage collection and release ComObject
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller) | Out-Null
        [System.GC]::Collect()
    }
} #End Get-MSIProduct

Function Get-MSIInfo {
    <# 
    .SYNOPSIS This function retrieves properties from a Windows Installer MSI database. 
    .DESCRIPTION This function uses the WindowInstaller COM object to pull all values from the Property table from a MSI.
    .EXAMPLE Get-MsiDatabaseProperties 'MSI_PATH' 
    .PARAMETER FilePath The path to the MSI you'd like to query
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = 'What is the path of the MSI you would like to query?')]
        [IO.FileInfo[]]$FilePath
    )

    begin {
        $com_object = New-Object -com WindowsInstaller.Installer
    }

    process {
        try {
            $database = $com_object.GetType().InvokeMember(
                "OpenDatabase",
                "InvokeMethod",
                $Null,
                $com_object,
                @($FilePath.FullName, 0)
            )

            $query = "SELECT * FROM Property"
            $View = $database.GetType().InvokeMember(
                "OpenView",
                "InvokeMethod",
                $Null,
                $database,
                ($query)
            )

            $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)

            $record = $View.GetType().InvokeMember(
                "Fetch",
                "InvokeMethod",
                $Null,
                $View,
                $Null
            )

            $msi_props = @{ }
            while ($record -ne $null) {
                $msi_props[$record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 1)] = $record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 2)
                $record = $View.GetType().InvokeMember(
                    "Fetch",
                    "InvokeMethod",
                    $Null,
                    $View,
                    $Null
                )
            }
            $obj = New-Object -TypeName PSObject -Property $msi_props
            $obj.PSObject.TypeNames.Insert(0, 'CMN.MSIProperties')
            Return $obj
        }
        catch {
            throw "Failed to get MSI file properties the error was: {0}." -f $_
        }
    }
} #End Get-MSIInfo

Function Set-PackageMSI {
    [cmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'PackageID')]
        [String]$pacakgeID
    )
    #Get package so we have necessary info
    $package = Get-CMPackage -Id $pacakgeID

    #Get a list of the MSI files
    #I've found that Get-ChildItem has a problem searching file systems if the currentlocation isn't a file system, so we save where we are, and change to the C: drive
    Push-Location
    Set-Location -Path c:\

    #Now we can get the info we need.
    $MSIs = Get-ChildItem -Path ($package.PkgSourcePath) -Filter '*.msi' -File -Recurse
    #Since we're done searching the file system, put the current location back
    Pop-Location

    if ($MSIs.Count -gt 0) {
        #Now, we get the product codes for the files
        $productCodes = New-Object -TypeName System.Collections.ArrayList
        if ($MSIs) {
            Write-Verbose "We have MSI's, going to get the ProductCodes"
            foreach ($MSI in $MSIs) {
                $productCode = Get-MSIInfo -FilePath $MSI.FullName
                $path = $MSI.FullName
                $result = @{
                    'Path'        = $path.Replace("$($package.PkgSourcePath)\", '');
                    'ProductCode' = $productCode.ProductCode
                }
                $productCodes.Add($result) | Out-Null
            }
        }
    }
    else {
        #no MSI files, so we exit
        return
    }
    
    #Get the programs for the package
    $programs = Get-CMProgram -PackageId $package.PackageID

    #Need to check to see if any of the products are already configured

    #Now, we start to update the programs with the MSI information
    $MSICount = 0
    foreach ($program in $programs) {
        if ($MSICount -lt $productCodes.Count) {
            Write-Verbose "Updating $($program.ProgramName) with $($productCodes[$MSICount].Path) - $($ProductCodes[$MSICount].ProductCode)"
            $program.MSIFilePath = $productCodes[$MSICount].path
            $program.MSIProductID = $productCodes[$MSICount].ProductCode
            $program.Put() | Out-Null
            $MSICount++
        }
    }
    #Now if we have more products, we need to create new programs
    while ($MSICount -lt $productCodes.Count) {
        $program = New-CMProgram -CommandLine 'CMD.exe Rem' -PackageId ($package.PackageID) -DiskSpaceRequirement 0 -Duration 15 -StandardProgramName "Z_PlaceHolder for $($productCodes[$MSICount].Path)"
        $program.MSIFilePath = $productCodes[$MSICount].path
        $program.MSIProductID = $productCodes[$MSICount].ProductCode
        $program.Put() | Out-Null
        $MSICount++
    }
} #End Set-PackageMSI

# TCP/IP Functions

Function ConvertTo-CmnCidr {
    <#
    .SYNOPSIS 
        Converts IP address and subnet mask to a CIDR address

    .DESCRIPTION
        Converts IP address and subnet amsk in put to a CIDR address

    .PARAMETER ipAddress
        IP Address in dotted decimal notation

    .PARAMETER subnetMask
        Subnet mask in dotted decimal notation

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep, default is 5
    
    .EXAMPLE
        ConvertTo-CmnCidr -ipAddress 192.168.0.1 -subnetMask 255.255.240.0
        will return 192.168.0.1/20

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	
        PSVer:	    2.0/3.0
        Updated:    2018-12-26
        Version:    1.0.0		
	#>
 
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'IP Address')]
        [string]$ipAddress,
        
        [Parameter(Mandatory = $true, HelpMessage = 'Subnet Mask')]
        [String]$subnetMask,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }
   
        #Build splat for log entries
        $NewLogEntry = @{
            logFile    = $logFile;
            component  = 'ConvertTo-CmnCidr';
            logEntries = $logEntries;
            maxLogSize = $MaxLogSize;
        }

        #Write to the log if we're supposed to!
        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "ipAddress = $ipAddress" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "subnetMask = $subnetMask" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        
        if ($PSCmdlet.ShouldProcess($ipAddress)) {
            $octets = $subnetMask -split "\." 
            $subnetInBinary = @() 
            foreach ($octet in $octets) { 
                #convert to binary 
                $octetInBinary = [convert]::ToString($octet, 2) 
                #get length of binary string add leading zeros to make octet 
                $octetInBinary = ("0" * (8 - ($octetInBinary).Length) + $octetInBinary) 
                $subnetInBinary = $subnetInBinary + $octetInBinary 
            } 
            $subnetInBinary = $subnetInBinary -join "" 
            Write-Verbose "Subnet = $subnetInBinary"
            $x = 0
            while ($subnetInBinary.Substring($x, 1) -eq '1') {
                $x++
            }
            $networkBits = $x
            $isValid = $true
            do {
                if ($subnetInBinary.Substring($x, 1) -ne '0') {
                    $isValid = $false
                } 
                $x++ 
            } while ($x -lt 32)
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        if (!$isValid) {
            New-CMNLogEntry "Invalid Mask" -type 3 @NewLogEntry
            throw "Invalid Mask"
        }
        Return "$ipAddress/$networkBits"
    }
} #End ConvertTo-CmnCidr

Function ConvertTo-CmnIpAddress {
    <#
    .SYNOPSIS 
        Converts binary IP address to dotted decimal notation

    .DESCRIPTION
        Converts binary IP address to dotted decimal notation
        
    .PARAMETER ipInBinary
        IP Address in binary

    .EXAMPLE
        ConvertTo-CmnIpAddress -ipInBinary '10000100101000101110011111111100'
        Returns:
        132.162.231.252

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	    2018-12-26
        PSVer:	    2.0/3.0
        Updated: 
        Version:    1.0.0		
	#>
 
    [CmdletBinding(ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'IP Address (in Binary) to convert')]
        [string]$ipInBinary,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    $IP = @() 
    For ($x = 1 ; $x -le 4 ; $x++) { 
        #Work out start character position 
        $StartCharNumber = ($x - 1) * 8 
        #Get octet in binary 
        $IPOctetInBinary = $ipInBinary.Substring($StartCharNumber, 8) 
        #Convert octet into decimal 
        $IPOctetInDecimal = [convert]::ToInt32($IPOctetInBinary, 2) 
        #Add octet to IP  
        $IP += $IPOctetInDecimal 
    } 
    #Separate by . 
    $IP = $IP -join "."
    Return $IP
} #End ConvertTo-CmnIpAddress

Function Get-CmnIpRange {
    <#
    .SYNOPSIS 

    .DESCRIPTION
        
    .PARAMETER 

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	
        PSVer:	    2.0/3.0
        Updated: 
        Version:    1.0.0		
	#>
 
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'IP Subnet (using CIDR) to get range of')]
        [String]$subnet,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }
        
        #Build splat for log entries
        $NewLogEntry = @{
            logFile    = $logFile;
            component  = 'Get-CmnSccmConnectionInfo';
            logEntries = $logEntries;
            maxLogSize = $MaxLogSize;
        }

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "subnet = $subnet" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        
        if ($PSCmdlet.ShouldProcess($subnet)) {
            
            #Split IP and subnet 
            $IP = ($Subnet -split "\/")[0] 
            $SubnetBits = ($Subnet -split "\/")[1] 
            #Convert IP into binary 
            #Split IP into different octects and for each one, figure out the binary with leading zeros and add to the total 
            $Octets = $IP -split "\." 
            $IPInBinary = @() 
            foreach ($Octet in $Octets) { 
                #convert to binary 
                $OctetInBinary = [convert]::ToString($Octet, 2) 
                #get length of binary string add leading zeros to make octet 
                $OctetInBinary = ("0" * (8 - ($OctetInBinary).Length) + $OctetInBinary) 
                $IPInBinary = $IPInBinary + $OctetInBinary 
            } 
            $IPInBinary = $IPInBinary -join "" 
            #Get network ID by subtracting subnet mask 
            $HostBits = 32 - $SubnetBits 
            $NetworkIDInBinary = $IPInBinary.Substring(0, $SubnetBits) 
            #Get host ID and get the first host ID by converting all 1s into 0s 
            $HostIDInBinary = $IPInBinary.Substring($SubnetBits, $HostBits)         
            $HostIDInBinary = $HostIDInBinary -replace "1", "0" 
            #Work out all the host IDs in that subnet by cycling through $i from 1 up to max $HostIDInBinary (i.e. 1s stringed up to $HostBits) 
            #Work out max $HostIDInBinary 
            $iSubnet = [convert]::ToInt32($HostIDInBinary, 2)
            $iSubnetHostBinary = [convert]::toString($iSubnet, 2)
            $iSubnetInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iSubnetHostBinary.Length) + $iSubnetHostBinary)"
            $imin = [convert]::ToInt32($HostIDInBinary, 2) + 1
            $iMinHostBinary = [convert]::ToString($imin, 2)
            $iMinInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iMinHostBinary.Length) + $iMinHostBinary)"
            $imax = [convert]::ToInt32(("1" * $HostBits), 2) - 1 
            $iMaxHostBinary = [Convert]::ToString($imax, 2)
            $iMaxInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iMaxHostBinary.Length) + $iMaxHostBinary)"
            $iBroadcast = [convert]::ToInt32(("1" * $HostBits), 2)
            $iBroadcastHostBinary = [Convert]::ToString($iBroadcast, 2)
            $iBroadcastInBinary = "$NetworkIDInBinary$("0" * ($HostIDInBinary.Length - $iBroadcastHostBinary.Length) + $iBroadcastHostBinary)"
            $returnHashTable.Add('Subnet', (ConvertTo-CmnIpAddress -ipInBinary $iSubnetInBinary))
            $returnHashTable.Add('Min', (ConvertTo-CmnIpAddress -ipInBinary $iMinInBinary))
            $returnHashTable.Add('Max', (ConvertTo-CmnIpAddress -ipInBinary $iMaxInBinary))
            $returnHashTable.Add('Broadcast', (ConvertTo-CmnIpAddress -ipInBinary $iBroadcastInBinary))
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.IpRange')
        Return $obj
    }
} #End Get-CmnIpRange

# Conversions

Function ConvertTo-CMNDomainUserSID {
    <#
	.SYNOPSIS
		Returns the SID for a domain user

	.DESCRIPTION
		Returns the SID for a domain user

	.PARAMETER domain
		Domain for the login

	.PARAMETER userID
		Login you want the SID for

	.EXAMPLE
		ConvertTo-CMNDomainUserSID -domain Contoso -user jparris

		Returns sid for user jparris

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	4/14/2017
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Domain for the login', Position = 1)]
        [String]$domain,

        [Parameter(Mandatory = $true, HelpMessage = 'Login you want SID for', Position = 2)]
        [String]$userID
    )

    try {
        $objUser = New-Object System.Security.Principal.NTAccount($Domain, $UserID)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        Return $strSID.Value
    }
	 
    catch {
        throw "Unable to resolve SID for user $userID in teh domain $domain"
    }
} # End ConvertTo-CMNDomainUserSID

Function Get-CmnObjectIDsBelowFolder {
    <#
	.SYNOPSIS
		This will return all the ObjectID's of type ObjectType from the branch starting at ContainerID

	.DESCRIPTION

		Returns all the ID's of the objects below the folder you specify. You can add the -recurse switch and it will get the objects in the subfolders as well.

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CmnSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER ObjectType
		Type of object you are working with. Valid values are:
			SMS_Package
			SMS_Advertisement
			SMS_Query
			SMS_Report
			SMS_MeteredProductRule
			SMS_ConfigurationItem
			SMS_OperatingSystemInstallPackage
			SMS_StateMigration
			SMS_ImagePackage
			SMS_BootImagePackage
			SMS_TaskSequencePackage
			SMS_DeviceSettingPackage
			SMS_DriverPackage
			SMS_Driver
			SMS_SoftwareUpdate
			SMS_ConfigurationBaselineInfo
			SMS_Collection_Device
			SMS_Collection_User
			SMS_ApplicationLatest
			SMS_ConfigurationItemLatest

	.PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    2019-01-30
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0	
	#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CmnSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Parent Container Node ID')]
        [string]$parentContainerNodeID,

        [Parameter(Mandatory = $true)]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$ObjectType,

        [Parameter(Mandatory = $false)]
        [Switch]$Recurse,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }
        
        #Build splat for log entries
        $NewLogEntry = @{
            logFile    = $logFile;
            component  = 'Get-CmnSccmConnectionInfo';
            logEntries = $logEntries;
            maxLogSize = $MaxLogSize;
        }

        New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
        #Initialize $ObjectIDs
        $ObjectIDs = @()
        #First, get list of items that have this object as a parent and recurse
        $ChildItemIDs = (Get-WmiObject -Class SMS_ObjectContainerNode -Filter "ParentContainerNodeID = '$parentContainerNodeID' and ObjectType = '$($ObjectTypetoObjectID[$ObjectType])'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).ContainerNodeID
    }

    process {
        if ($PSBoundParameters["Recurse"]) {
            foreach ($ChildItemID in $ChildItemIDs) {
                #$ObjectIDs = $ObjectIDs + (Get-CmnObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -ObjectID $ChildItemID -ObjectType $ObjectType)
                if ($logEntries.IsPresent) {
                    $ObjectIDs = $ObjectIDs + (Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $ChildItemID -ObjectType $objectType -logFile $logFile -logEntries)
                }
                else {
                    $ObjectIDs = $ObjectIDs + (Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -parentContainerNodeID $ChildItemID -ObjectType $objectType -logFile $logFile)
                }
            }
        }

        #Now, get a list of Items in the folder and build array
        $ObjectIDs = $ObjectIDs + (Get-WmiObject -Class SMS_ObjectContainerItem -Filter "ContainerNodeID = '$parentContainerNodeID' and ObjectType = '$($ObjectTypetoObjectID[$ObjectType])'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).InstanceKey
    }

    end {
        #Return Results
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
        Return $ObjectIDs
    }
} #End Get-CmnObjectIDsBelowFolder

#Patching Section

Function Get-CmnPatchTuesday {
    <#
	.SYNOPSIS
		Calculates Patch Tuesday for the current month

	.DESCRIPTION
		See Synopsis

	.EXAMPLE
		$PatchTuesday = Get-CmnPatchTuesday
	#>
    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $false, HelpMessage = 'Date for the month you want to deterimine patch Tuesday')]
        [DateTime]$date = $(Get-Date),

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )
    #Calculate Patch Tuesday Date
    [DateTime]$StrtDate = Get-Date("$((Get-Date $date).Month)/1/$((Get-Date $date).Year)")
    While ($StrtDate.DayOfWeek -ne 'Tuesday') {
        $StrtDate = $StrtDate.AddDays(1)
    }
    #Now that we know when the first Tuesday is, let's get the second.
    $StrtDate = $StrtDate.AddDays(7)
    Return Get-Date $StrtDate -Format g
} #End Get-CmnPatchTuesday

Function New-CmnSoftwareUpdateGroup {
    <# 
    .SYNOPSIS
        This function creates a new Software Update Group.

    .DESCRIPTION
        This function creates a new Software Update Group.

    .PARAMETER SCCMConnectionInfo
        This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
        Get-CmnSCCMConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	    4/25/2018
        PSVer:	    3.0
        Updated: 
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$SCCMConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Authorization List Name')]
        [String]$authListName,
        
        [Parameter(Mandatory = $false, HelpMessage = 'Authorization List Description')]
        [String]$authListDescription,

        [Parameter(Mandatory = $false, HelpMessage = 'Authorization List Locale')]
        [Int]$authListLocale = 1033,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'New-CmnSoftwareUpdateGroup';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Build splats for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }

        if ($PSCmdlet.ShouldProcess($authListName)) {
            $SMS_CI_LocalizedProperties = ([WMIClass] "\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_CI_LocalizedProperties").CreateInstance()
            $SMS_CI_LocalizedProperties.DisplayName = $authListName
            $SMS_CI_LocalizedProperties.Description = $authListDescription
            $SMS_CI_LocalizedProperties.LocaleID = $authListLocale
            $authList = ([WMIClass] "\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_AuthorizationList").CreateInstance()
            $authList.CIType_ID = 9
            $authList.LocalizedInformation = $SMS_CI_LocalizedProperties
            $authList.Put() | Out-Null
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        Return $authList
    }
} # End New-CmnSoftwareUpdateGroup

Function Get-CmnSoftwareUpdateGroup {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CmnSCCMConnectoinInfo and New-CmnLogEntry functions for these scripts, 
        please make sure you account for that.

    .PARAMETER sccmConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CmnsccmConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CmnSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Software Update Group to enumerate')]
        [String]$softwareUpdateGroup,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Get-CmnSoftwareUpdateGroup';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        $cimSession = New-CimSession -ComputerName $sccmConnectionInfo.Computername

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "softwareUpdateGroup = $softwareUpdateGroup" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        if ($PSCmdlet.ShouldProcess($softwareUpdateGroup)) {
            $sms_SoftwareUpdateGroup = Get-CimInstance -CimSession $cimSession -Query "Select * from SMS_AuthorizationList where LocalizedDisplayName = '$softwareUpdateGroup'" -Namespace $sccmConnectionInfo.NameSpace
            $sms_SoftwareUpdateGroup = Get-CimInstance -CimSession $cimSession -InputObject $sms_SoftwareUpdateGroup
            New-CMNLogEntry -entry 'Building array of updates' -type 1 @NewLogEntry
            $returnHashTable.Add('Authorization List', $sms_SoftwareUpdateGroup.LocalizedDisplayName)
            $updates = New-Object -TypeName System.Collections.ArrayList
            if ($sms_SoftwareUpdateGroup.Updates.Count -ne 0 -and $sms_SoftwareUpdateGroup.Updates.Count -ne $null) {
                foreach ($update in $sms_SoftwareUpdateGroup.Updates) {
                    New-CMNLogEntry -entry "Getting update CI_ID $update" -type 1 @NewLogEntry
                    $updateDetail = Get-CimInstance -CimSession $cimSession -Query "SELECT * FROM SMS_SoftwareUpdate WHERE CI_ID='$update'" -Namespace $sccmConnectionInfo.NameSpace
                    $updateObject = New-Object PSObject -Property @{
                        CI_ID                          = $updateDetail.CI_ID;
                        CI_UniqueID                    = $updateDetail.CI_UniqueID;
                        ArticleID                      = $updateDetail.ArticleID;
                        BulletinID                     = $updateDetail.BulletinID;
                        LocalizedCategoryInstanceNames = $updateDetail.LocalizedCategoryInstanceNames;
                        LocalizedDescription           = $updateDetail.LocalizedDescription;
                        LocalizedDisplayName           = $updateDetail.LocalizedDisplayName;
                    }
                    New-CMNLogEntry -entry "Update Detail $($updateObject)" -type 1 @NewLogEntry
                    $updates.Add($updateObject) | Out-Null
                }
                $returnHashTable.Add('Updates', $updates)
                $returnHashTable.Add('SUG', $sms_SoftwareUpdateGroup)
            }
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.SoftwareUpdateGroup')
        Return $obj	
    }
} #End Get-CmnSoftwareUpdateGroup

Function Copy-CmnSoftwareUpdateGroup {
    <# 
    .SYNOPSIS
        Copies the software update group, specified as an AuthlistID from the source site to the destination site

    .DESCRIPTION
        Copies the software update group, specified as an AuthlistID from the source site to the destination site

    .PARAMETER SrcConnectionInfo
        This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
        Get-CmnSCCMConnectionInfo in a variable and passing that variable.

    .PARAMETER DstConnectionInfo
        This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
        Get-CmnSCCMConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        FileName:    Copy-CmnSoftwareUpdateGroup.ps1
        Author:      James Parris
        Contact:     Jim@ConfigMan-Notes.com
        Created:     2018-04-06
        Updated:     
        Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Source Connection Info')]
        [PSObject]$SrcConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Destination Connection Info')]
        [PSObject]$DstConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'CI_ID for AuthList')]
        [String]$AuthListCI_ID,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    Begin {
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Copy-CmnSoftwareUpdateGroup';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        # Build splats for WMIQueries
        $WMISrcQueryParameters = $SrcConnectionInfo.WMIQueryParameters
        $WMIDstQueryParameters = $DstConnectionInfo.WMIQueryParameters
        
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        # Define hashtable for passing updates
        $updates = @{ }

        # Do some logging
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SrcConnectionInfo = $SrcConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "DstConnectionInfo = $DstConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "AuthListCI_ID = $AuthListCI_ID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "Verifying Authorization List exists" -type 1 @NewLogEntry
        }

        #  Get the source authorization list
        $srcAuthList = Get-WmiObject -Query "Select * from SMS_AuthorizationList Where CI_ID='$AuthListCI_ID'" @WMISrcQueryParameters -ErrorAction SilentlyContinue

        if (-not($srcAuthList)) {
            #  If it does not exist, error out.
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry "Authorization list $AuthListCI_ID does not exist." -type 3 @NewLogEntry
            }
            throw "Authorization list $AuthListCI_ID does not exist."
        }
        else {
            #  Make array of updates in list
            if ($PSBoundParameters['logEntries']) {
                New-CMNLogEntry -entry 'Building array of updates' -type 1 @NewLogEntry
            }
            $srcAuthList.Get()
            if ($srcAuthList.Updates.Count -ne 0 -and $srcAuthList.Updates.Count -ne $null) {
                foreach ($update in $srcAuthList.Updates) {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Getting update CI_ID $update" -type 1 @NewLogEntry
                    }
                    $updateDetail = Get-WmiObject -Query "SELECT * FROM SMS_SoftwareUpdate WHERE CI_ID='$update'" @WMISrcQueryParameters
                    $updateObject = New-Object PSObject -Property @{
                        ArticleID                      = $updateDetail.ArticleID;
                        BulletinID                     = $updateDetail.BulletinID;
                        LocalizedCategoryInstanceNames = $updateDetail.LocalizedCategoryInstanceNames;
                        LocalizedDescription           = $updateDetail.LocalizedDescription;
                        LocalizedDisplayName           = $updateDetail.LocalizedDisplayName;
                    }
                    $updates.Add($updateDetail.CI_UniqueID, $updateObject)
                }
            }
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Finished building update list, end Begin loop' -type 1 @NewLogEntry
        }
    }

    Process {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry
        }
        
        # Find out if the Authorization List already exists
        if ($PSCmdlet.ShouldProcess($AuthListCI_ID)) {
            $authList = Get-WmiObject -Query "Select * from SMS_AuthorizationList Where LocalizedDisplayName ='$($srcAuthList.LocalizedDisplayName)'" @WMIDstQueryParameters
            if ($authList) {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "$($authList.LocalizedDisplayName) already exists" -type 2 @NewLogEntry
                }
                $authList.Get()
            }
            else {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "$($srcAuthList.LocalizedDisplayName) doesn't exist, creating" -type 1 @NewLogEntry
                }
                $authList = New-CmnSoftwareUpdateGroup -SCCMConnectionInfo $DstConnectionInfo -authListName $srcAuthList.LocalizedDisplayName -AuthListDescription $srcAuthList.LocalizedDescription -authListLocale $srcAuthList.LocalizedPropertyLocaleID -logFile $logFile -logEntries:$logEntries -maxLogHistory $maxLogHistory -maxLogSize $maxLogSize
            }
            
            # Now, we need to build an array of UInt32 of each update CI_ID.
            $updateCI_ID = New-Object System.Collections.ArrayList
            foreach ($updateItem in $updates.GetEnumerator()) {
                $update = Get-CimInstance -CimSession $cimSession -Query "SELECT * FROM SMS_SoftwareUpdate WHERE CI_UniqueID = '$($updateItem.Key)'" @WMIDstQueryParameters
                if ($update) {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Adding update $($updateItem.Value.BulletinID) - $($updateItem.Value.ArticleID) - $($updateItem.Value.LocalizedDisplayName)." -type 1 @NewLogEntry
                    }
                    $return = New-Object -TypeName psobject -Property $update.Value
                    $return.PSObject.TypeNames.Insert(0, 'Success')
                    $returnHashTable.add($updateItem.key, $return)
                    $updateCI_ID.Add($update.CI_ID) | Out-Null
                }
                else {
                    if ($PSBoundParameters['logEntries']) {
                        New-CMNLogEntry -entry "Update $($updateItem.Value.BulletinID) - $($updateItem.Value.ArticleID) - $($updateItem.Value.LocalizedDisplayName) does not exist on site $($DstConnectionInfo.Site)" -type 3 @NewLogEntry
                    }
                    $return = New-Object -TypeName psobject -Property $update.Value
                    $return.PSObject.TypeNames.Insert(0, 'Fail')
                    $returnHashTable.add($updateItem.key, $return)
                }
            }
        }
        $authList.Updates = $updateCI_ID
        $authList.Put() | Out-Null
    }
    
    End {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.CopyCMNSoftwareUpdateGroup')
        Return $obj	
    }
} # End Copy-CmnSoftwareUpdateGroup

Function Get-CmnUpdateAssignments {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CmnSCCMConnectoinInfo and New-CmnLogEntry functions for these scripts, 
        please make sure you account for that.

    .PARAMETER sccmConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CmnsccmConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CmnSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Get-CmnUpdateAssignments';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build splat for WMIQueries
        $cimSession = New-CimSession -ComputerName $sccmConnectionInfo.ComputerName

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        if ($PSCmdlet.ShouldProcess($sccmConnectionInfo.ComputerName)) {
            $sms_UpdateAssigments = Get-CimInstance -ClassName SMS_UpdatesAssignment -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
            $sms_UpdateAssigments = Get-CimInstance -InputObject $sms_UpdateAssigments
            $sms_UpdateGroupAssigments = Get-CimInstance -ClassName SMS_UpdateGroupAssignment -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
            $sms_UpdateGroupAssigments = Get-CimInstance -InputObject $sms_UpdateGroupAssigments
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj
    }
} #End Get-CmnUpdateAssignments

#SCCM Utilities

Function Get-CmnSccmConnectionInfo {
    <#
	.SYNOPSIS
		Returns a hashtable to containing the SCCMDBServer (Site Database Server), SCCMDB (Site Database),
		ComputerName (Site Server), SiteCode (Site Code), NameSpace (WMI NameSpace), and WMI Query Paramter hash Table (WMIQueryParameters)

	.DESCRIPTION
		This function creates a hashtable with the necessary information used by a variety of my functions.
		Whenever a function has to talk to an SCCM site, it expects to be passed this hastable so it knows the
		connection information

	.PARAMETER SiteServer
		This is the siteserver for the site you want to connect to.

	.PARAMETER logFile
		File for writing logs to.

    .PARAMETER logEntries
        Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
		Specifies, in bytes, how large the file should be before rolling log over.

	.EXAMPLE
		Get-CmnSccmConnctionInfo -SiteServer Server01

	.LINK
		http://configman-notes.com

	.NOTES
		Author:      James Parris
		Contact:     jim@ConfigMan-Notes.com
		Created:     2016-11-07
		Updated:     2018-10-27 Added Comments and adjusted for new logentry function
		Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = "Site server where the SMS Provider is installed.", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [string]$siteServer,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$MaxLogSize = 5242880
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }
        
        #Build splat for log entries
        $NewLogEntry = @{
            logFile    = $logFile;
            component  = 'Get-CmnSccmConnectionInfo';
            logEntries = $logEntries;
            maxLogSize = $MaxLogSize;
        }

        #Write to the log if we're supposed to!
        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry

        # Create a hashtable with your output info
        $returnHashTable = @{ }
    }

    process {
        try {
            #Get the site code from the site server
            $siteCode = $(Get-WmiObject -ComputerName $siteServer -Namespace 'root/SMS' -Class SMS_ProviderLocation -ErrorAction SilentlyContinue).SiteCode
        }
        catch {
            #if we don't get a result, we have a problem.
            New-CMNLogEntry -entry "Unable to connect to Site Server $SiteServer" -type 3 @NewLogEntry
            throw "Unable to connect to Site Server $siteServer"
            break
        }
        #Now, to determine the SQL Server and database being used for the site.
        $DataSourceWMI = $(Get-WmiObject -Class SMS_SiteSystemSummarizer -Namespace root/sms/site_$siteCode -ComputerName $siteServer -Filter "Role = 'SMS SQL SERVER' and SiteCode = '$siteCode' and ObjectType = 1").SiteObject
        $returnHashTable.Add('SccmDBServer', ($DataSourceWMI -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'))
        $returnHashTable.Add('SCCMDB', ($DataSourceWMI -replace ".*\\([A-Z_0-9]*?)\\$", '$+'))
        $returnHashTable.Add('SiteCode', $SiteCode)
        $returnHashTable.Add('ComputerName', $SiteServer)
        $returnHashTable.Add('NameSpace', "Root/SMS/Site_$siteCode")
        $returnHashTable.Add('WMIQueryParameters', @{
                Namespace    = "Root/SMS/Site_$siteCode";
                ComputerName = $SiteServer;
            })
        #Log if if we're supposed to!
        New-CMNLogEntry -entry "SCCMDBServer = $SCCMDBServer" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "SCCMDB = $SCCMDB" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "SiteCode = $siteCode" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "ComputerName = $siteServer" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "NameSpace = Root/SMS/Site_$siteCode" -type 1 @NewLogEntry
    }

    end {
        #Done! Log it!
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        #Let's put our TypeName on the results
        $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.SCCMConnectionInfo')
        Return $obj
    }
} #End Get-CmnSccmConnectionInfo

Function New-CmnLogEntry {
    <#
		.SYNOPSIS
			Writes log entry that can be read by CMTrace.exe

		.DESCRIPTION
			If you specify 'logEntries' writes log entries to a file. If the file is larger then MaxFileSize, it will rename it to *yyyymmdd-HHmmss.log and start a new file.
			You can specify if it's an (1) informational, (2) warning, or (3) error message as well. It will also add time zone information, so if you
            have machines in multiple time zones, you can convert to UTC and make sure you know exactly when things happened.
            
            Will always write the entry verbose for troubleshooting

		.PARAMETER entry
			This is the text that is the log entry.

		.PARAMETER type
			Defines the type of message, 1 = Informational (default), 2 = Warning, and 3 = Error.

		.PARAMETER component
			Specifies the Component information. This could be the name of the function, or thread, or whatever you like,
			to further help identify what is being logged.

		.PARAMETER logFile
            File for writing logs to.
            
        .PARAMETER logEntries
            Switch to say if we write to the log file. Otherwise, it will just be write-verbose

		.PARAMETER maxLogSize
			Specifies, in bytes, how large the file should be before rolling log over.

		.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

		.EXAMPLE
			New-CmnLogEntry -entry "Machine $computerName needs a restart." -type 2 -component 'Installer' -logFile $logFile -logEntries -MaxLogSize 10485760
			This will add a warning entry, after expanding $computerName from the compontent Installer to the logfile and roll it over if it exceeds 10MB

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Copy-CmnApplicationDeployment.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
            Updated:     2017-03-01 - Added log rollover
                         2018-10-23 - Added Write-Verbose
                                      Added adjustment in TimeZond for Daylight Savings Time
                                      Corrected time format for renaming logs because I'm an idiot and put 3 digits in the minute field.
			Version:     2.0
    #>
    
    [CmdletBinding(ConfirmImpact = 'Low')]

    Param
    (
        [Parameter(Mandatory = $false, HelpMessage = 'Entry for the log')]
        [String]$entry = '',

        [Parameter(Mandatory = $true, HelpMessage = 'Type of message, 1 = Informational, 2 = Warning, 3 = Error')]
        [ValidateSet(1, 2, 3)]
        [INT32]$type,

        [Parameter(Mandatory = $true, HelpMessage = 'Component')]
        [String]$component,

        [Parameter(Mandatory = $true, HelpMessage = 'Log File')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    #Get Timezone info
    $now = Get-Date
    $tzInfo = [System.TimeZoneInfo]::Local
    #Get Timezone Offset
    $tzOffset = $tzInfo.BaseUTcOffset.Negate().TotalMinutes
    #If it's daylight savings time, we need to adjust
    if ($tzInfo.IsDaylightSavingTime($now)) {
        $tzAdjust = ((($tzInfo.GetAdjustmentRules()).DaylightDelta).TotalMinutes)[0]
        $tzOffset -= $tzAdjust
    }
    #Now, to figure out the format. if the timezone adjustment is posative, we need to represent it as +###
    if ($tzOffset -ge 0) {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$($tzOffset)"
    }
    #otherwise, we need to represent it as -###
    else {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")$tzOffset"
    }

    #Create entry line, properly formatted
    $cmEntry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $entry, (Get-Date -Format "MM-dd-yyyy"), $tzOffset, $pid, $type, $component

    if ($PSBoundParameters['logEntries']) {
        #Now, see if we need to roll the log
        if (Test-Path $logFile) {
            #File exists, now to check the size
            if ((Get-Item -Path $logFile).Length -gt $MaxLogSize) {
                #Rename file
                $backupLog = ($logFile -replace '\.log$', '') + "-$(Get-Date -Format "yyyymmdd-HHmmss").log"
                Rename-Item -Path $logFile -NewName $backupLog -Force
                #Get filter information
                #First, we do a regex search, and just get the text before the .log and after the \
                $logFile -match '(\w*).log' | Out-Null
                #Now, we add a trailing * for the filter
                $logFileName = "$($Matches[1])*"
                #Get the path for the log so we know where to search
                $logPath = Split-Path -Path $logFile
                #And we remove any extra rollover logs.
                Get-ChildItem -Path $logPath -filter $logFileName | Where-Object { $_.Name -notin (Get-ChildItem -Path $logPath -Filter $logFileName | Sort-Object -Property LastWriteTime -Descending | Select-Object -First $maxLogHistory).name } | Remove-Item
            }
        }
        #Finally, we write the entry
        $cmEntry | Out-File $logFile -Append -Encoding ascii
    }
    #Also, we write verbose, just incase that's turned on.
    Write-Verbose $entry
} #End New-CmnLogEntry

#Client Utilities

Function Repair-CmnCacheLocation {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CmnSCCMConnectoinInfo and New-CmnLogEntry functions for these scripts, 
        please make sure you account for that.

    .PARAMETER sccmConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CmnSccmConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CmnSccmConnectionInfo')]
        [String]$computerName,

        [Parameter(Mandatory = $false, HelpMessage = 'Force move, even if on good drive')]
        [Switch]$force,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        #Assign a value to Force
        if ($PSBoundParameters['force']) {
            $force = $true
        }
        else {
            $force = $false
        }

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Repair-CmnCacheLocation';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "computerName = $computerName" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        if ($PSCmdlet.ShouldProcess($sccmConnectionInfo)) {
            try {
                New-CMNLogEntry -entry "Fixing $computerName" -type 1 @NewLogEntry
                $results = New-Object psobject
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'ComputerName' -Value $computerName
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'CurrentCacheLocation' -Value 'UnKnown'
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'CurrentCacheSize' -Value 'UnKnown'
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'UpdatedCacheLocation' -Value 'None'
                Add-Member -InputObject $results -MemberType NoteProperty -name 'UpdatedCacheSize' -Value 'None'
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'Results' -Value 'Error'
            
                #Gather current Cache Location and size
                $cache = Get-WmiObject -Namespace root\ccm\softmgmtagent -Class cacheconfig -ComputerName $computerName
                if ($null -eq $cache.Location) {
                    $cache.Location = 'Z:\Error'
                }
                $results.CurrentCacheLocation = $cache.Location
                $results.CurrentCacheSize = $cache.Size
                New-CMNLogEntry -entry "`tCurrent cache location - $($Cache.Location)" -type 1 @NewLogEntry
                if ($PSBoundParameters['force']) {
                    $cache.Location = 'C:\Temp\'
                    $cache.put() | Out-Null
                    $cache.get()
                    Get-Service -ComputerName $computerName -Name CcmExec | Restart-Service
                }
                $drives = [Array](Get-WmiObject -ComputerName $computerName -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Sort-Object -Property FreeSpace -Descending).DeviceID
                New-CMNLogEntry -entry "`tDrives = $drives" -type 1 @NewLogEntry
            
                # Time to figure out what we've got
                New-CMNLogEntry -entry "`tDetermining if virtual" -type 1 @NewLogEntry
                $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName
                if ($computerSystem.Model -match 'Virtual') {
                    New-CMNLogEntry -entry "`tThis is a virtual machine" -type 1 @NewLogEntry
                    $isVirtual = $true
                }
                else {
                    New-CMNLogEntry -entry "`tThis is a physical machine" -type 1 @NewLogEntry
                    $isVirtual = $false
                }
            
                #What OS are we working with?
                #ProductType 1=Workstation, 2 = DC, 3=Server Ref - https://docs.microsoft.com/en-us/windows/desktop/CIMWin32Prov/win32-operatingsystem
                New-CMNLogEntry -entry "`tChecking OS" -type 1 @NewLogEntry
                $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName
                if ($os.ProductType -eq 1) {
                    New-CMNLogEntry -entry "`tThis is a workstation" -type 1 @NewLogEntry
                    $isWorkstation = $true
                }
                else {
                    New-CMNLogEntry -entry "`tThis is a server" -type 1 @NewLogEntry
                    $isWorkstation = $false
                }
                   
                #Let's work with workstations first...
                if ($isWorkstation) {
                    if ($drives.Contains('B:') -and $isVirtual) {
                        $CCMCacheDir = 'B:\CCMCache'
                    }
                    else {
                        $CCMCacheDir = 'C:\Windows\CCMCache'
                    }
                }
                elseif ($computerSystem.Domain -eq 'ts.humad.com' -or $computerSystem.Domain -eq 'tmt.loutms.tree') {
                    ## It's a server, is it Citrix?
                    if ((($computerSystem.Name -notmatch '...[CX][MA][FH].*' -or $computerSystem.Name -match '...[CX][MA][ABCDFLNSPX].....S.*')) -and $computerSystem.Name -notmatch '......WP[VU].*') {
                        ## Persistent machines with cache on D:\Program Files\CCMCache
                        New-CMNLogEntry -entry "`tPersistent Citrix Server, setting cache to D:\Program Files\CCMCache" -type 1 @NewLogEntry
                        $CCMCacheDir = 'D:\Program Files\CCMCache'
                    }
                    else {
                        ## Non-persistent machines
                        New-CMNLogEntry -entry "`tNon-persistent Citrix Server, setting cache to E:\Persistent\CCMCache" -type 1 @NewLogEntry
                        $CCMCacheDir = 'E:\Persistent\CCMCache'
                    }
                }
                elseif ($computerSystem.Name -match '............c.*') {
                    #ClusterNode - Cache must be on C: or D:
                    foreach ($drive in $drives) {
                        if ($drive -match '[CD]:') {
                            $CCMCacheDir = "$drive\CCMCache"
                            if ($CCMCacheDir -eq 'C:\CCMCache') {
                                $CCMCacheDir = 'C:\Windows\CCMCache'
                            }
                        }
                    }
                    #Make sure it's on C or D
                    if ($CCMCacheDir -notmatch '[CD]:\CCMCache') {
                        $CCMCacheDir = 'C:\Windows\CCMCache'
                    }
                    if ($CCMCacheDir -eq 'C:\CCMCache') {
                        $CCMCacheDir = 'C:\Windows\CCMCache'
                    }
                }
                else {
                    #Standard server, put cache on drive with most free space
                    $CCMCacheDir = "$($drives[0])\CCMCache"
                    if ($CCMCacheDir -eq 'C:\CCMCache') {
                        $CCMCacheDir = 'C:\Windows\CCMCache'
                    }
                }
            
                if ($isWorkstation -and !$isVirtual) {
                    $ccmCacheSize = 51200
                }
                else {
                    $ccmCacheSize = 5120
                }
            
                #We should have a cache directory, now to verify and set (need to add checks for cahce size as well)
                if ($CCMCacheDir -ne $results.CurrentCacheLocation -or $PSBoundParameters['force']) {
                    $CacheDriveExists = $false
                    $CacheDrive = $CCMCacheDir.Substring(0, 2)
                    foreach ($drive in $drives) {
                        if ($CacheDrive -eq $drive) {
                            $CacheDriveExists = $true
                        }
                    }
                    if (-not($CacheDriveExists)) {
                        New-CMNLogEntry -entry "`tCache drive doesn''t exist, looking for a new one." -type 1 @NewLogEntry
                        $CCMCacheDir = "$($drives[0])\CCMCache"
                        if ($CCMCacheDir -eq 'C:\CCMCache') {
                            $CCMCacheDir = 'C:\Windows\CCMCache'
                        }
                        New-CMNLogEntry -entry "`tNew cache location is $CCMCacheDir" -type 1 @NewLogEntry
                    } # End if(-not($CacheDriveExists))
                    $results.UpdatedCacheLocation = $CCMCacheDir
                    $cache.Location = $CCMCacheDir
                    if ($cache.Size -ne $ccmCacheSize) {
                        $results.UpdatedCacheSize = $ccmCacheSize
                        $cache.Size = $ccmCacheSize
                    }
                    $cache.put() | Out-Null
                    $cache.Get()
                    New-CMNLogEntry -entry "`tCache location is now $($Cache.Location)" -type 1 @NewLogEntry
                    $results.Results = 'Updated'
                    Get-Service -ComputerName $computerName -Name CcmExec | Restart-Service
                }
                else {
                    New-CMNLogEntry -entry "`tCache location is good" -type 1 @NewLogEntry
                    $results.Results = 'Good'
                } # End of else
            } # End of try
            Catch [System.Exception] {
                New-CMNLogEntry -entry "`t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`tUnable to fix $computerName" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`t$($Error[0])" -type 1 @NewLogEntry
                $results.Results = 'Error'
                $results | Export-Csv -Path $logFile -Append -NoTypeInformation
            } # end of catch
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Repair-CmnCacheLocation

Function Repair-CmnClient {
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $false, HelpMessage = 'Do we ignore maintenance windows?')]
        [switch]$ignoreMW,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )
    #Get cimclass for future use
    $client = Get-CimClass -Namespace Root\CCM -ClassName SMS_Client

    $mwInstances = Get-CimInstance -CimSession $cimSession -Namespace ROOT\ccm\ClientSDK -ClassName CCM_ServiceWindow -Filter "Type != 6"
    if ($mwInstances.Count -ne 0) {
        $inMW = $false
        if ($mwInstances.Count -gt 0) {
            $currentTime = Get-Date
            foreach ($mwInstance in $mwInstances) {
                if ($mwInstance.StartTime -lt $currentTime -and $mwInstance.EndTime -lt $currentTime) {
                    $inMW = $true
                }
            }
        }
    }
    else {
        $inMW = $true
    }

    if ($inMW -or $PSBoundParameters['ignoreMW']) {
        #Reset machine group policy so we clear out any Windows Update settings
        #http://www.sherweb.com/blog/resolving-group-policy-error-0x8007000d/
        try {
            $gpoCacheDir = "$($env:ALLUSERSPROFILE)\Application Data\Microsoft\Group Policy\History\*.*"
        
            if (Test-Path $gpoCacheDir -PathType Container) {
                Write-Output "Removing contents of $gpoCacheDir"
                Remove-Item -Path $gpoCacheDir -Force -Recurse
            }
            else {
                Write-Output "Unable to find $gpoCacheDir"
            }
        }
        catch {
            Write-Output "Problem removing $gpoCacheDir"
            Return "Problem removing $gpoCacheDir"
        }

        try {
            Write-Output 'Cleaning CCM Temp Dir'
            $ccmTempDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM).TempDir
            if ($null -ne $ccmTempDir -and (Test-Path -Path $ccmTempDir) -and $ccmTempDir -ne '') {
                Get-ChildItem -Path $ccmTempDir | Where-Object { !$_.PSisContainer } | Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-Output "Unable to clear $ccmTempDir"
            Return "Unable to clear $ccmTempDir"
        }

        #Force a resync of inventory and DDR information
        try {
            Write-Output "Removing InventoryActionSatus from WMI"
            Get-CimInstance -CimSession $cimSession -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus -Filter "InventoryActionID = '{00000000-0000-0000-0000-000000000001}' or InventoryActionID = '{00000000-0000-0000-0000-000000000003}'" -ErrorAction SilentlyContinue | Remove-CimInstance
        }
        catch {
            Write-Output "Unable to remove InventoryActionSatus from WMI"
            Write-Output $Error.
            Return "Unable to remove InventoryActionSatus from WMI"
        }

        #Clear out the WMI repository where policy was stored, force refresh
        Write-Output 'Resetting Policy'
        Invoke-CimMethod -CimClass $client -MethodName ResetPolicy -Arguments @{uFlags = 1 } | Out-Null

        #Remove SMS Certs
        Write-Output 'Removing SMS Certs'
        Get-ChildItem Cert:\LocalMachine\SMS | Where-Object { $_.Subject -match "^CN=SMS, CN=$($env:COMPUTERNAME)" } | Remove-Item -Force -ErrorAction SilentlyContinue

        Write-Output 'Restarting CCMExec'
        Restart-Service CcmExec | Out-Null

        Write-Output 'Running GPUpdate'
        & gpupdate.exe

        Write-Output "$(Get-Date) - Sleeping for 5 minutes until $((Get-Date).AddMinutes(5))"
        Start-Sleep -Seconds 300

        try {
            Write-Output 'Refreshing compliance state'
            $sccmClient = New-Object -ComObject Microsoft.CCM.UpdatesStore
            $sccmClient.RefreshServerComplianceState()
        }
        catch {
            Write-Output 'Unable to refresh compliance state'
            Return 'Unable to refresh compliance state'
        }

        try {
            Write-Output 'Running Machine Policy Retrieval & Evaluation Cycle'
            Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000021}' } -ErrorAction SilentlyContinue | Out-Null

            Write-Output 'Running Discovery Data Collection Cycle'
            Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000003}' } -ErrorAction SilentlyContinue | Out-Null

            Write-Output 'Running Hardware Inventory Cycle'
            Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}' } -ErrorAction SilentlyContinue | Out-Null
        }
        catch {
            Write-Output "Unable to reset $env:COMPUTERNAME"
            Write-Output $Error.
            Return "Unable to reset $env:COMPUTERNAME"
        }

        Return "$env:COMPUTERNAME complete!"
    }
    else {
        Write-Output "$env:COMPUTERNAME is not currently in it's maintenance window and ignoreMW parameter was not specified, not resetting client"
    }
} #End Repair-CmnClient

Function Repair-CmnProgressStuck {
    Stop-Service -Name CcmExec -Force
    Stop-Service -Name BITS -Force
    if (Test-Path -Path "$($env:ALLUSERSPROFILE)\Microsoft\Network\Downloader\qmgr?.dat") {
        Write-Output 'Removing existing bits transfers'
        Remove-Item -Path "$($env:ALLUSERSPROFILE)\Microsoft\Network\Downloader\qmgr?.dat" -Force
    }
    if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).EnableBitsMaxBandwidth -ne 1) {
        Write-Output 'Enableing BITS limitations'
        Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name EnableBitsMaxBandwidth -Value 1
    }
    if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).MaxTransferRateOnSchedule -ne 9999) {
        Write-Output 'Setting MaxTransferRateOnSchedule'
        Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name MaxTransferRateOnSchedule -Value 9999
    }
    if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS).MaxTransferRateOffSchedule -ne 999999) {
        Write-Output 'Setting MaxTransferRateOffSchedule'
        Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\BITS -Name MaxTransferRateOffSchedule -Value 999999
    }
    Start-Service -Name BITS
    Start-Service -Name CcmExec
} #End Repair-CmnProgressStuck

Function Repair-CmnWsusSoftwareDir {

    #https://gallery.technet.microsoft.com/scriptcenter/ConfigMgr-Client-Action-16a364a5
    #https://powershell.org/forums/topic/remotely-invoking-sccm-client-actions/

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM()
    Write-Output 'Starting'
    Write-Verbose 'Stopping WUAUSERV'
    Stop-Service -Name wuauserv
    Write-Verbose 'Deleting Downloads'
    Remove-Item C:\windows\SoftwareDistribution\Download\* -Recurse -Force -ErrorAction SilentlyContinue
    Write-Verbose 'Deleting Datastore'
    Remove-Item C:\windows\SoftwareDistribution\DataStore\*.edb -Force -ErrorAction SilentlyContinue
    Write-Verbose 'Starting WUAUSERV'
    Start-Service -Name wuauserv
    Write-Verbose 'Deleteing DownloadContentRequestEx2 class'
    Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class DownloadContentRequestEx2 | Remove-WmiObject -ErrorAction SilentlyContinue
    Write-Verbose 'Deleting DownloadInfoex2 class'
    Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class DownloadInfoex2 | Remove-WmiObject -ErrorAction SilentlyContinue
    Write-Verbose 'Restarting CcmExec'
    Restart-Service -Name CcmExec
    Write-Output 'Sleeping for 60 seconds'
    Start-Sleep -Seconds 60
    Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name TriggerSchedule -ArgumentList '{00000000-0000-0000-0000-000000000108}' | Out-Null
    Write-Output 'Finished'
} #End Repair-CmnWsusSoftwareDir

Function Reset-CmnInventory {
    try {
        Write-Output "Renaming $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old"
        if (Test-Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol") {
            Write-Output "Moving $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old"
            Move-Item -Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol" -Destination "$env:windir\System32\GroupPolicy\Machine\Registry.old" -Force
        }
        else {
            Write-Output "unable to find $env:windir\System32\GroupPolicy\Machine\Registry.pol"
        }
    }
    
    Catch {
        Write-Output "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol"
        Throw "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol"
    }
    
    try {
        Write-Output "Removing InventoryActionSatus from WMI"
        Get-CimInstance -CimSession $cimSession -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus -Filter "InventoryActionID = '{00000000-0000-0000-0000-000000000001}'" -ErrorAction SilentlyContinue | Remove-CimInstance
        Invoke-CimMethod -Namespace root\ccm -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}' } -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        Write-Output "Unable to reset inventory"
        Write-Output $Error.ErrorDetails
        Throw "Unable to reset inventory"
    }
    
    Write-Output "$env:COMPUTERNAME complete!"
} #End Reset-CmnInventory

Function Remove-RegKey {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Validateset('HKCR', 'HKCU', 'HKLM', 'HKUS', 'HKCC')]
        [string]$hive,

        [Parameter(Mandatory = $true)]
        [string]$key,

        [Parameter(Mandatory = $false)]
        [Int32]$retries = 10
    )
    Switch ($hive) {
        'HKCR' { $hiveName = 'HKEY_CLASSES_ROOT' }
        'HKCU' { $hiveName = 'HKEY_CURRENT_USER' }
        'HKLM' { $hiveName = 'HKEY_LOCAL_MACHINE' }
        'HKUS' { $hiveName = 'HKEY_USERS' }
        'HKCC' { $hiveName = 'HKEY_CURRENT_CONFIG' }
    }
    $count = 0
    While ($count -lt $retries -and (Test-Path -Path "$($hive):$($key)" -ErrorAction SilentlyContinue)) {
        $count++
        Set-RegKeyOwner -hive $hive -key $key
        Remove-Item "$($hive):$($key)" -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path "$($hive):$($key)" -ErrorAction SilentlyContinue) {
            $dirs = Get-ChildItem -Path "$($hive):$($key)" -Recurse | Select-Object -Property Name
            foreach ($dir in $dirs) {
                $keyPath = $dir.Name -replace "$($hiveName)\\", ''
                Write-Log -Message "Taking Ownership of $keyPath"
                Set-RegKeyOwner -hive $hive -key -$keyPath
                Write-Log -Message "Removing $keyPath"
                Remove-Item "$($hive):$($key)" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
} #End Remove-RegKey

Function Set-RegKeyOwner {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$ComputerName = 'localhost',

        [Parameter(Mandatory = $true)]
        [Validateset('HKCR', 'HKCU', 'HKLM', 'HKUS', 'HKCC')]
        [string]$hive,

        [Parameter(Mandatory = $true)]
        [string]$key
    )
    Write-Log -Message "Set Hive"
    switch ($hive) {
        'HKCR' { $reg = [Microsoft.Win32.Registry]::ClassesRoot }
        'HKCU' { $reg = [Microsoft.Win32.Registry]::CurrentUser }
        'HKLM' { $reg = [Microsoft.Win32.Registry]::LocalMachine }
        'HKUS' { $reg = [Microsoft.Win32.Registry]::Users }
        'HKCC' { $reg = [Microsoft.Win32.Registry]::CurrentConfig }
    }

    $permchk = [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree
    # $regrights = [System.Security.AccessControl.RegistryRights]::ChangePermissions
    $regrights = [System.Security.AccessControl.RegistryRights]::TakeOwnership

    Write-Log -Message "Open Key ($key) and get access control"
    $regkey = $reg.OpenSubKey($key, $permchk, $regrights)
    $rs = $regkey.GetAccessControl()

    Write-Log -Message 'Create security principal'
    $user = New-Object -TypeName Security.Principal.NTaccount -ArgumentList 'Administrators'

    $rs.SetGroup($user)
    $rs.SetOwner($user)
    $regkey.SetAccessControl($rs)
} #End Set-RegKeyOwner

# Variables
$FeatureTypes = @("Unknown", "Application", "Program", "Invalid", "Invalid", "Software Update", "Invalid", "Task Sequence")

$OfferTypes = @("Required", "Not Used", "Available")

$FastDPOptions = @('RunProgramFromDistributionPoint', 'DownloadContentFromDistributionPointAndRunLocally')

$ObjectIDtoObjectType = @{
    2    = 'SMS_Package';
    3    = 'SMS_Advertisement';
    7    = 'SMS_Query';
    8    = 'SMS_Report';
    9    = 'SMS_MeteredProductRule';
    11   = 'SMS_ConfigurationItem';
    14   = 'SMS_OperatingSystemInstallPackage';
    17   = 'SMS_StateMigration';
    18   = 'SMS_ImagePackage';
    19   = 'SMS_BootImagePackage';
    20   = 'SMS_TaskSequencePackage';
    21   = 'SMS_DeviceSettingPackage';
    23   = 'SMS_DriverPackage';
    25   = 'SMS_Driver';
    1011 = 'SMS_SoftwareUpdate';
    2011 = 'SMS_ConfigurationBaselineInfo';
    5000 = 'SMS_Collection_Device';
    5001 = 'SMS_Collection_User';
    6000 = 'SMS_ApplicationLatest';
    6001 = 'SMS_ConfigurationItemLatest';
}

$ObjectTypetoObjectID = @{
    'SMS_Package'                       = 2;
    'SMS_Advertisement'                 = 3;
    'SMS_Query'                         = 7;
    'SMS_Report'                        = 8;
    'SMS_MeteredProductRule'            = 9;
    'SMS_ConfigurationItem'             = 11;
    'SMS_OperatingSystemInstallPackage' = 14;
    'SMS_StateMigration'                = 17;
    'SMS_ImagePackage'                  = 18;
    'SMS_BootImagePackage'              = 19;
    'SMS_TaskSequencePackage'           = 20;
    'SMS_DeviceSettingPackage'          = 21;
    'SMS_DriverPackage'                 = 23;
    'SMS_Driver'                        = 25;
    'SMS_SoftwareUpdate'                = 1011;
    'SMS_ConfigurationBaselineInfo'     = 2011;
    'SMS_Collection_Device'             = 5000;
    'SMS_Collection_User'               = 5001;
    'SMS_ApplicationLatest'             = 6000;
    'SMS_ConfigurationItemLatest'       = 6001;
}

$RerunBehaviors = @{
    RERUN_ALWAYS       = 'AlwaysRerunProgram';
    RERUN_NEVER        = 'NeverRerunDeployedProgra';
    RERUN_IF_FAILED    = 'RerunIfFailedPreviousAttempt';
    RERUN_IF_SUCCEEDED = 'RerunIfSucceededOnpreviousAttempt';
}

$SlowDPOptions = @('DoNotRunProgram', 'DownloadContentFromDistributionPointAndLocally', 'RunProgramFromDistributionPoint')

$SMS_Advertisement_AdvertFlags = @{
    IMMEDIATE                         = "0x00000020";
    ONSYSTEMSTARTUP                   = "0x00000100";
    ONUSERLOGON                       = "0x00000200";
    ONUSERLOGOFF                      = "0x00000400";
    WINDOWS_CE                        = "0x00008000";
    ENABLE_PEER_CACHING               = "0x00010000";
    DONOT_FALLBACK                    = "0x00020000";
    ENABLE_TS_FROM_CD_AND_PXE         = "0x00040000";
    OVERRIDE_SERVICE_WINDOWS          = "0x00100000";
    REBOOT_OUTSIDE_OF_SERVICE_WINDOWS = "0x00200000";
    WAKE_ON_LAN_ENABLED               = "0x00400000";
    SHOW_PROGRESS                     = "0x00800000";
    NO_DISPLAY                        = "0x02000000";
    ONSLOWNET                         = "0x04000000";
}

$SMS_Advertisement_DeviceFlags = @{
    AlwaysAssignProgramToTheClient = "0x01000000";
    OnlyIfDeviceHighBandwidth      = "0x02000000";
    AssignIfDocked                 = "0x04000000";
}

$SMS_Advertisement_ProgramFlags = @{
    DYNAMIC_INSTALL            = "0x00000001";
    TS_SHOW_PROGRESS           = "0x00000002";
    DEFAULT_PROGRAM            = "0x0000001";
    DISABLE_MOM_ALERTS         = "0x00000020";
    GENERATE_MOM_ALERT_IF_FAIL = "0x00000040";
    ADVANCED_CLIENT            = "0x00000080";
    DEVICE_PROGRAM             = "0x00000100";
    RUN_DEPENDENT              = "0x00000200";
    NO_COUNTDOWN_DIALOG        = "0x00000400";
    RESTART_ADR                = "0x00000800";
    PROGRAM_DISABLED           = "0x00001000";
    NO_USER_INTERACTION        = "0x00002000";
    RUN_IN_USER_CONTEXT        = "0x00004000";
    RUN_AS_ADMINISTRATOR       = "0x00008000";
    RUN_FOR_EVERY_USER         = "0x00010000";
    NO_USER_LOGGED_ON          = "0x00020000";
    EXIT_FOR_RESTART           = "0x00080000";
    USE_UNC_PATH               = "0x00100000";
    PERSIST_CONNECTION         = "0x00200000";
    RUN_MINIMIZED              = "0x00400000";
    RUN_MAXIMIZED              = "0x00800000";
    RUN_HIDDEN                 = "0x01000000";
    LOGOFF_WHEN_COMPLETE       = "0x02000000"
    ADMIN_ACCOUNT_DEFINED      = "0x04000000";
    OVERRIDE_PLATFORM_CHECK    = "0x08000000";
    UNINSTALL_WHEN_EXPIRED     = "0x20000000";
    PLATFORM_NOT_SUPPORTED     = "0x40000000"
    DISPLAY_IN_ADR             = "0x80000000";
}

$SMS_Advertisement_RemoteClientFlags = @{
    BATTERY_POWER                     = "0x00000001";
    RUN_FROM_CD                       = "0x00000002";
    DOWNLOAD_FROM_CD                  = "0x00000004";
    RUN_FROM_LOCAL_DISPPOINT          = "0x00000008";
    DOWNLOAD_FROM_LOCAL_DISPPOINT     = "0x00000010";
    DONT_RUN_NO_LOCAL_DISPPOINT       = "0x00000020";
    DOWNLOAD_FROM_REMOTE_DISPPOINT    = "0x00000040";
    RUN_FROM_REMOTE_DISPPOINT         = "0x00000080";
    DOWNLOAD_ON_DEMAND_FROM_LOCAL_DP  = "0x00000100";
    DOWNLOAD_ON_DEMAND_FROM_REMOTE_DP = "0x00000200";
    BALLOON_REMINDERS_REQUIRED        = "0x00000400";
    RERUN_ALWAYS                      = "0x00000800";
    RERUN_NEVER                       = "0x00001000";
    RERUN_IF_FAILED                   = "0x00002000";
    RERUN_IF_SUCCEEDED                = "0x00004000";
    PERSIST_ON_WRITE_FILTER_DEVICES   = "0x00008000";
    DONT_FALLBACK                     = "0x00020000";
    DP_ALLOW_METERED_NETWORK          = "0x00040000";
}

$SMS_Advertisement_TimeFlags = @{
    ENABLE_PRESENT     = '0x00000001';
    ENABLE_EXPIRATION  = '0x00000002';
    ENABLE_AVAILABLE   = '0x00000004';
    ENABLE_UNAVAILABLE = '0x00000008';
    ENABLE_MANDATORY   = '0x00000010';
    GMT_PRESENT        = '0x00000020';
    GMT_EXPIRATION     = '0x00000040';
    GMT_AVAILABLE      = '0x00000080';
    GMT_UNAVAILABLE    = '0x00000100';
    GMT_MANDATORY      = '0x00000200';
}

$SMS_Package_PkgFlags = @{
    COPY_CONTENT         = '0x00000080';
    DO_NOT_DOWNLOAD      = '0x01000000';
    PERSIST_IN_CACHE     = '0x02000000';
    USE_BINARY_DELTA_REP = '0x04000000';
    NO_PACKAGE           = '0x10000000';
    USE_SPECIAL_MIF      = '0x20000000';
    DISTRIBUTE_ON_DEMAND = '0x40000000';
}

$SMS_Program_ProgramFlags = @{
    AUTHORIZED_DYNAMIC_INSTALL = '0x00000001';
    USECUSTOMPROGRESSMSG       = '0x00000002';
    DEFAULT_PROGRAM            = '0x00000010';
    DISABLEMOMALERTONRUNNING   = '0x00000020';
    MOMALERTONFAIL             = '0x00000040';
    RUN_DEPENDANT_ALWAYS       = '0x00000080'
    WINDOWS_CE                 = '0x00000100';
    COUNTDOWN                  = '0x00000400';
    FORCERERUN                 = '0x00000800';
    DISABLED                   = '0x00001000';
    UNATTENDED                 = '0x00002000';
    USERCONTEXT                = '0x00004000';
    ADMINRIGHTS                = '0x00008000';
    EVERYUSER                  = '0x00010000';
    NOUSERLOGGEDIN             = '0x00020000';
    OKTOQUIT                   = '0x00040000';
    OKTOREBOOT                 = '0x00080000';
    USEUNCPATH                 = '0x00100000';
    PERSISTCONNECTION          = '0x00200000';
    RUNMINIMIZED               = '0x00400000';
    RUNMAXIMIZED               = '0x00800000';
    HIDEWINDOW                 = '0x01000000';
    OKTOLOGOFF                 = '0x02000000';
    RUNACCOUNT                 = '0x04000000';
    ANY_PLATFORM               = '0x08000000';
    SUPPORT_UNINSTALL          = '0x20000000';
}

Remove-RegKey -hive 'HKLM' -key 'SOFTWARE\Humana\Test'
function Export-CMTaskSequenceStepClasses {
    <#
    .Synopsis
       Exports all task sequence step properties to .csv for reference
    .DESCRIPTION
       This cmdlet is used to gather all available task sequence actions from a ConfigMgr Site Server. It queries all WMI classes with the name SMS_TaskSequence_* (ConfigMgr native steps) and BDD_* (MDT integrated steps). The gathered steps are exported to a .csv file with all available property names. The default path is $env:TEMP\ConfigMgr_TSStep_Reference.csv.
    .EXAMPLE
        .\Export-CMTaskSequenceStepClasses.ps1 -SiteServer CM01 -SiteCode CM1
       This example exports all TS step properties to the default path in the users TEMP directory
    .EXAMPLE
       .\Export-CMTaskSequenceStepClasses.ps1 -SiteServer CM01 -SiteCode CM1 -ExportPath c:\temp\TSReference.csv
       This example exports all TS step properties to a specified .csv path
    .EXAMPLE
       .\Export-CMTaskSequenceStepClasses.ps1 -SiteServer CM01 -SiteCode CM1 -ExportPath c:\temp\TSReference.csv -NoMDT
       This example exports all TS step properties to a specified .csv path but does not include MDT steps
    .LINK
        Operating System Deployment Server WMI Classes
        https://msdn.microsoft.com/en-us/library/cc145036.aspx
    #>

    #requires -version 3

    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue})]
    [string]$SiteServer,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -eq ([wmiclass]"\\$SiteServer\root\ccm:sms_client").GetAssignedSite().sSiteCode})]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -like "*.csv"})]
    [string]$ExportPath = "$env:TEMP\ConfigMgr_TSStep_Reference.csv",
    [switch]$NoMDT = $false
    )

    # Create array object to populate
    $ClassList = @()

    # Gather the ConfigMgr Task Sequence Step Classes from the site server WMI
    Get-CimClass -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -ClassName sms_tasksequence_* | 
    ForEach-Object {
        $TSClassName = $_.CimClassName
        $_.CimClassProperties |
        ForEach-Object {
            $TSClassList = New-Object psobject
            $TSClassList | Add-Member -MemberType NoteProperty -Name ClassName -Value $TSClassName
            $TSClassList | Add-Member -MemberType NoteProperty -Name PropertyName -Value $_.Name
            $TSClassList | Add-Member -MemberType NoteProperty -Name PropertyValue -Value $_.Value
            $TSClassList | Add-Member -MemberType NoteProperty -Name PropertyCimType -Value $_.CimType
            $TSClassList | Add-Member -MemberType NoteProperty -Name PropertyFlags -Value $_.Flags
            $TSClassList | Add-Member -MemberType NoteProperty -Name PropertyQualifiers -Value $_.Qualifiers
            $TSClassList | Add-Member -MemberType NoteProperty -Name PropertyReferenceClassName -Value $_.ReferenceClassName
            $ClassList += $TSClassList
        }
    }

    if (!$NoMDT) {
        # Gather the BDD/MDT Task Sequence Step Classes from the site server WMI
        Get-CimClass -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -ClassName BDD_* | 
        ForEach-Object {
            $BDDClassName = $_.CimClassName
            $_.CimClassProperties |
            ForEach-Object {
                $BDDClassList = New-Object psobject
                $BDDClassList | Add-Member -MemberType NoteProperty -Name ClassName -Value $BDDClassName
                $BDDClassList | Add-Member -MemberType NoteProperty -Name PropertyName -Value $_.Name
                $BDDClassList | Add-Member -MemberType NoteProperty -Name PropertyValue -Value $_.Value
                $BDDClassList | Add-Member -MemberType NoteProperty -Name PropertyCimType -Value $_.CimType
                $BDDClassList | Add-Member -MemberType NoteProperty -Name PropertyFlags -Value $_.Flags
                $BDDClassList | Add-Member -MemberType NoteProperty -Name PropertyQualifiers -Value $_.Qualifiers
                $BDDClassList | Add-Member -MemberType NoteProperty -Name PropertyReferenceClassName -Value $_.ReferenceClassName
                $ClassList += $BDDClassList
            }
        }
    }

    # Export the task sequence step classes to .csv
    $ClassList | Export-Csv -Path $ExportPath -NoTypeInformation -Verbose
}

function Get-CMTaskSequenceSteps {
    <#
    .Synopsis
       Enumerates all steps for a ConfigMgr task sequence and exports to .csv
    .DESCRIPTION
       This script connects to a ConfigMgr site server specified in the parameters and enumerates all task sequence steps from the task sequence
       specified in the parameters. 
   
       The following common properties are gathered:
        -Step index
        -Step name
        -Step ObjectClass (Type of step)
        -Step enabled
        -Condition Type
        -Condition details
        -Continue on Error
        -PackageID
        -Description
        -Supported environment
   
       The output is .csv with a default path of $env:TEMP, the users TEMP directory. 
    .NOTES
       In the Condition Details, multiple If statements are not currently documented
    .EXAMPLE
       .\Get-CMTaskSequenceSteps -SiteServer CM01 -SiteCode CM1 -TaskSequenceName "Win7x64 Deploy"
       This example exports all TS steps for Win7x64-Deploy to the default path in the users TEMP directory, CMTaskSequenceSteps_<Task Sequence Name>.csv
    .EXAMPLE
       .\Get-CMTaskSequenceSteps -SiteServer CM01 -SiteCode CM1 -TaskSequenceName "Win7x64 Deploy" -ExportPath c:\temp\TSSteps.csv
       This example exports all TS steps for Win7x64-Deploy to the path specified, c:\temp\TSSteps.csv
    .LINK
        Operating System Deployment SDK Reference - Enumerate task sequence steps
        https://msdn.microsoft.com/en-us/library/jj217971.aspx
    #>

    #requires -version 3
    #requires -Modules ConfigurationManager

    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue})]
    [string]$SiteServer,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -eq ([wmiclass]"\\$SiteServer\root\ccm:sms_client").GetAssignedSite().sSiteCode})]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -in (Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -Class SMS_TaskSequencePackage).Name})]
    $TaskSequenceName,
    $ExportPath = "$env:TEMP\CMTaskSequenceSteps_$TaskSequenceName.csv"
    )

    # Import the ConfigurationManager module and set the Site Code path
    Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $SiteServer | Out-Null
    Push-Location "${SiteCode}:"

    # Get the task sequence
    $TaskSequencePackage = Get-CMTaskSequence -Name $taskSequenceName

    # Prepare parameters
    $MethodParams = New-Object "System.Collections.Generic.Dictionary [string, object]"
    $MethodParams.Add("TaskSequencePackage", $taskSequencePackage)

    # Get the task sequence steps
    $OutParams = $taskSequencePackage.ConnectionManager.ExecuteMethod("SMS_TaskSequencePackage", "getSequence", $methodParams)
    $TaskSequence = $outParams.GetSingleItem("TaskSequence")

    # Build step array and set counters
    $global:TSSteps = @()
    $global:i = 0
    $x = 0

    # Function to identify and parse groups
    function Get-CMTSGroupSteps {
        if ($_.SmsProviderObjectPath -eq "SMS_TaskSequence_Group"){
            $TSStepGroup = $_.Name
            Get-CMTSStepProperties
            $_.Steps |
            ForEach-Object {
                Get-CMTSGroupSteps
            }
        } else {
            Get-CMTSStepProperties
        }
    }

    # Function to enumerate steps and gather step properties                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    function Get-CMTSStepProperties {
        $global:i++
        $Step = $_

        # Gather condition properties
        $ConditionProperties = $_.Condition.Operands
        switch ($ConditionProperties.SmsProviderObjectPath) {
                    SMS_TaskSequence_VariableConditionExpression {
            $Condition = "TSVariable: " + $ConditionProperties.Variable + " " + $ConditionProperties.Operator + " " + $ConditionProperties.Value
        }
                                    SMS_TaskSequence_OSConditionGroup {
            if ($ConditionProperties.Operands.Name.Count -gt 1) {
                $Condition = [string]::join(",",($ConditionProperties.Operands.Name))
            } else {
                $Condition = $ConditionProperties.Operands.Name
            }
        }
                                                    SMS_TaskSequence_FileConditionExpression {
            if ($ConditionProperties.DateTime -ne $null -and $ConditionProperties.Version -ne $null) {
                $Condition = "File: " + $ConditionProperties.Path + "`nVersion " + $ConditionProperties.VersionOperator + " " + $ConditionProperties.Version + "`nDateTime " + $ConditionProperties.DateTimeOperator + " " + $ConditionProperties.DateTime
            } elseif ($ConditionProperties.Version -ne $null) {
                $Condition = "File: " + $ConditionProperties.Path + "`nVersion " + $ConditionProperties.VersionOperator + " " + $ConditionProperties.Version
            } elseif ($ConditionProperties.DateTime -ne $null) {
                $Condition = "File: " + $ConditionProperties.Path + "`nDateTime " + $ConditionProperties.DateTimeOperator + " " + $ConditionProperties.DateTime
            } else {
                $Condition = "File: " + $ConditionProperties.Path
            }
        }
                                    SMS_TaskSequence_FolderConditionExpression {
            if ($ConditionProperties.DateTime -ne $null) {
                $Condition = "Folder: " + $ConditionProperties.Path + "`nDateTime " + $ConditionProperties.DateTimeOperator + " " + $ConditionProperties.DateTime
            } else {
                $Condition = "Folder: " + $ConditionProperties.Path
            }
        }
                                    SMS_TaskSequence_RegistryConditionExpression {
            if ($ConditionProperties.Data -ne $null) {
                $Condition = "Key: " + $ConditionProperties.KeyPath + "\" + $ConditionProperties.Value + "`nType: " + $ConditionProperties.Type + "`nCondition: " + $ConditionProperties.Operator + " " + $ConditionProperties.Data
            } else {
                $Condition = "Key: " + $ConditionProperties.KeyPath + "\" + $ConditionProperties.Value + "`nType: " + $ConditionProperties.Type + "`nCondition: " + $ConditionProperties.Operator
            }
        }
                    SMS_TaskSequence_WMIConditionExpression {
            $Condition = "Namespace: " + $ConditionProperties.Namespace + "`nQuery: " + $ConditionProperties.Query
        }
                    SMS_TaskSequence_SoftwareConditionExpression {
            $Condition = $ConditionProperties.Operator + " of `nProductCode: " + $ConditionProperties.ProductCode + "`nProduct: " + $ConditionProperties.ProductName + "`nUpgradeCode: " + $ConditionProperties.UpgradeCode + "`nVersion: " + $ConditionProperties.Version
        }
                                                                                                                                                                                                                        SMS_TaskSequence_ConditionOperator {
            $ConditionArray = @()
            $ConditionArray += "Logic: " + $ConditionProperties.OperatorType + "`n"
            $ConditionProperties.Operands | 
            ForEach-Object {
                switch ($ConditionProperties.Operands.SmsProviderObjectPath) {
                    SMS_TaskSequence_VariableConditionExpression {
                            $ConditionArray += "TSVariable: " + $ConditionProperties.Operands.Variable[0] + " " + $ConditionProperties.Operands.Operator[0] + " " + $ConditionProperties.Operands.Value[0]
                    }
                    SMS_TaskSequence_OSConditionGroup {
                        if ($ConditionProperties.Operands.Operands.Name.Count -gt 1) {
                            $ConditionArray += [string]::join(",",($ConditionProperties.Operands.Operands.Name))
                        } else {
                            $ConditionArray += $ConditionProperties.Operands.Operands.Name
                        }
                    }
                    SMS_TaskSequence_FileConditionExpression {
                        if ($ConditionProperties.Operands.DateTime -ne $null -and $ConditionProperties.Operands.Version -ne $null) {
                            $ConditionArray += "File: " + $ConditionProperties.Operands.Path + "`nVersion " + $ConditionProperties.Operands.VersionOperator + " " + $ConditionProperties.Operands.Version + "`nDateTime " + $ConditionProperties.Operands.DateTimeOperator + " " + $ConditionProperties.Operands.DateTime
                        } elseif ($ConditionProperties.Operands.Version -ne $null) {
                            $ConditionArray += "File: " + $ConditionProperties.Operands.Path + "`nVersion " + $ConditionProperties.Operands.VersionOperator + " " + $ConditionProperties.Operands.Version
                        } elseif ($ConditionProperties.Operands.DateTime -ne $null) {
                            $ConditionArray += "File: " + $ConditionProperties.Operands.Path + "`nDateTime " + $ConditionProperties.Operands.DateTimeOperator + " " + $ConditionProperties.Operands.DateTime
                        } else {
                            $ConditionArray += "File: " + $ConditionProperties.Operands.Path
                        }
                    }
                    SMS_TaskSequence_FolderConditionExpression {
                        if ($ConditionProperties.Operands.DateTime -ne $null) {
                            $ConditionArray += "Folder: " + $ConditionProperties.Operands.Path + "`nDateTime " + $ConditionProperties.Operands.DateTimeOperator + " " + $ConditionProperties.Operands.DateTime
                        } else {
                            $ConditionArray += "Folder: " + $ConditionProperties.Operands.Path
                        }
                    }
                    SMS_TaskSequence_RegistryConditionExpression {
                        if ($ConditionProperties.Operands.Data -ne $null) {
                            $ConditionArray += "Key: " + $ConditionProperties.Operands.KeyPath + "\" + $ConditionProperties.Operands.Value + "`nType: " + $ConditionProperties.Operands.Type + "`nCondition: " + $ConditionProperties.Operands.Operator + " " + $ConditionProperties.Operands.Data
                        } else {
                            $ConditionArray += "Key: " + $ConditionProperties.Operands.KeyPath + "\" + $ConditionProperties.Operands.Value + "`nType: " + $ConditionProperties.Operands.Type + "`nCondition: " + $ConditionProperties.Operands.Operator
                        }
                    }
                    SMS_TaskSequence_WMIConditionExpression {
                        $ConditionArray += "Namespace: " + $ConditionProperties.Operands.Namespace + "`nQuery: " + $ConditionProperties.Operands.Query
                    }
                    SMS_TaskSequence_SoftwareConditionExpression {
                        $ConditionArray += $ConditionProperties.Operands.Operator + " of `nProductCode: " + $ConditionProperties.Operands.ProductCode + "`nProduct: " + $ConditionProperties.Operands.ProductName + "`nUpgradeCode: " + $ConditionProperties.Operands.UpgradeCode + "`nVersion: " + $ConditionProperties.Operands.Version
                    }
                }
                $ConditionArray += "`n"
            }
            $Condition = [string]::join("`n",$ConditionArray)
        }
        }
        # Gather common properties
        $Global:TSStepsTemp = [PSCustomObject]@{
        Index = $i
        Group = $TSStepGroup
        Name = $Step.Name
        ObjectClass = $Step.ObjectClass
        PackageID = $Step.PackageID
        Description = $Step.Description
        Enabled = $Step.Enabled
        ContinueOnError = $Step.ContinueOnError
        SupportedEnvironment = $Step.SupportedEnvironment
        ConditionType = $ConditionProperties.SmsProviderObjectPath
        Condition = $Condition
        }
        
        # Gather specific properties to each class
        $SkipProperties = "Name", "ObjectClass", "Enabled", "Description", "ContinueOnError", "SupportedEnvironment", "Condition","PSComputerName","PSShowComputerName","PackageID","SMSProviderObjectPath","Timeout"
        $StepProperties = $Step | Get-Member -MemberType Property | Where-Object {$_.Name -notin $SkipProperties}

        for ($x = 0; $x -le 20; $x++) {
            if ($StepProperties -ne $null -and $Step.ObjectClass -ne "SMS_TaskSequence_Group") {
                $StepValue = $StepProperties[$x].Name + ": " + $Step.($StepProperties[$x].Name)
                if ($StepValue -eq ": ") {
                    $StepValue = " "
                }
                $global:TSStepsTemp | Add-Member -MemberType NoteProperty -Name "Property$x" -Value $StepValue
            } else {
                $global:TSStepsTemp | Add-Member -MemberType NoteProperty -Name "Property$x" -Value " "
            }
        }

        # Merge arrays and reset condition
        $global:TSSteps += $global:TSStepsTemp
        $condition = $null
    }

    # Enumerate the steps and check for groups
    $TaskSequence.Steps | 
    ForEach-Object {
        Get-CMTSGroupSteps
    }

    # Reset location and export array to .csv
    Pop-Location
    $global:TSSteps | Export-Csv -NoTypeInformation $ExportPath -Verbose
}

function Remove-CMTaskSequenceStep {
    <#
    .Synopsis
    Removes a Configuration Manager task sequence step
    .DESCRIPTION
    This script connects to a ConfigMgr site server specified in the parameters and enumerates all task sequence steps from the task sequence
    specified in the parameters. The step found matching the specified StepIndex is removed.
   
    This script does not generate any output. 
    .NOTES

    .EXAMPLE
    .\Remove-CMTaskSequenceStep -SiteServer CM01 -SiteCode CM1 -TaskSequencePackageID CM10000A -StepIndex 5
    This example removes the 5th step in the task sequence
    .EXAMPLE
    .\Remove-CMTaskSequenceStep -SiteServer CM01 -SiteCode CM1 -TaskSequencePackageID CM10000A -StepIndex 4 -Force
    This example removes the 4th step in the task sequence and forces removal if the step is a group
    .LINK
    Operating System Deployment SDK Reference - Delete a task sequence action
    https://msdn.microsoft.com/en-us/library/jj217830.aspx

    Operating System Deployment SDK Reference - Deleta a task sequence action from a group
    https://msdn.microsoft.com/en-us/library/jj217754.aspx
    #>

    #requires -version 3
    #requires -Modules ConfigurationManager
    
    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue})]
    [string]$SiteServer,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -eq ([wmiclass]"\\$SiteServer\root\ccm:sms_client").GetAssignedSite().sSiteCode})]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -in (Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -Class SMS_TaskSequencePackage).PackageID})]
    $TaskSequencePackageID,
    [Parameter(Mandatory=$True)]
    [int]$StepIndex
    )

    $SiteCode = $SiteCode.ToUpper()

    if (-not (test-path ${SiteCode}:)) {
        # Import the ConfigurationManager module and set the Site Code location
        Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $SiteServer -ErrorAction SilentlyContinue | Out-Null
    }
    

    if (Test-Path ${SiteCode}:) {
        # Set the ConfigMgr drive
        Push-Location "${SiteCode}:"

        # Get the task sequence
        $TaskSequencePackage = Get-CMTaskSequence -TaskSequencePackageID $TaskSequencePackageID

        # Prepare parameters
        $InMethodParams = New-Object "System.Collections.Generic.Dictionary [string, object]"
        $InMethodParams.Add("TaskSequencePackage", $TaskSequencePackage)

        # Get the task sequence steps
        $InParams = $TaskSequencePackage.ConnectionManager.ExecuteMethod("SMS_TaskSequencePackage", "getSequence", $InMethodParams)
        $TaskSequence = $InParams.GetSingleItem("TaskSequence")

        # Get array of SMS_TaskSequence_Steps
        $TaskSequenceSteps = $TaskSequence.GetArrayItems("Steps")

        # Build group array and set counters
        $global:TSGroupNest = @()
        $global:i = 0
        $global:z = 0

        # Function to identify and parse groups
        function Get-CMTSGroupSteps {
            # Store current step in variable for use later
            $global:Step = $_
            if ($_.SmsProviderObjectPath -eq "SMS_TaskSequence_Group"){
                # $_.UniqueIdentifier.Guid changes each time you reference it, have to store in a variable so steps/groups match up
                $global:CurrentTSStepGroup = $_
                $global:CurrentTSStepGroupSteps = $_.GetArrayItems("Steps")
                $global:TSGroupNest += $global:CurrentTSStepGroup
                
                # Store groups for parsing later
                New-Variable -Name TSGroupNestSteps$z -Value $global:CurrentTSStepGroupSteps -Scope global -ErrorAction SilentlyContinue

                # Increment counter to store groups in new variable
                $z++

                # Gather properties
                Get-CMTSStepProperties

                # Parse steps in current group
                $global:CurrentTSStepGroupSteps |
                ForEach-Object {
                    Get-CMTSGroupSteps
                }
            } else {
                # Gather properties
                Get-CMTSStepProperties
            }
        }

        # Function to enumerate steps and gather step properties                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        function Get-CMTSStepProperties {
            # Increment to match index
            $global:i++
            if ($global:i -le $StepIndex) {
                # If a group, add to group array to parse later
                if ($_.SmsProviderObjectPath -eq "SMS_TaskSequence_Group"){
                    $global:TSGroupNest | Add-Member -MemberType NoteProperty -Name Index -Value $i -ErrorAction SilentlyContinue
                }

                if ($i -eq $StepIndex) {
                    # Remove step from array and set array
                    if ($_ -in $TaskSequenceSteps) {
                        $TaskSequenceSteps.Remove($global:Step)
                        return
                    } else {
                        $global:CurrentTSStepGroupSteps.Remove($global:Step)
                        $global:CurrentTSStepGroup.SetArrayItems("Steps", $global:CurrentTSStepGroupSteps)
                        return
                    }
                }
            }
        }

        # Enumerate the steps and check for groups
        $TaskSequenceSteps | ForEach-Object {
            if ($global:i -le $StepIndex-1) {
                Get-CMTSGroupSteps
            }
        }

        if ($global:Step -notin $TaskSequenceSteps) {
            for ($x = $global:TSGroupNest.Length-2; $x -ge $TSGroupNestLength; $x--) {
                if ($x -eq 0) {
                    $TaskSequenceSteps[$TSGroupNest[0].Index-1].SetArrayItems("Steps", $TSGroupNestSteps0)
                }
            }
        }

        # Set the task sequence array
        $TaskSequence.SetArrayItems("Steps", $TaskSequenceSteps)

        # Prepare parameters for "SetSequence"
        $OutMethodParams = New-Object "System.Collections.Generic.Dictionary [string, object]"
        $OutMethodParams.Add("TaskSequence", $TaskSequence)
        $OutMethodParams.Add("TaskSequencePackage", $TaskSequencePackage)

        # Set the sequence
        $OutParams = $TaskSequencePackage.ConnectionManager.ExecuteMethod("SMS_TaskSequencePackage", "SetSequence", $OutMethodParams)
    } else {
        Write-Warning "Configuration Manager drive cannot be found!"
    }

    # Clean up variables
    Remove-Variable z -Scope global -ErrorAction SilentlyContinue
    Remove-Variable i -Scope global -ErrorAction SilentlyContinue
    Remove-Variable Step -Scope global -ErrorAction SilentlyContinue
    Remove-Variable TSGroupNest -Scope global -ErrorAction SilentlyContinue
    Remove-Variable TSGroupNestSteps0 -Scope global -ErrorAction SilentlyContinue
    Remove-Variable TSGroupNestSteps1 -Scope global -ErrorAction SilentlyContinue
    Remove-Variable CurrentTSStepGroup -Scope global -ErrorAction SilentlyContinue
    Remove-Variable CurrentTSStepGroupSteps -Scope global -ErrorAction SilentlyContinue

    # Set location back to local drive
    Pop-Location
}

function Add-CMTaskSequenceStep {
    <#
    .Synopsis
    Adds a new Configuration Manager task sequence step
    .DESCRIPTION
    This script connects to a ConfigMgr site server specified in the parameters and adds a step with the specified configuration to the task sequence 
    specified in the parameters. 

    If no StepIndex is specified, the step is added as the last step of the task sequence. Otherwise the step is inserted at the StepIndex specified.
   
    This script does not generate any output.
    .NOTES

    .EXAMPLE
    Add-CMTaskSequenceStep -SiteServer CM01 -SiteCode CM1 -TaskSequencePackageID CM10001B -StepType RunCommandLine -Name "Run a command" -CommandLine "cmd /c md c:\temp"
    This example creates a Run Command Line step with the default parameters
    .EXAMPLE
    Add-CMTaskSequenceStep -SiteServer CM01 -SiteCode CM1 -TaskSequencePackageID CM10001B -StepType RunCommandLine -Name "Run a command" -CommandLine "cmd /c md c:\temp" -StepIndex 8
    This example creates a Run Command Line step with the default parameters as the 8th step in the task sequence
    .EXAMPLE
    Add-CMTaskSequenceStep -SiteServer CM01 -SiteCode CM1 -TaskSequencePackageID CM10001B -StepType RunCommandLine -Name "Run a command" -CommandLine "cmd /c md c:\temp" -Enabled:$false
    This example creates a Run Command Line step with the default parameters and the step disabled
    .EXAMPLE
    Add-CMTaskSequenceStep -SiteServer CM01 -SiteCode CM1 -TaskSequencePackageID CM10001B -StepType RunCommandLine -Name "Run a command" -CommandLine "cmd /c md c:\temp" -Description "Test cmdline step"
    This example creates a Run Command Line step with the default parameters and a description
    .EXAMPLE
    Add-CMTaskSequenceStep -SiteServer CM01 -SiteCode CM1 -TaskSequencePackageID CM10001B -StepType RunCommandLine -Name "Run a command" -CommandLine "cmd /c md c:\temp" -ContinueOnError:$true
    This example creates a Run Command Line step with the default parameters and sets the step to Continue On Error.
    .LINK
    Operating System Deployment SDK Reference - Add a step
    https://msdn.microsoft.com/en-us/library/jj218110.aspx
    
    Operating System Deployment SDK Reference - Add a step to a group
    https://msdn.microsoft.com/en-us/library/jj217987.aspx
     
    Ben Burckart - Edit existing task sequence with PowerShell
    http://www.thegeeksclub.de/archives/83
    #>

    #requires -version 3
    #requires -Modules ConfigurationManager

    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue})]
    [string]$SiteServer,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -eq ([wmiclass]"\\$SiteServer\root\ccm:sms_client").GetAssignedSite().sSiteCode})]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [ValidateScript({$_ -in (Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode -Class SMS_TaskSequencePackage).PackageID})]
    $TaskSequencePackageID,
    [Parameter(Mandatory=$True)]
    [ValidateSet("RunCommandLine","InstallPackage","InstallApplication","Group")]
    [String]$StepType,
    [int]$StepIndex = '9999',
    [Parameter(Mandatory=$True)]
    [string]$Name,
    [string]$Description,
    [switch]$Enabled = $true,
    [switch]$ContinueOnError = $false,
    [Parameter(ParameterSetName='RunCommandLine', Mandatory=$True)]
    [string]$CommandLine = "",
    [Parameter(ParameterSetName='RunCommandLine')]
    [Parameter(ParameterSetName='InstallPackage')]
    [string]$PackageID,
    [Parameter(ParameterSetName='RunCommandLine')]
    [switch]$DisableWow64Redirection = $false,
    [Parameter(ParameterSetName='RunCommandLine')]
    [string]$SuccessCodes,
    [Parameter(ParameterSetName='RunCommandLine')]    
    [string]$WorkingDirectory,
    [Parameter(ParameterSetName='RunCommandLine')]
    [switch]$RunAsUser = $false,
    [Parameter(ParameterSetName='RunCommandLine')]
    [string]$CmdlineUserName,
    [Parameter(ParameterSetName='RunCommandLine')]
    [string]$CmdlineUserPassword,
    [Parameter(ParameterSetName='RunCommandLine')]
    [int32]$TimeOut,
    [Parameter(ParameterSetName='InstallPackage')]
    [string]$ProgramName,
    [Parameter(ParameterSetName='InstallPackage')]
    [string]$BasePkgVariableName,
    [Parameter(ParameterSetName='InstallApplication')]
    [string]$BaseAppVariableName,
    [Parameter(ParameterSetName='InstallPackage')]
    [Parameter(ParameterSetName='InstallApplication')]
    [switch]$ContinueOnInstallError = $false,
    [Parameter(ParameterSetName='InstallApplication')]
    [string]$ApplicationName,
    [Parameter(ParameterSetName='InstallApplication')]
    $ApplicationInfo,
    [Parameter(ParameterSetName='InstallApplication')]
    [ValidateRange(1,10)]
    [int32]$NumApps,
    [Parameter(ParameterSetName='InstallApplication')]
    [ValidateRange(0,5)]
    [string]$RetryCount
    )

    $SiteCode = $SiteCode.ToUpper()

    if (-not (test-path ${SiteCode}:)) {
        # Import the ConfigurationManager module and set the Site Code location
        Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $SiteServer -ErrorAction SilentlyContinue | Out-Null
    }

    if (Test-Path ${SiteCode}:) {
        # Set the ConfigMgr drive
        Push-Location "${SiteCode}:"

        # Get the task sequence
        $TaskSequencePackage = Get-CMTaskSequence -TaskSequencePackageID $TaskSequencePackageID

        # Prepare parameters
        $InMethodParams = New-Object "System.Collections.Generic.Dictionary [string, object]"
        $InMethodParams.Add("TaskSequencePackage", $TaskSequencePackage)

        # Get the task sequence steps
        $InParams = $TaskSequencePackage.ConnectionManager.ExecuteMethod("SMS_TaskSequencePackage", "getSequence", $InMethodParams)
        $TaskSequence = $InParams.GetSingleItem("TaskSequence")

        # Get array of SMS_TaskSequence_Steps
        $TaskSequenceSteps = $TaskSequence.GetArrayItems("Steps")

        # Set the step class
        switch ($StepType) {
            RunCommandLine {$StepClass = "SMS_TaskSequence_RunCommandLineAction"}
            InstallPackage {$StepClass = "SMS_TaskSequence_InstallSoftwareAction"}
            InstallApplication {$StepClass = "SMS_TaskSequence_InstallApplicationAction"}
            Group {}
        }

        # Create step instance
        $NewTsStep = $taskSequencePackage.ConnectionManager.CreateEmbeddedObjectInstance($StepClass)

        # Set common step properties
        $NewTsStep.Name = $Name
        $NewTsStep.Description = $Description
        $NewTsStep.Enabled = $Enabled.IsPresent
        $NewTsStep.ContinueOnError = $ContinueOnError.IsPresent

        # Set specific step properties
        switch ($StepType) {
            RunCommandLine {
                if ($CommandLine) { $NewTsStep.CommandLine = $CommandLine }
                if ($DisableWow64Redirection) { $NewTsStep.DisableWow64Redirection = $DisableWow64Redirection.IsPresent }
                if ($PackageID) { $NewTsStep.PackageID = $PackageID }
                if ($RunAsUser) { $NewTsStep.RunAsUser = $RunAsUser.IsPresent }
                if ($SuccessCodes) { $NewTsStep.SuccessCodes = $SuccessCodes }
                if ($CmdlineUserName) { $NewTsStep.UserName = $CmdlineUserName }
                if ($CmdlineUserPassword) { $NewTsStep.UserPassword = $CmdlineUserPassword }
                if ($WorkingDirectory) { $NewTsStep.WorkingDirectory = $WorkingDirectory }
                if ($Timeout) { $NewTsStep.Timeout = $TimeOut }
            }
            InstallPackage {
                if ($PackageID) { $NewTsStep.PackageID = $PackageID }
                if ($ProgramName) { $NewTsStep.ProgramName = $ProgramName }
                if ($BasePkgVariableName) { $NewTsStep.BaseVariableName = $BasePkgVariableName }
                if ($ContinueOnInstallError) { $NewTsStep.ContinueOnInstallError = $ContinueOnInstallError.IsPresent }
            }
            InstallApplication {
                if ($ApplicationName) { $NewTsStep.ApplicationName = $ApplicationName}
                if ($ApplicationInfo) { $NewTsStep.AppInfo = $ApplicationInfo}
                if ($NumApps) { $NewTsStep.NumApps = $NumApps}
                if ($RetryCount) { $NewTsStep.RetryCount = $RetryCount}
                if ($BaseAppVariableName) { $NewTsStep.BaseVariableName = $BaseAppVariableName }
                if ($ContinueOnInstallError) { $NewTsStep.ContinueOnInstallError = $ContinueOnInstallError.IsPresent }
            }
            Group {}
        }

        $NewTsStep | select *

        # Build group array and set counters
        $global:TSGroupNest = @()
        $global:i = 0
        $global:z = 0
        $global:Continue = $True

        # Function to identify and parse groups
        function Get-CMTSGroupSteps {
            if ($Continue) {
                # Store current step in variable for use later
                $global:Step = $_
                if ($_.SmsProviderObjectPath -eq "SMS_TaskSequence_Group"){
                    # $_.UniqueIdentifier.Guid changes each time you reference it, have to store in a variable so steps/groups match up
                    $global:CurrentTSStepGroup = $_
                    $global:CurrentTSStepGroupSteps = $_.GetArrayItems("Steps")
                    $global:TSGroupNest += $global:CurrentTSStepGroup
                
                    # Store groups for parsing later
                    New-Variable -Name TSGroupNestSteps$z -Value $global:CurrentTSStepGroupSteps -Scope global -ErrorAction SilentlyContinue

                    # Increment counter to store groups in new variable
                    $z++

                    # Gather properties
                    Get-CMTSStepProperties

                    # Parse steps in current group
                    $global:CurrentTSStepGroupSteps |
                    ForEach-Object {
                        Get-CMTSGroupSteps
                    }
                } else {
                    # Gather properties
                    Get-CMTSStepProperties
                }
            }
        }

        # Function to enumerate steps and gather step properties                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        function Get-CMTSStepProperties {
            # Increment to match index
            $global:i++
            if ($global:i -le $StepIndex) {
                # If a group, add to group array to parse later
                if ($_.SmsProviderObjectPath -eq "SMS_TaskSequence_Group"){
                    $global:TSGroupNest | Add-Member -MemberType NoteProperty -Name Index -Value $i -ErrorAction SilentlyContinue
                }

                if ($i -eq $StepIndex) {
                    $global:Continue = $false
                    # Remove step from array and set array
                    if ($global:Step -in $TaskSequenceSteps) {
                        $Index = $TaskSequenceSteps.IndexOf($global:Step)
                        $TaskSequenceSteps.Insert($Index, $NewTsStep)
                        return
                    } else {
                        $Index = $CurrentTSStepGroupSteps.IndexOf($global:Step)
                        $global:CurrentTSStepGroupSteps.Insert($Index, $NewTsStep)
                        $global:CurrentTSStepGroup.SetArrayItems("Steps", $global:CurrentTSStepGroupSteps)
                        return
                    }
                }
            }
        }

        # Enumerate the steps and check for groups
        if ($StepIndex -eq '9999') {
            $TaskSequenceSteps.Add($NewTsStep)
        } else {
            $TaskSequenceSteps | foreach {
                if ($global:Continue) {
                    Get-CMTSGroupSteps
                }
            }
        }

        if ($global:Step -notin $TaskSequenceSteps) {
            for ($x = $global:TSGroupNest.Length-2; $x -ge $TSGroupNestLength; $x--) {
                if ($x -eq 0) {
                    $TaskSequenceSteps[$TSGroupNest[0].Index-1].SetArrayItems("Steps", $TSGroupNestSteps0)
                }
            }
        }

        # Set the task sequence array
        $TaskSequence.SetArrayItems("Steps", $TaskSequenceSteps)

        # Prepare parameters for "SetSequence"
        $OutMethodParams = New-Object "System.Collections.Generic.Dictionary [string, object]"
        $OutMethodParams.Add("TaskSequence", $TaskSequence)
        $OutMethodParams.Add("TaskSequencePackage", $TaskSequencePackage)

        # Set the sequence
        $OutParams = $TaskSequencePackage.ConnectionManager.ExecuteMethod("SMS_TaskSequencePackage", "SetSequence", $OutMethodParams)
    } else {
        Write-Warning "Configuration Manager drive cannot be found!"
    }

    # Clean up variables
    Remove-Variable z -Scope global -ErrorAction SilentlyContinue
    Remove-Variable i -Scope global -ErrorAction SilentlyContinue
    Remove-Variable Step -Scope global -ErrorAction SilentlyContinue
    Remove-Variable TSGroupNest -Scope global -ErrorAction SilentlyContinue
    Remove-Variable TSGroupNestSteps0 -Scope global -ErrorAction SilentlyContinue
    Remove-Variable TSGroupNestSteps1 -Scope global -ErrorAction SilentlyContinue
    Remove-Variable CurrentTSStepGroup -Scope global -ErrorAction SilentlyContinue
    Remove-Variable CurrentTSStepGroupSteps -Scope global -ErrorAction SilentlyContinue
    Remove-Variable NewTsStep -Scope global -ErrorAction SilentlyContinue

    # Set location back to local drive
    Pop-Location
}
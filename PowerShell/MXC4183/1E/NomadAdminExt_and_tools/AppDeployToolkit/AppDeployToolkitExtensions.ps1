<#
.SYNOPSIS
	This script is a template that allows you to extend the toolkit with your own custom functions.
    # LICENSE #
    PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows. 
    Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
    This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
    You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is automatically dot-sourced by the AppDeployToolkitMain.ps1 script.
.NOTES
    Toolkit Exit Code Ranges:
    60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
    69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
    70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK 
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
)

##*===============================================
##* VARIABLE DECLARATION
##*===============================================

# Variables: Script
[string]$appDeployToolkitExtName = 'PSAppDeployToolkitExt'
[string]$appDeployExtScriptFriendlyName = 'App Deploy Toolkit Extensions'
[version]$appDeployExtScriptVersion = [version]'1.5.0'
[string]$appDeployExtScriptDate = '02/12/2017'
[hashtable]$appDeployExtScriptParameters = $PSBoundParameters

##*===============================================
##* FUNCTION LISTINGS
##*===============================================

# <Your custom functions go here>
#region function Get-ComputerVirtualStatus
function Get-ComputerVirtualStatus {
    <# 
    .SYNOPSIS 
    Validate if a remote server is virtual or physical 
    .DESCRIPTION 
    Uses wmi (along with an optional credential) to determine if a remote computers, or list of remote computers are virtual. 
    If found to be virtual, a best guess effort is done on which type of virtual platform it is running on. 
    .PARAMETER ComputerName 
    Computer or IP address of machine 
    .PARAMETER Credential 
    Provide an alternate credential 
    .EXAMPLE 
    $Credential = Get-Credential 
    Get-RemoteServerVirtualStatus 'Server1','Server2' -Credential $Credential | select ComputerName,IsVirtual,VirtualType | ft 
     
    Description: 
    ------------------ 
    Using an alternate credential, determine if server1 and server2 are virtual. Return the results along with the type of virtual machine it might be. 
    .EXAMPLE 
    (Get-RemoteServerVirtualStatus server1).IsVirtual 
     
    Description: 
    ------------------ 
    Determine if server1 is virtual and returns either true or false. 

    .LINK 
    http://www.the-little-things.net/ 
    .LINK 
    http://nl.linkedin.com/in/zloeber 
    .NOTES 
     
    Name       : Get-RemoteServerVirtualStatus 
    Version    : 1.1.0 12/09/2014
                 - Removed prompt for credential
                 - Refactored some of the code a bit.
                 1.0.0 07/27/2013 
                 - First release 
    Author     : Zachary Loeber 
    #> 
    [cmdletBinding(SupportsShouldProcess = $true)] 
    param( 
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage="Computer or IP address of machine to test")] 
        [string[]]$ComputerName = $env:COMPUTERNAME, 
        [parameter(HelpMessage="Pass an alternate credential")] 
        [System.Management.Automation.PSCredential]$Credential = $null 
    ) 
    begin {
        $WMISplat = @{} 
        if ($Credential -ne $null) { 
            $WMISplat.Credential = $Credential 
        } 
        $results = @()
        $computernames = @()
    } 
    process { 
        $computernames += $ComputerName 
    } 
    end {
        foreach($computer in $computernames) { 
            $WMISplat.ComputerName = $computer 
            try { 
                $wmibios = Get-WmiObject Win32_BIOS @WMISplat -ErrorAction Stop | Select-Object version,serialnumber 
                $wmisystem = Get-WmiObject Win32_ComputerSystem @WMISplat -ErrorAction Stop | Select-Object model,manufacturer
                $ResultProps = @{
                    ComputerName = $computer 
                    BIOSVersion = $wmibios.Version 
                    SerialNumber = $wmibios.serialnumber 
                    Manufacturer = $wmisystem.manufacturer 
                    Model = $wmisystem.model 
                    IsVirtual = $false 
                    VirtualType = $null 
                }
                if ($wmibios.SerialNumber -like "*VMware*") {
                    $ResultProps.IsVirtual = $true
                    $ResultProps.VirtualType = "Virtual - VMWare"
                }
                else {
                    switch -wildcard ($wmibios.Version) {
                        'VIRTUAL' { 
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Hyper-V" 
                        } 
                        'A M I' {
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Virtual PC" 
                        } 
                        '*Xen*' { 
                            $ResultProps.IsVirtual = $true 
                            $ResultProps.VirtualType = "Virtual - Xen" 
                        }
                    }
                }
                if (-not $ResultProps.IsVirtual) {
                    if ($wmisystem.manufacturer -like "*Microsoft*") 
                    { 
                        $ResultProps.IsVirtual = $true 
                        $ResultProps.VirtualType = "Virtual - Hyper-V" 
                    } 
                    elseif ($wmisystem.manufacturer -like "*VMWare*") 
                    { 
                        $ResultProps.IsVirtual = $true 
                        $ResultProps.VirtualType = "Virtual - VMWare" 
                    } 
                    elseif ($wmisystem.model -like "*Virtual*") { 
                        $ResultProps.IsVirtual = $true
                        $ResultProps.VirtualType = "Unknown Virtual Machine"
                    }
                }
                $results += New-Object PsObject -Property $ResultProps
            }
            catch {
                Write-Warning "Cannot connect to $computer"
            } 
        } 
        return $results 
    } 
}
#endregion

#region Function Set-Owner
Function Set-Owner {
    <#
        .SYNOPSIS
            Changes owner of a file or folder to another user or group.

        .DESCRIPTION
            Changes owner of a file or folder to another user or group.

        .PARAMETER Path
            The folder or file that will have the owner changed.

        .PARAMETER Account
            Optional parameter to change owner of a file or folder to specified account.

            Default value is 'Builtin\Administrators'

        .PARAMETER Recurse
            Recursively set ownership on subfolders and files beneath given folder.

        .NOTES
            Name: Set-Owner
            Author: Boe Prox
            Version History:
                 1.0 - Boe Prox
                    - Initial Version

        .EXAMPLE
            Set-Owner -Path C:\temp\test.txt

            Description
            -----------
            Changes the owner of test.txt to Builtin\Administrators

        .EXAMPLE
            Set-Owner -Path C:\temp\test.txt -Account 'Domain\bprox

            Description
            -----------
            Changes the owner of test.txt to Domain\bprox

        .EXAMPLE
            Set-Owner -Path C:\temp -Recurse 

            Description
            -----------
            Changes the owner of all files and folders under C:\Temp to Builtin\Administrators

        .EXAMPLE
            Get-ChildItem C:\Temp | Set-Owner -Recurse -Account 'Domain\bprox'

            Description
            -----------
            Changes the owner of all files and folders under C:\Temp to Domain\bprox
    #>
    [cmdletbinding(
        SupportsShouldProcess = $True
    )]
    Param (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('FullName')]
        [string[]]$Path,
        [parameter()]
        [string]$Account = 'Builtin\Administrators',
        [parameter()]
        [switch]$Recurse
    )
    Begin {
        #Prevent Confirmation on each Write-Debug command when using -Debug
        If ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
        Try {
            [void][TokenAdjuster]
        } Catch {
            $AdjustTokenPrivileges = @"
            using System;
            using System.Runtime.InteropServices;

             public class TokenAdjuster
             {
              [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
              internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
              ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
              [DllImport("kernel32.dll", ExactSpelling = true)]
              internal static extern IntPtr GetCurrentProcess();
              [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
              internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr
              phtok);
              [DllImport("advapi32.dll", SetLastError = true)]
              internal static extern bool LookupPrivilegeValue(string host, string name,
              ref long pluid);
              [StructLayout(LayoutKind.Sequential, Pack = 1)]
              internal struct TokPriv1Luid
              {
               public int Count;
               public long Luid;
               public int Attr;
              }
              internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
              internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
              internal const int TOKEN_QUERY = 0x00000008;
              internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
              public static bool AddPrivilege(string privilege)
              {
               try
               {
                bool retVal;
                TokPriv1Luid tp;
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_ENABLED;
                retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
                retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
                return retVal;
               }
               catch (Exception ex)
               {
                throw ex;
               }
              }
              public static bool RemovePrivilege(string privilege)
              {
               try
               {
                bool retVal;
                TokPriv1Luid tp;
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_DISABLED;
                retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
                retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
                return retVal;
               }
               catch (Exception ex)
               {
                throw ex;
               }
              }
             }
"@
            Add-Type $AdjustTokenPrivileges
        }

        #Activate necessary admin privileges to make changes without NTFS perms
        [void][TokenAdjuster]::AddPrivilege("SeRestorePrivilege") #Necessary to set Owner Permissions
        [void][TokenAdjuster]::AddPrivilege("SeBackupPrivilege") #Necessary to bypass Traverse Checking
        [void][TokenAdjuster]::AddPrivilege("SeTakeOwnershipPrivilege") #Necessary to override FilePermissions
    }
    Process {
        ForEach ($Item in $Path) {
            Write-Verbose "FullName: $Item"
            #The ACL objects do not like being used more than once, so re-create them on the Process block
            $DirOwner = New-Object System.Security.AccessControl.DirectorySecurity
            $DirOwner.SetOwner([System.Security.Principal.NTAccount]$Account)
            $FileOwner = New-Object System.Security.AccessControl.FileSecurity
            $FileOwner.SetOwner([System.Security.Principal.NTAccount]$Account)
            $DirAdminAcl = New-Object System.Security.AccessControl.DirectorySecurity
            $FileAdminAcl = New-Object System.Security.AccessControl.DirectorySecurity
            $AdminACL = New-Object System.Security.AccessControl.FileSystemAccessRule('Builtin\Administrators','FullControl','ContainerInherit,ObjectInherit','InheritOnly','Allow')
            $FileAdminAcl.AddAccessRule($AdminACL)
            $DirAdminAcl.AddAccessRule($AdminACL)
            Try {
                $Item = Get-Item -LiteralPath $Item -Force -ErrorAction Stop
                If (-NOT $Item.PSIsContainer) {
                    If ($PSCmdlet.ShouldProcess($Item, 'Set File Owner')) {
                        Try {
                            $Item.SetAccessControl($FileOwner)
                        } Catch {
                            Write-Warning "Couldn't take ownership of $($Item.FullName)! Taking FullControl of $($Item.Directory.FullName)"
                            $Item.Directory.SetAccessControl($FileAdminAcl)
                            $Item.SetAccessControl($FileOwner)
                        }
                    }
                } Else {
                    If ($PSCmdlet.ShouldProcess($Item, 'Set Directory Owner')) {                        
                        Try {
                            $Item.SetAccessControl($DirOwner)
                        } Catch {
                            Write-Warning "Couldn't take ownership of $($Item.FullName)! Taking FullControl of $($Item.Parent.FullName)"
                            $Item.Parent.SetAccessControl($DirAdminAcl) 
                            $Item.SetAccessControl($DirOwner)
                        }
                    }
                    If ($Recurse) {
                        [void]$PSBoundParameters.Remove('Path')
                        Get-ChildItem $Item -Force | Set-Owner @PSBoundParameters
                    }
                }
            } Catch {
                Write-Warning "$($Item): $($_.Exception.Message)"
            }
        }
    }
    End {  
        #Remove priviledges that had been granted
        [void][TokenAdjuster]::RemovePrivilege("SeRestorePrivilege") 
        [void][TokenAdjuster]::RemovePrivilege("SeBackupPrivilege") 
        [void][TokenAdjuster]::RemovePrivilege("SeTakeOwnershipPrivilege")     
    }
}
#endregion

#region Function Write-SWIDTag
Function Write-SWIDTag {
<#
.SYNOPSIS
    Writes an SWIDTag xmlfile as specified in ISO/IEC 19770 around Software asset management 
.DESCRIPTION
    Writes an SWIDTag xmlfile as specified in ISO/IEC 19770 around Software asset management
    Which can help much in software asset management and license compliance if the software is not logged in standard locations.
.PARAMETER SWIDTagFilename
    eg: regid.1995-08.com.techsmith Snagit 12.swidtag saved in $env:ProgramData 
    Full path is required if you are not using the default.
    Optional – Without this it will create file based on this format: c:\programdata\[AppVendor]\[AppName]_CR[CR#].swidtag
.PARAMETER EntitlementRequired
    Does the software require a license to be used. 
    Optional - Default is $true 
.PARAMETER ProductTitle
    Title of the software installed. 
    Optional - Default is $appname when used in powershell app deployment toolkit 
.PARAMETER ProductVersion
    Version of the software in x.y.z.w format, where x is major, y is minor, z is build and w is review. 
    Optional - Default is $appversion when used in powershell app deployment toolkit
    If your product version has fewer levels, complete with 0 for any level (minor, build or review) you don't have.
.PARAMETER CreatorName
    Name of the software creator. 
    Optional - Default is $appvendor when used in powershell app deployment toolkit
.PARAMETER CreatorRegid
    Regid of the software creator. Regid's in ISO/IEC 19770 are defined as the word regid. followed by the date you owned a particular DNS domain in YYYY-MM format followed by the domain name in reverse formatting. 
    eg: regid.1991-06.com.microsoft
    Optional – If there was an easy way to use a whois lookup within our network and if the system service account used by SCCM wasn’t restricted from touching anything on a network, then this could have been done, but it’s the biggest pain in the ISO.
.PARAMETER LicensorName
    Name of the software licensor. 
    Optional - Default is $appvendor when used in powershell app deployment toolkit 
.PARAMETER LicensorRegid
    Regid of the software Licensor. Regid's in ISO/IEC 19770 are defined as the word regid. followed by the date you owned a particular DNS domain in YYYY-MM format followed by the domain name in reverse formatting. eg: regid.1991-06.com.microsoft
    Optional - Default is $CreatorRegid value 
.PARAMETER SoftwareUniqueID
    UniqueID assigned to the software in GUID format 8HexCharacters-4HexCharacters-4HexCharacters-4HexCharacters-12HexCharacters whatever unique format you desire.
    eg: BDFD9ADC-3F97-4A8A-A533-987B21776449
    Optional and no longer needs to be in GUID format (too much pain to try and come up with one really and is not part of the ISO)
.PARAMETER TagCreatorRegid
    Regid of the TagCreator. Regid's in ISO/IEC 19770 are defined as the word regid. followed by the date you owned a particular DNS domain in YYYY-MM format followed by the domain name in reverse formatting. 
    eg: regid.1991-06.com.microsoft
    Optional - Default is $CreatorRegid value

 
.EXAMPLE
    Write-SWIDTag -Softwareuniqueid '1234ABCD-3987-3802-9ADE-FE1298CABE30' -CreatorRegid 'regid.2008-03.be.oscc'

    Write a software id tag using the minimum set of parameters to specify, other parameters will use the powershell app deployment toolkit variables for software title, version, vendor to generate the tag.
    This example will not work outside the Powershell app deployment toolkit 

.EXAMPLE
    Write-SWIDTag -ProductTitle "SWIDTagHandler" -ProductVersion "1.2.3.4" -CreatorName "OSCC" -CreatorRegid "regid.2008-03.be.oscc" -SoftwareUniqueid "a6ca313e-c7ae-447c-9ee0-bd872278c166"

    Write a software id tag using the minimum set of parameters when used outside of the powershell app deployment toolkit
    This generates a tag for a product called Swidtaghandler with version 1.2.3.4 by Software vendor OSCC, oscc's regid is regid.2008-30.BE.OSCC 

.NOTES
    You can generate a guid in powershell using this code [guid]::NewGuid(), don't generate a new one for every install. The idea of the guid is that is the same on every machine you write this swidtag to
    If this is to install an msi, the ps app deployment toolkit containts a function to get the productcode from that msi, please use that productcode as your guid, the following command returns the productcode from an msi.
    Get-MsiTableProperty -Path RelativePathToMsiFile | select productcode 
.NOTES
    the regid as definied in ISO19770 is the literal string regid, followed by the date the domain was first registered in YYYY-MM format, followed by the domain reversed
    eg: regid.1991-06.com.microsoft
    You can typically find the registration date using whois
 
.LINK
    http://psappdeploytoolkit.codeplex.com
.LINK
    http://www.scug.be/thewmiguy
.LINK
    http://www.oscc.be
.LINK
    http://www.oscc.be/blog
.LINK
    https://technet.microsoft.com/en-us/library/gg681998.aspx#BKMK_WhatsNewSP1
.LINK
    http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/
#>
[CmdletBinding()]
    Param (
 
        [Parameter(Mandatory=$false,
            HelpMessage='Does the software license require an entitlement also known as software usage right or license?')]
        [boolean]$EntitlementRequired = $true,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Name of the software to add to the swidtag, default is the $appName variable from the PS app deploy toolkit.')]
        [Alias('SoftwareName','ApplicationName','Name')]
        [ValidateNotNullorEmpty()]
        [string] $ProductTitle = $appName,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Version of the software to add to the swidtag, in 4 digit format separated by the . character')]
        [Alias('SoftwareVersion','ApplicationVersion','Version')]
        #[ValidatePattern("^\d+\.\d+\.\d+\.\d+$")]
        [string] $ProductVersion = $appVersion,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Vendor of the software to add to the swidtag, default is the $appvendor variable in the PS app deploy toolkit.')]
        [Alias('SoftwareVendor','Vendor','Manufacturer')]
        [ValidateNotNullorEmpty()]
        [string] $CreatorName = $appVendor,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Regid of the Vendor of the software to add to the swidtag, format is: regid.YYYY-MM.FirstLevelDomain.SecondLeveldomain, eg: regid.1991-06.com.microsoft the date is the date when the domain referenced was first registered')]
        [Alias('Regid','VendorRegid')]
        #[ValidatePattern("^regid\.(19|20)\d\d-(0[1-9]|1[012])\.[A-Za-z]{2,6}\.[A-Za-z0-9-]{1,63}.+$")]
        [string]$CreatorRegid = $appVendor,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='LicensorName of the software to add to the swidtag.')]
        [ValidateNotNullorEmpty()]
        [string] $LicensorName = $CreatorName,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Licensor Regid of the software to add to the swidtag, format is identical to $CreatorRegid')]
        #[ValidatePattern("^regid\.(19|20)\d\d-(0[1-9]|1[012])\.[A-Za-z]{2,6}\.[A-Za-z0-9-]{1,63}.+$")]
        [string]$LicensorRegid = $creatorRegid,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Uinqueid to add to the swid tag, format is: 8 hex chars-4 hex chars-4 hex chars-4 hex chars-12 hex chars. If this is an MSI install use the MSI ProductID, guid can but does not have to be enclosed in {}')]
        [Alias('UniqueId','GUID')]
        #[ValidatePattern("^{?[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}}?$")]
        [string]$SoftwareUniqueid = $appName + '_CR' + $CR,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Tag creator name of the software to add to the swidtag.')]
        [ValidateNotNullorEmpty()]
        [string] $TagCreatorName = $CreatorName,
 
        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='TagCreator Regid of the software to add to the swidtag, format is identical to $CreatorRegid')]
        #[ValidatePattern("^regid\.(19|20)\d\d-(0[1-9]|1[012])\.[A-Za-z]{2,6}\.[A-Za-z0-9-]{1,63}.+$")]
        [string]$TagCreatorRegid = $creatorRegid,

        [Parameter(Mandatory=$False,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Path, including filename of the swidtag to generate.')]
        [Alias('Filename')]
        [string] $SWIDTagFilename = $env:ProgramData + '\' + $CreatorRegid + '\' + $creatorRegid + '_' + $ProductTitle + '_' + $ProductVersion + '_' + $SoftwareUniqueid + '.swidtag',
 
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [boolean]$ContinueOnError = $true
    )
    
    Begin {
        ## Get the name of this function and write header
        [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
    }
    Process {
        Try {
            # this is where the document will be saved:
            $Path = $SWIDTagFilename
            $SWIDTagFolder = split-path $Path
                Write-Log -Message "Testing whether [$SWIDTagFolder] exists, if not path is recursively created." -Source ${CmdletName}
            if(-not(test-path($SWIDTagFolder))){
                Write-Log -Message "Folder [$SWIDTagFolder] does not exist, recursively creating it." -Source ${CmdletName}
                New-Item -path $SWIDTagFolder -type directory
                Write-Log -Message "Folder [$SWIDTagFolder] is successfully created." -Source ${CmdletName}
            }
            else {
                Write-Log -Message "Folder [$SWIDTagFolder] already exists, no need to create it." -Source ${CmdletName}
            }
  
            # get an XMLTextWriter to create the XML and set the encoding to UTF8
            Write-Log -Message "Creating XMLTextWriter object and set encoding to UTF8." -Source ${CmdletName}
            $encoding = [System.Text.Encoding]::UTF8
            $XmlWriter = New-Object System.XMl.XmlTextWriter($Path,$encoding)
 
            # choose a pretty formatting: (set Indentation to 1 Tab)
            Write-Log -Message "Setting indentation of the file to 1 Tab." -Source ${CmdletName}
            $xmlWriter.Formatting = 'Indented'
            $xmlWriter.Indentation = 1
            $XmlWriter.IndentChar = "`t"
            # write the header
            Write-Log -Message "Writing SWIDTag header." -Source ${CmdletName}
            $xmlWriter.WriteStartDocument("true")
            $xmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")
            $XmlWriter.WriteStartElement("swid","software_identification_tag","http://standards.iso.org/iso/19770/-2/2008/schema.xsd")
            $XmlWriter.WriteAttributeString("xsi:schemalocation","http://standards.iso.org/iso/19770/-2/2008/schema.xsd software_identification_tag.xsd")
            $XmlWriter.WriteAttributeString("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
            $XmlWriter.WriteAttributeString("xmlns:ds","http://www.w3.org/2000/09/xmldsig#")
            # write the mandatory elements, and the sccm supported elements of an iso 19770 swidtag
            Write-Log -Message "Writing EntitlementRequired field, settng it to [$EntitleMentRequired]." -Source ${CmdletName}
            if ($EntitlementRequired) {
                $XmlWriter.WriteElementString("swid:entitlement_required_indicator","true")
            }
            else {
                $XmlWriter.WriteElementString("swid:entitlement_required_indicator","false")
            }
            Write-Log -Message "Writing other SWIDTag elements." -Source ${CmdletName}
            $XmlWriter.WriteElementString("swid:product_title",$ProductTitle)
            $XmlWriter.WriteStartElement("swid:product_version")
            $XmlWriter.WriteElementString("swid:name",$ProductVersion)
            $XmlWriter.WriteStartElement("swid:numeric")
            $splitProductVersion = $ProductVersion.Split('.')
            $XmlWriter.WriteElementString("swid:major",$splitProductversion[0])
            $XmlWriter.WriteElementString("swid:minor",$splitProductversion[1])
            $XmlWriter.WriteElementString("swid:build",$splitProductversion[2])
            $XmlWriter.WriteElementString("swid:review",$splitProductversion[3])
            $XmlWriter.WriteEndElement();
            $XmlWriter.WriteEndElement();
            $XmlWriter.WriteStartElement("swid:software_creator")
            $XmlWriter.WriteElementString("swid:name",$CreatorName)
            $XmlWriter.WriteElementString("swid:regid",$creatorRegid)
            $XmlWriter.WriteEndElement();
            $XmlWriter.WriteStartElement("swid:software_licensor")
            $XmlWriter.WriteElementString("swid:name",$LicensorName)
            $XmlWriter.WriteElementString("swid:regid",$LicensorRegid)
            $XmlWriter.WriteEndElement();
            $XmlWriter.WriteStartElement("swid:software_id")
            Write-Log -Message "Writing SoftwareuniqueId [$SoftwareUniqueid] to swid tag." -Source ${CmdletName}
            $XmlWriter.WriteElementString("swid:unique_id",$SoftwareUniqueid)
            $XmlWriter.WriteElementString("swid:tag_creator_regid",$TagCreatorRegid)
            $XmlWriter.WriteEndElement();
            $XmlWriter.WriteStartElement("swid:tag_creator")
            $XmlWriter.WriteElementString("swid:name",$TagCreatorName)
            $XmlWriter.WriteElementString("swid:regid",$TagCreatorRegid)
            $XmlWriter.WriteEndElement();
            $xmlWriter.Flush()
            $xmlWriter.Close()
        }
        Catch {
            Write-Log -Message "Failed to write swidtag to destination [$SWIDTagFilename]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
            If (-not $ContinueOnError) {
                Throw "Failed to write swidtag to destination [$SWIDTagFilename]: $($_.Exception.Message)"
            }
        }
    }
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}
#endregion


##*===============================================
##* END FUNCTION LISTINGS
##*===============================================

##*===============================================
##* SCRIPT BODY
##*===============================================

If ($scriptParentPath) {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] dot-source invoked by [$(((Get-Variable -Name MyInvocation).Value).ScriptName)]" -Source $appDeployToolkitExtName
}
Else {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] invoked directly" -Source $appDeployToolkitExtName
}

##*===============================================
##* END SCRIPT BODY
##*===============================================
#******************************************************************** 
#-- HUMANA CONFIDENTIAL.  For authorized use only.  
#-- Except for as expressly authorized by HUMANA, 
#-- do not disclose, copy, reproduce, distribute, or modify.                                             
#********************************************************************* 
#PURPOSE:		
#AUTHOR:		Brian Brewer
#DATE:				01/04/2016
#NOTES:		
#CHANGE CONTROL:	
#********************************************************************
[CmdletBinding()]
Param(
    [Parameter(Mandatory,Position=1)]
    [string]$Mailbox,
    [int]$Quota = 1024,
    [string]$Path,
    [string]$ModulePath = "C:\Program Files (x86)\Microsoft\Exchange\Web Services\2.1\Microsoft.Exchange.WebServices.dll"
)
Import-Module -Name $ModulePath
$TimeStamp = get-date -f "yyyyMMdd_HHmm"
if (-not $Path)
{
    $Path = "C:\temp\$mailbox$TimeStamp.csv"
}

"

-----------------------------------
Powershell EWS Example
-----------------------------------
Adapted from http://gsexdev.blogspot.com/2014/08/getting-folder-sizes-and-other-stats.html
-----------------------------------"

Write-Output "Stats for mailbox: "  $mailbox 
Write-Output "File path: "  $Path
Write-Output "Quota in MB: "  $Quota  
"---------------------------------
"

## EWS Managed API Connect Script 
##Add-Type -Path "https://webmail.humana.com/ews/Services.wsdl"  

## Set Exchange Version  
## 14.2.235.4001
$ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010_SP2

## Create Exchange Service Object  
$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)  

##Use Default Credentials
$service.UseDefaultCredentials = $true

## Choose to ignore any SSL Warning issues caused by Self Signed Certificates  
  
## Code From http://poshcode.org/624
## Create a compilation environment
$Provider=New-Object Microsoft.CSharp.CSharpCodeProvider
$Compiler=$Provider.CreateCompiler()
$Params=New-Object System.CodeDom.Compiler.CompilerParameters
$Params.GenerateExecutable=$False
$Params.GenerateInMemory=$True
$Params.IncludeDebugInformation=$False
$Params.ReferencedAssemblies.Add("System.DLL") | Out-Null

$TASource=@'
  namespace Local.ToolkitExtensions.Net.CertificatePolicy{
    public class TrustAll : System.Net.ICertificatePolicy {
      public TrustAll() { 
      }
      public bool CheckValidationResult(System.Net.ServicePoint sp,
        System.Security.Cryptography.X509Certificates.X509Certificate cert, 
        System.Net.WebRequest req, int problem) {
        return true;
      }
    }
  }
'@ 
$TAResults=$Provider.CompileAssemblyFromSource($Params,$TASource)
$TAAssembly=$TAResults.CompiledAssembly

## We now create an instance of the TrustAll and attach it to the ServicePointManager
$TrustAll=$TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
[System.Net.ServicePointManager]::CertificatePolicy=$TrustAll

## end code from http://poshcode.org/624

#CAS URL  
$uri=[system.URI] "https://webmail.humana.com/EWS/Exchange.asmx"  
$service.Url = $uri    

function ConvertToString($ipInputString){  
    $Val1Text = ""  
    for ($clInt=0;$clInt -lt $ipInputString.length;$clInt++){  
            $Val1Text = $Val1Text + [Convert]::ToString([Convert]::ToChar([Convert]::ToInt32($ipInputString.Substring($clInt,2),16)))  
            $clInt++  
    }  
    return $Val1Text  
} 

##$service | Get-Member

##---------------------------------------------

$folderid = new-object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::MsgFolderRoot,$mailbox)   


function ConvertToString($ipInputString){  
    $Val1Text = ""  
    for ($clInt=0;$clInt -lt $ipInputString.length;$clInt++){  
            $Val1Text = $Val1Text + [Convert]::ToString([Convert]::ToChar([Convert]::ToInt32($ipInputString.Substring($clInt,2),16)))  
            $clInt++  
    }  
    return $Val1Text  
} 

$TotalFolderSize = 0

$FolderClassrpt = @{}
function GetFolderSizes{
	param (
	        $rootFolderId = $folderid
		  )
	process{
	#Define Extended properties  
	$PR_FOLDER_TYPE = new-object Microsoft.Exchange.WebServices.Data.ExtendedPropertyDefinition(13825,[Microsoft.Exchange.WebServices.Data.MapiPropertyType]::Integer);  
	$PR_MESSAGE_SIZE_EXTENDED = new-object Microsoft.Exchange.WebServices.Data.ExtendedPropertyDefinition(3592, [Microsoft.Exchange.WebServices.Data.MapiPropertyType]::Long);
	$folderidcnt = $rootFolderId
	#Define the FolderView used for Export should not be any larger then 1000 folders due to throttling  
	$fvFolderView =  New-Object Microsoft.Exchange.WebServices.Data.FolderView(1000)  
	#Deep Transval will ensure all folders in the search path are returned  
	$fvFolderView.Traversal = [Microsoft.Exchange.WebServices.Data.FolderTraversal]::Deep;  
	$psPropertySet = new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)  
	$PR_Folder_Path = new-object Microsoft.Exchange.WebServices.Data.ExtendedPropertyDefinition(26293, [Microsoft.Exchange.WebServices.Data.MapiPropertyType]::String);  
	$PR_ATTACH_ON_NORMAL_MSG_COUNT = new-object Microsoft.Exchange.WebServices.Data.ExtendedPropertyDefinition(0x66B1, [Microsoft.Exchange.WebServices.Data.MapiPropertyType]::Long);
	#Add Properties to the  Property Set  
	$psPropertySet.Add($PR_Folder_Path);  
	$psPropertySet.Add($PR_MESSAGE_SIZE_EXTENDED)
	$psPropertySet.Add($PR_ATTACH_ON_NORMAL_MSG_COUNT)
	$fvFolderView.PropertySet = $psPropertySet;  
	#The Search filter will exclude any Search Folders  
	$sfSearchFilter = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo($PR_FOLDER_TYPE,"1")  
	$fiResult = $null  
	#The Do loop will handle any paging that is required if there are more the 1000 folders in a mailbox  
	do {  
	    $fiResult = $Service.FindFolders($folderidcnt,$sfSearchFilter,$fvFolderView)  
	    foreach($ffFolder in $fiResult.Folders){
	        $foldpathval = $null  
	        #Try to get the FolderPath Value and then covert it to a usable String   
	        if ($ffFolder.TryGetProperty($PR_Folder_Path,[ref] $foldpathval))  
	        {  
	            $binarry = [Text.Encoding]::UTF8.GetBytes($foldpathval)  
	            $hexArr = $binarry | ForEach-Object { $_.ToString("X2") }  
	            $hexString = $hexArr -join ''  
	            $hexString = $hexString.Replace("FEFF", "5C00")  
	            $fpath = ConvertToString($hexString)  
	        } 
			$folderSize = $null
			[Void]$ffFolder.TryGetProperty($PR_MESSAGE_SIZE_EXTENDED,[ref] $folderSize)
			
			[Int64]$attachcnt = 0
			[Void]$ffFolder.TryGetProperty($PR_ATTACH_ON_NORMAL_MSG_COUNT,[ref] $attachcnt)
			if($attachcnt -eq $null){
				$attachcnt = 0
			}
            #I like objects
            $CsvData=[ordered]@{}
            $CsvData.Path = $fpath
            $CsvData."Size(MB)" = [math]::round($folderSize / 1MB,2)
            $CsvData.Percent = [math]::round((([math]::round($folderSize / 1MB,2))/$quota)*100,2)
            	        
            $CSVDataObject = New-Object -TypeName psobject -Property $CSVData
            $CSVDataObject | Export-Csv $Path -NoTypeInformation -NoClobber -Append

            #Export-Csv -InputObject $CsvOutput -NoTypeInformation -Path $Path
            #$fpath + "`t" + [math]::round($folderSize / 1MB,2)   + " MB " + "`t" + [math]::round((([math]::round($folderSize / 1MB,2))/$quota)*100,2) + "% of Quota"
			$fldClass = $ffFolder.FolderClass
			if($fldClass -eq $null){$fldClass = "IPF.Note"}
			if($FolderClassrpt.ContainsKey($fldClass)){
				$FolderClassrpt[$fldClass].NumberOfFolders += 1
				$FolderClassrpt[$fldClass].AttachOnMsgCount += $attachcnt
				$FolderClassrpt[$fldClass].ItemSize += [Int64]$folderSize
				$FolderClassrpt[$fldClass].ItemCount += [Int64]$ffFolder.TotalCount
			}
			else{
				$rptObj = "" | select FolderClass,NumberOfFolders,AttachOnMsgCount,ItemSize,ItemCount
				$rptObj.FolderClass = $fldClass
				$FolderClassrpt[$fldClass].NumberOfFolders
				$rptObj.ItemSize = [Int64]$folderSize
				$rptObj.ItemCount = [Int64]$ffFolder.TotalCount
				$rptObj.AttachOnMsgCount += $attachcnt
				$rptObj.NumberOfFolders = 1
				$FolderClassrpt.Add($fldClass,$rptObj)
			}	
			
		$TotalFolderSize += if ($folderSize -eq $null) { 0 } else { $folderSize }
		
	    } 
	    $fvFolderView.Offset += $fiResult.Folders.Count
		Import-Csv $Path
		"---------------------------------"
		"Total size of mailbox: "  + [math]::round($TotalFolderSize  / 1MB,2)  + " MB"
		"---------------------------------
		"
		
		} while($fiResult.MoreAvailable -eq $true)  		
	}
}







#"Path`tSize(MB)`tPercent Of Quota"
GetFolderSizes -rootFolderId (new-object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::MsgFolderRoot,$MailboxName))   
#Add-Content -Path $Path -Value "Path`tSize(MB)`tPercent Of Quota"
#$Results | Add-Content $Path


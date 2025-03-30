# Generate file report for entire site collection - Enter URL of site collection to generate report.
# For this script to work, you must run it under an account with site collection administrator access.
# By: Andrew Toh

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
 
# Get site collection URL from user
$webURL= Read-host "Enter Site Collection URL:"
 
#Name of log file is<script type="text/javascript">// <![CDATA[\<site name>.csv
$logfile = "$($dir)\$($weburl.split("([^/]+$)'")[-1]).csv"
$logfile
 
# Exclude the following libaries / lists
$excludeLists = @("Master Page Gallery",
                "Images",
                "Pages",
                "Links",
                "User Information List",
                "TaxonomyHiddenList",
                "Theme Gallery",
                "Style Library",
                "Solution Gallery",
                "Site Pages",
                "Site Collection Images",
                "Reusable Content",
                "Reporting Templates",
                "Reporting Metadata",
                "Long Running Operation Status",
                "List Template Gallery",
                "Content and Structure Reports",
                "Cache Profiles",
                "wfpub",
                "Workflows",
                "Workflow History",
                "Web Part Gallery",
                "Form Templates",
                "Workflow Tasks",
                "Tasks",
                "Announcements",
                "Relationships List",
                "Suggested Content Browser Locations",
                "Team Discussions",
                "Site Template Gallery",
                "fpdatasources",
                "Variation Labels",
                "Content type publishing error log",
                "Converted Forms",
                "Site Assets",
                "Publishing Images",
                "Team Discussions",
                "Discussion",
                "Team Calendar"
                )
 
# Variables used by GetListItems function
 
[string]$viewName = ""
[string]$rowLimit = "0"
[String]$viewFieldsValue=""
#[String]$viewFieldsValue="<FieldRef Name='Title' />"
[String]$queryValue="<Where><Neq><FieldRef Name='ID'/><Value Type='Number'>0</Value></Neq></Where>"
[String]$queryOptionsValue="<ViewAttributes Scope='RecursiveAll'/>"
 
$output = @()
#----------------------------------------------------- functions -----------------------------------------------------------
 
function GetAllSubWebCollection()
{
     $uriWeb=$webURL+"/_vti_bin/Webs.asmx?wsdl" 
     $service = New-WebServiceProxy -Uri $uriWeb -UseDefaultCredential
     [System.Xml.XmlNode]$webCollXmlNode=$service.GetAllSubWebCollection()
     $subsites = $webCollXmlNode.Web
     return $subsites        
}
 
function GetListCollection($site)
{
     $uriWeb=$site+"/_vti_bin/lists.asmx?wsdl" 
     $service = New-WebServiceProxy -Uri $uriWeb -UseDefaultCredential 
     [System.Xml.XmlNode]$webCollXmlNode=$service.GetListCollection()
     $listcol = $webCollXmlNode.List
     return $listcol        
}
 
Function GetListItems
{
      param([string]$site, [string]$listname)
      $uri=$site+"/_vti_bin/Lists.asmx?wsdl"
      $listsWebServiceReference = New-WebServiceProxy -Uri $uri -UseDefaultCredential 
      [System.Xml.XmlDocument]$xmlDoc=New-Object -TypeName System.Xml.XmlDocument
      [System.Xml.XmlElement]$query = $xmlDoc.CreateElement("Query")
      [System.Xml.XmlElement]$viewFields =$xmlDoc.CreateElement("ViewFields")
      [System.Xml.XmlElement]$queryOptions =$xmlDoc.CreateElement("QueryOptions")
      $viewFields.InnerXml = $viewFieldsValue
      $query.InnerXml = $queryValue
      $queryOptions.InnerXml = $queryOptionsValue
      [System.Xml.XmlNode]$nodeListItems =$listsWebServiceReference.GetListItems($listName, $viewName, $query, $viewFields, $rowLimit, $queryOptions, $null)
      $result = $nodeListItems.data.row
      return $result
}
 
#--------------------------------------- Work with the data ------------------------------------------
 
ac $logfile "Generating File Report for $($webURL) - $(Get-Date)"
 
#Get list of subsites
$allsubsites = GetAllSubWebCollection
 
$i = 1
$countfiles = 0
 
# Loop through each subsite and perform the following
foreach($site in $allsubsites)
{
    # Update progress bar
    Write-Progress -Activity "Generating report for sites.." -status "Processing $i sites of $($allsubsites.count)" -percentComplete ($i / $allsubsites.count*100)
 
    # Loop through each subsite and get collection of document libraries
    $alllistcol = GetListCollection($site.Url)
 
    # Perform the following for each document library
    foreach($list in $alllistcol)
    {
        if (($excludeLists -notcontains $list.Title) -and ($list.Basetype -eq "1"))
        {
            $files = GetListItems -site $site.Url -listname $list.Title
 
            # Loop through each file in the document library and perform the following
            foreach($file in $files)
            {
                Write-host "$($site.Title),$($list.Title),$($file.ows_LinkFileName)"
 
                # Use the following to add additional metadata columns
 
                $record = new-object System.Object
                $record | Add-Member -type NoteProperty -name Site -value $site.Title
                $record | Add-Member -type NoteProperty -name List -value $list.Title
                #$record | Add-Member -type NoteProperty -name FileTitle -value $file.ows_Title
                $record | Add-Member -type NoteProperty -name Filename -value $file.ows_LinkFileName
                $record | Add-Member -type NoteProperty -name Created -value $file.ows_Created
                $record | Add-Member -type NoteProperty -name CreatedBy -value $file.ows_Author
                $record | Add-Member -type NoteProperty -name Modified -value $file.ows_Modified
                $record | Add-Member -type NoteProperty -name ModifiedBy -value $file.ows_Editor
                $record | Add-Member -type NoteProperty -name ContentType -value $file.ows_ContentType
                if ($file.ows_File_x0020_Size)
                {
                    $record | Add-Member -type NoteProperty -name Filesize -value $file.ows_File_x0020_Size.split("([^#]+$)'")[-1]
                }
                $output += $record
                $countfiles++
 
                #$output += "$($site.Title),$($list.Title),$($file.ows_Title),$($file.ows_LinkFileName),$($file.ows_Created)"
            }
        }
    } 
    # Increment progress counter
    $i++
}
 
#-------------------------- Output to file ------------------------------
 
$output | export-csv $logfile -notype -force -Verbose
write-host "Done - $(Get-Date) - found $($countfiles) files"

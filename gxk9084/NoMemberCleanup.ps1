#####################################################################################
######################GOOD WORKING CODE##############################################
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
$MT1Site = "MT1"
$MT1Server = "LOUAPPWTS1140.rsc.humad.com"
New-PSDrive -Name $MT1Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $MT1Server
Set-Location MT1:
$WMIQueryParameters = @{Namespace = 'root\sms\site_$MT1Site'; Computername = '$MT1Server'}
#$CollectionList = Get-WMIobject -Class SMS_Collection -Namespace root\sms\site_mt1 -ComputerName LOUAPPWTS1140 | Where-Object {$_.ObjectPath -match '/Prod'} | Select-Object -Property Name,MemberCount,CollectionID,IsReferenceCollection
$CollectionList = Get-WMIobject -Class SMS_Collection -Namespace root\sms\site_$MT1Site -ComputerName $MT1Server | Where-Object {$_.CollectionType -eq '2' -and $_.ObjectPath -match '/Prod'} | Select-Object -Property Name,MemberCount,CollectionID,IsReferenceCollection
ForEach ($collection in $CollectionList)
    {
    #$CollectionlWrite-Host $collection.CollectionID
    ###$result=(Get-WMIObject -Namespace root\sms\site_MT1 -ComputerName LOUAPPWTS1140 -Query "select * from SMS_Collection where CollectionID = '$($collection.CollectionID)'" -Namespace root\sms\site_mt1 -ComputerName LOUAPPWTS1140)
    ###$path=$result.ObjectPath.Substring(0,5)
    ###if ($path -eq "/Prod")
       ### {
        ###Write-Host $result.name "`t" $result.ObjectPath 
        Write-Host $collection.name "`t" $collection.CollectionID "`t" $collection.MemberCount
        #WriteLog WHich One are we deleting?
        #DELETE $collection.collectionID
        ###}
    }
    #Get-WmiObject -Class SMS_Collection -Namespace root\sms\site_mt1 -ComputerName LOUAPPWTS1140 | Where-Object {$_.ObjectPath -match '^/Prod'}
######################GOOD WORKING CODE##############################################
#####################################################################################

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\CMNSCCMTools\CMNSccmTools.psd1


#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
#Set-location $SiteCode":"
Set-location $SiteCode":"DeviceCollection\Prod
Clear-Host




$CollectionList = Get-CmCollection | Where-Object {$_.CollectionID -notlike 'SMS*' -and $_.CollectionType -eq '2' -and $_.MemberCount -eq 0} | Select-Object -Property Name,MemberCount,CollectionID,IsReferenceCollection

#Write log
Write-Host ("Found " + $CollectionList.Count + " collections without members (MemberCount = 0) `n")
#Write log
Write-Host ("Analyzing list to find collection without deployments... `n")

foreach ($Collection in $CollectionList)
{
    $NumCollectionMembers = $Collection.MemberCount
    $CollectionID = $Collection.CollectionID
            
    # Delete collection if no members
    If ($GetDeployment -eq $null) 
    {
        # User Prompt ..Make this write to a log instead
        Write-Host ("Collection " + $Collection.Name +" (" + $Collection.CollectionID + ")" + " has no members and deployments")

        # User Confirmation
        If ((Read-Host -Prompt "Type `"Y`" to delete the collection, any other key to skip") -ieq "Y")
        {
            #Check if Reference collection           
            Try
            {
                #Delete the collection object    
                Remove-CMCollection -Id $CollectionID -Force
                Write-Host -ForegroundColor Green ("Collection: " + $Collection.Name + " Deleted")
            }
            Catch{Write-Host -ForegroundColor Red ("Can't delete " + $Collection.Name + " collection. Possible cause : There's referenced collection or a custom security scope assigned to the collection.")}    
        }
    }
}
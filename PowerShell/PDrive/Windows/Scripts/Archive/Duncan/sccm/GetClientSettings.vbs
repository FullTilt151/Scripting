wscript.echo "Client:"
Set smsclient = CreateObject("Microsoft.SMS.Client")
wscript.echo "Assigned to: " & smsclient.GetAssignedSite
wscript.echo "MP: " & smsclient.GetCurrentManagementPoint
wscript.echo ""
set UI = CreateObject("UIResource.UIResourceMgr")
set ads=UI.GetAvailableApplications
wscript.echo ads.count & " available advertisements:"
for i=1 to ads.count
    wscript.echo ads.item(i).packagename
next
wscript.echo ""
wscript.echo "Client actions:"
set mgr = CreateObject("CPApplet.CPAppletMgr")
set actions=mgr.GetClientActions
for each action in actions
    wscript.echo action.name
    if action.name="Hardware Inventory Collection Cycle" then
        action.PerformAction
        wscript.echo "  hardware inventory initiated"    
        end if
next
wscript.echo ""
wscript.echo "Client components:"
set components=mgr.GetClientComponents
for each component in components
    if component.state=0 then state="installed"    
    if component.state=1 then state="enabled"    
    wscript.echo component.displayname, state
next
wscript.echo ""
wscript.echo "Client properties:"
set properties=mgr.GetClientProperties
for each property in properties
    wscript.echo property.name & ": " & property.value
next
wscript.echo ""
set ws=CreateObject("WScript.Shell")
timeoffset=ws.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\ActiveTimeBias")
set cacheinfo=ui.GetCacheInfo
wscript.echo "Cache Info:"
WScript.echo "Location:          ", cacheinfo.location
WScript.echo "Total Size:        ", cacheinfo.TotalSize
WScript.echo "Free Size:         ", cacheinfo.FreeSize
if cacheinfo.TotalSize=250 then
    cacheinfo.TotalSize=1000 'MB
else
    cacheinfo.TotalSize=250 'MB
end if
wscript.echo "  cache size toggled"
set elements=cacheinfo.GetCacheElements
for each element in elements
    lastreferencetimeadjusted = dateadd( "n", -1 * timeoffset, element.lastreferencetime  )
    wscript.echo element.cacheelementid, element.contentid, element.contentsize, element.contentversion, lastreferencetimeadjusted, element.referencecount
    wscript.echo "   ",  element.location
next

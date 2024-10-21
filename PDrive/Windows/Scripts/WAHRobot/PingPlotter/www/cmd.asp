<% Option Explicit
%>
 <!--#include file="HelperFunctions.asp"-->
<%

if (UserName > "") and (PingPlotter.HasWebAccess(UserName, UserPassword) = 0) then
	' Didn't get logged in right.
	Session("Login Error") = "Username / password combination not correct or doesn't have access"
	Response.Redirect "Login.asp"
end if

UserName = Session("UserName")
UserPassword = Session("UserPassword")

dim EDITING_ALLOWED, SINGLE_TARGET

EDITING_ALLOWED = TRUE   ' False = No editing allowed, True = Able to add new targets, trace interval change, stop/start, etc.
SINGLE_TARGET = False		' False = show all targets, True = show the passed in target only (usually by IP)

Response.Buffer = True

' PingPlotter object is defined by HelperFunctions
dim ScriptName, NewDestination

NewDestination = false
ScriptName = ""

dim UID, objHops, Column
UID = Variable("ID")

dim TraceTarget
dim IsSummary
dim Graph
dim ErrorMessage

ErrorMessage = ""
' OK, what command is passed?
dim Action
Action = Variable("cmd")
Graph = null
if (lcase(Action) = "newsummary") then
	dim NewSummary
	set NewSummary = PingPlotter.CreateNewSummary(Variable("name"))
	
	UID = NewSummary.UniqueID
end if

if (Left(ucase(UID),4) = "SUM-") then
	set TraceTarget = GetSummaryByID(PingPlotter, UID)
	set Graph = TraceTarget
	IsSummary = TRUE	
else 
	if (ucase(UID) = "NEWTARGET") then
	  TraceTarget = NULL
	  set TraceTarget = GetNewTarget(PingPlotter, Variable("target"))
		on Error resume next ' Enable error handling...
	  TraceTarget.Resolve
		If Err.Number <> 0 then 
			ErrorMessage = Err.Description
			Err.Clear
   		On Error goto 0 ' disable error handling...
   		TraceTarget.Close
   		TraceTarget = NULL
		else 
   		On Error goto 0 ' disable error handling...
   	  NewDestination = true
			IsSummary = FALSE
  		set Graph = TraceTarget.Graph
   	end if
  else
    set TraceTarget = GetTargetByID(PingPlotter, UID)
    set Graph = TraceTarget.Graph
  end if
  IsSummary = FALSE
end if


function AddXMLValue(objDom, objXMLSection, Name, Value)

  dim objElement 
  
  set objElement = objDom.createElement(escape(Name))
	objElement.text = Value
	objXMLSection.appendChild objElement
end function

Dim objXML, objTarget, I, oRoot, ColValue, CurGraph

'create an instance of the DOM
Set objXML = CreateObject("Msxml2.DOMDocument.3.0")  ' Use the 3.0 XML version
set oRoot = objXML.createElement("PingPlotter")

objXML.AppendChild(oRoot)

if (Variable("setcolwidth") > "") then
	
	dim ColWidth
  	
  for I = 0 to Graph.ColumnCount-1
    set CurCol = Graph.Columns(I)
    
		ColWidth = Variable("colwidth" & I)
		
		if IsNumeric(ColWidth) then
			CurCol.Width = ColWidth
		end if
	next

end if

if (Variable("setcolvisible") > "") then
	
	dim ColVisible

  for I = 0 to Graph.ColumnCount-1
    set CurCol = Graph.Columns(I)
    
		ColVisible = Variable("colvisible" & I)
		
		if IsNumeric(ColVisible) then
			if (ColVisible) <> 0 then
			  CurCol.Visible = true
			else
				CurCol.Visible = false
			end if
		end if
	next

end if

if ((Variable("setsortcol") > "") and (IsSummary))then
	Graph.SortColumn = Variable("setsortcol")
end if

if (ErrorMessage = "") and (IsObject(TraceTarget)) then

	' Were any settings changes specified?  Let's apply them!
	if IsNumeric(Variable("TimeGraphTime")) then
		Graph.TimeGraphTime = StrToLng(Variable("TimeGraphTime"))
	end if
	
	' Many settings don't apply to the summary graph.
	if (not IsSummary) then

		if (EDITING_ALLOWED) then
			' If an action is specified, do something.
			if Variable("formaction") = "Close" then
			  TraceTarget.Close
			  if (PingPlotter.SummaryGraphCount > 0) then
			    set TraceTarget = PingPlotter.SummaryGraphs(0)
			    set Graph = TraceTarget
			    IsSummary = true
			  elseif (PingPlotter.TargetCount > 0) then
			    set TraceTarget = PingPlotter.Targets(0)
			    set Graph = TraceTarget.Graph
			  else
			    TraceTarget = GetNewTarget
			  end if
			elseif Variable("formaction") = "Resume Trace" then
			  TraceTarget.Start
			elseif Variable("formaction") = "Stop Trace" then
			  TraceTarget.Stop
			elseif Variable("formaction") = "Reset Trace" then
			    dim TargetAddress
			    TargetAddress = TraceTarget.SpecifiedTargetName
			    TraceTarget.Reset
			    if Variable("target") > "" then
			      TargetAddress = Variable("target")
			    end if
			    if TargetAddress > "" then
			      TraceTarget.TargetDescription = TargetAddress
			      TraceTarget.Start
			      NewDestination = true
			    end if
			end if
		end if		
		

		if (not IsSummary) then
			if IsNumeric(Variable("TraceCount")) then
				TraceTarget.MaxSampleCount = StrToLng(Variable("TraceCount"))
			end if

			if IsNumeric(Variable("Interval")) then
				TraceTarget.TraceInterval = StrToLng(Variable("Interval"))
			end if

			if IsNumeric(Variable("SamplesToInclude")) then
				TraceTarget.Graph.SamplesToInclude = StrToLng(Variable("SamplesToInclude"))
			end if

			if ((Variable("SettingsName") > "") and (Variable("SettingsName") <> TraceTarget.SettingsName)) then
		    TraceTarget.SettingsName = Variable("SettingsName")
			end if
		end if
	else
		if (Action = "renamesummary") then
    	Graph.SummaryName = Variable("name")
  	end if
		if (Action = "closesummary") then
		  Graph.Close
		  set Graph = PingPlotter.SummaryGraphs(0)
  	end if
  	if (Action = "removehost") then
  	  Graph.RemoveHostByID Variable("host")
  	end if
  	if (Action = "addhost") then
  	  Graph.AddHostByID Variable("host")
  	end if
		if (Variable("SummaryFocusPeriod") > "") then
	  		Graph.FocusPeriod = StrToLng(Variable("SummaryFocusPeriod"))
		end if
	end if
	
	if (NewDestination) and (ErrorMessage = "") then
		TraceTarget.Start
	end if
end if

if (ErrorMessage = "") and (Variable("targetstats") > "") then
	 'these are our variables
	'create the top level node for this target
	Set objTarget = objXML.createElement("targetdetails")
	
	
	' Set up the data for the current target in summary
	if (not IsSummary) then
		AddXMLValue objXML, objTarget, "UniqueID", TraceTarget.UniqueID
		AddXMLValue objXML, objTarget, "SpecifiedTargetName", TraceTarget.SpecifiedTargetName
		AddXMLValue objXML, objTarget, "TargetDescription", TraceTarget.TargetDescription
		AddXMLValue objXML, objTarget, "TargetIPAddress", TraceTarget.TargetIPAddress
		AddXMLValue objXML, objTarget, "TargetDNSName", TraceTarget.TargetDNSName
		AddXMLValue objXML, objTarget, "IsRunning", TraceTarget.IsRunning
		AddXMLValue objXML, objTarget, "TraceInterval", TraceTarget.TraceInterval
		AddXMLValue objXML, objTarget, "SettingsName", TraceTarget.SettingsName
		AddXMLValue objXML, objTarget, "SampleCount", TraceTarget.SampleCount
		AddXMLValue objXML, objTarget, "StartFocusSample", Graph.StartSample
		AddXMLValue objXML, objTarget, "EndFocusSample", Graph.EndSample
		AddXMLValue objXML, objTarget, "TraceCount", TraceTarget.MaxSampleCount
		AddXMLValue objXML, objTarget, "SamplesToInclude", Graph.SamplesToInclude 
		AddXMLValue objXML, objTarget, "IsRunning", TraceTarget.IsRunning
  else
		AddXMLValue objXML, objTarget, "SummaryName", Graph.SummaryName
		AddXMLValue objXML, objTarget, "CanClose", Graph.CanClose
	end if
	
	AddXMLValue objXML, objTarget, "WarningSpeed", Graph.DisplaySettings.WarningSpeed
	AddXMLValue objXML, objTarget, "BadSpeed", Graph.DisplaySettings.BadSpeed
	AddXMLValue objXML, objTarget, "GraphScale", Graph.DisplaySettings.GraphScale
	AddXMLValue objXML, objTarget, "TimeGraphTime", Graph.TimeGraphTime
	
	if (IsSummary) then
		' Only send over times if we have some samples.
		AddXMLValue objXML, objTarget, "UniqueID", Graph.UniqueID
		if (Graph.HostCount > 0) then
 			AddXMLValue objXML, objTarget, "StartFocusTime", Graph.FocusStartTime
 			AddXMLValue objXML, objTarget, "EndFocusTime", Graph.FocusEndTime
 		end if
 		AddXMLValue objXML, objTarget, "SortColumn", Graph.SortColumn
 		AddXMLValue objXML, objTarget, "FocusPeriod", Graph.FocusPeriod
 		AddXMLValue objXML, objTarget, "HostCount", Graph.HostCount
	else
		if (TraceTarget.SampleCount > 0) and (Graph.StartSample < TraceTarget.SampleCount) and (Graph.EndSample < TraceTarget.SampleCount) then
	  		AddXMLValue objXML, objTarget, "StartFocusTime", TraceTarget.Times(Graph.StartSample)
  			AddXMLValue objXML, objTarget, "EndFocusTime", TraceTarget.Times(Graph.EndSample)
  		end if
  	end if
	
	if (not IsSummary) then
  	dim CurHost, CurRoute, objHop
  	set CurRoute = TraceTarget.CollectingHostList
		AddXMLValue objXML, objTarget, "ReachedDestination", CurRoute.ReachedDestination
		if not (CurRoute.FinalDestination is Nothing) then
			AddXMLValue objXML, objTarget, "FinalDestinationID", CurRoute.FinalDestination.UniqueID
		end if
	else
		set CurRoute = Graph
	end if
	Set objHops = objXML.createElement("hosts")
	

	dim ColLoop, colObj

  ' Build our list of columns that we want to have back.	
	dim RequiredColumns, ColArray, DataArray
	set RequiredColumns = CreateObject( "Scripting.Dictionary" )
	RequiredColumns.CompareMode = 1 ' Text Compare Mode (case insensitive)
	RequiredColumns.Add "UniqueID", ""
	RequiredColumns.Add "DNSName", ""
	RequiredColumns.Add "IP", ""
	RequiredColumns.Add "SampleCount", ""
	RequiredColumns.Add "GoodCount", ""
	RequiredColumns.Add "PL", ""
	RequiredColumns.Add "Min", ""
	RequiredColumns.Add "Max", ""
	RequiredColumns.Add "Avg", ""
	RequiredColumns.Add "Cur", ""
	RequiredColumns.Add "Err", ""
	
	' Figure out which additional columns we need to pull
	for ColLoop = 0 to Graph.ColumnCount-1
		set Column = Graph.Columns(ColLoop)
				' We're adding all columns, not just Column.Visible columns, because the remote end of things might be looking at different
				' data than we are locally.
		if (Column.Name <> "Hop") then
			if not RequiredColumns.Exists(Column.Name) then
				RequiredColumns.Add Column.Name, ""
			end if
		end if
	next
	
	ColArray = RequiredColumns.Keys
	
	dim ColumnData
	ColumnData = CurRoute.HostColumnsAsArray(Join(ColArray, ","))
	
	dim SettingsNamesArray
	if ((IsSummary) and (SettingsFilter > "")) then
	  SettingsNamesArray = CurRoute.HostColumnsAsArray("Settings")
	end if

	dim StringValue
	dim AddRow
	dim lSettingsName
	lSettingsName = ""
	
  for I = 0 to UBound(ColumnData)

    DataArray = ColumnData(I)
    
    if (SettingsFilter > "") and (IsSummary) then
	    lSettingsName = SettingsNamesArray(I)(0) 
	  else
	  	lSettingsname = SettingsFilter   
    end if
    
		' Do we want to filter the summary graphs by settings?
	  if ((SettingsFilter > "") and (lSettingsName <> SettingsFilter)) then
      ' Don't add this one...
    else			
			Set objHop = objXML.createElement("Hop")
			AddXMLValue objXML, objHop, "HopNum", I+1
			for ColLoop = LBound(ColArray) to UBound(ColArray)
			  if IsNull(DataArray(ColLoop)) then
			  	StringValue = ""
			  else
			  	StringValue = Cstr(DataArray(ColLoop))
			  end if
			  
			  AddXMLValue objXML, objHop, ColArray(ColLoop), StringValue
			next

			objHops.appendChild objHop
		end if
  next
  
  objTarget.appendChild objHops
  
  oRoot.appendChild objTarget
  
end if	

if (ErrorMessage = "") and (Variable("alltargets") > "") then
	'Create our root element using the createElement method
  dim ListTarget, objListOf
	set objListOf = objXML.createElement("targetlist")
	
  oRoot.appendChild objListOf
  
  dim AllTargets
  AllTargets = PingPlotter.TargetFieldsAsArray("UniqueID, TargetDescription, TargetIPAddress, TargetDNSName, IsRunning, TraceInterval, SampleCount, SettingsName")
  
  for I = 0 to UBound(AllTargets)
    ListTarget = AllTargets(I)
    
    if ((SettingsFilter > "") and (SettingsFilter <> ListTarget(7))) then
    	' Skip this one - doesn't match the Settings filter.
    else
	    if (ListTarget(6) > 0) then
	    
				'Create the tracetarget element
				Set objTarget = objXML.createElement("tracetarget")
				
				AddXMLValue objXML, objTarget, "UniqueID", ListTarget(0)
				AddXMLValue objXML, objTarget, "TargetDescription", ListTarget(1)
				AddXMLValue objXML, objTarget, "TargetIPAddress", ListTarget(2)
				AddXMLValue objXML, objTarget, "TargetDNSName", ListTarget(3)
				AddXMLValue objXML, objTarget, "IsRunning", ListTarget(4)
				AddXMLValue objXML, objTarget, "TraceInterval", ListTarget(5)
				AddXMLValue objXML, objTarget, "SampleCount", ListTarget(6)
				
				objListOf.appendChild objTarget
			end if
		end if
  next
  
end if

if (Variable("summaries") > "") then
	'Create our root element using the createElement method
  dim CurSummary, objSummaries
	set objSummaries = objXML.createElement("summaries")
	
  oRoot.appendChild objSummaries
  
  dim AllSummaries
  AllSummaries = PingPlotter.SummaryGraphDataAsArray("UniqueID, SummaryName, TargetCount, CanClose")
  
  for I = 0 to UBound(AllSummaries)
    CurSummary = AllSummaries(I)
    
		'Create the tracetarget element
		Set objTarget = objXML.createElement("summary")
		
		AddXMLValue objXML, objTarget, "UniqueID", CurSummary(0)
		AddXMLValue objXML, objTarget, "SummaryName", CurSummary(1)
		AddXMLValue objXML, objTarget, "TargetCount", CurSummary(2)
		AddXMLValue objXML, objTarget, "CanClose", CurSummary(3)

		
		objSummaries.appendChild objTarget
  next
  
end if

if (ErrorMessage = "") and ((Variable("columns") > "") or (Variable("setcolvisible") > "")) then
	
	 'these are our variables
	'create the top level node for this target
	dim objColumns
	Set objColumns = objXML.createElement("graphcolumns")
	
	dim CurCol, objColumn
	
  for I = 0 to Graph.ColumnCount-1
    set CurCol = Graph.Columns(I)
    
		'Create the newsitem element
		Set objColumn = objXML.createElement("column")
		
		AddXMLValue objXML, objColumn, "ColumnType", CurCol.ColumnType
		AddXMLValue objXML, objColumn, "Hint", CurCol.Hint
		AddXMLValue objXML, objColumn, "Caption", CurCol.Caption
		AddXMLValue objXML, objColumn, "Name", CurCol.Name
		AddXMLValue objXML, objColumn, "SizeAbility", CurCol.SizeAbility
		AddXMLValue objXML, objColumn, "Visible", CurCol.Visible
		AddXMLValue objXML, objColumn, "Width", CurCol.Width
		AddXMLValue objXML, objColumn, "ColIndex", CurCol.ColIndex
		
		objColumns.appendChild objColumn
  next
  
  oRoot.appendChild objColumns
  
end if

if (ErrorMessage > "") then
  Response.Status = "400 "+ErrorMessage
  Response.Write ErrorMessage
else
	Response.ContentType = "text/xml; charset=utf-8"
	Response.Clear
	Response.Write "<?xml version=""1.0"" encoding=""utf-8""?>"
	Response.Write objXML.xml
end if

%>
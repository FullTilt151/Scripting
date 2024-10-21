<% Option Explicit
%><!--#include file="HelperFunctions.asp"--><%
	Response.ContentType = "text/html; charset=utf-8"

if (UserName > "") and (PingPlotter.HasWebAccess(UserName, UserPassword) = 0) then
	' Didn't get logged in right.
	Session("Login Error") = "Username / password combination not correct or doesn't have access"
	Response.Redirect "Login.asp"
end if

EnsureLoggedIn()

dim EDITING_ALLOWED, SINGLE_TARGET

EDITING_ALLOWED = True   ' False = No editing allowed, True = Able to add new targets, trace interval change, stop/start, etc.
SINGLE_TARGET = False		' False = show all targets, True = show the passed in target only (usually by IP)

Response.Buffer = True

' PingPlotter object is defined by HelperFunctions
dim ScriptName, NewDestination
dim UseJavascript, Printable

UseJavaScript = true

NewDestination = false
ScriptName = ""

' IIS doesn't like to post to a default.asp file unless it's specified
if IsIIS then
  ScriptName = "Default.asp"
end if

dim UID, IP, URL, IsSummary
UID = Variable("ID")
' If the new target button is hit, we don't want to pull the IP Address as passed
if Variable("formaction") <> "New Target" then
  IP = Variable("IP")
end if


if (IsNumeric(Variable("Printable"))) then
  Printable = true
else
	Printable = false
end if

if Printable then
	UseJavaScript = False
end if

' Default to show the AllTargets page, if nothing is visible
if (UID = "") and (not SINGLE_TARGET) then
  if (PingPlotter.SummaryGraphCount > 0) then
    UID = PingPlotter.SummaryGraphs(0).UniqueID
  else
	  UID = "SUM-ALLTARGETS"
	end if
end if

if (Left(ucase(UID),4) = "SUM-") then
	IsSummary = TRUE
else
	IsSummary = FALSE
end if

dim TraceTarget, ErrorMessage, I, ListTarget, SummaryGraph, ForceCreateTarget

ErrorMessage = ""
ForceCreateTarget = false

' If someone hits the enter key to add a new target, we may not get the "New Target"
' command through, so let's check to see if the conditions match to do that.
if (Variable("formaction") = "") then
	if (Variable("target") > "") then
		if (IsSummary) then
			' The only reason we enter a name when looking at the summary is to create a new target
			ForceCreateTarget = true
		end if
	end if
end if

if (Variable("formaction") = "New Target") or (ForceCreateTarget) then
  if (Variable("target") > "") then
	  TraceTarget = NULL
	  set TraceTarget = GetNewTarget(PingPlotter, Variable("target"))
		on Error resume next ' Enable error handling...
	  TraceTarget.Resolve
		If Err.Number <> 0 then
			ErrorMessage = "Error resolving: " + Err.Description
			Err.Clear
   		On Error goto 0 ' disable error handling...
   		if (not IsSummary) then
				set TraceTarget = GetTargetByID(PingPlotter, UID) ' Return to the previous object...
			else
			  set SummaryGraph = GetSummaryByID(PingPlotter, UID)
			end if
		else
   		On Error goto 0 ' disable error handling...

	   	' Should this be added to a specific summary screen?  Almost certainly, yes.
	   	if (Variable("onsummary") > "") then
	   		dim AddToSummary
	   		set AddToSummary = PingPlotter.SummaryGraphByID(Variable("onsummary"))

				if (IsObject(AddToSummary) and (not (AddToSummary is Nothing))) then
					AddToSummary.AddHostByID(TraceTarget.UniqueID)
				end if
	    end if

	    TraceTarget.Start
   	  NewDestination = true
			IsSummary = FALSE
   	end if
  end if
elseif Variable("formaction") = "newsummary" then
	dim NewSummary
	set NewSummary = PingPlotter.CreateNewSummary(Variable("name"))
	IsSummary = TRUE
	UID = NewSummary.UniqueID
end if

if (ErrorMessage = "") and (IsSummary) and (not NewDestination) then
  set SummaryGraph = GetSummaryByID(PingPlotter, UID)

  TraceTarget = Null

 	URL = ScriptName & "?ID=" & SummaryGraph.UniqueID
	if (Printable) then
		URL = Url & "&Printable=1"
	end if

	if Variable("formaction") = "CloseSummary" then
		if IsObject(SummaryGraph) and SummaryGraph.CanClose then
			SummaryGraph.Close
  		set SummaryGraph = GetSummaryByID(PingPlotter, "") ' Get "All Targets"
		end if
  end if
  if (SettingsFilter > "") then
		URL = URL & "&SettingsFilter=" & SettingsFilter
  end if

	if (IsSummary) and IsObject(SummaryGraph) then
		if (Variable("selectSummaryFocus") > "") then
  		SummaryGraph.FocusPeriod = StrToLng(Variable("selectSummaryFocus"))
		end if
	end if

elseif (ErrorMessage = "") then
	if (not IsObject(TraceTarget)) then
		if ((SINGLE_TARGET) or (IP > "")) then
			' Iterate the list of currently traced targets and match the IP Address
			TraceTarget = NULL

			for I = 0 to PingPlotter.TargetCount-1
			  set ListTarget = PingPlotter.Targets(I)
			  if ListTarget.TargetIPAddress = IP then
			  	set TraceTarget = ListTarget
				end if
			next

			if IsNull(TraceTarget) and (UID > "") then
				set TraceTarget = GetTargetByID(PingPlotter, UID)
				if (TraceTarget is Nothing) then
					TraceTarget = NULL
				end if
			end if

		else
			set TraceTarget = GetTargetByID(PingPlotter, UID)
		end if
	end if

	if (IsObject(TraceTarget)) then
		if (EDITING_ALLOWED) then
			' If an action is specified, do something.
			if Variable("formaction") = "Change Target" then
			  if (TraceTarget.SpecifiedTargetName <> Variable("target")) and (Variable("target") > "") then
			    TraceTarget.Reset
				TraceTarget.TargetDescription = Variable("target")
				TraceTarget.Resolve
				TraceTarget.Start
				NewDestination = true
			  end if
			elseif Variable("formaction") = "Close" then
			  TraceTarget.Close
			  if (PingPlotter.TargetCount > 0) then
			    set TraceTarget = PingPlotter.Targets(0)
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

			' Were any settings changes specified?  Let's apply them!
			if IsNumeric(Variable("TraceCount")) then
				TraceTarget.MaxSampleCount = StrToLng(Variable("TraceCount"))
			end if

			if IsNumeric(Variable("Interval")) then
				TraceTarget.TraceInterval = StrToLng(Variable("Interval"))
			end if
		end if

		if IsNumeric(Variable("SamplesToInclude")) then
			TraceTarget.Graph.SamplesToInclude = StrToLng(Variable("SamplesToInclude"))
		end if

		if IsNumeric(Variable("TimeGraphTime")) then
			TraceTarget.Graph.TimeGraphTime = StrToLng(Variable("TimeGraphTime"))
		end if

		if (Variable("SettingsName") > "") and (Variable("SettingsName") <> TraceTarget.SettingsName) then
			TraceTarget.SettingsName = Variable("SettingsName")
		end if

		' How tall are the time-graph images?
		TraceTarget.Graph.TimeGraphHeight = 125

		if (IP > "") then
	  	URL = ScriptName & "?IP=" & IP
		else
	  	URL = ScriptName & "?ID=" & TraceTarget.UniqueID
		end if

		if (Printable) then
			URL = Url & "&Printable=1"
		end if
	else

	  URL = ScriptName
	end if

end if

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
		<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title>PingPlotter - <%
	if (IsSummary) then
		Response.Write SummaryGraph.SummaryName
	else
		if (IsObject(TraceTarget)) then
			Response.Write TraceTarget.TargetDescription
		else
			Response.Write "No Target"
		end if
	end if
    %></title>
    <link rel="stylesheet" type="text/css" href="PP_Web.css">
    <link rel="stylesheet" type="text/css" href="jquery/cm_default/style.css">
    <% if (UseJavaScript) then %>
    <script type="text/javascript">
    <% if IsObject(TraceTarget) then %>
  var IsSummary = false;
	var initialSampleNum = <%= TraceTarget.SampleCount %>;
	var curTraceInterval =  <%= TraceTarget.TraceInterval %>;
	var curTargetID = "<%= TraceTarget.UniqueID %>";
		<% else %>
	var initialSampleNum = 0;
	var curTraceInterval = 10000;
	<% if IsObject(SummaryGraph) then %>
	var curTargetID = "<%= SummaryGraph.UniqueID %>";
	var IsSummary = true;
	<% end if %>
<% end if %>
<% if (SettingsFilter > "") then %>
  var settingsFilter = "<%= SettingsFilter %>";
<% end if %>
    </script>
    <script type="text/javascript" src="js/wz_jsgraphics.js"> </script>
    <script type="text/javascript" src="jquery/js/jquery-1.11.2.min.js"> </script>
    <script type="text/javascript" src="jquery/js/jquery-ui.min.js"> </script>
    <script type="text/javascript" src="jquery/js/jquery.address-1.5.min.js"> </script>
    <script type="text/javascript" src="jquery/js/jquery.jeegoocontext-2.0.0.min.js"> </script>
    <script type="text/javascript" src="jquery/js/jquery.ui.touch.js"> </script>
    <script type="text/javascript" src="jquery/css/custom-theme/jquery-ui.min.css"> </script>
    <script type="text/javascript" src="js/cookie.js"> </script>
    <script type="text/javascript" src="js/pp_web.js">
    </script>
    <% end if %>

    <% if (SINGLE_TARGET) or (Printable) then %>
    <style>
        .rightsideouter {
            margin-left: 5px;
        }
    </style>
    <% end if %>
    <meta name="format-detection" content="telephone=no" />
</head>
<body>
<form name="settings" action="<%=URL %>" method="POST">
<div id="mainpage" class="mainpage">
	<div class="toplogo">
	    <a href="http://www.pingplotter.com/" target="_blank">
	        <img class="logo" border="0" align="left" title="PingPlotter Pro - See the Network, Pinpoint the Problem" src="./images/logo_pingplotter_head.png"></img>
	    </a>
	    <%
	    	if (Session("UserName") > "") then
					Response.Write("<div class='logoutlink'><a href='" + URL + "&Logout=1'>Logout</a></div>")
				end if
			%>
	</div>
	<div class="frame">
	  <% BuiltLeftPanelControlArea %>
	  <div class="right-col">
	    <div class="pingplotter">
	    	<div class="main-top-row">
	<span class="curTargetDesc" id="curTargetDesc">
		<% if (IsSummary) then %>
		<span class="main-target-name"><%= SummaryGraph.SummaryName %></span>
	 <% else if (IsObject(TraceTarget)) then %>
			Target: <span class="main-target-name"><%= TraceTarget.TargetDNSName %> (<%= TraceTarget.TargetIPAddress %>)
<% 	if (not TraceTarget.IsRunning) and (TraceTarget.SampleCount > 0) then
			Response.Write(" - (Paused)")
			  end if
				else
				Response.Write("No Target")
		end if
	end if
	%></span></span>
<%
	if (not Printable) then %>
	  <div id='printableversion' class='printablelink'>
	    <a href='<%= URL %>&Printable=1' target='_blank'><span class="printablelink-txt">Printable version</span></a>
	  </div>
	<% end if
  BuildHeaderArea
  if (SINGLE_TARGET) and (not IsObject(TraceTarget)) then
	  if (IP > "") then
	    Response.Write("The target you specified: " + IP + " is not being monitored by PingPlotter currently.")
	  else
	    Response.Write("You must specify the address of a currently running target.")
		end if
	end if
  if (IsObject(TraceTarget) or IsObject(SummaryGraph)) then %>
                        <%	if (ErrorMessage > "") then %>
                        <div id="ajaxerror" class="ajaxerror" style="display: block"><%=ErrorMessage %><br>
                        </div>
                        <%	else %>
                        <div id="ajaxerror" class="ajaxerror" style="display: none"></div>
                        <%	end if

   	dim DisplaySettings
		if (IsSummary) then
			set DisplaySettings = SummaryGraph.DisplaySettings
		elseif (IsObject(TraceTarget)) then
			set DisplaySettings = TraceTarget.Graph.DisplaySettings
		else
			' Get the first settings - the one the summary graphs use
			set DisplaySettings = PingPlotter.SummaryGraphs(0).DisplaySettings
		end if

  ' We always want to paint in the graph information so we can fill it in later
  ' from the Javascript.  If we don't put it in even for an empty graph, then we
  ' can't fill it later.
                        %>
                        <div id="tracegraph" class="tracegraph" style="display: none; text-align: left;">
                            <div id="tracegraphheader" class="tracegraphheader" style="position: relative">
                                <div class="legend-bars">
                                    <div style="width: 100px" class="Hop_Good">0-<%=DisplaySettings.WarningSpeed %> ms</div>
                                    <div style="width: 100px" class="Hop_Warn"><%=DisplaySettings.WarningSpeed+1 %>-<%=DisplaySettings.BadSpeed %> ms</div>
                                    <div style="width: 100px" class="Hop_Bad"><%=DisplaySettings.BadSpeed+1 %> ms and up</div>
                                </div>
                                <div class="tracegraphheader-table">
                                    <table>
                                        <% if (IsSummary) then %>
                                        <tr>
                                            <td class="headernamecaption"></td>
                                            <td id="headertargetname"><%=SummaryGraph.SummaryName %></td>
                                        </tr>
                                        <tr class="target_setting" style="display: none">
                                            <td class="headeripcaption">Target IP:</td>
                                            <td id="headertargetip">Summary</td>
                                        </tr>
                                        <tr>
                                            <td class="headersamplecaption">Sample Time:</td>
                                            <td id="headersamplerange"></td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                        </tr>
                                        <% else %>
                                        <tr>
                                            <td class="headernamecaption">Target Name:</td>
                                            <td id="headertargetname"></td>
                                        </tr>
                                        <tr class="target_setting">
                                            <td class="headeripcaption">Target IP:</td>
                                            <td id="headertargetip"></td>
                                        </tr>
                                        <tr>
                                            <td class="headersamplecaption">Sample Set:</td>
                                            <td id="headersamplerange"></td>
                                        </tr>
                                        <% end if %>
                                    </table>
                                </div>
                            </div>
                            <div id="contextmenu" style="position: absolute; z-index: 15;"></div>
                            <div id="tracegraphbody" class="tracegraphbody" style="position: relative;"></div>
                            <div id="timegraphframe" class="timegraphframe" style="position: relative;"></div>
                        </div>

                        <table id="graphimage" cellspacing="0" cellpadding="0" width=<%
	if (IsSummary) then
		Response.Write SummaryGraph.ImageWidth+2
	elseif IsObject(TraceTarget) then
		Response.Write TraceTarget.Graph.ImageWidth+2
	else
		' Default
		Response.Write "450"
	end if
%>>
                            <tr>
                                <td align="CENTER">
                                    <%
  ' The Image on the following line has a variable to make sure it refreshes correctly.  If the
  ' same image name is used, then browsers "cache" it - adding the ? means that the browser sees
  ' it different, but the image name doesn't actually need to change.
                                    %>
                                    <img name="maingraph" src="GetImage.asp?ID=<%
  if (IsSummary) then
  	Response.Write SummaryGraph.UniqueID
  elseif IsObject(TraceTarget) then
    Response.Write TraceTarget.UniqueID
  end if
%>">
                                </td>
                            </tr>
                        </table>
                        <script language="JavaScript" type="text/javascript">
                            // If scripting is enabled, hide the image and show the AJAX version
                            <% if (UseJavaScript) then %>
                              document.getElementById("graphimage").style.display = "none";
                              document.getElementById("tracegraph").style.display = "block";
                          <% end if %>
                              document.getElementById("mainpage").style.width = "100%";
                        </script>
                        <table class="listdetails">
                            <tr>
                                <td align="left" valign="middle"><% BuildAutoRefreshSelector %></td>
                                <td align="RIGHT" nowrap id="timegraphtimechanger">Graph&nbsp;Time:&nbsp;<select name="TimeGraphTime" id="selectTimeGraphTime" size="1">
                                    <%
  ' Set
  dim CurMatch2, MatchGraphTime
  if (IsSummary) then
  	MatchGraphTime = SummaryGraph.TimeGraphTime
  elseif (IsObject(TraceTarget)) then
  	MatchGraphTime = TraceTarget.Graph.TimeGraphTime
  else
  	MatchGraphTime = 10
  end if

  CurMatch2 = PrintListBox(Array(Array(1, "60 Seconds"), _
                    Array(5, "5 Minutes"), _
					Array(10, "10 Minutes"), _
					Array(30, "30 Minutes"), _
					Array(60, "60 Minutes"), _
					Array(180, "3 Hours"), _
					Array(360, "6 Hours"), _
					Array(720, "12 Hours"), _
					Array(1440, "24 Hours"), _
					Array(2880, "48 Hours"), _
					Array(10080, "7 days")), MatchGraphTime)
                                    %>
                                </select><br>
                                    <div id="nonStandardGraphTime">
                                        <%
  if (not CurMatch2) then
    Response.Write "Current: " & MatchGraphTime & " minutes"
  end if
end if
                                        %>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="bottom-info">
                        <div class="pman-text">powered by:</div>
                        <div class="pman-logo"><a href="http://www.pingman.com" target="_blank"><img src="images/pman-logo.png"></a></div>
                        <div class="Copyright"><a href="http://www.pingman.com" target="_blank">Copyright (C) 1998, 2015 Pingman Tools,
                            LLC</a></div>

                    </div>
                </div>
                <div style="clear: both"></div>
            </div>
            <% if (not SINGLE_TARGET) and (not Printable) then %>
        </div>
        <% end if %>
</div>
    </form>
</body>
</html>
<%

sub BuiltLeftPanelControlArea
  if (not SINGLE_TARGET) and (not Printable) then %>
  <div class="left-col">
		<div class="targetarea" id="targetarea">
	    <% 	if (EDITING_ALLOWED) then   %>
	    <div class="inputtargetbox">
	      <div class="controlhead">
					<label for="targetinput">New Target to Trace:</label>
				</div>
	      <div><input class="targetinput" id="targetinput" size="25" name="target" value="">
	        </div>
	        <div style="text-align: center;">
	            <button id="newtargetbtn" class="blue-btn trace-btn">Trace New Target</button>
	        </div>
	        <div style="position: absolute; left: 0px; top: 0px">
	            <img src="images/newtargetside.png"></div>
	        <div style="position: absolute; right: 0px; top: 0px">
	            <img src="images/newtargetside.png"></div>
	    </div>
	    <%	end if %>
	    <div class="inputtargetbox summarylist">
	        <div>
	            Summaries:
	        </div>
	        <div id="summarylist">
	            <%		  dim TargetData
				TargetData = PingPlotter.SummaryGraphDataAsArray("UniqueID, SummaryName, TargetCount")	' 0 = UniqueID, 1 = SummaryName, 2 = SummaryName
		        if UBound(Targetdata) >= 0 then
						  for I = 0 to UBound(TargetData)
						    ListTarget = TargetData(I)
						    Response.Write "<div id='summarylistname"&I&"' class='summarylistname'>"
						  	Response.Write "<a HREF='"+ Scriptname + "?ID=" + ListTarget(0) +"'>"+ListTarget(1)+"</a></div>"
								Response.Write "&nbsp;&nbsp;<span class='summarylistdetails' id='summarylistdetails"&I&"'>"+CStr(ListTarget(2))+" Targets</span><BR>"
							next
						else
							Response.Write "(no targets)<br>"
						end if
	            %>
	        </div>
	    </div>
	  </div>
</div>
<% end if
end sub

sub BuildHeaderArea
  dim showGraphCSS
  dim showSummCSS
  dim showStopBtn
  dim showResumeBtn
  dim showResetBtn
  dim showCloseBtn
  dim showDownloadBtn
  dim SettingsName
  dim TraceInterval
  dim SamplesToInclude
  dim MaxSampleCount
  dim CanCloseSummary

  ' Default everything invisible.
	showSummCSS = "display:none"
	showStopBtn = false
	showResumeBtn = false
	showResetBtn = false
	showCloseBtn = false
	showDownloadBtn = false
	CanCloseSummary = false

	SettingsName = ""
	TraceInterval = 10000
	SamplesToInclude = 10
	MaxSampleCount = 0

  if (IsSummary) then
  	showSummCSS = ""
  	if (SummaryGraph.CanClose) then
  	  CanCloseSummary = true
  	end if
  else
  	showGraphCSS = ""
  	if IsObject(TraceTarget) then
  		SettingsName = TraceTarget.SettingsName
  		TraceInterval = TraceTarget.TraceInterval
  		SamplesToInclude = TraceTarget.Graph.SamplesToInclude
  		MaxSampleCount = TraceTarget.MaxSampleCount
  		if (TraceTarget.SampleCount > 0) then
  			showResetBtn = true
  			showCloseBtn = true
  			showDownloadBtn = true
  			if (TraceTarget.IsRunning) then
  				showStopBtn = true
  			else
  				showResumeBtn = true
  			end if
  		end if
  	end if
  end if
%>
<div class="commandouter" id="Div1">
	<div class="trace-graph-buttons">
	  <div class="actionlinks">
  <%if (EDITING_ALLOWED) and (not Printable) then %>
    <a id="btnCloseSummary" class="blue-btn close-btn trace-button-cell" href="<%= URL %>&formaction=CloseSummary" <%
          if (not IsSummary) or (not CanCloseSummary) then
          	%> style="display: none" <%
          end if %>>Close Summary</a>
<%	if (not SINGLE_TARGET) then %>
		<A id="btnClose" class="blue-btn close-btn trace-button-cell" HREF="<%= URL %>&formaction=Close"<% if (not showCloseBtn) then %> style="display:none"<% end if %>>Close Target</A>
<%	end if %>
		<A id="btnReset" class="blue-btn reset-btn trace-button-cell" HREF="<%= URL %>&formaction=Reset Trace"<% if (not showResetBtn) then %> style="display:none"<% end if %>>Reset</A>
		<A id="btnStop" class="blue-btn pause-btn trace-button-cell" HREF="<%= URL %>&formaction=Stop Trace"<% if (not showStopBtn) then %> style="display:none"<% end if %>>Stop Trace</A>
		<A id="btnResume" class="blue-btn play-btn trace-button-cell" HREF="<%= URL %>&formaction=Resume Trace"<% if (not showResumeBtn) then %> style="display:none"<% end if %>>Resume Trace</A>
    <a id="btnRenameSummary" class="blue-btn trace-button-cell" style="display: none" href="<%= URL %>&formaction=RenameSummary">Rename Summary</a>
<%end if %>
    <div class="sample-set">
			<a title="Download collected data (.pp2 file) for local analysis in PingPlotter Pro or Standard." id="btnDownload" href="GetSampleData.asp?ID=<% if IsObject(TraceTarget) then %><%= TraceTarget.UniqueID %><% end if %>" <% if (not showDownloadBtn) then %> style="display:none"<% end if %>><span class="sample-set-text">Download Sample Set</span></a>
		</div>
	</div>
 </div>
 </div>
	<div>
	<TABLE class="settings_table" id="settings_table" cellspacing=0 cellpadding=0 class="listdetails">
<% ' If we have more than one setting, then display which one here, and make it editable if appropriate.
	if (PingPlotter.SettingsCount > 1) and (SettingsFilter = "") then
		%>
		<TR class="target_setting" style="<%= ShowGraphCSS %>"><TD ALIGN=RIGHT>Settings:</TD><TD VALIGN=middle COLSPAN=2>
<%	if (EDITING_ALLOWED) then %>
			<SELECT NAME="SettingsName" class="inputControls" ID="selectSettingsName"><%
		  for I = 0 to PingPlotter.SettingsCount-1
				Response.Write "<OPTION VALUE=""" & PingPlotter.Settings(I).Name & """"
				if (PingPlotter.Settings(I).Name = SettingsName) then
				Response.Write " SELECTED"
				end if
				Response.Write ">" & PingPlotter.Settings(I).Name & "</OPTION>"
			next
		else
			Response.Write SettingsName
			end if  %></SELECT>
		</TD></TR>
<%end if %>

	<!-- Do the # of times to trace -->
<%if (EDITING_ALLOWED) then %>
		<TR class="target_setting" style="<%= ShowGraphCSS %>"><TD ALIGN=RIGHT>#&nbsp;of&nbsp;times&nbsp;to&nbsp;Trace:</TD><TD VALIGN=middle COLSPAN=2><INPUT SIZE=10 id="editTraceCount" NAME="TraceCount" class="inputControls" ID="Text1" value="<%
	  	if (MaxSampleCount = 0) then
				Response.Write("Unlimited")
	  	else
				Response.Write(MaxSampleCount)
			end if
	%>">&nbsp;&nbsp;<span class="zero-4-unlimited">Enter 0 for Unlimited</span>
		</TD></TR>
		<TR class="target_setting" style="<%= ShowGraphCSS %>"><TD ALIGN=RIGHT>Trace&nbsp;Interval:</TD><TD><SELECT NAME="Interval" ID="selectTraceInterval"  class="inputControls" SIZE=1>
	<%
	  dim CurMatch
	  CurMatch = PrintListBox(Array(Array(1000, "1 Second"), _
						Array(2500, "2.5 Seconds"), _
						Array(5000, "5 Seconds"), _
						Array(10000, "10 Seconds"), _
						Array(15000, "15 Seconds"), _
						Array(30000, "30 Seconds"), _
						Array(60000, "1 Minute"), _
						Array(150000, "2.5 Minutes"), _
						Array(300000, "5 Minutes")), TraceInterval)
	%>
	</SELECT>
	<%
	  if (CurMatch > 0) then
		Response.Write "Current: "&TraceInterval&" ms"
	  end if
	%>
		</TD><TD></TD></TR>
<%end if
	' OK, next is "Samples to include" - this is always editable since it doesn't affect anything.
%>
		<TR class="target_setting" style="<%= ShowGraphCSS %>"><TD ALIGN=RIGHT>Samples&nbsp;to&nbsp;Include:</TD><TD><INPUT SIZE=5 NAME="SamplesToInclude" ID="editSamplesToInclude" class="inputControls" value="<%
		  if (SamplesToInclude = 0) then
			Response.Write("ALL")
		  else
			Response.Write(SamplesToInclude)
		  end if
		%>"></TD>
				<tr class="summary_setting" style="<%= ShowSummCSS %>"><td width="150" ALIGN=RIGHT>Focus Period:</td>
						<td><SELECT NAME="selectSummaryFocus" ID="selectSummaryFocus"  class="inputControls" SIZE=1>
<%
  dim FocusPeriodMatch
  dim FocusPeriod

  if IsObject(SummaryGraph) then
  	FocusPeriod = SummaryGraph.FocusPeriod
  else
  	FocusPeriod = 600
  end if

  FocusPeriodMatch = PrintListBox(Array( _
          Array(-9999, ""), _
          Array(0, "All"), _
          Array(15, "15 Seconds"), _
					Array(30, "30 Seconds"), _
					Array(60, "60 Seconds"), _
					Array(90, "90 Seconds"), _
					Array(120, "2 Minutes"), _
					Array(210, "3.5 Minutes"), _
					Array(300, "5 Minutes"), _
					Array(600, "10 Minutes"), _
					Array(900, "15 Minutes"), _
					Array(1800, "30 Minutes"), _
					Array(3600, "60 Minutes"), _
					Array(21600, "6 Hours"), _
					Array(86400, "24 Hours")), FocusPeriod)
%>
</SELECT>&nbsp;&nbsp;<span id="Span1"><%
  if (not FocusPeriodMatch) then
		if (FocusPeriod < 120) then
    	Response.Write "Current: " & FocusPeriod & " seconds"
    ElseIf (FocusPeriod < 60 * 60 * 2) then
    	Response.Write "Current: " & FocusPeriod / 60 & " minutes"
    Else
    	Response.Write "Current: " & FocusPeriod / (60 * 60) & " hours"
    end if
  end if
%></span></td></tr>
<% if (not Printable) then %>
<TR><TD><INPUT NAME="formaction" TYPE=submit value="Change Settings" ID="btnChangeSettings"></TD></TR>
<% end if %>
	</TABLE>
	<% if (UseJavaScript) then %>
	<script language="JavaScript" type="text/javascript">
	    // If scripting is enabled, hide the submit button
	    document.getElementById("btnChangeSettings").style.display = "none";
	</script>
	<% end if %>
</div></div><%
end sub

sub BuildAutoRefreshSelector
 if (UseJavaScript) then
%><div id="refreshInterval" class="refreshInterval" style="display: none">Auto refresh: <a href="javascript:setRefreshInterval(-1)">Stop</a> <a href="javascript:setRefreshInterval(-2)">Auto</a> <a href="javascript:setRefreshInterval(1000)">1 sec</a> <a href="javascript:setRefreshInterval(5000)">5 sec</a> <a href="javascript:setRefreshInterval(10000)">10 sec</a> <a href="javascript:setRefreshInterval(30000)">30 sec</a> <a href="javascript:setRefreshInterval(60000)">60 sec</a> <a href="javascript:setRefreshInterval(600000)">10 min</a> <a href="javascript:setRefreshInterval(0)">Now</a></div>
<script language="JavaScript" type="text/javascript">
    // If scripting is enabled, hide the image and show the AJAX version
    document.getElementById("refreshInterval").style.display = "block";
</script>
<%
 end if
end sub
%>
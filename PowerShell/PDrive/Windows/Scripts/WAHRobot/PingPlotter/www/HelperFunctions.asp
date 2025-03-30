<%
' --------------------------------------------------------------------
' Helper Functions for Ping Plotter asp pages.
' --------------------------------------------------------------------

dim IsIIS ' Is this an instance of IIS, or is it the embedded PingPlotter Engine?

dim UserName, UserPassword
dim myShareUI, myShareTargets

' ------------ static Parameters -------------
' Do NOT use the "Variable" function until after the IIS check has been done!

myShareUI			  = false
myShareTargets		  = true

dim PingPlotter
set PingPlotter = nothing

' If running from inside PingPlotter, then the "PingPlotter_Embedded" object is
' defined and part of the script.  If it's running under IIS, it won't be an
' object yet...
on error resume next
set PingPlotter = PingPlotter_Embedded
on error goto 0

if (not IsObject(PingPlotter)) or (PingPlotter is Nothing) then
	
	' To create this object, the web server (ie: IUSR_(machine name)) has to have
	' local rights to launch and activate.
	' Open dcomcnfg.  Open Component Services, Computers, My Computer, DCOM Config.  Right-click "PingPlotter".
	' Go to the "Security" tab.  "Customize" Launch and Activation Permissions.  Add the 
	' Internet Guest Account (IUSR_MACHINENAME) and make sure there is "Local Launch" and "Local Activation".
	' "Apply" and it should work (if you don't apply, but just "OK", on XP a reboot may be required first).
	
  On Error resume next
  set PingPlotter = Server.CreateObject("pingplotter.PingPlotter_Engine")
  
  if (Err.Number <> 0) then
  	' Object couldn't be created
  	PrintErrorPage "Error creating PingPlotter object","<font size=+2>Couldn't create PingPlotter Object.</font><br>Make sure rights to the PingPlotter engine object are correctly configured.<hr>"
  End If
  On Error goto 0

  ' Need to signal to leave the application running in case it's not running as a
  ' service.
  PingPlotter.LeaveApplicationRunning = true
  IsIIS = true
else
  IsIIS = false
end if

' If the user interface should come to the foreground on each new target, then set
' this.  As a web page, it's probably best to leave it off
PingPlotter.AllowUIVisible = false
PingPlotter.SharedUI = myShareUI
PingPlotter.SharedTargets = myShareTargets

' Shared variables
SettingsFilter = Variable("SettingsFilter") ' Used to filter targets to only a certain settings group.
dim SettingsFilter

' --------------------------------------------
' ----- helper functions -----------------------
' --------------------------------------------

' ----- Get Variable function -----------------------
' This will pull a parameter first from the command line interface (ie: part of URL)
' and if it's not defined there, it will then come from the form.
function Variable(VarName)
  ' Prefer the "Get"
  if (IsIIS) then
	  if not IsEmpty(Request.QueryString(VarName)) then
			Variable = Request.QueryString(VarName)
	  ' Then the "Put"
	  elseif not IsEmpty(Request.form(VarName)) then
			Variable = Request.form(VarName)
	  else
			Variable = ""
	  end if
  else
  	Variable = request.Params.Values(VarName)
  end if
end function

' Built in web server is different than IIS for cookie values, and also doesn't support
' complex objects.
function GetCookieValue( CookieName )
  if (IsIIS) then
    GetCookieValue = Request.Cookies( CookieName )
  else
    GetCookieValue = Request.Cookies( CookieName ).Value
  end if
end function

sub SetCookieValue( CookieName, Value )
  if (IsIIS) then
    Response.Cookies( CookieName ) = Value
  else
    Response.Cookies( CookieName ).Value = Value
  end if
end sub

Function IIf( expr, truepart, falsepart )
   IIf = falsepart
   If expr Then IIf = truepart
End Function

sub EnsureLoggedIn
	
	if (Variable("logout") > "") then
		Response.Redirect "Login.asp?Logout=1"
	end if

	' Did we do the login form?
	UserName = Trim(Variable("txtLoginId"))
	UserPassword = Trim(Variable("txtLoginPasswd"))

  ' If we didn't get username / password passed in, do a quick session check to see if we have valid
  ' session username / password.  This is the most common path through this routine, so it should minimize
  ' the number of COM calls	
	if (UserName = "") and (UserPassword = "") then
		if (PingPlotter.HasWebAccess(Session("UserName"), Session("UserPassword")) <> 0) then
			' We have access!
			exit sub
		end if 
	end if
	
	' Was username specified, or password specified, or do we not need that?
	if ((UserName > "") or (UserPassword > "") or (Variable("cbFromLoginForm") = "1") or (PingPlotter.HasWebAccess(UserName, UserPassword) <> 0)) then
		if (PingPlotter.HasWebAccess(UserName, UserPassword) <> 0) then
			' Succesful Login (or we don't care).
			Session("LoginError")= ""
			Session("loggedIn") = "1"
			Session("UserName") = UserName
			Session("UserPassword") = UserPassword
	
			if Variable("chkRemPasswd") > "" then
				SetCookieValue "UserName", UserName
				SetCookieValue "UserPassword", UserPassword
				Response.Cookies("UserName").Expires = "Dec 31, 2037"
				Response.Cookies("UserPassword").Expires = "Dec 31, 2037"
			else
				SetCookieValue "UserName", ""
				SetCookieValue "UserPassword", ""
			end if
		else
			' Invalid username / password specified in dialog
			Session("LoginError") = "Username / password combination not correct or doesn't have access"
			Response.Redirect "Login.asp"
		end if
	else
		' No session, check for cookie
		UserName = GetCookieValue("UserName")
		UserPassword = GetCookieValue("UserPassword")

		if (UserName > "") and (PingPlotter.HasWebAccess(UserName, UserPassword) <> 0) then
			' Good cookie for login - set the session
			Session("UserName") = UserName
			Session("UserPassword") = UserPassword
			Session("loggedIn") = "1"
			Session("LoginError") = ""
		else
			Response.Redirect "Login.asp"
		end if
	end if
end sub

sub PrintErrorPage(Title, Message)
  %><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title><%= Title %></title>
<link rel="stylesheet" type="text/css" href="PP_Web.css">
</head>
<body bgcolor="#FFCACB">
	<h2>Critical Error</h2>
	<p>The PingPlotter web interface had an error.</p>
	<p><%= Message %><p>
	<p>Error: <%= Err.Description %><br>
Source: <%= Err.Source %></p>
</body>
</html><%
	Response.Flush
  Response.End  
end sub

' ----- Str To Long function -----------------------
' Convert a string to a numeric value.  If the string isn't a number,
' then set the return value to 0.
function StrToLng(InStr)
  if IsNumeric(InStr) then
	StrToLng = CDbl(InStr)
  else
	StrToLng = 0
  end if
end function

' ----- Create List Box function -----------------------
' This is used to iterate an array (ListContents), and to set
' the "Selected" one if there is a match with MatchValue.
'
' ListContents is a 2 dimensional array...
' [ Value1 ][ Description1 ]
' [ Value2 ][ Description2 ]
function PrintListBox(ListContents, MatchValue)  ' Returns matched
  dim ArrayLoop

  PrintListBox = false
  for ArrayLoop = LBound(ListContents) to UBound(ListContents)
	Response.Write "<OPTION VALUE="&ListContents(ArrayLoop)(0)
	if ListContents(ArrayLoop)(0) = MatchValue then
	  Response.Write " SELECTED"
	  PrintListBox = true
	end if
	Response.Write ">" & ListContents(ArrayLoop)(1) & "</OPTION>"
  next
end function

' ----- Create new TraceTarget Instance -----------------------
' Set up all default variables, etc...  This creates a new target.
function GetNewTarget (PingPlotter, myDest)
	set GetNewTarget = PingPlotter.NewTarget
	GetNewTarget.TargetDescription 		= myDest
end function

' --- When passed a "PingPlotter" and a UID, return a summary graph.  If the UID
' isn't found, then return the first summary.  If there is no summary, then return
' the AllTargets summary (which should always exist), or create one.
function GetSummaryByID(PingPlotter, UID)
	dim LSummary
	set LSummary = Nothing
	
	if not IsEmpty(UID) then
		
		if (UID = "SUM-ALLTARGET") then
			if PingPlotter.SummaryGraphCount > 0 then
			  set LSummary = PingPlotter.SummaryGraphs(0)
	    end if
	  else
      on error resume next
  		set LSummary = PingPlotter.SummaryGraphByID(UID)
      on error goto 0
	  end if
	end if
	
	if ((IsObject(LSummary) and (LSummary is Nothing)) or (not IsObject(LSummary))) then
		if PingPlotter.SummaryGraphCount > 0 then
		  set LSummary = PingPlotter.SummaryGraphs(0)
    else
      set LSummary = PingPlotter.CreateNewSummaryGraph("")
    end if
	end if

	set GetSummaryByID = LSummary
end function

' --- When passed a "PingPlotter" and a UID, get a target (if the UID is specified and
' found.  If it's not found, then we'll return the 0'th index.  If it's not
' specified, then we'll, return "Nothing".
function GetTargetByID(PingPlotter, UID)

	dim LTarget
	set LTarget = Nothing

	if not IsEmpty(UID) then
    on error resume next
		set LTarget = PingPlotter.FindByID(UID)
    on error goto 0
	end if
	
	if ((IsObject(LTarget) and (LTarget is Nothing)) or (not IsObject(LTarget))) then
		dim index
		index = 0
		do while (((IsObject(LTarget) and (LTarget is Nothing)) or (not IsObject(LTarget))) and (index < (PingPlotter.TargetCount)))
			if (SettingsFilter = "") or (SettingsFilter = PingPlotter.Targets(index).SettingsName) then
  		  set LTarget = PingPlotter.Targets(index)
  		end if
  		index = index + 1
	  Loop
	  
  	if ((IsObject(LTarget) and (LTarget is Nothing)) or (not IsObject(LTarget))) then
      set LTarget = PingPlotter.NewTarget
    end if
	end if

	set GetTargetByID = LTarget
	
end function

function Session_OnStart
end function

function Session_OnEnd
end function

%>

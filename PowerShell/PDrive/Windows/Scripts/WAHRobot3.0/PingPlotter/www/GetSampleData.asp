<% Option Explicit
%><!--#include file="HelperFunctions.asp"--><%

if (UserName > "") and (PingPlotter.HasWebAccess(UserName, UserPassword) = 0) then
	' Didn't get logged in right.
	Session("Login Error") = "Username / password combination not correct or doesn't have access"
	Response.Redirect "Login.asp"
end if

EnsureLoggedIn()

' This routine will download the .pp2 data file
Response.Buffer = True

' PingPlotter object is defined by HelperFunctions
Dim ID, strFile

ID = Variable("ID")
if IsEmpty(ID) then
  ID = PingPlotter.Targets(0).UniqueID
end if


if IsEmpty(ID) then
  Response.Write "Must specify a Ping Plotter Session"
else

  dim TraceTarget
  set TraceTarget = PingPlotter.FindByID(ID)

  if (TraceTarget is Nothing) then
    set TraceTarget = PingPlotter.Targets(0)
  end if

'  set PingPlotter = Server.CreateObject("pingplotter.PingPlotter_Engine")
 
  if (TraceTarget is Nothing) then
    Response.Write "Invalid Session ID (Could possibly return a cached file here...)"
  else
    ' Got a trace object...
		
		' add the header with the download file's name	
    dim FileName
    FileName = Server.URLEncode(TraceTarget.TargetDescription) & ".pp2"

    Response.ContentType = "application/pp2; charset=utf-8"

    If InStr(Request.ServerVariables("HTTP_USER_AGENT"), "MSIE") Then 'Internet Explorer
        Response.AddHeader "Content-Disposition", "attachment; filename=""" & FileName & """"
    Else ' Not Internet Explorer
        'According to RFC 2231 @ http://tools.ietf.org/html/rfc2231#section-3
        Response.AddHeader "Content-Disposition", "attachment; filename*=UTF-8''" & FileName 
    End If
	  Response.BinaryWrite( TraceTarget.SaveFileData )
  end if
end if

%>

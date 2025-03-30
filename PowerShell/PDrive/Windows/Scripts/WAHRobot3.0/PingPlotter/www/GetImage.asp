<%
Option Explicit
%><!--#include file="HelperFunctions.asp"--><%

if (UserName > "") and (PingPlotter.HasWebAccess(UserName, UserPassword) = 0) then
	' Didn't get logged in right.
	Session("Login Error") = "Username / password combination not correct or doesn't have access"
	Response.Redirect "Login.asp"
end if

' This routine can be pointed to instead of an image file.  This will load a dynamic image
' from PingPlotter each time its called.  This causes more load than if the server just 
' had files, so be a big cautious about overuser.

EnsureLoggedIn()

Response.Buffer = True

Dim ID, strFile, IsSummary

' PingPlotter object is defined by HelperFunctions

ID = Variable("ID")
IsSummary = (Variable("Summary") > "")

if IsEmpty(ID) then
  Response.Write "Must specify a PingPlotter Session"
else

  dim ImageVar
	
  if (Left(UCase(ID),4) = "SUM-") and (not IsSummary) then
  	
  	dim SummaryGraph
  	set SummaryGraph = PingPlotter.SummaryGraphByID(ID)
  	
	  if (SummaryGraph is Nothing) then
	   	Response.Write "Invalid Session ID (Probably querying for an old object, but browser doesn't know it!)"
	  else
    	SummaryGraph.TimeGraphHeight = 85
  	  ImageVar = SummaryGraph.Image("PNG")
  	  Response.BinaryWrite ImageVar
      Response.ContentType = "image/png"
	  end if
  	
	else
		
		dim TraceTarget
		  	
  	if (IsSummary) then
			set TraceTarget = PingPlotter.SummaryGraphByID(Variable("Summary"))
		  if (TraceTarget is Nothing) then
	    	Response.Write "Invalid Session ID (Probably querying for an old object, but browser doesn't know it!)"
		  end if
  	else
			set TraceTarget = PingPlotter.FindByID(ID)		
		  if (TraceTarget is Nothing) then
	    	Response.Write "Invalid Session ID (Probably querying for an old object, but browser doesn't know it!)"
	  	elseif (TraceTarget.SampleCount = 0) then
		  	Response.Write "No samples in target of specified ID.  Target probably closed but Browser doesn't know it!"
		  	set TraceTarget = Nothing
		  end if
		end if
		
		if (not (TraceTarget is Nothing)) then
			
			' Check to see if it's a two part ID, in which case this is just a graph for a hop
			if (InStr(ID, "-HST")) then
		  	dim CurRoute, CurHost
		  	
		  	if (IsSummary) then
		  	  set CurRoute = TraceTarget
		  	else
	  			set CurRoute = TraceTarget.CollectingHostList
	  		end if
	  		set CurHost = CurRoute.HostByID(ID)
	  		
	  		if (IsObject(CurHost)) and (not (CurHost is Nothing)) then
			    dim Height, Width, BackgroundColor
			    
			    Height = Variable("Height")
			    Width = Variable("Width")
			    BackgroundColor = Variable("Color")
			    
			    if (not IsNumeric(Height)) then
			    	Height = 85
			    end if
			    
			    if (not IsNumeric(Width)) then
			    	Width = 500
			    end if
			    
			    if (IsEmpty(BackgroundColor)) then
			    	BackgroundColor = ""
			    end if
			    
			    ImageVar = CurHost.TimeGraphImage(CLng(Height), CLng(Width), "PNG", BackgroundColor)
			    Response.Clear
			    Response.BinaryWrite ImageVar
			    Response.ContentType = "image/png"
			  else
	    		Response.Write "Invalid Session ID (Probably querying for an old object, but browser doesn't know it!)"
			  end if
			else
		  	
		    ' Got a trace object...
				TraceTarget.Graph.TimeGraphHeight = 85
		
		    ' add the header with the download file's name
		'    Response.AddHeader "Content-Disposition:attachment; filename="& TraceTarget.TargetDescription &".png"
		
		    ImageVar = TraceTarget.Graph.Image("PNG")
		    Response.Clear
		    Response.BinaryWrite ImageVar
		    Response.ContentType = "image/png"
		    
		  end if 
	  end if
	end if
end if  %>
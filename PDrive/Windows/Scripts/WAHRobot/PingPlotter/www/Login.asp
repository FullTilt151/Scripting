<% Option Explicit %><!--#include file="HelperFunctions.asp"--><%

  ' Always clear out everything when we come in here
	Session("loggedIn") = ""
	Session("UserName") = ""
	Session("UserPassword") = ""
	SetCookieValue "UserName", ""
	SetCookieValue "UserPassword", ""
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>PingPlotter Pro - Login</title>
<link rel="stylesheet" type="text/css" href="PP_Web.css">
</script>
<html>
<body>

<center>

<table cellspacing="0" cellpadding="0" height="15" 	class="login-background">
  <tr>
  	<td>
  			<div class="topline1"></div>
	<div class="toplogo">
	    <a href="http://www.pingplotterpro.com/" target="_blank"><img class="login-logo" border="0" src="./images/logo_pingplotter_head.png"></a>
	</div>
	</td>
</tr>
<tr>
	<br>
    <td width="100%" height="13" >
      <form method="POST" action="./" >
      	<br>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
          <tr>
            <td width="100%" colspan="2">
          </tr>
          <tr>
            <td width="46%"></td>
            <td width="54%"></td>
          </tr>
          <% if (Session("LoginError") > "") then %>
            <tr>
            	<td colspan=2><span class='loginerror'><%=Session("LoginError") %></span></td>
            </tr>
        	<%   Session("LoginError") = "" %>
        	<% end if %>
          <tr>
            <td width="46%" align="right">Login :&nbsp; </td>
            <td width="54%" align="left"><input type="text" name="txtLoginId" size="23" value=""></td>
          </tr>
          <tr>
            <td width="46%" align="right">Password :&nbsp; </td>
            <td width="54%" align="left"><input type="password" name="txtLoginPasswd" size="23" value=""></td>
          </tr>
          <tr>
            <td width="46%" align="right">Remember Password :&nbsp; </td>
            <td width="54%" align="left"><input type="checkbox" name="chkRemPasswd" value="ON" ></td>
          </tr>
          <tr>
            <td width="46%" height="20"></td>
            <td width="54%" height="20"><input type="hidden" name="cbFromLoginForm" value="1" /></td>
          </tr>
          <tr>
            <td width="46%"></td>
            <td width="54%"><input type="submit" value="Submit" name="cmdSubmit">&nbsp;
              <input type="reset" value="Reset" name="cmdReset></td>
          </tr>
          <tr>
            <td width="46%"></td>
            <td width="54%"></td>
          </tr>
        </table>
      </form>
    </td>
  </tr>
  <tr><td><div class="Copyright">
<a target="_blank" href="http://www.nessoft.com">Copyright (C) 1998, 2015 Pingman Tools, LLC</a>
</div></td></tr>
</table>
</center>

</body>

</html>

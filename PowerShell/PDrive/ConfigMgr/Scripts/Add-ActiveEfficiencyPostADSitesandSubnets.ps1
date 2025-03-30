# Copyright © 1E LTD 2012

# All rights reserved. No part of this document or of the software (“the software”) 
# to which it relates shall be reproduced, adapted, stored in a retrieval system, 
# or transmitted by any means, electronic, mechanical, photocopying, recording, or 
# otherwise, without permission from 1E Ltd. It is the responsibility of the user 
# to use the software in accordance with this document and 1E Ltd shall not be 
# responsible if the user fails to do so. Although every precaution has been taken 
# in the preparation of this document, 1E Ltd and the authors assume no responsibility 
# for errors or omissions, nor shall they be liable for damages resulting from any 
# information in it.

# Your use of these items is at your sole risk.  All items are provided 
# "as-is", without any warranty, whether express or implied, of accuracy, 
# completeness, fitness for a particular purpose, title or non-infringement, 
# and none of the items are supported or guaranteed by 1E.  1E shall not be 
# liable for any damages you may sustain by using these items, whether direct, 
# indirect, special, incidental or consequential, even if it has been advised 
# of the possibility of such damages.

# Overview:
# This software is provided free of charge with no formal support provided by 1E.  
# If you find any problems with this product please email support@1e.com detailing 
# the problem and we will make best endeavours to fix.

function DeleteAllLocations()
{
    param(
        [string] $target = $null
    )

    $webRequest = [System.Net.WebRequest]::Create($target)
    $webRequest.ContentType = "application/json"
    $webRequest.Accept = "application/json"
    $webrequest.ContentLength = $postStr.Length
    $webRequest.ServicePoint.Expect100Continue = $false

    $webRequest.PreAuthenticate = $true
    $webRequest.Method = "DELETE"

    [string] $result;

    [System.Net.WebResponse] $response;
    try
    {
        $response = $webRequest.GetResponse();
        $rs = $response.GetResponseStream();
        [System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs;
        $result = $sr.ReadToEnd();
    }
    catch [System.Net.WebException]
    {
	$_.Exception
#        throw $_.Exception

    }

    return $result;

}

function AddLocation() 
{
    param(
        [string] $target = $null,
	[string] $location = $null

    )

    $webRequest = [System.Net.WebRequest]::Create($target)
    $webRequest.ContentType = "application/json"
    $webRequest.Accept = "application/json"
    $postStr = [System.Text.Encoding]::UTF8.GetBytes($location)
    $webrequest.ContentLength = $postStr.Length
    $webRequest.ServicePoint.Expect100Continue = $false

    $webRequest.PreAuthenticate = $true
    $webRequest.Method = "POST"

    $requestStream = $webRequest.GetRequestStream()

    try
    {
    	$requestStream.Write($postStr, 0,$postStr.length)
    }
    finally
    {
        $requestStream.Close()
    }

    [string] $result;

    [System.Net.WebResponse] $response;
    try
    {
        $response = $webRequest.GetResponse();
        $rs = $response.GetResponseStream();
        [System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs;
        $result = $sr.ReadToEnd();
    }
    catch [System.Net.WebException]
    {
	$_.Exception
#        throw $_.Exception

    }

    return $result;
}

function PostADSitesandSubnets()
{
    param(
        [string] $target = $null
    )
    
    $strFilter = "(&(objectCategory=subnet))";

    $rootDomain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://RootDSE");

    $objDomain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://cn=Subnets,cn=Sites," + $rootDomain.Properties["configurationNamingCOntext"].Value);

    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    
    $objSearcher.SearchRoot = $objDomain
    $objSearcher.PageSize = 500
    $objSearcher.Filter = $strFilter
    $objSearcher.SearchScope = "Subtree"

    
    $objSearcher.PropertiesToLoad.Add("cn");
    $objSearcher.PropertiesToLoad.Add("siteobject");

    $colResults = $objSearcher.FindAll();

    foreach ($objResult in $colResults)
    {
    	 $objItem = $objResult.Properties         
         $siteString = $objItem.siteobject | Out-String

	 $post = '{"Site":"' + $siteString.Split(",")[0].Substring(3) + '","Subnet":"' + $objItem.cn + '"}'
	 AddLocation $target $post
    }

}

$url = "http://ActiveEfficiency.humana.com/ActiveEfficiency/Locations";

DeleteAllLocations $url
PostADSitesandSubnets $url
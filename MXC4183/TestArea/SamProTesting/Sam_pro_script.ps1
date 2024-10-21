Param(
   [string]$properties
)

$uri = "https://$computer/AdminService/wmi/SMS_Collection"

# Import SCCM module
Import-Module "$executingScriptDirectory\SCCMSpoke\SCCMMain" -DisableNameChecking; #Not sure what this is. Some SN thing I guess

# Copy the environment variables to their parameters. More SN stuff, again not really sure what is getting passed into that var.
if (test-path env:\SNC_properties) {
  $properties = $env:SNC_properties;
}

SNCLog-ParameterInfo @("Running GetDeviceCollections", $properties);

function Get-DeviceCollections() {
   # Import-Module -Name "$(split-path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1";
   # Set-Location -path "$(Get-PSDrive -PSProvider CMSite):\";

   #getting list of all properties associated with device collections
   $allPropsArray = @();

   # Gather all collection information
   $Collections = ((Invoke-RestMethod -Method 'Get' -Uri $uri -Credential $creds).value).where({$_.ObjectPath -eq '/Software Reclamation'})

   # Get-CMDeviceCollection | Select * | ForEach-Object {
   $Collections | ForEach-Object {
      $_ | Get-Member -MemberType "NoteProperty" | Select-Object "Name" | ForEach-Object {
         $allPropsArray += $_.name;
      }
   }

   #the array with list of properties displayed by default
   $searchFilterDefault =  "Name,CollectionID,CollectionType,LocalMemberCount,MemberCount";
   $defaultFilterArray  = $searchFilterDefault -split ",";

   #the array with additional properties taken from input
   $properties = $args[0];
   $additionalFilterArray = $properties -split ",";

   $resultArray = @();

   if($properties -eq "" -or $properties -eq $null) {
      $searchFilterArray = $defaultFilterArray;
   } else {
      #concatenate default and valid input properties arrays
      $searchFilterArray = $defaultFilterArray + $additionalFilterArray | Select-Object -Unique;
   }

   $Collections | Select-Object $searchFilterArray | ForEach-Object {
      $collectionInfo = @{};
      $collection = $_;

      $collection | Get-Member -MemberType Properties | ForEach-Object {
         $key = $_.name;
         if($allPropsArray.Contains($key)) {
            $collectionInfo.Add($key, $collection.$key);
        } else {
            return "invalid property";
         }
      }

      $resultArray += $collectionInfo;
   }

   ConvertTo-Json $resultArray;
}

function Get-AllDeviceCollections() {
   # Import-Module -Name "$(split-path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1";
   # Set-Location -path "$(Get-PSDrive -PSProvider CMSite):\";

   $resultArray = @();

   # Gather all collection information
   $Collections = ((Invoke-RestMethod -Method 'Get' -Uri $uri -Credential $creds).value).where({$_.ObjectPath -eq '/Software Reclamation'})

   #Get-CMDeviceCollection 
   $Collections | ForEach-Object {
      $collectionInfo = @{};
      $collection = $_;

      $collection | Get-Member -MemberType Properties  | ForEach-Object {
         $key = $_.name;
         $collectionInfo.Add($key, $collection.$key);
      }
         
      $resultArray += $collectionInfo;
   }
   ConvertTo-Json $resultArray;
}

try {
    # $session = Create-PSSession -sccmServerName $computer -credential $cred;

   if($properties -match "^[a-zA-Z,*?\[\]\-_]+$" -or $properties -eq "" -or $properties -eq $null -and  $properties -ne "*") {
      SNCLog-DebugInfo "`tInvoking Invoke-Command -ScriptBlock `$'{function:Get-DeviceCollections}' -ArgumentList $properties";
      Invoke-Command -ScriptBlock ${function:Get-DeviceCollections} -ArgumentList $properties;
   } elseif($properties -eq "*") {
      SNCLog-DebugInfo "`tInvoking Invoke-Command -ScriptBlock `$'{function:Get-AllDeviceCollections}' -ArgumentList $properties";
      Invoke-Command -ScriptBlock ${function:Get-AllDeviceCollections} -ArgumentList $properties;
   } else {
      Write-Host "invalid chars in property";
   }
} catch {
    Write-Host $error
} <#finally {
    if($session -ne $null) {
        Remove-PSSession -session $session
    } 
} #>
Invoke-Command -ScriptBlock {(Get-ChildItem Env:\Path).value}  -ComputerName WKR90SZM24 | Format-table


[cmdletbinding()]            
param(            
 [string[]]$ComputerName =$env:ComputerName,            
 [string]$Name            
)            
            
foreach($Computer in $ComputerName) {            
 Write-Verbose "Working on $Computer"            
 if(!(Test-Connection -ComputerName $Computer -Count 1 -quiet)) {            
  Write-Verbose "$Computer is not online"            
  Continue            
 }            
             
 try {            
  $EnvObj = @(Get-WMIObject -Class Win32_Environment -ComputerName $Computer -EA Stop)            
  if(!$EnvObj) {            
   Write-Verbose "$Computer returned empty list of environment variables"            
   Continue            
  }            
  Write-Verbose "Successfully queried $Computer"            
              
  if($Name) {            
   Write-Verbose "Looking for environment variable with the name $name"            
   $Env = $EnvObj | Where-Object {$_.Name -eq $Name}            
   if(!$Env) {            
    Write-Verbose "$Computer has no environment variable with name $Name"            
    Continue            
   }            
   $Env               
  } else {            
   Write-Verbose "No environment variable specified. Listing all"            
   $EnvObj            
  }            
              
 } catch {            
  Write-Verbose "Error occurred while querying $Computer. $_"            
  Continue            
 }            
            
}


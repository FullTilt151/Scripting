# All setting written to
# C:\Windows\System32\inetsrv\config\applicationHost.config

# add Authoring Rule WebDav
“c:\windows\system32\inetsrv\appcmd.exe set config “”Default Web Site/”" /section:system.webServer/webdav/authoringRules /”"+[users='*',path='*',access='Read']“” /commit:apphost” | Invoke-Expression

# allow Hidden Files WebDav
“c:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/webdav/authoring /fileSystem.allowHiddenFiles:true /commit:apphost” | Invoke-Expression

# allow Anonymous Property Find WebDav
“c:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/webdav/authoring /properties.allowAnonymousPropfind:true /commit:apphost” | Invoke-Expression

# DON’T allow Custom Properties WebDav
“c:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/webdav/authoring /properties.allowCustomProperties:false /commit:apphost” | Invoke-Expression

# allow Infinite Property Depth Find WebDav
“c:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/webdav/authoring /properties.allowInfinitePropfindDepth:true /commit:apphost” | Invoke-Expression

# DON’T allow Hidden Segment Filtering WebDav
“c:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /hiddenSegments.applyToWebDAV:false /commit:apphost” | Invoke-Expression

# Allow double-escaping
"c:\windows\system32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestfiltering /allowdoubleescaping:true /commit:apphost" | Invoke-Expression

# Remove all Hidden Segments
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='bin']"" /commit:apphost" | Invoke-Expression
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='web.config']"" /commit:apphost" | Invoke-Expression
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='App_code']"" /commit:apphost" | Invoke-Expression
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='App_GlobalResources']"" /commit:apphost" | Invoke-Expression
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='App_LocalResources']"" /commit:apphost" | Invoke-Expression
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='App_WebReferences']"" /commit:apphost" | Invoke-Expression
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='App_Data']"" /commit:apphost" | Invoke-Expression
"C:\Windows\System32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /""-hiddenSegments.[segment='App_Browsers']"" /commit:apphost" | Invoke-Expression

# Allow all file extensions
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.asa']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.asa']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.asax']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.ascx']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.master']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.skin']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.browser']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.sitemap']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.config']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.cs']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.csproj']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.vb']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.vbproj']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.webinfo']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.licx']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.resx']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.resources']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.mdb']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.vjsproj']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.java']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.jsl']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.ldb']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.dsdgm']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.ssdgm']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.lsad']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.ssmap']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.cd']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.dsprototype']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.lsaprototype']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.sdm']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.sdmDocument']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.mdf']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.ldf']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.ad']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.dd']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.ldd']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.sd']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.adprototype']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.lddprototype']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.exclude']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.refresh']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.compiled']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.msgx']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.vsdisco']"
cmd /c "c:\windows\System32\InetSrv\appcmd.exe set config ""Default Web Site/"" /section:system.webServer/security/requestFiltering /-fileExtensions.[fileExtension='.rules']"

# Disable app filtering
New-ItemProperty -Path ${HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ASP.NET} -Name StopProtectedDirectoryFiltering -Value 1 -PropertyType DWORD -Force
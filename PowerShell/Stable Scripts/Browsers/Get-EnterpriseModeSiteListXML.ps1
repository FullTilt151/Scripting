[xml]$xml1 = ([xml]((invoke-webrequest -Uri http://iesitelist.humana.com:81/ieem-win10.xml).content) | Select-Object -ExpandProperty innerxml)
$table1 = ([xml]$xml1 | Select-Object Childnodes).Childnodes.site
$table1 | Where-Object {$_.{open-in} -eq 'MSEdge' -or $_.{open-in}.'#text' -eq 'MSEdge'} | Format-Table -AutoSize

[xml]$xml2 = ([xml]((invoke-webrequest -Uri http://iesitelist.humana.com:81/ieem-win10-test.xml).content) | Select-Object -ExpandProperty innerxml)
$table2 = ([xml]$xml2 | Select-Object Childnodes).Childnodes.site
$table2 | Where-Object {$_.{open-in} -eq 'MSEdge' -or $_.{open-in}.'#text' -eq 'MSEdge'}
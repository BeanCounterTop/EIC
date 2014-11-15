$string = 'LyncFEHostname'
Get-ChildItem c:\eic\deploy\*.xml | get-content | %{$_ | select-string -Pattern $String }

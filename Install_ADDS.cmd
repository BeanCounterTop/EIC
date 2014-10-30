powershell.exe set-executionpolicy bypass -force
if not exist c:\deploy d:\_runmefirst.cmd
powershell -noexit -file c:\deploy\setup.ps1 -flow adds
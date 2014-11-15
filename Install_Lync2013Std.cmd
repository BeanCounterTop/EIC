powershell.exe set-executionpolicy bypass -force
schtasks.exe /CREATE /F /RU "BUILTIN\users" /SC ONLOGON /RL HIGHEST /TN "EIC" /tr "powershell.exe -noexit -file c:\deploy\Setup.ps1"
powershell -noexit -file .\setup.ps1 -flow Lync2013Std
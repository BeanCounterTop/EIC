powershell.exe set-executionpolicy bypass -force
powershell -noexit -ex bypass .\setup.ps1 -Flow SPPost

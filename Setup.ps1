param($Flow)

schtasks.exe /CREATE /RU "BUILTIN\users" /SC ONLOGON /RL HIGHEST /TN "EIC" /tr "powershell.exe -noexit -file c:\deploy\Setup.ps1" /F
$ScriptPath = "c:\deploy"
Start-Transcript -Path "c:\users\public\Desktop\Transcript$(get-date -Format yyyyMMdd.hhmm).txt"
if (test-path c:\deploy) {set-location c:\deploy} else {set-location c:\eic\deploy -ErrorAction Stop}

[xml]$XML = Get-Content ".\Settings.xml" 
$ConfigNode = $XML | Select-XML -XPath "//Configuration/Parameters/*"
$ConfigNode | % { $_.Node.ChildNodes.Name | % { Set-Variable $_ -Value ($xml.SelectSingleNode("//$_").innertext) -Scope Script } }

$XML.Configuration.Hosts.ChildNodes | % { Set-Variable $_.Name -Value $_ -Scope Script }
    
$DerivedParameters = $xml | Select-XML -XPath "//Configuration/DerivedParameters" 
$DerivedParameters | % { $_.Node.ChildNodes.Name | %{ Set-Variable $_ -Value (& ([scriptblock]::create("$($xml.SelectSingleNode(""//$_"").innertext)"))) -Scope Script -Force }}
    
$FunctionNodes = Select-Xml -XPath "//Configuration/Functions/*" -xml $XML
$FunctionNodes.node.ChildNodes | % {invoke-expression ". $($_.innertext)"}

if (-NOT (Test-Path $AutoSPInstallerXMLFile)) {
    $AutoSPInstallerNode = $xml.Configuration.AutoSPInstallerXML.Configuration
    $AutoSPInstallerXML=New-Object System.XML.XMLDocument
    $ImportNode = $AutoSPInstallerXML.ImportNode($AutoSPInstallerNode,$True)
    $AutoSPInstallerXML.AppendChild($ImportNode)
    $AutoSPInstallerXML.save($AutoSPInstallerXMLFile)
    }

if (-NOT (Test-Path $TopologyFile)) {
    $LyncTopologyNode = $xml.Configuration.LyncTopology.FirstChild
    $LyncTopologyXML = New-Object System.XML.XMLDocument
    $ImportNode = $LyncTopologyXML.ImportNode($LyncTopologyNode,$True)
    $LyncTopologyXML.AppendChild($ImportNode)
    $LyncTopologyXML.save($TopologyFile)
    }

ValidateParameters

if (Test-Path $StepFile) {
    [int]$Step = Get-Content $StepFile
    } else {
    $Step = 0
    }
$Step++; $Step | Out-File $StepFile -Force

if (test-path $FlowFile) { 
    $Flow = Get-Content $FlowFile
    } ELSE {
    $Flow | out-file $FlowFile
    }
Write-Host "Flow: $flow"
Write-host "Step: $step"
if (Test-Path $SharepointModule) {. $SharepointModule}

$FlowNodes = Select-Xml -XPath "//Configuration/Flows" -xml $XML
if (($FlowNodes.node.ChildNodes.Name -match "$Flow")) { 
    $FlowNode = $FlowNodes.node.ChildNodes | ? Name -match $Flow
    if (-NOT $FlowNode) { 
        Throw "Error getting flow node: $Flow" 
        }
    } ELSE {
    Throw "No flow found matching: $Flow"
    }

$Command = $FlowNode.Childnodes | ? Order -eq $Step | Select -ExpandProperty Command
Invoke-Expression $Command

if (!($Error[0])) {
    Restart-Computer -Force
    } else {
    Write-Host "Errors!"; 
    $Error | Select-Object * | Out-File c:\errors.txt -Append; 
    notepad.exe c:\errors.txt
    }







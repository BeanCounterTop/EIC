$JiveUrl = "http://jiveit-c6-64-1.eng.jiveland.com:8080/admin"


$LoginContent = Invoke-WebRequest -Uri $JiveUrl -SessionVariable Session
$LoginContent.Forms[0].Fields.Add("username","admin")
$LoginContent.Forms[0].Fields.Add("password","admin")
Invoke-Webrequest -Uri "$JiveUrl/$($LoginContent.Forms[0].Action)" -WebSession $Session -Body $LoginContent.Forms[0].fields -Method Post


Function AddProperty ($PropertyName, $PropertyValue, $JiveUrl) {
    $Content = Invoke-WebRequest -Uri "$JiveUrl/system-properties.jsp" -WebSession $Session
    $SubmitForm = $Content.Forms[(($content.Forms.count) - 1)]
    $SubmitForm.Fields.Add("propName",$PropertyName)
    $SubmitForm.Fields.Add("propValue",$PropertyValue)
    $SubmitForm.Fields.Remove("newPropName")
    $SubmitForm.Fields.Remove("cancel")
    Invoke-WebRequest -Uri "$JiveUrl/system-properties.jsp" -Method Post -Body $SubmitForm.Fields -WebSession $Session
    }

 $Properties = @{
  "extended-apis.im.enabled"="true"
  "extended-apis.im.visible" = "true"
  "ediscovery.enabled" = "true"
  "jive.module.event.enabled" = "true"
  "jive.module.ideas.enabled" = "true"
  "extended-apis.office.enabled" = "true"
  "extended-apis.office.visible" = "true"
  "extended-apis.outlook.enabled" = "true"
  "extended-apis.outlook.visible" = "true"
  "jive.feature.projects.disabled" = "false"
  "__jive.extension.global-registry.edition" = "cloud.200"
  "extended-apis.sharepoint.enabled" = "true"
  "extended-apis.sharepoint.visible" = "true"
  "jive.module.antivirus.enabled" = "true"
  "freeeeow" = "true"
  }

  Foreach ($Property in $Properties.Keys) {
    Write-host $Property
    AddProperty $Property $Properties.$Property $JiveUrl 
    }
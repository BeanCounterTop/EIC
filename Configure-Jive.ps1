$JiveHost = "10.10.100.110"
$jiveurl = "http://$jivehost`:8080/admin"
$SSHUsername = "root"
$SSHPassword = "Abc123!"
$WebUsername = "admin"
$WebPassword = "admin"

$Credential = New-Object System.Management.Automation.PSCredential ($SSHUsername, (ConvertTo-SecureString $SSHPassword -AsPlainText -Force))
$SSHSession = New-SSHSession -ComputerName $JiveHost -Credential $Credential

$LoginContent = Invoke-WebRequest -Uri $JiveUrl -SessionVariable Session
$LoginContent.Forms[0].Fields.Add("username",$WebUsername)
$LoginContent.Forms[0].Fields.Add("password",$WebPassword)
Invoke-Webrequest -Uri "$JiveUrl/$($LoginContent.Forms[0].Action)" -WebSession $Session -Body $LoginContent.Forms[0].fields -Method Post


Function AddSystemProperty ($PropertyName, $PropertyValue, $JiveUrl) {
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
  }

  Foreach ($Property in $Properties.Keys) {
    Write-host $Property
    AddSystemProperty $Property $Properties.$Property $JiveUrl 
    }






$Configure1 = @"
yum -y install libXdmcp sysstat & \
sed -i '/ONBOOT/s/no/yes/i' /etc/sysconfig/network-scripts/ifcfg-eth0 & \
mkdir /mnt/cdrom
mount /dev/cdrom /mnt/cdrom
rpm -ihv /mnt/cdrom/jive_sbs_employee-7.0.2.1.RHEL-6.x86_64.rpm & \
echo jive    soft    nofile  100000 >> /etc/security/limits.conf & \
echo jive    hard    nofile  200000 >> /etc/security/limits.conf & \
echo net.core.rmem_max = 16777216 >> /etc/sysctl.conf & \
echo net.core.wmem_max = 16777216 >> /etc/sysctl.conf & \
echo net.ipv4.tcp_wmem = 4096 65536 16777216 >> /etc/sysctl.conf & \
echo net.ipv4.tcp_rmem = 4096 87380 16777216 >> /etc/sysctl.conf
"@

$Configure2 = @'
wget http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-centos91-9.1-4.noarch.rpm & \
rpm -ivh pgdg-centos91-9.1-4.noarch.rpm & \
yum -y install postgresql91-server & \
service postgresql-9.1 initdb & \
sed -i '/^local *all *all *peer$/s/[^ \t]*$/ident/' /var/lib/pgsql/9.1/data/pg_hba.conf & \
sed -i '/^host *all *all .*ident$/s/[^ \t]*$/md5/' /var/lib/pgsql/9.1/data/pg_hba.conf & \
service postgresql-9.1 start
chkconfig postgresql-9.1 on
@'

$Configure3 = @'
su - postgres -c '\
psql
create user core with password 'core';
create database core owner core encoding 'UTF-8';
create user eae with password 'eae';
create database eae owner eae encoding 'UTF-8';
\q
'
'@

$Configure4 = @'
openssl req -x509 -nodes -days 365 -subj '/C=US/ST=OR/L=Portland/O=Jive/CN=jivetest'  -newkey rsa:2048 -keyout /usr/local/jive/etc/httpd/ssl/jive.key -out /usr/local/jive/etc/httpd/ssl/jive.crt & \
/usr/local/jive/java/jre/bin/keytool -import -alias jiveCert -file /usr/local/jive/etc/httpd/ssl/jive.crt -keystore /usr/local/jive/java/jre/lib/security/cacerts -storepass changeit -noprompt & \
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8443 & \
iptables -A INPUT -m state --state NEW -m tcp --dport 8080 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp --dport 8443 -j ACCEPT
iptables-save > /etc/sysconfig/iptables & \
'@

$Configure5 = @'
su - jive -c ' \
jive enable cache & \
jive enable eae & \
jive enable webapp & \
jive enable httpd & \
jive enable search & \
jive enable ingress-replicator & \
jive set cache.hostnames $(ip addr show eth0 | grep inet\ | awk '{print $2}' | cut -d/ -f1) & \
jive setup & \
jive start
'@

$Configure6 = @'
su - jive -c '\
jive set httpd.ssl_enabled True & \
jive set httpd.ssl_certificate_file /usr/local/jive/etc/httpd/ssl/jive.crt & \
jive set httpd.ssl_certificate_key_file /usr/local/jive/etc/httpd/ssl/jive.key & \
jive set webapp.http_proxy_scheme https  & \
jive set webapp.http_proxy_port 443 & \
sleep 5 & \
jive restart'
'@

Invoke-SSHCommand -SSHSession $SSHSession -Command $Configure5






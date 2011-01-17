maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures the apache2 webserver"
version          "0.0.1"

provides "web_apache_enable_vhost(fqdn)"

recipe "web_apache::default", "Runs web_apache::install_apache."
recipe "web_apache::install_apache", "Install and configure Apache2 webserver."
recipe "web_apache::enable_site_vhost", "Creates and enables a new virtual host for the supplied fully qualified domain name (FQDN)"
recipe "web_apache::configure_ssl_reverse_proxy","Sets Apache up as a reverse proxy for ssl"

supports "ubuntu"

depends "apache2"
depends "aws"
depends "rs_utils"

attribute "web_apache",
  :display_name => "apache hash",
  :description => "Apache Web Server",
  :type => "hash"

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["web_apache::configure_ssl_reverse_proxy"],
  :required => "required"

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["web_apache::configure_ssl_reverse_proxy"],
  :required => "required"

attribute "rs_utils/process_list",
  :display_name => "Process List",
  :description => "A optional list of additional processes to monitor in the RightScale Dashboard.  Ex: sshd crond",
  :required => "optional",
  :default => "",
  :recipes => [ "web_apache::install_apache" ]
  
attribute "web_apache/contact",
  :display_name => "Contact Email",
  :description => "The email address that Apache uses to send administrative mail (set in /etc/httpd/conf/httpd.conf).  By setting it to root@localhost.com emails are saved on the server.  You can use your own email address, but your spam filters might block them because reverse DNS lookup will show a mismatch between EC2 and your domain.",
  :recipes => ["web_apache::install_apache", "web_apache::default"],
  :default => "root@localhost"

attribute "web_apache/mpm",
  :display_name => "Multi-Processing Module",
  :description => "Can be set to 'worker' or 'prefork' and defines the setting in httpd.conf.  Use 'worker' for Rails/Tomcat/Standalone frontends and 'prefork' for PHP.",
  :recipes => [ "web_apache::install_apache", "web_apache::default" ],
  :choice => [ "worker", "prefork" ],
  :default =>  "worker"

attribute "web_apache/vhost_fqdn",
  :display_name => "VHOST FQDN",
  :description => "The fully qualified domain name (FQDN) of the new vhost to create.  Example www.apache.org",
  :required => "required",
  :recipes => ["web_apache::enable_site_vhost"]

attribute "web_apache/aliases",
  :display_name => "Apache Site Aliases",
  :description => "The possible hostname aliases (if any) for the vhost.  For instance to host the same content at www.yourdomain.com and yourdomain.com simply put \"yourdomain.com\" here.  Many values can be supplied, separated by spaces",
  :type => "array",
  :default => [],
  :required => "recommended",
  :recipes => ["web_apache::enable_site_vhost", "web_apache::configure_ssl_reverse_proxy"]

attribute "web_apache/accept_fqdn",
  :display_name => "Proxy for FQDN",
  :description => "The FQDN of a domain name which will be proxied to another server and port",
  :required => "required",
  :recipes => ["web_apache::configure_ssl_reverse_proxy"]

attribute "web_apache/dest_fqdn",
  :display_name => "Proxy Destination FQDN",
  :description => "The FQDN the server that will back the proxy, the actual source of the responses for HTTP requests.",
  :required => "required",
  :recipes => ["web_apache::configure_ssl_reverse_proxy"]

attribute "web_apache/dest_port",
  :display_name => "Proxy Port",
  :description => "The the proxy port to forward to",
  :required => "required",
  :recipes => ["web_apache::configure_ssl_reverse_proxy"]

attribute "web_apache/s3_cert_bucket",
  :display_name => "S3 Bucket",
  :description => "The S3 bucket containing site certificate and key pairs in the pkcs12 format.",
  :required => "required",
  :recipes => ["web_apache::configure_ssl_reverse_proxy"]

attribute "web_apache/pkcs12_pass",
  :display_name => "PKCS12 Cert Password",
  :description => "The password used to protect the PKCS12 file.  This password is specified when the certificate is exported from windows",
  :required => "required",
  :recipes => ["web_apache::configure_ssl_reverse_proxy"]

attribute "web_apache/proxy_http",
  :display_name => "Proxy for HTTP?",
  :description => "A boolean indicating if the proxy should listen and forward traffic on port 80 (HTTP)",
  :required => "required",
  :choice => ["true", "false"]

attribute "web_apache/force_https",
  :display_name => "Force HTTPS?",
  :description => "A boolean indicating if the proxy should redirect all requests to the destination using HTTPS.  This setting requires web_apache/proxy_http to be true.",
  :required => "required",
  :choice => ["true", "false"]
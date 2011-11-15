maintainer        "Ryan J. Geyer"
maintainer_email  "me@ryangeyer.com"
license           "Apache 2.0"
description       "Originally forked from and inspired by the opscode nginx cookbook, but subsequently tweaked and hacked to no longer represent it. https://github.com/opscode/cookbooks/tree/master/nginx"
version           "0.0.1"

recipe "nginx::install_from_package", "Installs nginx package and sets up configuration with Debian apache style with sites-enabled/sites-available"
recipe "nginx::install_from_source", "Installs nginx from source and sets up configuration with Debian apache style with sites-enabled/sites-available"
recipe "nginx::setup_ssl_reverse_proxy","Sets nginx up as a reverse proxy for ssl"
recipe "nginx::setup_stats","Configure collectd stat collection for the nginx server. Intended to work with RightScale monitoring services."
recipe "nginx::setup_server", "Only intended to be included by nginx::source and nginx::default.  Does the common configuration for any installation type."
recipe "nginx::setup_reverse_proxy","Sets nginx up as a reverse proxy for http or https"
recipe "nginx::setup_vhost","Sets up a basic vhost directory and configuration"

%w{ ubuntu debian centos rhel }.each do |os|
  supports os
end

%w{ build-essential runit rs_utils skeme utils }.each do |cb|
  depends cb
end

attribute "nginx/dir",
  :display_name => "Nginx Directory",
  :description => "Location of nginx configuration files",
  :default => "/etc/nginx",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/content_dir",
  :display_name => "Nginx Content Directory",
  :description => "Location of nginx content files",
  :default => "/var/www",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/log_dir",
  :display_name => "Nginx Log Directory",
  :description => "Location for nginx logs",
  :default => "/var/log/nginx",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/user",
  :display_name => "Nginx User",
  :description => "User nginx will run as",
  :default => "www-data",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/binary",
  :display_name => "Nginx Binary",
  :description => "Location of the nginx server binary",
  :default => "/usr/sbin/nginx",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/gzip",
  :display_name => "Nginx Gzip",
  :description => "Whether gzip is enabled",
  :default => "on",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/gzip_http_version",
  :display_name => "Nginx Gzip HTTP Version",
  :description => "Version of HTTP Gzip",
  :default => "1.0",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/gzip_comp_level",
  :display_name => "Nginx Gzip Compression Level",
  :description => "Amount of compression to use",
  :default => "2",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/gzip_proxied",
  :display_name => "Nginx Gzip Proxied",
  :description => "Whether gzip is proxied",
  :default => "any",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/gzip_types",
  :display_name => "Nginx Gzip Types",
  :description => "Supported MIME-types for gzip",
  :type => "array",
  :default => [ "text/plain", "text/html", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript" ],
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/keepalive",
  :display_name => "Nginx Keepalive",
  :description => "Whether to enable keepalive",
  :default => "on",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/keepalive_timeout",
  :display_name => "Nginx Keepalive Timeout",
  :default => "65",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/worker_processes",
  :display_name => "Nginx Worker Processes",
  :description => "Number of worker processes",
  :default => "1",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/worker_connections",
  :display_name => "Nginx Worker Connections",
  :description => "Number of connections per worker",
  :default => "1024",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/server_names_hash_bucket_size",
  :display_name => "Nginx Server Names Hash Bucket Size",
  :default => "64",
  :recipes => ["nginx::install_from_package", "nginx::install_from_source", "nginx::setup_server"]

attribute "nginx/aliases",
  :display_name => "Nginx Site Aliases",
  :description => "The possible hostname aliases (if any) for the vhost.  For instance to host the same content at www.yourdomain.com and yourdomain.com simply put \"yourdomain.com\" here.  Many values can be supplied, separated by spaces. The full syntax which Nginx supports for the server_name directive are applicable here, http://wiki.nginx.org/HttpCoreModule#server_name",
  :type => "array",
  :default => [],
  :required => "recommended",
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy", "nginx::setup_vhost"]

attribute "nginx/accept_fqdn",
  :display_name => "Proxy for FQDN",
  :description => "The FQDN of a domain name which will be proxied to another server and port",
  :required => "required",
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/dest_fqdn",
  :display_name => "Proxy Destination FQDN",
  :description => "The FQDN the server that will back the proxy, the actual source of the responses for HTTP requests.",
  :required => "required",
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/dest_port",
  :display_name => "Proxy Port",
  :description => "The the proxy port to forward to",
  :required => "optional",
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/s3_cert_bucket",
  :display_name => "S3 Bucket",
  :description => "The S3 bucket containing site certificate and key pairs in the pkcs12 format.",
  :required => "required",
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/pkcs12_pass",
  :display_name => "PKCS12 Cert Password",
  :description => "The password used to protect the PKCS12 file.  This password is specified when the certificate is exported from windows",
  :required => "required",
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/proxy_http",
  :display_name => "Proxy for HTTP?",
  :description => "A boolean indicating if the proxy should listen and forward traffic on port 80 (HTTP)",
  :required => "required",
  :choice => ["true", "false"],
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/proxy_https",
  :display_name => "Proxy for HTTPS?",
  :description => "A boolean indicating if the proxy should listen and forward traffic on port 443 (HTTPS)",
  :required => "required",
  :choice => ["true", "false"],
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/force_https",
  :display_name => "Force HTTPS?",
  :description => "A boolean indicating if the proxy should redirect all requests to the destination using HTTPS.  This setting requires nginx/proxy_http to be true.",
  :required => "required",
  :choice => ["true", "false"],
  :recipes => ["nginx::setup_ssl_reverse_proxy", "nginx::setup_server", "nginx::setup_reverse_proxy"]

attribute "nginx/vhost_fqdn",
  :display_name => "VHOST FQDN",
  :description => "The fully qualified domain name (FQDN) of the new vhost to create.  Example www.apache.org",
  :required => "required",
  :recipes => ["nginx::setup_vhost"]
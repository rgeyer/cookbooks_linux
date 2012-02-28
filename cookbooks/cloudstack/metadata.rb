maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures cloudstack"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "centos"

depends "rs_utils"
depends "sys_firewall"

recommends "db"
recommends "db_mysql"
recommends "openvpn"

recipe "cloudstack::install_cloudstack", "Installs the CloudStack binary files used for setting up the CloudStack agent and management server"
recipe "cloudstack::setup_management_server", "Sets up the CloudStack management server software"
recipe "cloudstack::setup_single_node_management_server", "Sets up a single node CloudStack management server"

attribute "cloudstack/csmanage/dbuser",
  :display_name => "CloudStack Management Database Username",
  :description => "The database username for the CloudStack Management Server DB connection",
  :required => "required",
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server"]
  
attribute "cloudstack/csmanage/dbpass",
  :display_name => "CloudStack Management Database Password",
  :description => "The database password for the CloudStack Management Server DB connection",
  :required => "required",
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/dbhost",
  :display_name => "CloudStack Management Database Hostname",
  :description => "The database hostname for the CloudStack Management Server DB connection",
  :required => "required",
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/listen_ip",
  :display_name => "CloudStack Management VPN ListenIP",
  :description => "The ip address for OpenVPN to listen on",
  :required => "required",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloustack/csmanage/vpn/subnet",
  :display_name => "CloudStack Management VPN Subnet",
  :description => "The ip subnet for OpenVPN to use",
  :required => "optional",
  :default => "176.16.1.0",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloustack/csmanage/vpn/netmask",
  :display_name => "CloudStack Management VPN Netmask",
  :description => "The ip netmask for OpenVPN to use",
  :required => "optional",
  :default => "255.255.255.0",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/hostname",
  :display_name => "CloudStack Management VPN Server Hostname",
  :description => "Used to create the client OpenVPN config files, this should be set to the remotely accessible hostname or ip address of the server",
  :required => "required",
  :recipes => ["cloudstack::setup_single_node_management_server"]
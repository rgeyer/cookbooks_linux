maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "Apache 2.0" #IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures cloudstack"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "centos"

depends "rightscale"
depends "sys_firewall"

recommends "db"
recommends "db_mysql"
recommends "openvpn"

recipe "cloudstack::install_cloudstack", "Installs the CloudStack binary files used for setting up the CloudStack agent and management server"
recipe "cloudstack::setup_management_server", "Sets up the CloudStack management server software"
recipe "cloudstack::setup_single_node_management_server", "Sets up a single node CloudStack management server"
recipe "cloudstack::do_prepare_system_vm_template","Mounts the secondary storage volume using NFS and downloads the system VM for the specified hypervisors"
recipe "cloudstack::setup_xenserver","Installs CloudStack xenserver support on a xenserver hypervisor node"

attribute "cloudstack/csmanage/version",
  :display_name => "CloudStack Management Version",
  :description => "The versin of CloudStack to install",
  :required => "required",
  :category => "CloudStack Management Server",
  :choice => ["2.2.x", "3.0.x"],
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/package_url",
  :display_name => "CloudStack Management Install Package URL",
  :description => "The full URL from which to download the CloudStack Management Server Installer",
  :required => "required",
  :category => "CloudStack Management Server",
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server", "cloudstack::install_cloudstack"]

attribute "cloudstack/csmanage/dbuser",
  :display_name => "CloudStack Management Database Username",
  :description => "The database username for the CloudStack Management Server DB connection",
  :required => "required",
  :category => "CloudStack Management Server",
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server"]
  
attribute "cloudstack/csmanage/dbpass",
  :display_name => "CloudStack Management Database Password",
  :description => "The database password for the CloudStack Management Server DB connection",
  :required => "required",
  :category => "CloudStack Management Server",
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/dbhost",
  :display_name => "CloudStack Management Database Hostname",
  :description => "The database hostname for the CloudStack Management Server DB connection",
  :required => "required",
  :category => "CloudStack Management Server",
  :recipes => ["cloudstack::setup_management_server","cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/listen_ip",
  :display_name => "CloudStack Management VPN ListenIP",
  :description => "The ip address for OpenVPN to listen on",
  :required => "required",
  :category => "CloudStack Management Server VPN",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/server/subnet",
  :display_name => "CloudStack Management VPN Subnet",
  :description => "The ip subnet for OpenVPN to use",
  :required => "optional",
  :default => "172.16.1.0",
  :category => "CloudStack Management Server VPN",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/server/netmask",
  :display_name => "CloudStack Management VPN Netmask",
  :description => "The ip netmask for OpenVPN to use",
  :required => "optional",
  :default => "255.255.255.0",
  :category => "CloudStack Management Server VPN",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/server/hostname",
  :display_name => "CloudStack Management VPN Server Hostname",
  :description => "Used to create the client OpenVPN config files, this should be set to the remotely accessible hostname or ip address of the server",
  :required => "required",
  :category => "CloudStack Management Server VPN",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/client/subnet",
  :display_name => "CloudStack Management VPN Client Subnet",
  :description => "Used to create the client OpenVPN config files, this should be set to the subnet of the local network which will connect to this server.  Example: 172.16.0.0",
  :required => "required",
  :category => "CloudStack Management Server VPN",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/vpn/client/netmask",
  :display_name => "CloudStack Management VPN Client Netmask",
  :description => "Used to create the client OpenVPN config files, this should be set to the netmask of the local network which will connect to this server.  Example: 255.255.255.0",
  :required => "required",
  :category => "CloudStack Management Server VPN",
  :recipes => ["cloudstack::setup_single_node_management_server"]

attribute "cloudstack/csmanage/system_vm/nfs_hostname",
  :display_name => "CloudStack Management System VM NFS Hostname",
  :description => "The hostname of the remote NFS server containing secondary storage",
  :required => "required",
  :category => "CloudStack Management Server System VM",
  :recipes => ["cloudstack::do_prepare_system_vm_template"]

attribute "cloudstack/csmanage/system_vm/nfs_path",
  :display_name => "CloudStack Management System VM NFS Path",
  :description => "The filesystem path to secondary storage on the remote NFS server containing secondary storage",
  :required => "required",
  :category => "CloudStack Management Server System VM",
  :recipes => ["cloudstack::do_prepare_system_vm_template"]

attribute "cloudstack/csmanage/system_vm/hypervisors",
  :display_name => "CloudStack Management System VM Hypervisors",
  :description => "A list of hypervisors to fetch a system vm template for. Possible values are (kvm, vmware, xenserver)",
  :type => "array",
  :required => "required",
  :category => "CloudStack Management Server System VM",
  :recipes => ["cloudstack::do_prepare_system_vm_template"]
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures openvpn and includes rake tasks for managing certs"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.99.2"

recipe "openvpn::default", "Does nothing"
recipe "openvpn::setup_server", "Installs and configures openvpn"
recipe "openvpn::users", "Sets up openvpn cert/configs for users data bag items"

%w{ redhat centos fedora ubuntu debian }.each do |os|
  supports os
end

depends "rs_utils"

attribute "openvpn",
  :display_name => "openvpn",
  :type => "hash"

attribute "openvpn/local",
  :display_name => "OpenVPN Local",
  :description => "Local interface (ip) to listen on",
  :default => "env:PUBLIC_IP",
  :recipes => ["openvpn::setup_server"]

attribute "openvpn/proto",
  :display_name => "OpenVPN Protocol",
  :description => "UDP or TCP",
  :default => "udp",
  :recipes => ["openvpn::setup_server"]

attribute "openvpn/type",
  :display_name => "OpenVPN Type",
  :description => "Server or server-bridge",
  :default => "server",
  :recipes => ["openvpn::setup_server"]

attribute "openvpn/subnet",
  :display_name => "OpenVPN Subnet",
  :description => "Subnet to hand out to clients",
  :default => "10.8.0.0",
  :recipes => ["openvpn::setup_server"]

attribute "openvpn/netmask",
  :display_name => "OpenVPN Netmask",
  :description => "Netmask for clients",
  :default => "255.255.0.0",
  :recipes => ["openvpn::setup_server"]

attribute "openvpn/users",
  :display_name => "OpenVPN Users",
  :description => "List of usernames or uids",
  :type => "array",
  :recipes => ["openvpn::users"]
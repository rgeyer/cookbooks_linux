default[:cloudstack][:package_url] = "http://sourceforge.net/projects/cloudstack/files/Cloudstack%202.2/2.2.14/CloudStack-2.2.14-1-rhel5.tar.gz"
default[:cloudstack][:install_dir] = "/opt/cloudstack"

default[:cloudstack][:csmanage][:vpn][:server][:subnet] = "172.16.1.0"
default[:cloudstack][:csmanage][:vpn][:server][:netmask] = "255.255.255.0"

default[:cloudstack][:csmanage][:system_vm][:download_url] = "http://download.cloud.com/releases/2.2.0/"
# We're prompting for the full path to the download in the inputs now
#default[:cloudstack]["2.2.x"][:package_url] = "http://sourceforge.net/projects/cloudstack/files/Cloudstack%202.2/2.2.14/CloudStack-2.2.14-1-rhel5.tar.gz"
#default[:cloudstack]["3.0.x"][:package_url] = "http://sourceforge.net/projects/cloudstack/files/CloudStack%20Acton/3.0.1/CloudStack-oss-3.0.1-1-rhel5.tar.gz"
default[:cloudstack][:install_dir] = "/opt/cloudstack"

default[:cloudstack][:csmanage][:vpn][:server][:subnet] = "172.16.1.0"
default[:cloudstack][:csmanage][:vpn][:server][:netmask] = "255.255.255.0"

default[:cloudstack][:csmanage][:system_vm]["2.2.x"][:download_url] = "http://download.cloud.com/releases/2.2.0/"
default[:cloudstack][:csmanage][:system_vm]["3.0.x"][:download_url] = "http://download.cloud.com/templates/acton/"

# XenServer Hypervisor bits
default[:cloudstack][:xenserver][:package_url] = "http://download.cloud.com/releases/2.2.0/xenserver-cloud-supp.tgz"
default[:cloudstack][:xenserver][:package_list] = [
  'kernel-csp-xen-2.6.32.12-0.7.1.xs5.6.100.327.170613csp.i686.rpm',
  'csp-pack-5.6.100-50867p.noarch.rpm',
  'ebtables-2.0.9-1.el5.1.xs.i386.rpm',
  'arptables-0.0.3-4.i686.rpm',
  'iptables-1.3.5-5.3.el5_4.1.1.xs26.i386.rpm',
  'iptables-ipv6-1.3.5-5.3.el5_4.1.1.xs26.i386.rpm',
  'iptables-devel-1.3.5-5.3.el5_4.1.1.xs26.i386.rpm',
  'ipset-modules-xen-2.6.32.12-0.7.1.xs5.6.100.327.170613csp-4.5-1.xs26.i686.rpm',
  'ipset-4.5-1.xs26.i686.rpm'
]
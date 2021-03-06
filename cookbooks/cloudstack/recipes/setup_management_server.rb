#
# Cookbook Name:: cloudstack
# Recipe:: setup_management_server
#
#  Copyright 2012 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

rightscale_marker :begin

include_recipe "cloudstack::install_cloudstack"

execute "Set selinux to permissive" do
  not_if "getenforce | egrep -qx 'Permissive|Disabled'"
  command "setenforce 0"
  ignore_failure true
  action :run
end

if !::File.exists?("/etc/selinux/config")
  directory "/etc/selinux" do
    owner "root"
    group "root"
    action :create
  end

  # Should probably use the opscode selinux cookbook. Maybe later
  cookbook_file "/etc/selinux/config" do
    source "config"
  end
end

execute "CS Manager Setup DB" do
  command "cloud-setup-databases #{node[:cloudstack][:csmanage][:dbuser]}:#{node[:cloudstack][:csmanage][:dbpass]}@localhost --deploy-as=root"
  not_if 'echo "show databases" | mysql | grep cloud'
end

execute "CS Manager db.properties Hack for Single-Node operation" do
  command "sed -i 's/=localhost/=#{node[:cloudstack][:csmanage][:dbhost]}/g' /etc/cloud/management/db.properties"
end

execute "Install/Setup CS Manager" do
  command "cloud-setup-management"
end

# Open up some firewall rules for the management server UI and API
if node[:sys_firewall][:enabled] == "enabled"  
  sys_firewall 8080
  sys_firewall 9090
  sys_firewall 8250
  sys_firewall 8096
end

# Mount secondary storage
# mount -t nfs servername:/nfs/share /mnt/secondary

# `/usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt -m 
# /mnt/secondary -u http://download.cloud.com/releases/2.2.0/systemvm.ova -h vmware -
# F`
# 
# `/usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt -m 
# /mnt/secondary -u http://download.cloud.com/releases/2.2.0/systemvm.qcow2.bz2 -h 
# kvm -F`
# 
# `/usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt -m 
# /mnt/secondary -u http://download.cloud.com/releases/2.2.0/systemvm.vhd.bz2 -h 
# xenserver -F`

rightscale_marker :end
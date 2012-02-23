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

include_recipe "cloudstack::install_cloudstack"

# Not sure if I need this or not
#%w{setools selinux-policy}.each do |p|
#  package p
#end

if !::File.exists?("/etc/selinux/config")
  directory "/etc/selinux" do
    user root
    group root
    action :create
  end  
  
  # Should probably use the opscode selinux cookbook. Maybe later
  cookbook_file "/etc/selinux/config" do
    source "config"    
  end
  
  # TODO: On the RS CentOS RightImage, all that's needed is to add the config file as above, don't need to reboot
  # because selinux is already "disabled" or "permissive"
else
  unless ::File.directory?("/etc/cloud/management")
    csmanager_script = ::File.join(ENV['TMPDIR'] || '/tmp', 'csmanager.sh')
  
    file csmanager_script do
      action :nothing
    end
  
    template csmanager_script do
      source "csmanage_install.sh.erb"
      backup false
    end
  
    execute "CS Manager Install Script" do
      command csmanager_script
      action :run
      notifies :delete, "file[#{csmanager_script}]", :immediately
    end
  end
  
  execute "CS Manager Setup DB" do
    command "cloud-setup-databases #{node[:cloudstack][:csmanage][:dbuser]}:#{node[:cloudstack][:csmanage][:dbpass]} --deploy-as=root"
    not_if 'echo "show databases" | mysql | grep cloud'
  end
  
  execute "CS Manager db.properties Hack for Single-Node operation" do
    command "sed -i 's/=localhost/=#{node[:cloudstack][:csmanage][:dbhost]}/g' /etc/cloud/management/db.properties"
    not_if "grep #{node[:cloudstack][:csmanage][:dbhost]} /etc/management/db.properties" # This is redundant with a sed *shrug*
  end
  
  execute "Set MySQL BinLog format to ROW" do
    command 'echo "set global binlog_format = 'ROW'" | mysql'
  end
  
  execute "Install/Setup CS Manager" do
    command "cloud-setup-management"
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

end
#
# Cookbook Name:: cloudstack
# Recipe:: do_prepare_system_vm_template
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

rs_utils_marker :begin

mount_dir = "/mnt/secondary"
hypervisor_hash = {
  "2.2.x" => {
    "vmware"    => "systemvm.ova",
    "kvm"       => "systemvm.qcow2.bz2",
    "xenserver" => "systevm.vhd.bz2"
  },
  "3.0.x" => {
    "vmware"    => "acton-systemvm-02062012.ova",
    "kvm"       => "acton-systemvm-02062012.qcow2.bz2",
    "xenserver" => "acton-systemvm-02062012.vhd.bz2"
  }
}

service "portmap" do
  action [:enable, :start]
end

directory mount_dir do
  action :create
end

mount mount_dir do
  device "#{node[:cloudstack][:csmanage][:system_vm][:nfs_hostname]}:#{node[:cloudstack][:csmanage][:system_vm][:nfs_path]}"
  fstype "nfs"
  action [:mount]
end

node[:cloudstack][:csmanage][:system_vm][:hypervisors].each do |hypervisor|
  bash "Download System VM for #{hypervisor}" do
    code <<-EOF
    /usr/lib64/cloud/agent/scripts/storage/secondary/cloud-install-sys-tmplt -m #{mount_dir} \
      -u #{node[:cloudstack][:system_vm][:csmanage][node[:cloudstack][:csmanage][:version]][:download_url]}#{hypervisor_hash[node[:cloudstack][:csmanage][:version]][hypervisor]} \
      -h #{hypervisor} -F
    EOF
  end
end

mount mount_dir do
  action [:umount]
  notifies :delete, "directory[#{mount_dir}]", :delayed
end

rs_utils_marker :end
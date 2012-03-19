#
# Cookbook Name:: cloudstack
# Recipe:: setup_xenserver
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

working_dir = ::File.join(ENV['TMPDIR'] || '/tmp', 'xenserver_supp')
package_dir = ::File.join(working_dir, 'packages.cloud-supp')
tarfile = ::File.join(ENV['TMPDIR'] || '/tmp', 'xenserver-cloud-supp.tgz')
post_install = ::File.join(working_dir, 'post-install.sh')

rs_utils_marker :begin

# This seems counterintuitive, but if this fails to find the package it'll return 1, which equates to true
if `yum list installed | grep kernel-csp-xen`
  file tarfile do
    action :nothing
  end

  directory working_dir do
    recursive true
  end

  remote_file tarfile do
    source node[:cloudstack][:xenserver][:package_url]
    backup false
  end

  execute "Extract the package" do
    command "tar xf #{tarfile} -C #{working_dir}"
    notifies :delete, "file[#{tarfile}]", :immediately
  end

  package "iptables" do
    action :purge
  end

  node[:cloudstack][:xenserver][:package_list].each do |p|
    yum_package p do
      source ::File.join(package_dir, p)
      options '--nogpgcheck'
      action :install
    end
  end

  file post_install do
    mode 00750
    action :touch
  end

  execute "Run post_install" do
    command post_install
  end
end
# reboot

rs_utils_marker :end
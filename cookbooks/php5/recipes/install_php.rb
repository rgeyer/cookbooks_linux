#
# Cookbook Name:: php5
# Recipe:: install_php
#
#  Copyright 2011-2012 Ryan J. Geyer
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

unless node[:php5][:packages]
  raise "The operating system #{node[:platform]} #{node[:platform_version]} is not supported."
end

# Possible package ppa's for Ubuntu 10.04
# https://launchpad.net/~nginx/+archive/php5
# https://launchpad.net/~fabianarias/+archive/php5
# https://launchpad.net/~chris-lea/+archive/php5.3.3
if node[:platform] == 'ubuntu' && node[:platform_version] == '10.04'
  e = bash "add-apt-repository" do
    code <<-EOF
apt-get -y -q install python-software-properties
add-apt-repository ppa:fabianarias/php5
apt-get update -o Acquire::http::No-Cache=1
EOF
    action :nothing
  end

  e.run_action(:run)
end

node[:php5][:packages_remove].each do |p|
  package p do
    action :purge
  end
end

node[:php5][:packages].each do |pkgs|
  package pkgs do
    action :install
  end
end

node[:php5][:module_list].split(' ').each do |mod|
  package "#{node[:php5][:package_prefix]}#{mod}" do
    action :install
  end
end

# This just sets the default include path, useful if we intend to extend it later in other
# conf.d/*.ini files.  If the default isn't already set, it will be excluded when extended
# with a statement like include_path=${include_path} ":/appended/path/to/includes"
template ::File.join(node[:php5][:conf_d_path], "include_path.ini") do
  source "include_path.ini.erb"
  backup false
end

# Bump up the max file upload size
template ::File.join(node[:php5][:conf_d_path], "upload_max_filesize.ini") do
  source "upload_max_filesize.ini.erb"
  backup false
end

rightscale_marker :end
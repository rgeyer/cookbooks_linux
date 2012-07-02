#
# Cookbook Name:: nginx
# Recipe:: setup_server
#
# Copyright 2011, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rightscale_marker :begin

include_recipe "runit"

directory node[:nginx][:log_dir] do
  recursive true
  mode 0755
  owner node[:nginx][:user]
  action :create
end

## Link logs back to /var/log if they've been moved, so that logrotate works
if node[:nginx][:log_dir] != "/var/log/nginx"
  # Gotta delete the bad boy first, otherwise it ends up as a link inside the directory
  directory "/var/log/nginx" do
    recursive true
    action :delete
  end

  link "/var/log/nginx" do
    to node[:nginx][:log_dir]
  end
end

# Some directory creation which is redundant for the APT package install
directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
  end
end
# /Some directory creation which is redundant for the APT package install

## Move Nginx
content_dir = node[:nginx][:content_dir]
bash 'Move Nginx Data Dir' do
  not_if do content_dir == '/var/www' || ::File.symlink?('/var/www') end
  code <<-EOF
    `mkdir -p #{content_dir}`
    `cp -rf /var/www/* #{content_dir}`
    `rm -rf /var/www`
    `ln -nsf #{content_dir} /var/www`
  EOF
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
    backup false
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  backup false
end

if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.9.0')
  cookbook_file "#{node[:nginx][:dir]}/mime.types" do
    source "mime.types"
    owner "root"
    group "root"
    mode "0644"
    backup false
  end
else
  remote_file "#{node[:nginx][:dir]}/mime.types" do
    source "mime.types"
    owner "root"
    group "root"
    mode "0644"
    backup false
  end
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# Disable the default site
nginx_site "default" do
  enable false
end

nginx_enable_vhost node.hostname do
  template "default-site.erb"
  create_doc_root false
end

rightscale_marker :end
#
# Cookbook Name:: svn
# Recipe:: setup_svn_dav_server
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

include_recipe "apache2::mod_dav_svn"
include_recipe "svn::default"

htpasswd_path = ::File.join(node[:svn][:install_path], 'htpasswd')

[node[:svn][:install_path], ::File.join(node[:svn][:install_path],"repositories")].each do |dir|
  directory dir do
    recursive true
    owner node[:apache][:user]
    group node[:apache][:user]
    mode "0755"
  end
end

execute "Create an htpasswd file for SVN" do
  user node[:apache][:user]
  command "htpasswd -scb #{htpasswd_path} #{node[:svn][:username]} #{node[:svn][:password]}"
  creates htpasswd_path
end

web_app "svn" do
  template "svn.conf.erb"
  server_name node[:svn][:fqdn]
  htpasswd_path htpasswd_path
  notifies :restart, resources(:service => "apache2")
end

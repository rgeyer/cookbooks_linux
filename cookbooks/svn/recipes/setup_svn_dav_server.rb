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

rightscale_marker :begin

include_recipe "apache2::mod_dav"
include_recipe "apache2::mod_dav_svn"
include_recipe "svn::default"

htpasswd_path = ::File.join(node[:svn][:svn_home], 'htpasswd')

group node[:svn][:gid] do
  members [node[:apache][:user]]
  action :modify
end

execute "Create an htpasswd file for SVN" do
  user node[:apache][:user]
  command "htpasswd -scb #{htpasswd_path} #{node[:svn][:username]} #{node[:svn][:password]}"
  creates htpasswd_path
end

template ::File.join(node[:svn][:svn_home], 'auth.conf') do
  source 'auth.conf.erb'
  backup false
  owner node[:apache][:user]
end

web_app node[:svn][:fqdn] do
  template "svn.conf.erb"
  server_name node[:svn][:fqdn]
  htpasswd_path htpasswd_path
  notifies :restart, resources(:service => "apache2")
end

rightscale_marker :end
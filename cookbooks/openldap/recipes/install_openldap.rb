#
# Cookbook Name:: openldap
# Recipe:: install_openldap
#
# Copyright 2011-2012, Ryan J. Geyer
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

Chef::Log.info("RIGHT UP AT THE TOP HERE LET'S ACCESS AN OHAI PROPERTY -- #{node["platform"]} #{node["platform_family"]}")

include_recipe "openldap::setup_openldap"

listen_host = ""
listen_host = "127.0.0.1" unless node[:openldap][:allow_remote] == "true"

listen_port = node[:openldap][:listen_port]

node[:openldap][:packages].each do |p|
  package p
end

service "slapd" do
  action [:enable,:start]
end

template "/etc/default/slapd" do
  source "slapd.defaults.erb"
  variables( :listen_host => listen_host, :listen_port => listen_port)
  backup false
  notifies :restart, resources(:service => "slapd"), :immediately
end

# TODO: Do we need to wait for slapd to come back here, like we do in the BASH script?

if node[:platform] == "ubuntu" && node[:platform_version] == "9.10"
  openldap_execute_ldif do
    source "ubuntu-karmic-9.10-fixRootDSE.ldif"
    source_type :cookbook_file
  end
end

# TODO: Actually need to bootstrap with a standard openldap_execute_ldif

openldap_config "Set Config Admin Credentials" do
  admin_cn node[:openldap][:config_admin_cn]
  admin_pass node[:openldap][:config_admin_password]
  action :set_admin_creds
end

%w{back_bdb back_hdb}.each do |mod|
  openldap_module mod do
    action :enable
  end
end

openldap_schema "Enable schema list" do
  schemas node[:openldap][:schemas]
  action :enable
end

directory node[:openldap][:db_dir] do
  recursive true
  owner node[:openldap][:username]
  group node[:openldap][:group]
  action :create
end

rightscale_marker :end
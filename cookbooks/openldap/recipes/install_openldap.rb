#
# Cookbook Name:: openldap
# Recipe:: install_openldap
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

rs_utils_marker :begin

listen_host = ""
listen_host = "127.0.0.1" unless node[:openldap][:allow_remote] == "true"

listen_port = node[:openldap][:listen_port]

%w{slapd ldap-utils}.each do |p|
  package p
end

package "Berkley DB Utils" do
  case node[:platform_version]
    when "9.10"
      package_name "db4.2-util"
    when "10.04"
      package_name "db4.7-util"
  end
  action :install
end

service "slapd" do
  action :nothing
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
    source_type :remote_file
  end
end

include_recipe "openldap::set_config_admin_creds"

%w{back_bdb back_hdb}.each do |mod|
  openldap_module mod do
    action :enable
  end
end

include_recipe "openldap::enable_schemas"

directory node[:openldap][:db_dir] do
  recursive true
  owner "openldap"
  group "openldap"
  action :create
end

include_recipe "openldap::create_database"

rs_utils_marker :end
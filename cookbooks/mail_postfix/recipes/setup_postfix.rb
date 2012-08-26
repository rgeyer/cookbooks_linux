#
# Cookbook Name:: mail_postfix
# Recipe:: setup_postfix
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

# Load the tail plugin in the main config file
rightscale_enable_collectd_plugin "tail"
rightscale_monitor_process "master"
rightscale_monitor_process "pickup"
rightscale_monitor_process "qmgr"

include_recipe "rightscale::setup_monitoring"

tmp_sqlfile = "/tmp/postfix.sql"

node[:mail_postfix][:packages].each do |pkg|
  package pkg do
    options "--enablerepo=centosplus" if node[:platform] == "centos"
  end
end

service "postfix" do
  action :enable
end

# Create the mysql database
mysql_database "Create postfix configuration database" do
  host "localhost"
  username "root"
  database node[:mail_postfix][:db_name]
  action :create_db
end

file tmp_sqlfile do
  action :nothing
end

#if Gem::Version.new(node[:chef_packages][:chef][:version]) < Gem::Version.new('0.9.0')
# TODO: This is a hacky check to see if we're running as chef-solo in the RightScale sandbox
if node[:rightscale_deprecated]
  remote_file tmp_sqlfile do
    source "postfix.sql"
  end
else
  cookbook_file tmp_sqlfile do
    source "postfix.sql"
  end
end

  # Populate the new database with the expected schema
bash "Populate postfix configuration database with empty schema" do
  user "root"
  code "mysql -u root -b postfix < #{tmp_sqlfile}"
  notifies :delete, resources(:file => tmp_sqlfile), :immediately
end

# Grant permissions to the mysql database for postfix
db_mysql_set_privileges "Create and authorize postfix MySQL user" do
  preset "user"
  username node[:mail_postfix][:db_user]
  password node[:mail_postfix][:db_pass]
  db_name node[:mail_postfix][:db_name]
end

# Template all of the mysql config files
%w{main master mysql-aliases mysql-relocated mysql-transport mysql-virtual-maps mysql-virtual}.each do |cfg|
  template "/etc/postfix/#{cfg}.cf" do
    source "#{cfg}.cf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "postfix"), :immediately
  end
end

# "Touch" the maillog file so that collectd can start monitoring postfix immediately
file "/var/log/maillog" do
  owner "root"
  group "root"
  mode 00600
  action :create
end

# Enable monitoring
template File.join(node.rightscale.collectd_plugin_dir, 'postfix.conf') do
  source "postfix.conf.erb"
  variables(
    :maillog => "/var/log/maillog"
  )
  notifies :restart, resources(:service => "collectd"), :immediately
end

sys_firewall 25 # SMTP

# For when we support local delivery, currently targeting dovecot
# Add the virtual mail group & user
#group "vmail" do
#  gid 1000
#end
#
#user "vmail" do
#  system true
#  shell "/bin/sh"
#  uid 1000
#  gid 1000
#  home "/home/vmail"
#end

rightscale_marker :end
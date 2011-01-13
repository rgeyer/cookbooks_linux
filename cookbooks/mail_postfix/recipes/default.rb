#
# Cookbook Name:: mail_postfix
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "rs_utils::setup_monitoring"

node[:mail_postfix][:packages].each do |pkg|
  package pkg
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

attachments_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files', 'default'))

# Populate the new database with the expected schema
bash "Populate postfix configuration database with empty schema" do
  user "root"
  cwd attachments_path
  code "mysql -u root -b postfix < postfix.sql"
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
    notifies :restart, resources(:service => "postfix")
  end
end

# Enable monitoring
template File.join(node.rs_utils.collectd_plugin_dir, 'postfix.conf') do
  source "postfix.conf.erb"
  variables(
    :maillog => "/var/log/maillog"
  )
  notifies :restart, resources(:service => "collectd")
end


# TODO: Enable logging by using collectd.conf.erb and adding mail_counter to types.db

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
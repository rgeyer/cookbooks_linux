#
# Cookbook Name:: mongod
# Recipe:: apt
#
#  Copyright 2011 Ryan J. Geyer
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

service "mongodb" do
  action :nothing
end

execute "apt-get update" do
  action :nothing
end

execute "add 10gen apt key" do
  command "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
  action :nothing
end

template "/etc/apt/sources.list.d/mongodb.list" do
  owner "root"
  mode "0644"
  source "mongodb.list.erb"
  notifies :run, resources(:execute => "add 10gen apt key"), :immediately
  notifies :run, resources(:execute => "apt-get update"), :immediately
end

package "mongodb-stable"

# All installed, and we could leave it at that, but lets do some configuration
directory node[:mongod][:datadir] do
  owner "mongodb"
  group "mongodb"
  mode 0755
  recursive true
end

file node[:mongod][:logfile] do
  owner "mongodb"
  group "mongodb"
  mode 0644
  action :create_if_missing
  backup false
end

template "/etc/mongodb.conf" do
  source "mongodb.conf.erb"
  owner "mongodb"
  group "mongodb"
  mode 0644
  backup false
  notifies :restart, resources(:service => "mongodb"), :immediately
end

template "/etc/logrotate.d/mongod" do
  source "mongodb.logrotate.erb"
  owner "mongodb"
  group "mongodb"
  mode "0644"
  backup false
  variables(:logfile => node[:mongod][:logfile])
end


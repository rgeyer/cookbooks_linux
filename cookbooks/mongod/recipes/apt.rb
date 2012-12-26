#
# Cookbook Name:: mongod
# Recipe:: apt
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

# If mongo is not yet installed, but the data dir exists, and there is a lock file, delete it.
# These conditions will occur only if restoring data from a snapshot, and probably needs some more thought and a more elegant solution
file ::File.join(node[:mongod][:datadir], "mongod.lock") do
  backup false
  action :delete
  only_if { `which mongo`.empty? }
end

service "mongodb" do
  action :nothing
end

case node[:platform]
  when "ubuntu","debian"
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
  when "centos","rhel"
    template "/etc/yum.repos.d/10gen.repo" do
      backup false
      source "10gen.repo.erb"
    end
end

node[:mongod][:packages].each do |pkg|
  package pkg
end

# All installed, and we could leave it at that, but lets do some configuration
directory node[:mongod][:datadir] do
  owner node[:mongod][:username]
  group node[:mongod][:group]
  mode 0755
  recursive true
end

execute "Recursively (re)set the permissions of the MongoDB data files" do
  command "chown -R #{node[:mongod][:username]}:#{node[:mongod][:group]} #{node[:mongod][:datadir]}"
end

file node[:mongod][:logfile] do
  owner node[:mongod][:username]
  group node[:mongod][:group]
  mode 0644
  action :create_if_missing
  backup false
end

# TODO: Move/symlink the data and log directories.  Maybe clear the log dir cause it's confusing to have
# the old /var/log files still in place

template "/etc/mongodb.conf" do
  source "mongodb.conf.erb"
  owner node[:mongod][:username]
  group node[:mongod][:group]
  mode 0644
  backup false
  notifies :restart, resources(:service => "mongodb"), :immediately
end

template "/etc/logrotate.d/mongod" do
  source "mongodb.logrotate.erb"
  owner node[:mongod][:username]
  group node[:mongod][:group]
  mode "0644"
  backup false
  variables(:logfile => node[:mongod][:logfile])
end

rightscale_marker :end
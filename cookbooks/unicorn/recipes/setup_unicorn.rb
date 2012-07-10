#
# Cookbook Name:: unicorn
# Recipe:: setup_unicorn
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

%w{/etc/unicorn /var/run/unicorn}.each do |dir|
  directory dir do
    recursive true
    action :create
  end
end

directory node[:unicorn][:log_path] do
  recursive true
  action :create
end

# All of the inputs to this are redundant since I'm specifying my own template
rightscale_logrotate_app "unicorn" do
  cookbook "unicorn"
  template "logrotate.d.erb"
  path ["#{node[:unicorn][:log_path]}/*.log" ]
  frequency "daily"
  rotate 52
end

rightscale_marker :end
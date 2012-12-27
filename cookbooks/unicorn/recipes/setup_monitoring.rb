#
# Cookbook Name:: unicorn
# Recipe:: setup_monitoring
#
# Copyright 2012, Ryan J. Geyer <me@ryangeyer.com>
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

rightscale_enable_collectd_plugin "exec"

rightscale_marker :begin

# Add the rabbitmq executable to node[:rightscale][:collectd_lib] /plugins/unicorns
directory ::File.join(node[:rightscale][:collectd_lib], 'plugins')

cookbook_file ::File.join(node[:rightscale][:collectd_lib], 'plugins', 'unicorns') do
  backup false
  source "unicorns.rb"
  mode 00755
end

# template the collectd rabbitmq conf file
template ::File.join(node[:rightscale][:collectd_plugin_dir], 'unicorns.conf') do
  backup false
  source "unicorns-collectd.conf.erb"
  notifies :restart, resources(:service => "collectd") # This will probably only work on RightScale when this is run in the boot runlist with rightscale::setup_monitoring
end

rightscale_marker :end
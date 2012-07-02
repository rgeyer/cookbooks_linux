#
# Cookbook Name:: nginx
# Recipe:: setup_stats
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

include_recipe "nginx::setup_server"

# Load the nginx plugin in the main config file
rightscale_enable_collectd_plugin "nginx"
#node[:rightscale][:plugin_list] += " nginx" unless node[:rightscale][:plugin_list] =~ /nginx/
rightscale_monitor_process "nginx"
#node[:rightscale][:process_list] += " nginx" unless node[:rightscale][:process_list] =~ /nginx/

include_recipe "rightscale::setup_monitoring"

nginx_conf    = ::File.join(node[:nginx][:dir], "sites-available", "#{node[:hostname]}.d", "nginx_stats.conf")
nginx_collectd_conf = ::File.join(node[:rightscale][:collectd_plugin_dir], "nginx.conf")

if node[:platform] == "centos"
  ruby_block "Install collectd-nginx plugin" do
    block do
      arch = (node[:kernel][:machine] == "x86_64") ? "64" : "i386"
      installed_ver = `rpm -q --queryformat %{VERSION}-%{RELEASE} collectd`.strip
      rpmfile = "collectd-nginx-#{installed_ver}.#{arch}.rpm"

      rpmfilepath = ::File.join(::File.dirname(__FILE__), "..", "files", "centos", rpmfile)
      `rpm -i #{rpmfilepath}`
    end
  end
end

template nginx_conf do
  source "stats.conf.erb"
  mode 0644
  owner "root"
  group "root"
  backup false
  notifies :restart, resources(:service => "nginx"), :immediately
end

template nginx_collectd_conf do
  source "nginx-collectd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  backup false
  notifies :restart, resources(:service => "collectd"), :immediately
end

rightscale_marker :end
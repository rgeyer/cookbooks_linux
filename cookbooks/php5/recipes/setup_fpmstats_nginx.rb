#
# Cookbook Name:: php5
# Recipe:: setup_fpmstats_nginx
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

include_recipe "nginx::install_from_package"
include_recipe "php5::install_fpm"
include_recipe "php5::setup_fpm_nginx"

# Load the nginx plugin in the main config file
rightscale_enable_collectd_plugin "exec"
rightscale_monitor_process node[:php5_fpm][:service_name]

nginx_conf = ::File.join(node[:nginx][:dir], "sites-available", "#{node[:hostname]}.d", "php5-fpm-stats.conf")
nginx_collectd_conf = ::File.join(node[:rightscale][:collectd_plugin_dir], "php5-fpm.conf")

listen_str = node[:php5_fpm][:listen] == "socket" ? "unix:#{node[:php5_fpm][:listen_socket]}" : "#{node[:php5_fpm][:listen_ip]}:#{node[:php5_fpm][:listen_port]}"

file nginx_conf do
  content <<-EOF
location /fpm_status {
  access_log off;
  fastcgi_pass #{listen_str};
  include /etc/nginx/fastcgi_params;
  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  fastcgi_param SERVER_PROTOCOL  $server_protocol;
}
  EOF
  notifies :restart, resources(:service => "nginx"), :immediately
  action :create
end

# Add the php-fpm executable to node[:rightscale][:collectd_lib] /plugins/php-fpm
directory ::File.join(node[:rightscale][:collectd_lib], 'plugins')

cookbook_file ::File.join(node[:rightscale][:collectd_lib], 'plugins', 'php-fpm') do
  backup false
  source "php-fpm.rb"
  mode 00755
end

template nginx_collectd_conf do
  source "php5-fpm-collectd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  backup false
  notifies :restart, resources(:service => "collectd"), :immediately
end

rightscale_marker :end
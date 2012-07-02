#
# Cookbook Name:: php5
# Recipe:: install_fpm
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

include_recipe "php5::install_php"

listen_str = node[:php5_fpm][:listen] == "socket" ? node[:php5_fpm][:listen_socket] : "#{node[:php5_fpm][:listen_ip]}:#{node[:php5_fpm][:listen_port]}"

# The default config for php-fpm blows up if there is no /var/www directory
directory "/var/www" do
  recursive true
  action :create
end

package value_for_platform("centos" => {"default" => "php53u-fpm"}, "ubuntu" => {"default" => "php5-fpm"})

directory node[:php5][:fpm_log_dir] do
  recursive true
  action :create
end

bash "Nuke the existing error log if it exists" do
  code "rm -rf /var/log/php5-fpm.log"
end

template "/etc/logrotate.d/php5-fpm" do
  source "php5-fpm-logrotate.erb"
  backup false
end

# enable php-fpm service
service node[:php5_fpm][:service_name] do
  supports :restart => true
  action [:enable, :start]
end

template node[:php5_fpm][:configfile] do
  source "php5-fpm.conf.erb"
  backup false
  variables(:listen_str => listen_str, :user => "www-data", :group => "www-data")
  notifies :restart, resources(:service => node[:php5_fpm][:service_name]), :delayed
end

# TODO: Stats http://forum.nginx.org/read.php?3,56426

rightscale_marker :end
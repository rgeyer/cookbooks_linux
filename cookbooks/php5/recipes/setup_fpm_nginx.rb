#
# Cookbook Name:: php5
# Recipe:: setup_fpm_nginx
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

rs_utils_marker :begin

include_recipe "nginx::install_from_package"
include_recipe "php5::install_fpm"

config_file = ::File.join(node[:nginx][:dir], "conf.d", "phpfpm-fastcgi.conf")

file config_file do
  content "include #{node[:nginx][:dir]}/fastcgi_params;"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "nginx"), :immediately
end

rs_utils_marker :end
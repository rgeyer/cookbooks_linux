#
# Cookbook Name:: nginx
# Recipe:: install_from_source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009, Opscode, Inc.
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
#

rightscale_marker :begin

include_recipe "build-essential"

%w{ libpcre3 libpcre3-dev libssl-dev}.each do |devpkg|
  package devpkg
end

nginx_version = node[:nginx][:version]
configure_flags = node[:nginx][:configure_flags].join(" ")
node.set[:nginx][:daemon_disable] = true

#remote_file "/tmp/nginx-#{nginx_version}.tar.gz" do
#  source "http://sysoev.ru/nginx/nginx-#{nginx_version}.tar.gz"
#  action :create_if_missing
#end

bash "compile_nginx_source" do
  cwd "/tmp"
  code <<-EOH
    wget -q -O /tmp/nginx-#{nginx_version}.tar.gz http://sysoev.ru/nginx/nginx-#{nginx_version}.tar.gz
    tar zxf nginx-#{nginx_version}.tar.gz
    cd nginx-#{nginx_version} && ./configure #{configure_flags}
    make && make install
  EOH
  creates node[:nginx][:src_binary]
end

include_recipe "nginx::setup_server"

rightscale_marker :end



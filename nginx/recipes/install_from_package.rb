#
# Cookbook Name:: nginx
# Recipe:: install_from_package
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

rs_utils_marker :begin

node[:nginx][:install_path] = "/usr"

case node[:platform]
  when "ubuntu"
    e = bash "add-apt-repository" do
      code <<-EOF
    apt-get -y -q install python-software-properties
    add-apt-repository ppa:nginx/stable
    apt-get update -o Acquire::http::No-Cache=1
    EOF
      action :nothing
    end

    e.run_action(:run)
  when "centos","rhel"
    t = template "/etc/yum.repos.d/nginx.repo" do
      backup false
      source "nginx.repo.erb"
      action :nothing
    end

    e = bash "yum update" do
      code "yum update"
      action :nothing
    end

    t.run_action(:create)
    e.run_action(:run)
end

package "nginx-full"

include_recipe "nginx::setup_server"

rs_utils_marker :end
#
# Cookbook Name:: znc
# Recipe:: source
#
# Copyright 2011, Seth Chisamore
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

configure_options = node['znc']['configure_options'].join(" ")

include_recipe 'build-essential'

pkgs = value_for_platform(
    [ "debian", "ubuntu" ] =>
        {"default" => %w{ libssl-dev libperl-dev pkg-config libc-ares-dev }},
    "default" => %w{ libssl-dev libperl-dev pkg-config libc-ares-dev }
  )

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

version = node['znc']['version']

remote_file "#{Chef::Config[:file_cache_path]}/znc-#{version}.tar.gz" do
  source "#{node['znc']['url']}/znc-#{version}.tar.gz"
  checksum node['znc']['checksum']
  mode "0644"
  not_if "which znc"
end

bash "build znc" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar -zxvf znc-#{version}.tar.gz
  (cd znc-#{version} && ./configure #{configure_options})
  (cd znc-#{version} && make && make install)
  EOF
  not_if "which znc"
end

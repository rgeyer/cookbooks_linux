#
# Cookbook Name:: handbrake
# Recipe:: install_cli_from_package
#
# Copyright 2012, Ryan J. Geyer
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

case node[:platform]
  when "debian", "ubuntu"
    apt_repository "handbrake" do
      uri "http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu"
      distribution node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "816950D8"
      action :add
    end

    execute "apt-get update" do
      ignore_failure true
      action :run
    end

    package 'handbrake-cli'

  when "centos", "rhel"
    package "handbrake-cli" do
      source ::File.join(::File.dirname(__FILE__), "..", "files", "default", 'handbrake-cli-0.9.4-1mud2010.1.x86_64.rpm')
      action :install
    end
  else
    raise "handbrake::install_cli_from_package does not support your operating system #{node[:platform]}"
end

rightscale_marker :end
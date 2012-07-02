#
# Cookbook Name:: cloudstack
# Recipe:: setup_single_node_management_server
#
#  Copyright 2012 Ryan J. Geyer
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

node[:openvpn] ||= {}

node[:openvpn][:local]    = node[:cloudstack][:csmanage][:vpn][:server][:listen_ip]
node[:openvpn][:netmask]  = node[:cloudstack][:csmanage][:vpn][:server][:netmask]
node[:openvpn][:subnet]   = node[:cloudstack][:csmanage][:vpn][:server][:subnet]
node[:openvpn][:protocol] = "udp"
node[:openvpn][:type]     = "server"
node[:openvpn][:users]    = [{"name" => "remote", "ccd" => {"routes" => ["#{node[:cloudstack][:csmanage][:vpn][:client][:subnet]} #{node[:cloudstack][:csmanage][:vpn][:client][:netmask]}"]} }]
node[:openvpn][:gateway]  = node[:cloudstack][:csmanage][:vpn][:server][:hostname]
node[:openvpn][:routes]   = ["route #{node[:cloudstack][:csmanage][:vpn][:client][:subnet]} #{node[:cloudstack][:csmanage][:vpn][:client][:netmask]}"]

include_recipe "cloudstack::setup_management_server"
include_recipe "openvpn::setup_server"
include_recipe "openvpn::users"

if node[:sys_firewall][:enabled] == "enabled"
  sys_firewall "Open UDP port 1194 for OpenVPN server" do
    port 1194
    protocol "udp"
    enable true
    action :update
  end
end

rightscale_marker :end
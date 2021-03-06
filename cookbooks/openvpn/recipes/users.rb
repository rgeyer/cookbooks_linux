#
# Cookbook Name:: openvpn
# Recipe:: users
#
# Copyright 2010, Opscode, Inc.
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

if !Chef::Config.solo
  search("users", "*:*") do |u|
    openvpn_add_user u
  end
else
  node[:openvpn][:users].each do |u|
    openvpn_add_user u
  end
end

rightscale_marker :end
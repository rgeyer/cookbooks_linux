#
# Cookbook Name:: svn
# Recipe:: default
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

svn_tools_name = value_for_platform(
  ["centos","redhat","fedora"] => {
    "default" => "subversion-devel"
  }, "default" => "subversion-tools"
)

package "subversion" do
  action :install
end

package svn_tools_name do
  action :install
end

# Add svn users & groups
group node[:svn][:gid] do
  action :create
end

user node[:svn][:uid] do
  comment "svn version control"
  gid node[:svn][:gid]
  home node[:svn][:svn_home]
  shell "/bin/sh"
end

[node[:svn][:svn_home], ::File.join(node[:svn][:svn_home],"repositories")].each do |dir|
  directory dir do
    recursive true
    mode "0775"
  end
end

rs_utils_marker :end
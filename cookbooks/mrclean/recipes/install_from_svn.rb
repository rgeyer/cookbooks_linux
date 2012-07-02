#
# Cookbook Name:: mrclean
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

rightscale_marker :begin

node[:mrclean][:package_list].each do |pkg|
  package pkg
end

directory node[:mrclean][:install_dir] do
  recursive true
  action :create
end

subversion node[:mrclean][:install_dir] do
  repository node[:mrclean][:svn_repo]
  if node[:mrclean][:svn_username]
    svn_username node[:mrclean][:svn_username]
  end
  if node[:mrclean][:svn_password]
    svn_password node[:mrclean][:svn_password]
  end
  revision "HEAD"
  action :force_export
end

template ::File.join(node[:mrclean][:install_dir], 'mrclean.py') do
  local true
  backup false
  source ::File.join(node[:mrclean][:install_dir], 'rightsync-example.py.erb')
end

rightscale_marker :end
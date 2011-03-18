#
# Cookbook Name:: rightgrid
# Recipe:: default
#
#  Copyright 2011 Ryan J. Geyer
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

node[:rightgrid][:ubuntu_packages].split(' ').each do |pkg|
  package pkg
end

include_recipe "rubygems::default"

# Install the necessary gems
node[:rightgrid][:worker_gems].split(' ').each do |gem|
  gem_package gem
end

#directory node[:rightgrid][:rundir] do
#  recursive true
#end

git node[:rightgrid][:rundir] do
  repository node[:rightgrid][:git_repo]
  if node[:rightgrid][:git_reference]
    reference node[:rightgrid][:git_reference]
  end
  action :sync
end

template ::File.join(node[:rightgrid][:rundir], "rightworker.yml") do
  source "rightworker.yml.erb"
end

bash "Launch the rightworker" do
  cwd node[:rightgrid][:rundir]
  code "rightworker start -e development -d"
end
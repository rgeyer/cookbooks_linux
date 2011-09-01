#
# Cookbook Name:: rax_rebundler
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

gem_package "bundler" do
  action :install
end

git node[:rax_rebundler][:path] do
  repository "git://github.com/caryp/rackspace_rebundle.git"
  action :sync
end

bash "Install rackspace_rebundler dependant gems" do
  cwd node[:rax_rebundler][:path]
  code "bundle install"
end
#
# Cookbook Name:: znc
# Recipe:: module_colloquy
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

# znc > 0.0.9 required...this means compiling from source on most platforms

remote_file "#{Chef::Config[:file_cache_path]}/colloquy.cpp" do
  source "https://github.com/wired/colloquypush/raw/master/znc/colloquy.cpp"
  mode "0644"
  not_if {::File.exists?("#{node['znc']['module_dir']}/colloquy.so")}
end

bash "build colloquy znc module" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  znc-buildmod colloquy.cpp
  mv colloquy.so #{node['znc']['module_dir']}/
  EOF
  creates "#{node['znc']['module_dir']}/colloquy.so"
  notifies :run, "execute[reload-znc-config]", :immediately
end

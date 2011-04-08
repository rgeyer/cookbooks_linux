#
# Cookbook Name:: rvm
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

bash "Download the RVM install script" do
  code <<-EOF
wget -q -O /tmp/rvm http://rvm.beginrescueend.com/install/rvm
chmod +x /tmp/rvm
  EOF
  creates "/tmp/rvm"
end

bash "Install RVM for all users" do
  code <<-EOF
/tmp/rvm --path #{node[:rvm][:install_path]}
  EOF
  not_if ::File.exists?(node[:rvm][:install_path])
end
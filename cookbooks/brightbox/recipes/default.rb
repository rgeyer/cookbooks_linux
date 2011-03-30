#
# Cookbook Name:: brightbox
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

b = bash "Adding Brightbox APT repository" do
  code <<-EOF
echo "deb http://apt.brightbox.net lucid main" > /etc/apt/sources.list.d/brightbox.list
echo "deb http://apt.brightbox.net lucid rubyee" >> /etc/apt/sources.list.d/brightbox.list
wget -q -O - http://apt.brightbox.net/release.asc | apt-key add -
apt-get update
  EOF
  action :nothing
end

b.run_action(:run) unless ::File.exist?("/etc/apt/sources.list.d/brightbox.list")
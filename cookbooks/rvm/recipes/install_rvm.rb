#
# Cookbook Name:: rvm
# Recipe:: default
#
#  Copyright 2011-2012 Ryan J. Geyer
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

# TODO: Test erasing of standard ruby & replacing w/ RVM
# This will effectively "erase" any ruby presence, and make the currently selected RVM environment
# the "system" ruby

rs_utils_marker :begin

bindir=::File.join(node[:rvm][:install_path], 'bin')
node[:rvm][:bin_path] = ::File.join(node[:rvm][:install_path], "bin", "rvm")

# Required to compile some rubies
package value_for_platform("centos" => {"default" => "openssl-devel"}, "default" => "libssl-dev")

bash "Download the RVM install script" do
  code <<-EOF
wget -q -O /tmp/rvm https://get.rvm.io
chmod +x /tmp/rvm
  EOF
  creates "/tmp/rvm"
end

bash "Install RVM for all users" do
  environment ({'rvm_path' => node[:rvm][:install_path]})
  code <<-EOF
/tmp/rvm --path #{node[:rvm][:install_path]} #{node[:rvm][:version]}
#{node[:rvm][:bin_path]} reload
  EOF
  not_if { ::File.exists?(node[:rvm][:install_path]) }
end

bash "Installing #{node[:rvm][:ruby]} as RVM's default ruby" do
  code <<-EOF
#{node[:rvm][:bin_path]} install #{node[:rvm][:ruby]}
#{node[:rvm][:bin_path]} --default use #{node[:rvm][:ruby]}
  EOF
end

# Erase all existence of "standard" ruby 1.8 and replace it with the RVM installed/default ruby
case node[:platform]
  when "debian","ubuntu"
    %w{libopenssl-ruby1.8 libreadline-ruby1.8 libruby1.8 libshadow-ruby1.8 ruby ruby1.8 ruby1.8-dev}.each do |p|
      package p do
        action :remove
      end
    end
  when "centos","rhel"
    %w{ruby}.each do |p|
      package p do
        action :remove
      end
    end
  else
    Chef::Log.info("Your platform (#{node[:platform]}) is not supported by this recipe!")
end

bash "Symlink RVM binaries to /usr/bin" do
  code "for bin in `ls #{bindir}`; do ln -sf #{bindir}/$bin /usr/bin/$bin; done;"
  creates "/usr/bin/ruby"
  action :run
end

rs_utils_marker :end
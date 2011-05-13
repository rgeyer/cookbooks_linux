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

# TODO: Test erasing of standard ruby & replacing w/ RVM
# This will effectively "erase" any ruby presence, and make the currently selected RVM environment
# the "system" ruby

bindir=::File.join(node[:rvm][:install_path], 'bin')
node[:rvm][:bin_path] = ::File.join(node[:rvm][:install_path], "bin", "rvm")

bash "Download the RVM install script" do
  code <<-EOF
wget -q -O /tmp/rvm http://rvm.beginrescueend.com/install/rvm
chmod +x /tmp/rvm
  EOF
  creates "/tmp/rvm"
end

bash "Install RVM for all users" do
  code <<-EOF
/tmp/rvm --path #{node[:rvm][:install_path]} #{node[:rvm][:version]}
#{node[:rvm][:bin_path]} reload
  EOF
  not_if { ::File.exists?(node[:rvm][:install_path]) }
end

# Erase all existence of "standard" ruby 1.8 and replace it with the RVM installed/default ruby
if node[:platform] == "ubuntu"
  %w{libopenssl-ruby1.8 libreadline-ruby1.8 libruby1.8 libshadow-ruby1.8 ruby ruby1.8 ruby1.8-dev}.each do |p|
    package p do
      action :remove
    end
  end

  # TODO: This symlinking is pointless here, since a ruby has not yet been installed, possibly need to notify this
  # from another recipe which actually installs a ruby.
  bash "Symlink RVM binaries to /usr/bin" do
    code "for bin in `ls #{bindir}`; do ln -sf #{bindir}/$bin /usr/bin/$bin; done;"
    creates "/usr/bin/ruby"
    action :run
  end
else
  Chef::Log.info("Your platform (#{node[:platform]}) is not supported by this recipe!")
end
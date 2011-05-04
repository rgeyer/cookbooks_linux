#
# Cookbook Name:: unicorn
# Recipe:: enterprise
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

include_recipe "rubygems::default"

gem_package "unicorn" do
  version node[:unicorn][:version] if node[:unicorn][:version]
end

%w{/etc/unicorn /var/run/unicorn}.each do |dir|
  directory dir do
    recursive true
    action :create
  end
end

directory node[:unicorn][:log_path] do
  recursive true
  action :create
end

template "/etc/logrotate.d/unicorn" do
  source "logrotate.d.erb"
end

#default_ruby = `#{node[:rvm][:bin_path]} list default string`.strip
#Chef::Log.info("Creating unicorn init wrapper for rvm.  Using rvm binary #{node[:rvm][:bin_path]}.  Using ruby #{default_ruby}")
bash "Create a unicorn_rails rvm wrapper if necessary" do
  code <<-EOF
rvm_bin="#{node[:rvm][:install_path]}/bin/rvm"
echo "Testing for RVM using $rvm_bin"
if [ ! -f $rvm_bin ]
then
  echo "No RVM installation found, not creating a unicorn_rails RVM wrapper"
  exit 0
fi

default_ruby=`$rvm_bin list default string`
unicorn_wrapper="#{node[:rvm][:install_path]}/bin/init_unicorn_rails"
echo "Testing for RVM unicorn_rails wrapper using $unicorn_wrapper"
if [ ! -f $unicorn_wrapper ]
then
  echo "Creating RVM wrapper for unicorn_rails in gemset $default_ruby@global"
  $rvm_bin wrapper $default_ruby@global init unicorn_rails
else
  echo "RVM wrapper for unicorn_rails already exists, skipping"
  exit 0
fi

exit 0
EOF
end
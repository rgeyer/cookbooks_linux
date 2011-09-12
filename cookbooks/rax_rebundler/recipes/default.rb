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

include_recipe "rs_utils::setup_monitoring"
include_recipe "rvm::default"

# Load the filecount plugin in the main collectd config file
rs_utils_enable_collectd_plugin "filecount"

gem_package "bundler" do
  action :install
end

git node[:rax_rebundler][:path] do
  repository "git://github.com/rgeyer/rackspace_rebundle.git"
  reference "output_options"
  action :sync
end

bash "Install rackspace_rebundler dependent gems" do
  cwd node[:rax_rebundler][:path]
  code "#{::File.join(node[:rvm][:install_path],"gems",node[:rvm][:ruby],"bin","bundle")} install"
end

template File.join(node[:rs_utils][:collectd_plugin_dir], 'rax_rebundle.conf') do
  backup false
  source "rax_rebundle.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

ruby_block "Launch an instance and wait" do
  block do
    require 'rubygems'
    require 'yaml'
    require 'pp'

    launch_bin = ::File.join(node[:rax_rebundler][:path],"bin","launch")
    upload_bin = ::File.join(node[:rax_rebundler][:path],"bin","upload")

    yaml_result = `#{launch_bin} #{node[:rax_rebundler][:instance_name]} #{node[:rax_rebundler][:image_id]} yaml #{node[:rax_rebundler][:wait_timeout]}`
    hash_result = YAML::load(yaml_result)

    if hash_result["server"]["status"] == "ACTIVE"
      ::File.open(::File.join(node[:rax_rebundler][:path],"instance-#{hash_result["server"]["id"]}")) { |f| f.write(hash_result) }
      ::Chef::Log.info <<EOF
Successfully launched a new instance from image ID: #{node[:rax_rebundler][:image_id]}
The next step is to SSH into this Rackspace Rebundle instance (#{ENV['RS_PUBLIC_IP']}) and run the following command...

[root@#{`hostname`} ~]# #{upload_bin} #{hash_result["server"]["addresses"]["public"]} [ubuntu|centos]

When prompted for the password enter (excluding the quote marks) "#{hash_result["server"]["adminPass"]}"

Here's the full output of the launch API call;
#{pp hash_result}
EOF
    else
      ::Chef::Log.error <<EOF
Something went wrong while trying to launch an instance from image ID:  #{node[:rax_rebundler][:image_id]}

Here's the full output from the launch API call;
#{pp hash_result}
EOF
    end
  end
end
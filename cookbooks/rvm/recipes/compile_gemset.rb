#
# Cookbook Name:: rvm
# Recipe:: compile_gemset
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

gemset_file = "/tmp/gemset.gems"
gemset_dir = ::File.join(node[:rvm][:install_path], "gems", "#{node[:rvm][:compile_gemset][:ruby]}@compile_me")
rvm_bin = ::File.join(node[:rvm][:install_path], "bin", "rvm")

include_recipe "rvm::default"

rjg_aws_s3 "Download gemset file" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:rvm][:compile_gemset][:s3_bucket]
  s3_file node[:rvm][:compile_gemset][:gemset_file]
  file_path gemset_file
  action :get
end

bash "Create and tar.gz gem binaries" do
  code <<-EOF
#{node[:rvm][:bin_path]} install #{node[:rvm][:compile_gemset][:ruby]}
#{node[:rvm][:bin_path]} --default use #{node[:rvm][:compile_gemset][:ruby]}
#{node[:rvm][:bin_path]} --create #{node[:rvm][:compile_gemset][:ruby]}@compile_me
#{node[:rvm][:bin_path]} gemset import #{gemset_file}
cd #{gemset_dir}
tar -cf /tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-#{node[:kernel][:machine]}.tar *
gzip /tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-#{node[:kernel][:machine]}.tar
  EOF
end

rjg_aws_s3 "Upload gemset file" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:rvm][:compile_gemset][:s3_bucket]
  s3_file node[:rvm][:compile_gemset][:gemset_file]
  file_path "/tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-#{node[:kernel][:machine]}.tar.gz"
  action :put
end
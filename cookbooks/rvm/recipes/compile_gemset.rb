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

bash "Create and upload gem binaries (i386 arch)" do
  code <<-EOF
rvm_archflags="-arch i386" CFLAGS="-arch i386" LDFLAGS="-arch i386" #{rvm_bin} install #{node[:rvm][:compile_gemset][:ruby]}
#{rvm_bin} --default use #{node[:rvm][:compile_gemset][:ruby]}
#{rvm_bin} --create #{node[:rvm][:compile_gemset][:ruby]}@compile_me
#{rvm_bin} gemset import #{gemset_file}
cd #{gemset_dir}
tar -cf /tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-i386.tar *
gzip /tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-i386.tar
  EOF
end

bash "Create and upload gem binaries (x86_64 arch)" do
  code <<-EOF
#{rvm_bin} remove #{node[:rvm][:compile_gemset][:ruby]}
rm -rf #{gemset_dir}
rvm_archflags="-arch x86_64" CFLAGS="-arch x86_64" LDFLAGS="-arch x86_64" #{rvm_bin} install #{node[:rvm][:compile_gemset][:ruby]}
#{rvm_bin} --default use #{node[:rvm][:compile_gemset][:ruby]}
#{rvm_bin} --create #{node[:rvm][:compile_gemset][:ruby]}@compile_me
#{rvm_bin} gemset import #{gemset_file}
cd #{gemset_dir}
tar -cf /tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-amd64.tar *
gzip /tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-amd64.tar
  EOF
end

rjg_aws_s3 "Upload i386 file" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:rvm][:compile_gemset][:s3_bucket]
  s3_file node[:rvm][:compile_gemset][:gemset_file]
  file_path "/tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-i386.tar.gz"
  action :put
end

rjg_aws_s3 "Upload x86_64 file" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:rvm][:compile_gemset][:s3_bucket]
  s3_file node[:rvm][:compile_gemset][:gemset_file]
  file_path "/tmp/#{node[:rvm][:compile_gemset][:gemset_name]}-amd64.tar.gz"
  action :put
end
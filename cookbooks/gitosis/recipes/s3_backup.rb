#
# Cookbook Name:: gitosis
# Recipe:: s3_backup
#
# Copyright 2010, Ryan J. Geyer
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

rightscale_marker :begin

tarfile = "/tmp/gitosis.tar"
gzipfile = "#{tarfile}.gz"

bash "create backup file" do
  cwd node[:gitosis][:gitosis_home]
  code <<-EOF
tar -cf #{tarfile} gitosis repositories .ssh
gzip #{tarfile}
  EOF
end

rjg_aws_s3 "Upload gitosis backup to S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:gitosis][:s3_bucket]
  s3_file_prefix node[:gitosis][:backup_prefix]
  s3_file_extension ".tar.gz"
  file_path gzipfile
  history_to_keep Integer(node[:gitosis][:backup_history_to_keep])
  action :put
end

file gzipfile do
  backup false
  action :delete
end

rightscale_marker :end
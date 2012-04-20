#
# Cookbook Name:: uox3
# Recipe:: do_shard_backup
#
# Copyright 2012, Ryan J. Geyer
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

shard_tar = "/tmp/uoshard.tar.gz"
prefix       = node[:uox3][:shard][:prefix]
container    = node[:uox3][:shard][:container]
cloud        = node[:uox3][:shard][:storage_account_provider]

rs_utils_marker :begin

file shard_tar do
  action :delete
end

bash "Tar the shard directory" do
  cwd node[:uox3][:install_dir]
  code "tar -zcf #{shard_tar} shard"
end

execute "Backup UO shard files to Remote Object Store" do
  command "/opt/rightscale/sandbox/bin/ros_util put --cloud #{cloud} --container #{container} --dest #{shard_tar} --source #{prefix}"
  environment ({
    'STORAGE_ACCOUNT_ID' => node[:uox3][:shard][:storage_account_id],
    'STORAGE_ACCOUNT_SECRET' => node[:uox3][:shard][:storage_account_secret]
  })
  notifies :delete, "file[#{shard_tar}]", :immediately
end

rs_utils_marker :end
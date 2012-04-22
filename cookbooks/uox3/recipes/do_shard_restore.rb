#
# Cookbook Name:: uox3
# Recipe:: do_shard_restore
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

prefix       = node[:uox3][:shard][:prefix]
container    = node[:uox3][:shard][:container]
cloud        = node[:uox3][:shard][:storage_account_provider]

rs_utils_marker :begin

uox_shard_restore "Restore the shard" do
  prefix prefix
  container container
  cloud cloud
end

rs_utils_marker :end
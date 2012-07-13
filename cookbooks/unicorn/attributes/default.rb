#
# Cookbook Name:: unicorn
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

default[:unicorn][:version] = nil
# TODO: Copied from OpsCode sample application recipe, maybe we want something a bit more scientific?
default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min

if attribute?(:ec2)
  default[:unicorn][:log_path] = "/mnt/log/unicorn"
else
  default[:unicorn][:log_path] = "/var/log/unicorn"
end
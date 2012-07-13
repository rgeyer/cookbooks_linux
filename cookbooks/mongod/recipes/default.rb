#
# Cookbook Name:: mongod
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

m = mongod "mongod" do
  persist true
  action :nothing
end

node['block_device']['devices']['device1']['backup']['before']['mongod'] = Hash.new
node['block_device']['devices']['device1']['backup']['before']['mongod']['resource'] = Hash.new
node['block_device']['devices']['device1']['backup']['before']['mongod']['resource']['type'] = 'mongod'
node['block_device']['devices']['device1']['backup']['before']['mongod']['resource']['name'] = 'mongod'
node['block_device']['devices']['device1']['backup']['before']['mongod']['resource']['action'] = 'lock_for_backup'
node['block_device']['devices']['device1']['backup']['before']['mongod']['resource']['object'] = m

node['block_device']['devices']['device1']['backup']['after']['mongod'] = Hash.new
node['block_device']['devices']['device1']['backup']['after']['mongod']['resource'] = Hash.new
node['block_device']['devices']['device1']['backup']['after']['mongod']['resource']['type'] = 'mongod'
node['block_device']['devices']['device1']['backup']['after']['mongod']['resource']['name'] = 'mongod'
node['block_device']['devices']['device1']['backup']['after']['mongod']['resource']['action'] = 'unlock_for_backup'
node['block_device']['devices']['device1']['backup']['after']['mongod']['resource']['object'] = m
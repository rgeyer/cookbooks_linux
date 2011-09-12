#
# Cookbook Name:: rax_rebundler
# Recipe:: launch
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

#ruby_block "Launch a new Rackspace instance from the specified image id" do
#  block do
#    require "rubygems"
#    require "pp"
#    require "yaml"
#    require "right_rackspace"
#
#    timeout_backoff = [2,5,10,15]
#
#    ENV["RACKSPACE_ACCOUNT"] = node[:rax_rebundler][:rax_username]
#    ENV["RACKSPACE_API_TOKEN"] = node[:rax_rebundler][:rax_api_token]
#
#    launch_bin = ::File.join(node[:rax_rebundler][:path],"bin","launch")
#    upload_bin = ::File.join(node[:rax_rebundler][:path],"bin","upload")
#
#    yaml_result = `#{launch_bin} #{node[:rax_rebundler][:instance_name]} #{node[:rax_rebundler][:image_id]} yaml`
#    hash_result = YAML::load(yaml_result)
#
#    rackspace_api = ::Rightscale::Rackspace::Interface::new(node[:rax_rebundler][:rax_username], token ,:verbose_errors => true)
#
#    begin
#      Timeout::timeout(10*60) do
#        while true
#          server = rackspace_api.get_server(hash_result["server"]["id"])
#          server_active = server["server"]["status"] == "ACTIVE"
#          unless server_active
#            sleep timeout_backoff[idx] || timeout_backoff.last
#          else
#            break
#          end
#        end
#      end
#    rescue Timeout::Error
#      ::Chef::Log.error("Waited 10 minutes for server to become active.")
#    end
#
#    `#{upload_bin} #{hash_result["server"]["addresses"]["public"]} #{node[:rax_rebundler][:image_type]}`
#
#    pp hash_result
#  end
#end

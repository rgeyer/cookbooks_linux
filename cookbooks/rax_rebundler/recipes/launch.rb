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

bash "Launch a new Rackspace instance from the specified image id" do
  cwd node[:rax_rebundler][:path]
  code <<-EOH
  export RACKSPACE_ACCOUNT="#{node[:rax_rebundler][:rax_username]}"
  export RACKSPACE_API_TOKEN="#{node[:rax_rebundler][:rax_api_token]}"
  #{::File.join("bin","launch")} #{node[:rax_rebundler][:instance_name]} #{node[:rax_rebundler][:image_id]}
  #{::File.join("bin","upload")}
EOH
end
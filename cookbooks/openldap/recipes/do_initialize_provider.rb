#
# Cookbook Name:: openldap
# Recipe:: do_initialize_provider
#
# Copyright 2011, Ryan J. Geyer
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

service "slapd" do
  action :nothing
end

openldap_module "syncprov" do
  action :enable
end

openldap_config "Add syncprov to all databases" do
  action :add_syncprov_to_all_dbs
end

include_recipe "sys_dns::do_set_private"

right_link_tag "openldap:role=provider"

rightscale_marker :end
#
# Cookbook Name:: openldap
# Recipe:: do_create_database
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

rs_utils_marker :begin

openldap_database node[:openldap][:base_dn] do
  base_dn node[:openldap][:base_dn]
  db_type node[:openldap][:db_type]
  admin_cn node[:openldap][:database_admin_cn]
  admin_password node[:openldap][:database_admin_password]
  cache_size node[:openldap][:cache_size]
  max_objects node[:openldap][:max_objects]
  max_locks node[:openldap][:max_locks]
  max_lockers node[:openldap][:max_lockers]
  checkpoint node[:openldap][:checkpoint]
  action :create
end

rs_utils_marker :end
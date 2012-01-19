#
# Cookbook Name:: openldap
# Recipe:: setup_config_admin_creds
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

ruby_block "Hash the config admin password" do
  block do
    node[:openldap][:config_admin_password] = `slappasswd -s #{node[:openldap][:config_admin_password]}`
  end
end

if `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b "cn=config" "(olcRootPw=*)"` =~ /numEntries/
  openldap_execute_ldif do
    executable "ldapadd"
    source "deleteConfigAdminPassword.ldif"
    source_type :remote_file
  end
end

if `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b "cn=config" "(olcRootDn=*)"` =~ /numEntries/
  openldap_execute_ldif do
    executable "ldapadd"
    source "deleteConfigAdminDn.ldif"
    source_type :remote_file
  end
end

openldap_execute_ldif do
  executable "ldapadd"
  source "setConfigAdminCreds.ldif.erb"
  source_type :template
  config_admin_cn node[:openldap][:config_admin_cn]
  config_admin_password node[:openldap][:config_admin_password]
end

rs_utils_marker :end
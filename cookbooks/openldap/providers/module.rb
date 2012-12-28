# Copyright 2011-2012, Ryan J. Geyer
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

include Rgeyer::Chef::NetLdap

action :enable do
  module_name = new_resource.name
  class_filter = Net::LDAP::Filter.eq("objectClass", "olcModuleList")
  module_filter = Net::LDAP::Filter.eq("olcModuleLoad", module_name)
  filter = class_filter & module_filter
  module_search = net_ldap.search(:base => new_resource.base_dn, :filter => filter, :attributes => "dn")
  unless module_search && module_search.length > 0
    filter = Net::LDAP::Filter.eq("objectClass", "olcModuleList")
    all_modules = net_ldap.search(:base => new_resource.base_dn, :filter => filter, :attributes => "dn")
    idx = all_modules ? all_modules.length : 0

    idx = idx.to_i

    Chef::Log.info("Enabling OpenLDAP module ({#{idx}}#{module_name})")

    openldap_execute_ldif do
      executable "ldapadd"
      source "addModule.ldif.erb"
      source_type :template
      index idx
      module_name module_name
    end
  end

  new_resource.updated_by_last_action(true)
end
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

action :enable do
  module_name = new_resource.name
  unless `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=config "(&(objectClass=olcModuleList)(olcModuleLoad=#{module_name}))"` =~ /numEntries/
    idx = `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=config "(objectClass=olcModuleList)" | grep numEntries | cut -d' ' -f3`
    idx = 0 if idx == ""

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
end
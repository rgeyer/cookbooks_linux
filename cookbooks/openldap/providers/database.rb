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

action :create do
  base_dn     = new_resource.base_dn
  db_type     = new_resource.db_type
  cache_size  = new_resource.cache_size
  max_objects = new_resource.max_objects
  max_locks   = new_resource.max_locks
  max_lockers = new_resource.max_lockers
  checkpoint  = new_resource.checkpoint

  admin_pwd = `slappasswd -s #{new_resource.admin_password}`
  admin_dn = "cn=#{new_resource.admin_cn}"

  if base_dn
    admin_dn = "#{base_dn},#{admin_dn}"
    existing_base_count=`ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=config "(olcSuffix=#{base_dn})" | grep numEntries | cut -d' ' -f3`.to_i
    if existing_base_count > 0
      Chef::Log.info("A database already exists for entries under #{base_dn}.  Exiting...")
      return
    end
  end

  openldap_execute_ldif do
    executable "ldapadd"
    source_type :template
    source "addDatabaseToConfig.ldif.erb"
    db_type db_type
    olc_suffix base_dn
    admin_dn admin_dn
    admin_password admin_pwd
    cache_size cache_size
    max_objects max_objects
    max_locks max_locks
    max_lockers max_lockers
    checkpoint checkpoint
  end

  new_resource.updated_by_last_action(true)
end
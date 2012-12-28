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

action :add_syncprov_to_all_dbs do
  if is_consumer
    raise "Can not initialize this server as a provider, since it is already configured as a consumer."
  end

  hdb_filter = Net::LDAP::Filter.eq("objectclass", "olchdbconfig")
  bdb_filter = Net::LDAP::Filter.eq("objectclass", "olcbdbconfig")
  filter = hdb_filter | bdb_filter
  dbs = net_ldap.search(:base => new_resource.base_dn, :filter => filter, :attributes => ["dn", "objectclass"])

  dbs.each do |db|
    update = db.objectclass.include?("olcSyncProvConfig")
    if update
      net_ldap.modify(:dn => db.dn, :operations => [
        [:replace, :olcSpCheckpoint, ["#{new_resource.provider_checkpoint_updates} #{new_resource.provider_checkpoint_updates}"]]
      ])
    else
      net_ldap.modify(:dn => db.dn, :operations => [
        [:add, :objectClass, ['olcOverlayConfig']],
        [:add, :objectClass, ['olcSycProvConfig']],
        [:add, :olcOverlay, ['syncprov']],
        [:add, :olcSpCheckpoint, ["#{new_resource.provider_checkpoint_updates} #{new_resource.provider_checkpoint_updates}"]]
      ])
    end
  end

  new_resource.updated_by_last_action(true)
end

action :set_admin_creds do
  hashed_pass = `slappasswd -s #{new_resource.admin_pass}`
  if `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b "cn=config" "(olcRootPw=*)"` =~ /numEntries/
    openldap_execute_ldif do
      executable "ldapadd"
      source "deleteConfigAdminPassword.ldif"
      source_type :cookbook_file
    end
  end

  if `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b "cn=config" "(olcRootDn=*)"` =~ /numEntries/
    openldap_execute_ldif do
      executable "ldapadd"
      source "deleteConfigAdminDn.ldif"
      source_type :cookbook_file
    end
  end

  openldap_execute_ldif do
    executable "ldapadd"
    source "setConfigAdminCreds.ldif.erb"
    source_type :template
    config_admin_cn node[:openldap][:config_admin_cn]
    config_admin_password hashed_pass
  end

  new_resource.updated_by_last_action(true)
end
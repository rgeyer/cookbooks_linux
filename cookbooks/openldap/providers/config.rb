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
end
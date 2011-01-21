directory

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
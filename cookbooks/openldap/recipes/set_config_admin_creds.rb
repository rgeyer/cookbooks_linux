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
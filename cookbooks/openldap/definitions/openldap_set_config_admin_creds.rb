define :openldap_set_config_admin_creds, :cn => nil, :password => nil do
  if `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b "cn=config" "(olcRootPw=*)"` =~ /numEntries/
    openldap_execute_ldif do
      executable "ldapadd"
      source "deleteConfigAdminPassword.ldif"
      type :remote_file
    end
  end

  template ldif_filepath do
    source "setConfigAdminCreds.ldif.erb"
    variables(:config_admin_cn => params[:cn], :config_admin_password => params[:password])
  end

  openldap_execute_ldif do
    executable "ldapadd"
    source "setConfigAdminCreds.ldif.erb"
    type :template
    config_admin_cn params[:cn]
    config_admin_password params[:password]
  end
end
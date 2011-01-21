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
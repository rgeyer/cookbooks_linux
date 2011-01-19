action :enable do
  unless `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=config "(&(objectClass=olcModuleList)(olcModuleLoad=#{new_resource.name}))"` =~ /numEntries/
    # TODO: Fairly certain that I can get away without the index here, and anywhere else I use in for cn=config stuff.
    idx = `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=config "(objectClass=olcModuleList)" | grep numEntries | cut -d' ' -f3`
    idx = 0 unless idx

    openldap_execute_ldif do
      executable "ldapadd"
      source "addModule.ldif.erb"
      type :template
      index idx
      module_name new_resource.name
    end
  end
end
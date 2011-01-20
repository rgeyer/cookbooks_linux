action :enable do
  slapd_conf = "/tmp/slapd.conf"
  schema_dir = "/tmp/slapd.schema"
  schema_ldif = "/tmp/slapd.schema.ldif"

  template slapd_conf do
    source "slapdSchemas.conf.erb"
    variables( :schemas => params[:schemas] )
  end

  d = directory schema_dir do
    recursive true
    action :create
  end

  execute "slapcat" do
    command 'slapcat -f #{slapd_conf} -F #{schema_dir} -n0 -s "cn=foo,cn=bar"'
  end

  idx = `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config "(&(objectClass=olcSchemaConfig))" | grep numEntries | cut -d' ' -f3`
  idx = 1 unless idx
  idx = idx - 1

  params[:schemas].each do |schema|
    unless `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config "(cn=*#{schema})"` =~ /numEntries/
      ldif_filepath = ::File.join(schema_dir, "cn\=config", "cn\=schema", "cn\=\{*\}#{schema}.ldif")

      # Nuke the last 7 lines of the ldif file, cause it's got attributes that won't go over well
      lines = ::File.readlines(ldif_filepath)
      ((lines.count-7)..lines.count).each do |idx|
        lines.delete_at(idx)
      end

      ::File.open(schema_ldif, "w") do |f|
        lines.each {|line|
          line += ",cn=schema,cn=config" if line =~ /^dn:/
          line.gsub!(/{[0-9]*}#{schema}/,"{#{idx}}#{schema}")
          f.puts(line)
        }
      end

      openldap_execute_ldif do
        executable "ldapadd"
        source schema_ldif
        type "file"
      end

      idx = idx + 1
    end
  end

  d.run_action(:delete)
end
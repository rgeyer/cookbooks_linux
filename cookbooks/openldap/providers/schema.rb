action :enable do
  slapd_conf = "/tmp/slapd.conf"
  schema_dir = "/tmp/slapd.schema"
  schema_ldif = "/tmp/slapd.schema.ldif"

  schema_ary = new_resource.schemas

  template slapd_conf do
    source "slapdSchemas.conf.erb"
    variables(:schemas => schema_ary)
  end

  directory schema_dir do
    recursive true
    action :create
  end

  execute "slapcat" do
    command "slapcat -f #{slapd_conf} -F #{schema_dir} -n0 -s \"cn=foo,cn=bar\""
  end

  ruby_block "The hard part" do
    block do
      idx = `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config "(&(objectClass=olcSchemaConfig))" | grep numEntries | cut -d' ' -f3`
      idx = 1 if idx == ""
      idx = idx.to_i
      idx = idx - 1

      schema_ary.each_with_index do |schema, schema_idx|
        unless `ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config "(cn=*#{schema})"` =~ /numEntries/
          ldif_filepath = ::File.join(schema_dir, "cn\=config", "cn\=schema", "cn\=\{#{schema_idx}\}#{schema}.ldif")

          # Nuke the last 7 lines of the ldif file, cause it's got attributes that won't go over well
          lines = ::File.readlines(ldif_filepath)
          ::File.open(schema_ldif, "w") do |f|
            lines.first(lines.count-7).each { |line|
              line.gsub!(/\{[0-9]*\}#{schema}/, "{#{idx}}#{schema}")
              line = "#{line.strip},cn=schema,cn=config" if line =~ /^dn:/
              f.puts(line)
            }
          end

          # TODO: This would be "the right way" but I can't execute chef definitions or resources from within a ruby block.
          # This suggests that either I'm doing it wrong, or there's room for improvement in chef, I suspect it's the former,
          # not the latter.
          #      openldap_execute_ldif do
          #        executable "ldapadd"
          #        source schema_ldif
          #        source_type :file
          #      end
          `ldapadd -Q -Y EXTERNAL -H ldapi:/// -f #{schema_ldif}`

          idx = idx + 1
        end
      end
    end
    notifies :delete, resources(:directory => schema_dir), :immediately
  end


end
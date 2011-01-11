actions :install, :update, :backup, :restore

attribute :fqdn, :kind_of => [ String ], :required => true #Required for actions [install, backup, restore]
attribute :aliases, :kind_of => [ String ] #Optional for actions [install]
attribute :db_pass, :kind_of => [ String ] #Required for actions [install]
attribute :backup_file_path, :kind_of => [ String ] #Required for actions [backup, restore]
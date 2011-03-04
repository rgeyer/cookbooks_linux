actions :install, :update, :backup, :restore

attribute :fqdn, :kind_of => [ String ], :required => true #Required for actions [install, backup, restore]
attribute :content_dir, :kind_of => [ String ], :required => true #Required for actions [install, backup, restore]
attribute :webserver, :kind_of => [ String ], :equal_to => ["apache2","nginx"] #Required for actions [install]
attribute :aliases, :kind_of => [ String ] #Optional for actions [install]
attribute :db_pass, :kind_of => [ String ] #Required for actions [install]
attribute :backup_file_path, :kind_of => [ String ] #Required for actions [backup, restore]
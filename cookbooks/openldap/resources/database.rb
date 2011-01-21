actions :create

attribute :base_dn, :kind_of => [ String ]
attribute :db_type, :kind_of => [ String ], :equal_to => ["hdb","bdb"], :required => true
attribute :admin_cn, :kind_of => [ String ], :required => true
attribute :admin_password, :kind_of => [ String ], :required => true
attribute :cache_size, :kind_of => [ String ]
attribute :max_objects, :kind_of => [ String ]
attribute :max_locks, :kind_of => [ String ]
attribute :max_lockers, :kind_of => [ String ]
attribute :checkpoint, :kind_of => [ String ]
actions :tar, :cp_to_dir

attribute :source, :kind_of => [ String ], :required => true
attribute :dest, :kind_of => [ String ], :required => true
attribute :result_dir, :kind_of => [ String ]
attribute :result_file, :kind_of => [ String ]
actions :schedule, :delete

attribute :template, :kind_of => [ String ]
attribute :name, :kind_of => [ String ], :name_attribute => true, :required => true
attribute :frequency, :kind_of => [ String ], :equal_to => ["hourly","daily","weekly","monthly"], :required => true
attribute :params, :kind_of => [ Hash ]
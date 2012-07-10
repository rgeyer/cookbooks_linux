maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "Apache 2.0" #IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures mongodb"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rightscale"

supports "ubuntu"

recipe "mongod::apt", "Installs mongodb from the net10 official packages"
recipe "mongod::lock_for_backup", "Locks the mongo server from writes so that a consistent backup can be made"
recipe "mongod::unlock_for_backup", "Unlocks the mongo server for writes after a backup has been completed"

attribute "mongod/datadir",
  :display_name => "MongoDB Data Directory",
  :description => "The full path to the directory where mongodb should store it's data files",
  :recipes => ["mongod::apt"],
  :required => "optional",
  :default => "/var/db/mongodb"

attribute "mongod/logfile",
  :display_name => "MongoDB Log File",
  :description => "The full path to a file where MongoDB will write logs",
  :recipes => ["mongod::apt"],
  :required => "optional",
  :default => "/var/log/mongodb.log"

attribute "mongod/port",
  :display_name => "MongoDB Listen Port",
  :description => "Accept connections on the specified port",
  :recipes => ["mongod::apt"],
  :required => "optional",
  :default => "27017"

attribute "mongod/bind_ip",
  :display_name => "MongoDB Bind IP",
  :description => "Accept connections on the interface with the given IP, or 0.0.0.0 for all",
  :recipes => ["mongod::apt"],
  :required => "optional",
  :default => "0.0.0.0"
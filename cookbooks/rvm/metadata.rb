maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures rvm"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"

recipe "rvm::default", "Installs Ruby Version Manager (RVM)"

attribute "rvm/install_path",
  :display_name => "RVM Installation Path",
  :description => "The full path where RVM will be installed. I.E. /opt/rvm",
  :required => "optional",
  :default => "/opt/rvm",
  :recipes => ["rvm::default"]
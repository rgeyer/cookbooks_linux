maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures app_zendframework"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"

recipe "zendframework::default", "Runs zendframework::install"
recipe "zendframework::install", "Installs the Zend Framework"

attribute "zendframework/version",
  :default => '1.11.1'
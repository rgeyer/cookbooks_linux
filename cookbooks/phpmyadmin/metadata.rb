maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "A definition for installing phpmyadmin in the desired location"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe "phpmyadmin::install", "Installs phpmyadmin at the specified location"

attribute "phpmyadmin/home",
  :display_name => "PHPMyAdmin Home",
  :description => "The full path to a directory where PHPMyAdmin will be installed",
  :required => "required",
  :recipes => ["phpmyadmin::install"]
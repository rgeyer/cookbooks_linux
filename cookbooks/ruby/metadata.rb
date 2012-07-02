maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "Apache 2.0" #IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures ruby"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"

recipe "ruby::install_gems", "Installs the provided list of gems for the system.  If ruby_enterprise was run previously, the gems are installed for ruby_enterprise"

attribute "ruby/gems_list",
  :display_name => "Ruby Gems List",
  :description => "A list of gems (separated by commas) to be installed.  You can specify a particular version by defining it after the gem name, seperated by whitespace.  I.E. (mysql 2.7.1,right_aws) would install version 2.7.1 of the mysql gem, and the latest version of the right_aws gem.",
  :required => "optional",
  :recipes => ["ruby::install_gems"]
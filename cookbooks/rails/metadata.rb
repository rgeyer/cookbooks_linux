maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures rails"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"

recipe "rails::install","Installs the specified version of rails"

attribute "rails/version",
  :display_name => "Rails Version",
  :description => "The full version number of rails to install.  I.E. 3.0.5",
  :required => "required",
  :default => "3.0.5",
  :recipes => ["rails::install"]

attribute "rails/environment",
  :display_name => "Rails Environment",
  :description => "The desired rails environment to run.  I.E. production",
  :required => "required",
  :recipes => ["rails::install"]
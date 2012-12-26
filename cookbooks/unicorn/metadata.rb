maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "Apache 2.0" #IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures unicorn"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.2"

%w{centos rhel ubuntu debian}.each do |sup|
  supports sup
end

%w{rightscale rvm logrotate}.each do |d|
  depends d
end

recipe "unicorn::install_unicorn", "Installs the unicorn gem for the system ruby"
recipe "unicorn::setup_unicorn", "Configures unicorn"
recipe "unicorn::setup_monitoring", "Enables collectd monitoring for all configured unicorns processes"

attribute "unicorn/version",
  :display_name => "Unicorn Version",
  :description => "The version of the unicorn gem to install.  If not supplied, the latest available version of unicorn will be installed",
  :required => "optional",
  :recipes => ["unicorn::install_unicorn"]

# HAX to make this available to the unicorn install recipe
attribute "rvm/install_path",
  :display_name => "RVM Installation Path",
  :description => "The full path where RVM will be installed. I.E. /opt/rvm",
  :required => "optional",
  :default => "/opt/rvm"
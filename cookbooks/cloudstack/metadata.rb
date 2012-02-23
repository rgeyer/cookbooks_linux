maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures cloudstack"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "centos"

depends "rs_utils"
depends "sys_firewall"

recipe "cloudstack::install_cloudstack", "Installs the CloudStack binary files used for setting up the CloudStack agent and management server"
recipe "cloudstack::setup_management_server", "Sets up a single node CloudStack management server"

attribute "cloudstack/csmanage/dbuser",
  :display_name => "CloudStack Management Database Username",
  :description => "The database username for the CloudStack Management Server DB connection",
  :required => "required"
  
attribute "cloudstack/csmanage/dbpass",
  :display_name => "CloudStack Management Database Password",
  :description => "The database password for the CloudStack Management Server DB connection",
  :required => "required"

attribute "cloudstack/csmanage/dbhost",
    :display_name => "CloudStack Management Database Hostname",
    :description => "The database hostname for the CloudStack Management Server DB connection",
    :required => "required"
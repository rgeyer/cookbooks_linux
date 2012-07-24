maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com  "
license          "All rights reserved"
description      "Installs/Configures postfix"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.2"

%w{rightscale db_mysql mysql sys_firewall}.each do |d|
  depends d
end

%w{ubuntu centos}.each do |os|
  supports os
end

recipe "mail_postfix::setup_postfix", "Installs postfix with mysql backend configuration"

attribute "mail_postfix",
  :display_name => "Mail Postfix",
  :description => "Hash of Mail Postfix attributes",
  :type => "hash"

attribute "mail_postfix/db_user",
  :display_name => "Postfix MySQL Database Username",
  :description => "The username to access the postfix configuration database in MySQL",
  :default => "postfix",
  :recipes => [ "mail_postfix::setup_postfix" ]

attribute "mail_postfix/db_pass",
  :display_name => "Postfix MySQL Database Password",
  :description => "The password to access the postfix configuration database in MySQL",
  :required => true,
  :recipes => [ "mail_postfix::setup_postfix" ]

attribute "mail_postfix/db_name",
  :display_name => "Postfix MySQL Database Name",
  :description => "The name of the postfix configuration database in MySQL",
  :default => "postfix",
  :recipes => [ "mail_postfix::setup_postfix" ]


attribute "mail_postfix/db_host",
  :display_name => "Postfix MySQL Database Host",
  :description => "The hostname of the postfix configuration MySQL database server",
  :default => "localhost",
  :recipes => [ "mail_postfix::setup_postfix" ]
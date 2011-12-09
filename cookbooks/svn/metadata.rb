maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures SVN"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{redhat centos fedora ubuntu debian}.each do |os|
  supports os
end

%w{apache2}.each do |dep|
  depends dep
end

recipe "svn::default", "Installs the svn package(s)."
recipe "svn::setup_svn_dav_server", "Configures an apache vhost for svn using web_dav."

attribute "svn/fqdn",
  :display_name => "SVN FQDN",
  :description => "The fully qualified domain name from which to host SVN",
  :required => "required",
  :recipes => ["svn::setup_svn_dav_server"]

attribute "svn/svn_home",
  :display_name => "SVN Home Directory",
  :description => "The full path where the SVN repositories will be stored",
  :required => "optional",
  :default => "/srv/svn"

attribute "svn/username",
  :display_name => "SVN Username",
  :description => "The username required to authenticate with the SVN server",
  :required => "required"

attribute "svn/password",
  :display_name => "SVN Password",
  :description => "The password required to authenticate with the SVN server",
  :required => "required"

attribute "svn/http_read_only",
  :display_name => "SVN dav readonly",
  :description => "A boolean indicating if the HTTP access should be read only",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "true"
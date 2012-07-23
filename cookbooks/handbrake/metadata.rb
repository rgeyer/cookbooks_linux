maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures handbrake"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{ubuntu debian centos rhel}.each do |sup|
  supports sup
end

%w{rightscale apt}.each do |dep|
  depends dep
end

recipe 'handbrake::install_cli_from_package', 'Installs the HandBrakeCLI from packages'
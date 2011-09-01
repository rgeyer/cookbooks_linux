maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com "
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures rax_rebundler"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "centos"

recipe "rax_rebundler::default", "Installs rackspace_rebundler from git and installs dependent gems"
recipe "rax_rebundler::launch", "Launches a specified image ID in the RAX account referenced by the provided credentials"
maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures vsftpd"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe "vsftpd::default", "Runs vsftpd::install"
recipe "vsftpd::install", "Installs and configures vsftpd"

supports "ubuntu"
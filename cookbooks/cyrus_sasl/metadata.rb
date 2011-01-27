maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures cyrus_sasl"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"

recipe "cyrus_sasl::install", "Installs the cyrus-sasl package"
recipe "cyrus_sasl::mod_ldap", "Installs the cyrus-sasl ldap package"
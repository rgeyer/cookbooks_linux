maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures ruby_enterprise"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"

recipe "ruby_enterprise::default", "Sets up ruby_enterprise from the official ubuntu packages"
recipe "ruby_enterprise::rvm_packaged", "Sets up ruby_enterprise as a ruby managed by rvm"
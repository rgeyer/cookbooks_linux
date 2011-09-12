maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com "
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures rax_rebundler"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rvm"
depends "rs_utils"

supports "centos"

recipe "rax_rebundler::default", "Installs rackspace_rebundler from git and installs dependent gems"
recipe "rax_rebundler::launch", "Launches a specified image ID in the RAX account referenced by the provided credentials"

attribute "rax_rebundler/rax_username",
  :display_name => "Rackspace Username",
  :description => "Your Rackspace Dashboard and API username",
  :required => "required",
  :recipes => ["rax_rebundler::default"]

attribute "rax_rebundler/rax_api_token",
  :display_name => "Rackspace API Token",
  :description => "Your Rackspace API Token",
  :required => "required",
  :recipes => ["rax_rebundler::default"]

attribute "rax_rebundler/image_id",
  :display_name => "Rackspace Image Id",
  :description => "The unique resource ID of the rackspace image you want to launch in your account",
  :required => "required",
  :recipes => ["rax_rebundler::default"]

#attribute "rax_rebundler/image_type",
#  :display_name => "Rackspace Image Type",
#  :description => "The OS of the image specified in \"Rackspace Image Id\"",
#  :required => "required",
#  :choice => ["centos", "ubuntu"],
#  :recipes => ["rax_rebundler::default"]

attribute "rax_rebundler/instance_name",
  :display_name => "Rackspace Instane Name",
  :description => "The name for the new Rackspace instance to be launched from the specified image",
  :required => "required",
  :recipes => ["rax_rebundler::default"]

attribute "rax_rebundler/wait_timeout",
  :display_name => "Rackspace Instane Launch Timeout",
  :description => "The length of time (in seconds) to wait for the requested Rackspace image to become ACTIVE before giving up",
  :required => "optional",
  :default => "600",
  :recipes => ["rax_rebundler::default"]

attribute "rvm/install_path",
  :display_name => "RVM Installation Path",
  :description => "The full path where RVM will be installed. I.E. /opt/rvm",
  :required => "optional",
  :default => "/opt/rvm",
  :recipes => ["rax_rebundler::default"]

attribute "rvm/ruby",
  :display_name => "RVM Ruby Name",
  :description => "The full RVM version to install and set as default. To find a list run `rvm list known`.  I.E. ruby-1.8.7-head",
  :required => "optional",
  :default => "ruby-1.8.7-p302",
  :recipes => ["rax_rebundler::default"]
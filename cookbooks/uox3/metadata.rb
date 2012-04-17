maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures uox3"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"
supports "centos"

depends "rs_utils"

# == Import/export attributes
#

attribute "uox3/client",
  :display_name => "Settings for fetching the UO multi/client files.",
  :type => "hash"

attribute "uox3/client/storage_account_provider",
  :display_name => "Client Files Storage Account Provider",
  :description => "Location where the UO Multis/Client files will be fetched from.",
  :required => "required",
  :choice => [ "s3", "cloudfiles", "cloudfilesuk", "SoftLayer_Dallas", "SoftLayer_Singapore", "SoftLayer_Amsterdam" ],
  :recipes => [ "uox3::default" ]

attribute "uox3/client/storage_account_id",
  :display_name => "Client Files Storage Account ID",
  :description => "In order to read the UO Multis/Client files from the specified cloud storage location, you need to provide cloud authentication credentials. For Amazon S3, use your Amazon access key ID (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your Rackspace login username (e.g., cred:RACKSPACE_USERNAME).",
  :required => "required",
  :recipes => [ "uox3::default" ]

attribute "uox3/client/storage_account_secret",
  :display_name => "Client Files Storage Account Secret",
  :description => "In order to read the UO Multis/Client files from the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use your AWS secret access key (e.g., cred:AWS_SECRET_ACCESS_KEY). For Rackspace Cloud Files, use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY).",
  :required => "required",
  :recipes => [ "uox3::default" ]

attribute "uox3/client/container",
  :display_name => "Client Files Container",
  :description => "The cloud storage location where the UO Multis/Client files will be restored from. For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name.",
  :required => "required",
  :recipes => [ "uox3::default" ]

attribute "uox3/client/prefix",
  :display_name => "Client Files Prefix",
  :description => "The prefix that will be used to locate the UO Multis/Client files archive.",
  :required => "required",
  :recipes => [ "uox3::default" ]
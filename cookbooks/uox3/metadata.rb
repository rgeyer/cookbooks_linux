maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures uox3"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"
supports "centos"

%w{rs_utils sys_firewall sys_dns scheduler}.each do |d|
  depends d
end

recipe "uox3::default", "Installs and configures UOX3 0.99.1"
recipe "uox3::do_shard_backup", "Backs up the shard information to a tar, and ships it off to a ROS"
recipe "uox3::do_shard_restore", "Restores the shard information from a tarfile stored in a ROS"
recipe "uox3::do_shard_backup_schedule_enable", "Enables daily backup of shard files"
recipe "uox3::do_shard_backup_schedule_disable", "Disables daily backup of shard files"

attribute "uox3",
  :display_name => "Settings for uox3",
  :type => "hash"

attribute "uox3/shard_name",
  :display_name => "UOX3 Shard Name",
  :description => "The name of your UO Emulation Shard",
  :required => "required",
  :category => "UOX3",
  :recipes => [ "uox3::default" ]

attribute "uox3/admin_password",
  :display_name => "UOX3 Admin Password",
  :required => "required",
  :category => "UOX3",
  :recipes => [ "uox3::default" ]

attribute "uox3/dns_id",
  :display_name => "UOX3 DNS Record ID",
  :description => "The unique identifier that is associated with the DNS A record of the server.  The unique identifier is assigned by the DNS provider when you create a dynamic DNS A record. This ID is used to update the associated A record with the private IP address of the server when this recipe is run.  If you are using DNS Made Easy as your DNS provider, a 7-digit number is used (e.g., 4403234).",
  :required => "required",
  :category => "UOX3",
  :recipes => ["uox3::default"]


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
  :category => "UOX3 Client Files",
  :recipes => [ "uox3::default" ]

attribute "uox3/client/storage_account_id",
  :display_name => "Client Files Storage Account ID",
  :description => "In order to read the UO Multis/Client files from the specified cloud storage location, you need to provide cloud authentication credentials. For Amazon S3, use your Amazon access key ID (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your Rackspace login username (e.g., cred:RACKSPACE_USERNAME).",
  :required => "required",
  :category => "UOX3 Client Files",
  :recipes => [ "uox3::default" ]

attribute "uox3/client/storage_account_secret",
  :display_name => "Client Files Storage Account Secret",
  :description => "In order to read the UO Multis/Client files from the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use your AWS secret access key (e.g., cred:AWS_SECRET_ACCESS_KEY). For Rackspace Cloud Files, use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY).",
  :required => "required",
  :category => "UOX3 Client Files",
  :recipes => [ "uox3::default" ]

attribute "uox3/client/container",
  :display_name => "Client Files Container",
  :description => "The cloud storage location where the UO Multis/Client files will be restored from. For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name.",
  :required => "required",
  :category => "UOX3 Client Files",
  :recipes => [ "uox3::default" ]

attribute "uox3/client/prefix",
  :display_name => "Client Files Prefix",
  :description => "The prefix that will be used to locate the UO Multis/Client files archive.",
  :required => "required",
  :recipes => [ "uox3::default" ]



attribute "uox3/shard",
  :display_name => "Settings for fetching and storing the UO shard files.",
  :type => "hash"

attribute "uox3/shard/storage_account_provider",
  :display_name => "Shard Files Storage Account Provider",
  :description => "Location where the UO shard files will be fetched from and stored to.",
  :required => "required",
  :choice => [ "s3", "cloudfiles", "cloudfilesuk", "SoftLayer_Dallas", "SoftLayer_Singapore", "SoftLayer_Amsterdam" ],
  :category => "UOX3 Shard Files",
  :recipes => [ "uox3::do_shard_backup", "uox3::do_shard_restore", "uox3::default" ]

attribute "uox3/shard/storage_account_id",
  :display_name => "Shard Files Storage Account ID",
  :description => "In order to read or write the UO shard files from the specified cloud storage location, you need to provide cloud authentication credentials. For Amazon S3, use your Amazon access key ID (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your Rackspace login username (e.g., cred:RACKSPACE_USERNAME).",
  :required => "required",
  :category => "UOX3 Shard Files",
  :recipes => [ "uox3::do_shard_backup", "uox3::do_shard_restore", "uox3::default" ]

attribute "uox3/shard/storage_account_secret",
  :display_name => "Shard Files Storage Account Secret",
  :description => "In order to read or write the UO shard files from the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use your AWS secret access key (e.g., cred:AWS_SECRET_ACCESS_KEY). For Rackspace Cloud Files, use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY).",
  :required => "required",
  :category => "UOX3 Shard Files",
  :recipes => [ "uox3::do_shard_backup", "uox3::do_shard_restore", "uox3::default" ]

attribute "uox3/shard/container",
  :display_name => "Shard Files Container",
  :description => "The cloud storage location where the UO shard files will be backed up and restored from. For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name.",
  :required => "required",
  :category => "UOX3 Shard Files",
  :recipes => [ "uox3::do_shard_backup", "uox3::do_shard_restore", "uox3::default" ]

attribute "uox3/shard/prefix",
  :display_name => "Shard Files Prefix",
  :description => "The prefix that will be used to locate the UO shard files archive.",
  :required => "required",
  :category => "UOX3 Shard Files",
  :recipes => [ "uox3::do_shard_backup", "uox3::do_shard_restore", "uox3::default" ]
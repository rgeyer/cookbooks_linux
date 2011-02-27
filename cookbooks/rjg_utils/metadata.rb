maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures rjg_utils"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "aws"
depends "cron"
depends "web_apache"
depends "app_wordpress"

recipe "rjg_utils::vhost_aio_boot","Does all sorts of wonderful things to configure a web/email/wordpress vhost AIO server"
recipe "rjg_utils::vhost_aio_backup_all_vhosts","Does what it says it'll do"
recipe "rjg_utils::aio_ebs_volume", "Creates a single EBS volume (XFS fstype) with the specified size at the specified mountpoint.  The EBS volume is intended to be persistent storage for an AIO server."
recipe "rjg_utils::aio_ebs_volume_snapshot", "Creates a snapshot of the EBS volume used for persistent storage on an AIO server."
recipe "rjg_utils::aio_ebs_volume_delete", "Detaches and deletes the single EBS volume."
recipe "rjg_utils::aio_ebs_volume_enable_continuous_backup", "Schedules the rjg_utils::aio_ebs_volume_snapshot recipe to run daily"
recipe "rjg_utils::aio_ebs_volume_disable_continuous_backup", "Stops the scheduled daily run of the rjg_utils::aio_ebs_volume_snapshot recipe"

provides "rjg_utils_schedule_recipe(name, json_file, frequency, action)"

supports "ubuntu"

# TODO: Add attributes to schedule recipes for each frequency.

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rjg_utils::vhost_aio_boot","rjg_utils::aio_ebs_volume","rjg_utils::aio_ebs_volume_snapshot","rjg_utils::aio_ebs_volume_delete"],
  :required => true

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rjg_utils::vhost_aio_boot","rjg_utils::aio_ebs_volume","rjg_utils::aio_ebs_volume_snapshot","rjg_utils::aio_ebs_volume_delete"],
  :required => true

attribute "rjg_utils/yaml_file",
  :display_name => "Configuration YAML file",
  :description => "The filename of a YAML file stored in an S3 bucket used to configure a server instance",
  :recipes => ["rjg_utils::vhost_aio_boot"],
  :required => true

attribute "rjg_utils/yaml_bucket",
  :display_name => "Configuration YAML file S3 bucket",
  :description => "The S3 bucket containing the YAML file used to configure a server instance",
  :recipes => ["rjg_utils::vhost_aio_boot"],
  :required => true

attribute "rjg_utils/aio_ebs_size_in_gb",
  :display_name => "EBS Volume Size in GB",
  :recipes => ["rjg_utils::aio_ebs_volume"],
  :required => "required"

attribute "rjg_utils/aio_ebs_snapshot_id",
  :display_name => "EBS Volume Snapshot Id",
  :description => "The full AWS id of a snapshot which will be used to create the volume.  This is used to launch a new server instance with the state stored in the specified snapshot.  If left blank a new EBS volume is created.",
  :recipes => ["rjg_utils::aio_ebs_volume"],
  :default => "blank",
  :required => "optional"

attribute "rjg_utils/aio_ebs_mountpoint",
  :display_name => "EBS Volume Mountpoint",
  :description => "The path where the new EBS volume will be mounted.",
  :recipes => ["rjg_utils::aio_ebs_volume","rjg_utils::aio_ebs_volume_snapshot"],
  :default => "/srv",
  :required => "optional"

attribute "rjg_utils/aio_ebs_snapshots_to_keep",
  :display_name => "EBS Snapshots To Keep",
  :description => "The number of snapshots for the AIO EBS volume to keep as history",
  :default => "7",
  :required => "optional",
  :recipes => ["rjg_utils::aio_ebs_volume","rjg_utils::aio_ebs_volume_snapshot"]

attribute "rjg_utils/rs_instance_uuid",
  :display_name => "env:RS_INSTANCE_UUID",
  :recipes => ["rjg_utils::aio_ebs_volume","rjg_utils::aio_ebs_volume_snapshot","rjg_utils::aio_ebs_volume_delete"],
  :required => "required"
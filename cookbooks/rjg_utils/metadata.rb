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
recipe "rjg_utils::schedule_recipes", "Schedules recipes to run hourly,daily,weekly, or monthly using cron"

provides "rjg_utils_schedule_recipe(name, frequency, action)"

supports "ubuntu"

# TODO: Add attributes to schedule recipes for each frequency.

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rjg_utils::vhost_aio_boot"],
  :required => true

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rjg_utils::vhost_aio_boot"],
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
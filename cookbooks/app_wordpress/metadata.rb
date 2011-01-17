maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com  "
license          "All rights reserved"
description      "Installs/Configures app_wordpress"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

# Does this really depend upon web_apache?  It's sorta more loosely coupled?
depends "aws"
depends "web_apache"
depends "db_mysql"
depends "mysql"
depends "execute[mysql_database]"
depends "rjg_utils"

provides "app_wordpress[site]"

recipe "app_wordpress::default","Don't do nuthin'"
recipe "app_wordpress::deploy","Installs an instance of wordpress for the specified vhost"
recipe "app_wordpress::update","Updates the instance of wordpress for the specified vhost to the latest version from wordpress.org"
recipe "app_wordpress::s3_backup","Backs up the content of the wp-content directory for the specified vhost."
recipe "app_wordpress::s3_restore","Installs (if necessary) and restores wordpress for the specified vhost"
recipe "app_wordpress::enable_continuous_backup","Creates a cron job which will run app_wordpress::s3_backup daily"

supports "ubuntu"

attribute "app_wordpress",
  :display_name => "app_wordpress",
  :type => "hash"

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["app_wordpress::s3_backup", "app_wordpress::s3_restore"],
  :required => true

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["app_wordpress::s3_backup", "app_wordpress::s3_restore"],
  :required => true

attribute "web_apache/vhost_fqdn",
  :display_name => "VHOST FQDN",
  :description => "The fully qualified domain name (FQDN) of the new vhost to create.  Example www.apache.org",
  :required => true,
  :recipes => ["app_wordpress::deploy","app_wordpress::s3_backup", "app_wordpress::s3_restore", "app_wordpress::update", "app_wordpress::enable_continuous_backup"]

attribute "web_apache/vhost_aliases",
  :display_name => "VHOST Aliases",
  :description => "The possible hostname aliases (if any) for the vhost.  For instance to host the same content at www.yourdomain.com and yourdomain.com simply put \"yourdomain.com\" here.  Many values can be supplied, separated by spaces",
  :default => "",
  :recipes => ["app_wordpress::deploy","app_wordpress::s3_restore"]

attribute "app_wordpress/db_pass",
  :display_name => "MySQL Database Password for this Wordpress instance",
  :description => "The password to access the MySQL database for this Wordpress instance",
  :required => true,
  :recipes => ["app_wordpress::deploy","app_wordpress::s3_restore"]

attribute "app_wordpress/s3_bucket",
  :display_name => "Vhost Backup S3 Bucket",
  :description => "The namne of the S3 bucket for backups.",
  :required => true,
  :recipes => ["app_wordpress::s3_backup", "app_wordpress::s3_restore", "app_wordpress::enable_continuous_backup"]

attribute "app_wordpress/backup_history_to_keep",
  :display_name => "Vhost Backups to keep",
  :description => "The number of S3 backups to keep as history.",
  :default => "7",
  :recipes => ["app_wordpress::s3_backup"]
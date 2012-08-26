maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com  "
license          "All rights reserved"
description      "Installs/Configures app_wordpress"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.2"

%w{rjg_aws db_mysql mysql rjg_utils web_apache nginx php5}.each do |dep|
  depends dep
end

provides "app_wordpress[site]"

recipe "app_wordpress::default","Installs and configures some defaults for the app_wordpress cookbook"
recipe "app_wordpress::deploy","Installs an instance of wordpress for the specified vhost"
recipe "app_wordpress::update","Updates the instance of wordpress for the specified vhost to the latest version from wordpress.org"
recipe "app_wordpress::s3_backup","Backs up the content of the wp-content directory for the specified vhost."
recipe "app_wordpress::s3_restore","Installs (if necessary) and restores wordpress for the specified vhost"
recipe "app_wordpress::enable_continuous_backup","Creates a cron job which will run app_wordpress::s3_backup daily"

%w{ubuntu debian centos rhel}.each do |supp|
  supports supp
end

attribute "app_wordpress",
  :display_name => "app_wordpress",
  :type => "hash"

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["app_wordpress::s3_backup", "app_wordpress::s3_restore"],
  :required => "required"

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["app_wordpress::s3_backup", "app_wordpress::s3_restore"],
  :required => "required"

attribute "app_wordpress/vhost_fqdn",
  :display_name => "Wordpress VHOST FQDN",
  :description => "The fully qualified domain name (FQDN) of the new vhost to deploy wordpress to.  Example www.apache.org",
  :required => "required",
  :recipes => ["app_wordpress::deploy","app_wordpress::s3_backup", "app_wordpress::s3_restore", "app_wordpress::update", "app_wordpress::enable_continuous_backup"]

attribute "app_wordpress/vhost_aliases",
  :display_name => "Wordpress VHOST Aliases",
  :description => "The possible hostname aliases (if any) for the vhost.  For instance to host the same content at www.yourdomain.com and yourdomain.com simply put \"yourdomain.com\" here.  Many values can be supplied, separated by spaces",
  :default => "",
  :recipes => ["app_wordpress::deploy","app_wordpress::s3_restore"]

attribute "app_wordpress/db_pass",
  :display_name => "MySQL Database Password for this Wordpress instance",
  :description => "The password to access the MySQL database for this Wordpress instance",
  :required => "required",
  :recipes => ["app_wordpress::deploy","app_wordpress::s3_restore"]

attribute "app_wordpress/s3_bucket",
  :display_name => "Vhost Backup S3 Bucket",
  :description => "The namne of the S3 bucket for backups.",
  :required => "required",
  :recipes => ["app_wordpress::s3_backup", "app_wordpress::s3_restore", "app_wordpress::enable_continuous_backup"]

attribute "app_wordpress/backup_history_to_keep",
  :display_name => "Vhost Backups to keep",
  :description => "The number of S3 backups to keep as history.",
  :default => "7",
  :recipes => ["app_wordpress::s3_backup"]

attribute "app_wordpress/webserver",
  :display_name => "Wordpress Web Server",
  :description => "The web server which will be serving pages for the wordpress instance",
  :choice => ["nginx","apache2"],
  :required => "required"
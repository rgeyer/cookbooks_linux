maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures gitosis"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{ubuntu debian redhat centos}.each do |os|
  supports os
end

%w{rjg_aws scheduler rs_utils}.each do |dep|
  depends dep
end

recipe "gitosis::default","Just runs gitosis::install"
recipe "gitosis::install","Installs gitosis in the specified directory"
recipe "gitosis::s3_backup", "Backs up all gitosis files to an S3 bucket"
recipe "gitosis::s3_restore", "Restores all gitosis files from an S3 bucket"
recipe "gitosis::enable_continuous_backup", "Sets up a cron job to run the gitosis::s3_backup recipe daily"
recipe "gitosis::disable_continuous_backup", "Kills the cron job which runs gitosis::s3_backup daily"


attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["gitosis::s3_backup", "gitosis::s3_restore"],
  :required => true

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["gitosis::s3_backup", "gitosis::s3_restore"],
  :required => true

attribute "gitosis/gitosis_home",
  :display_name => "Gitosis Home Directory",
  :description => "The full path to the home directory for Gitosis",
  :default => "/mnt/gitosis-home",
  :recipes => ["gitosis::default", "gitosis::install", "gitosis::s3_backup", "gitosis::s3_restore"]

attribute "gitosis/gitosis_key",
  :display_name => "Gitosis Private Key",
  :description => "Private RSA (or DSA) key material to be used when initializing the gitosis repository/home. Set to ignore for a new key to be automatically generated.",
  :required => false,
  :recipes => ["gitosis::default", "gitosis::install"]

attribute "gitosis/backup_prefix",
  :display_name => "Gitosis Backup Prefix",
  :description => "The prefix of the filename stored in S3 for backups.",
  :required => true,
  :recipes => ["gitosis::s3_backup", "gitosis::s3_restore"]

attribute "gitosis/s3_bucket",
  :display_name => "Gitosis Backup S3 Bucket",
  :description => "The namne of the S3 bucket for backups.",
  :required => true,
  :recipes => ["gitosis::s3_backup", "gitosis::s3_restore"]

attribute "gitosis/backup_history_to_keep",
  :display_name => "Gitosis Backups to keep",
  :description => "The number of S3 backups to keep as history.",
  :default => "7",
  :recipes => ["gitosis::s3_backup"]
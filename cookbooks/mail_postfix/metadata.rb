maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com  "
license          "All rights reserved"
description      "Installs/Configures postfix"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "aws"
depends "rs_utils"

recipe "mail_postfix::default", "Installs postfix with mysql backend configuration"
recipe "mail_postfix::s3_backup", "Backs up the configuration database to s3"
recipe "mail_postfix::s3_restore", "Restores the configuration database from s3"
recipe "mail_postfix::enable_continuous_backup", "Schedules mail_postfix::s3_backup to be run daily using cron"
recipe "mail_postfix::disable_continuous_backup", "Stops daily scheduled runs of mail_postfix::s3_backup"

supports "ubuntu"

attribute "mail_postfix",
  :display_name => "Mail Postfix",
  :description => "Hash of Mail Postfix attributes",
  :type => "hash"

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["mail_postfix::s3_backup", "mail_postfix::s3_restore"],
  :required => true

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["mail_postfix::s3_backup", "mail_postfix::s3_restore"],
  :required => true

attribute "mail_postfix/backup_prefix",
  :display_name => "Postfix Backup Prefix",
  :description => "The prefix of the filename stored in S3 for backups.",
  :required => true,
  :recipes => ["mail_postfix::s3_backup", "mail_postfix::s3_restore"]

attribute "mail_postfix/s3_bucket",
  :display_name => "Postfix Backup S3 Bucket",
  :description => "The namne of the S3 bucket for backups.",
  :required => true,
  :recipes => ["mail_postfix::s3_backup", "mail_postfix::s3_restore"]

attribute "mail_postfix/backup_history_to_keep",
  :display_name => "Postfix Backups to keep",
  :description => "The number of S3 backups to keep as history.",
  :default => "7",
  :recipes => ["mail_postfix::s3_backup"]

attribute "mail_postfix/db_user",
  :display_name => "Postfix MySQL Database Username",
  :description => "The username to access the postfix configuration database in MySQL",
  :default => "postfix",
  :recipes => [ "mail_postfix::default" ]

attribute "mail_postfix/db_pass",
  :display_name => "Postfix MySQL Database Password",
  :description => "The password to access the postfix configuration database in MySQL",
  :required => true,
  :recipes => [ "mail_postfix::default" ]

attribute "mail_postfix/db_name",
  :display_name => "Postfix MySQL Database Name",
  :description => "The name of the postfix configuration database in MySQL",
  :default => "postfix",
  :recipes => [ "mail_postfix::default", "mail_postfix::s3_backup", "mail_postfix::s3_restore" ]


attribute "mail_postfix/db_host",
  :display_name => "Postfix MySQL Database Host",
  :description => "The hostname of the postfix configuration MySQL database server",
  :default => "localhost",
  :recipes => [ "mail_postfix::default" ]
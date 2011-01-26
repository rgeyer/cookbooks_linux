gzipfile="/tmp/mysql-#{node[:mail_postfix][:db_name]}.gz"

db_mysql_gzipfile_backup "create a backup file" do
  file_path gzipfile
  db_name node[:mail_postfix][:db_name]
end

aws_s3 "Upload postfix configuration db to S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:mail_postfix][:s3_bucket]
  s3_file_prefix node[:mail_postfix][:backup_prefix]
  s3_file_extension ".gz"
  file_path gzipfile
  history_to_keep Integer(node[:mail_postfix][:backup_history_to_keep])
  action :put
end

file gzipfile do
  backup false
  action :delete
end
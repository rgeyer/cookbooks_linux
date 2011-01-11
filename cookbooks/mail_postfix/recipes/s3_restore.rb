gzipfile="/tmp/mysql-postfix.gz"

aws_s3 "Download postfix backup from S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:mail_postfix][:s3_bucket]
  s3_file_prefix node[:mail_postfix][:backup_prefix]
  file_path gzipfile
  action :get
end

db_mysql_gzipfile_restore "Postfix DB restore" do
  db_name node[:mail_postfix][:db_name]
  file_path gzipfile
end

#bash "(Over)Write the postfix config db with data from the backup" do
#  code <<-EOF
#mysqladmin -uroot -f drop #{node[:mail_postfix][:db_name]}
#mysqladmin -uroot create #{node[:mail_postfix][:db_name]}
#gunzip < #{gzipfile} | mysql -u root #{node[:mail_postfix][:db_name]}
#  EOF
#end

file gzipfile do
  backup nil
  action :delete
end
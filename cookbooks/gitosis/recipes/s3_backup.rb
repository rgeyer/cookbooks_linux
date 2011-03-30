tarfile = "/tmp/gitosis.tar"
gzipfile = "#{tarfile}.gz"

bash "create backup file" do
  cwd node[:gitosis][:gitosis_home]
  code <<-EOF
tar -cf #{tarfile} gitosis repositories .ssh
gzip #{tarfile}
  EOF
end

rjg_aws_s3 "Upload gitosis backup to S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:gitosis][:s3_bucket]
  s3_file_prefix node[:gitosis][:backup_prefix]
  s3_file_extension ".tar.gz"
  file_path gzipfile
  history_to_keep Integer(node[:gitosis][:backup_history_to_keep])
  action :put
end

file gzipfile do
  backup false
  action :delete
end
wpgzip="/tmp/wordpress.tar.gz"

app_wordpress_site node[:web_apache][:vhost_fqdn] do
  fqdn node[:web_apache][:vhost_fqdn]
  backup_file_path wpgzip
  action :backup
end

aws_s3 "Push backup to S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:app_wordpress][:s3_bucket]
  s3_file_prefix "#{node[:web_apache][:vhost_fqdn]}-wordpress"
  s3_file_extension ".tar.gz"
  file_path wpgzip
  history_to_keep Integer(node[:app_wordpress][:backup_history_to_keep])
  action :put
end
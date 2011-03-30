tarfile="/tmp/wordpress.tar.gz"

rjg_aws_s3 "Download #{node[:web_apache][:vhost_fqdn]} backup file" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:app_wordpress][:s3_bucket]
  s3_file_prefix "#{node[:web_apache][:vhost_fqdn]}-wordpress"
  file_path tarfile
  action :get
end

# TODO: Seems like I should just be able to do action [:install, :restore] but that blows up!
# Install (if necessary) and restore the wordpress site
app_wordpress_site node[:web_apache][:vhost_fqdn] do
  fqdn node[:web_apache][:vhost_fqdn]
  aliases node[:web_apache][:vhost_aliases]
  db_pass node[:app_wordpress][:db_pass]
  backup_file_path tarfile
  action :install
end

app_wordpress_site node[:web_apache][:vhost_fqdn] do
  fqdn node[:web_apache][:vhost_fqdn]
  aliases node[:web_apache][:vhost_aliases]
  db_pass node[:app_wordpress][:db_pass]
  backup_file_path tarfile
  action :restore
end

file tarfile do
  backup false
  action :delete
end
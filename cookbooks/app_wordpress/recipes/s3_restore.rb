#
# Cookbook Name:: app_wordpress
# Recipe:: s3_restore
#
#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

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
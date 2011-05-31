#
# Cookbook Name:: app_wordpress
# Recipe:: enable_continuous_backup
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

# TODO: When 5.6 is released, exchange this for rs_run_recipe with json input.
# TODO: Make this apache2/nginx aware

include_recipe "utils::install_rest_connection_gem"

# Cron hates periods in file names
fqdn = node[:app_wordpress][:vhost_fqdn].gsub(".", "_")

cron_job "#{fqdn}_wordpress_backup" do
  frequency "daily"
  template "wordpress_backup.rb.erb"
  action :schedule
end

# This will be used with rs_run_recipe after 5.6
vhost_dir = "#{node[:web_apache][:content_dir]}/#{node[:web_apache][:vhost_fqdn]}"
template "#{vhost_dir}/wordpress.attr.js" do
  source "wordpress.attr.js.erb"
  variables(
    "s3_bucket" => node[:app_wordpress][:s3_bucket],
    "fqdn" => node[:web_apache][:vhost_fqdn]
  )
end

# TODO: This doesn't support the "json_file" parameter yet!
rjg_utils_schedule_recipe "app_wordpress::s3_backup" do
  frequency "daily"
  action "schedule"
  json_file "#{vhost_dir}/wordpress.attr.js"
end
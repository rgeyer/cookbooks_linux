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
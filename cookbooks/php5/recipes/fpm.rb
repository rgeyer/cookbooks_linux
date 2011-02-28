include_recipe "php5::default"

package "php5-fpm"

directory node[:php5][:fpm_log_dir] do
  recursive true
  action :create
end

bash "Nuke the existing error log if it exists" do
  code "rm -rf /var/log/php5-fpm.log"
end

template "/etc/logrotate.d/php5-fpm" do
  source "php5-fpm-logrotate.erb"
end

# start up php-fpm
service "php5-fpm" do
  supports :restart => true
  action [:enable, :start]
end

template "/etc/php5/fpm/php5-fpm.conf" do
  source "php5-fpm.conf.erb"
  notifies :restart, resources(:service => "php5-fpm"), :immediately
end
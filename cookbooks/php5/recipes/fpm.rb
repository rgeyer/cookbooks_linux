include_recipe "php5::default"

listen_str = node[:php5_fpm][:listen] == "socket" ? node[:php5_fpm][:listen_socket] : "#{node[:php5_fpm][:listen_ip]}:#{node[:php5_fpm][:listen_port]}"

# The default config for php-fpm blows up if there is no /var/www directory
directory "/var/www" do
  recursive true
  action :create
end

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

# enable php-fpm service
service "php5-fpm" do
  supports :restart => true
  action [:enable, :start]
end

template "/etc/php5/fpm/main.conf" do
  source "php5-fpm.conf.erb"
  variables({:listen_str => listen_str})
  notifies :restart, resources(:service => "php5-fpm"), :immediately
end

# TODO: Stats http://forum.nginx.org/read.php?3,56426
include_recipe "php5::default"

package "php-fpm"

# start up php-fpm
service "php5-fpm" do
  supports :restart => true
  action [:enable, :start]
end

template "/etc/php5/fpm/php5-fpm.conf" do
  source "php5-fpm.conf.erb"
  notifies :restart, resources(:service => "php5-fpm"), :immediately
end
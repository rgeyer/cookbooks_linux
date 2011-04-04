include_recipe "nginx::default"
include_recipe "php5::fpm"
include_recipe "php5::fpmenable_nginx"

# Load the nginx plugin in the main config file
node[:rs_utils][:plugin_list] += " curl" unless node[:rs_utils][:plugin_list] =~ /curl/
node[:rs_utils][:process_list] += " php5-fpm" unless node[:rs_utils][:process_list] =~ /php5-fpm/

nginx_conf = ::File.join(node[:nginx][:dir], "sites-available", "#{node[:hostname]}.d", "php5-fpm-stats.conf")
nginx_collectd_conf = ::File.join(node[:rs_utils][:collectd_plugin_dir], "php5-fpm.conf")

file nginx_conf do
  content <<-EOF
location /fpm_status {
  access_log off;
  allow 127.0.0.1;
  deny all;
  fastcgi_pass #{node[:php5_fpm][:listen]};
}
  EOF
  notifies :reload, resources(:service => "nginx"), :immediately
end

template nginx_collectd_conf do
  source "php5-fpm-collectd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "collectd"), :immediately
end
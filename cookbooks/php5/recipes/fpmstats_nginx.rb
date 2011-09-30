include_recipe "nginx::install_from_package"
include_recipe "php5::fpm"
include_recipe "php5::fpmenable_nginx"

# Load the nginx plugin in the main config file
rs_utils_enable_collectd_plugin "curl_json"
#node[:rs_utils][:plugin_list] += " curl_json" unless node[:rs_utils][:plugin_list] =~ /curl/
rs_utils_monitor_process "php5-fpm"
#node[:rs_utils][:process_list] += " php5-fpm" unless node[:rs_utils][:process_list] =~ /php5-fpm/

nginx_conf = ::File.join(node[:nginx][:dir], "sites-available", "#{node[:hostname]}.d", "php5-fpm-stats.conf")
nginx_collectd_conf = ::File.join(node[:rs_utils][:collectd_plugin_dir], "php5-fpm.conf")

listen_str = node[:php5_fpm][:listen] == "socket" ? "unix:#{node[:php5_fpm][:listen_socket]}" : "#{node[:php5_fpm][:listen_ip]}:#{node[:php5_fpm][:listen_port]}"

# This is necessary for collectd's curl_json plugin, but apparently not installed already *shrug*
package "libyajl1"

file nginx_conf do
  content <<-EOF
location /fpm_status {
  access_log off;
  fastcgi_pass #{listen_str};
}
  EOF
  notifies :restart, resources(:service => "nginx"), :immediately
  action :create
end

template nginx_collectd_conf do
  source "php5-fpm-collectd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  backup false
  notifies :restart, resources(:service => "collectd"), :immediately
end
include_recipe "nginx::install_from_package"
include_recipe "php5::fpm"

config_file = ::File.join(node[:nginx][:dir], "conf.d", "phpfpm-fastcgi.conf")

file config_file do
  content "include #{node[:nginx][:dir]}/fastcgi_params;"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "nginx"), :immediately
end
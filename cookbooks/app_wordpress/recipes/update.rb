app_wordpress_site node[:web_apache][:vhost_fqdn] do
  fqdn node[:web_apache][:vhost_fqdn]
  action :update
end
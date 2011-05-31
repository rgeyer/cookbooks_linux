app_wordpress_site node[:app_wordpress][:vhost_fqdn] do
  fqdn node[:app_wordpress][:vhost_fqdn]
  action :update
end
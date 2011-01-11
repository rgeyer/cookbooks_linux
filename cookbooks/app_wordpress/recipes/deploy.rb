app_wordpress_site "Deploy Wordpress for a vhost" do
  fqdn node[:web_apache][:vhost_fqdn]
  aliases node[:web_apache][:vhost_aliases]
  db_pass node[:app_wordpress][:db_pass]
  action :install
end
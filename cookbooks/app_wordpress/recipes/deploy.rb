# TODO: So this sorta assumes that an instance runs either nginx or apache2, but not both.  And that either one is already installed
is_apache2 = ::File.exists? `which apache2`
content_dir = is_apache2 ? node[:web_apache][:content_dir] : node[:nginx][:content_dir]
webserver = is_apache2 ? "apache2" : "nginx"

app_wordpress_site "Deploy Wordpress for a vhost" do
  fqdn node[:app_wordpress][:vhost_fqdn]
  aliases node[:app_wordpress][:vhost_aliases]
  db_pass node[:app_wordpress][:db_pass]
  content_dir content_dir
  webserver webserver
  action :install
end
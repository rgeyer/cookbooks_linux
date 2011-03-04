# TODO: So this sorta assumes that an instance runs either nginx or apache2, but not both
is_apache2 = `which apache2` != nil
content_dir = is_apache2 ? node[:web_apache][:content_dir] : node[:nginx][:content_dir]
webserver = is_apache2 ? "apache2" : "nginx"

Chef::Log.info("Is Apache2 was (#{is_apache2})")
Chef::Log.info("Content dir was (#{content_dir})")
Chef::Log.info("Webserver was (#{webserver})")

app_wordpress_site "Deploy Wordpress for a vhost" do
  fqdn node[:app_wordpress][:vhost_fqdn]
  aliases node[:app_wordpress][:vhost_aliases]
  db_pass node[:app_wordpress][:db_pass]
  content_dir content_dir
  webserver webserver
  action :install
end
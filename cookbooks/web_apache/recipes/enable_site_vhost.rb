web_apache_enable_vhost "Vhost" do
  fqdn node[:web_apache][:vhost_fqdn]
  aliases node[:web_apache][:aliases]
end
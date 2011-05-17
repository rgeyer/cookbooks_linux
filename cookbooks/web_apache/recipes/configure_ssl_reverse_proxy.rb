accept_fqdn=node[:web_apache][:accept_fqdn]
underscored_accept_fqdn=accept_fqdn.gsub(".","_")

rsa_cert="/etc/apache2/ssl/#{node[:web_apache][:accept_fqdn]}.crt"
rsa_key="/etc/apache2/ssl/#{node[:web_apache][:accept_fqdn]}.key"

rsa_keypair_from_pkcs12 "Convert PKCS12 to RSA keypair" do
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:web_apache][:s3_cert_bucket]
  s3_file "#{underscored_accept_fqdn}.pkcs12"
  rsa_cert_path rsa_cert
  rsa_key_path rsa_key
  pkcs12_pass node[:web_apache][:pkcs12_pass]
end

apache_module "ssl"
apache_module "proxy_http"

# Disable the default site
apache_site "000-default" do
  enable false
end

docroot=::File.join(node[:web_apache][:content_dir], "#{accept_fqdn}-proxy", "htdocs")
system_root=::File.join(docroot, "system")

# Create the docroot, used for maintenance
directory system_root do
  mode 0775
  owner "www-data"
  group "www-data"
  recursive true
  action :create
end

# Enable the proxy site
web_app "#{accept_fqdn}-proxy" do
  template "ssl-vhost-proxy.conf.erb"
  accept_fqdn accept_fqdn
  server_aliases node[:web_apache][:aliases]
  dest_fqdn node[:web_apache][:dest_fqdn]
  dest_port node[:web_apache][:dest_port]
  listen_on_http node[:web_apache][:proxy_http] == "true"
  force_https node[:web_apache][:force_https] == "true"
  docroot docroot
end


# TODO: This is illegal according to RightScale.  Each namespace:key can have only one value
skeme_tag "reverse_proxy:for=https://#{accept_fqdn}" do
  action :add
end
skeme_tag "reverse_proxy:target=https://#{node[:web_apache][:dest_fqdn]}:#{node[:web_apache][:dest_port]}" do
  action :add
end

if node[:web_apache][:proxy_http] == "true"
  skeme_tag "reverse_proxy:for=http://#{accept_fqdn}" do
    action :add
  end
  skeme_tag "reverse_proxy:target=http://#{node[:web_apache][:dest_fqdn]}" do
    action :add
  end unless node[:web_apache][:force_https] == "true"
end

node[:web_apache][:aliases].each do |a|
  skeme_tag "reverse_proxy:for=https://#{a}" do
    action :add
  end
  skeme_tag "reverse_proxy:for=http://#{a}" do
    action :add
  end if node[:web_apache][:proxy_http] == "true"
end if node[:web_apache][:aliases]
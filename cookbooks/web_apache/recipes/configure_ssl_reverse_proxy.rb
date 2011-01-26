accept_fqdn=node[:web_apache][:accept_fqdn]
underscored_accept_fqdn=accept_fqdn.gsub(".","_")

pkcs12_pass=node[:web_apache][:pkcs12_pass]

pkcs12_cert="/etc/apache2/ssl/#{node[:web_apache][:accept_fqdn]}.pkcs12"
rsa_pair="/tmp/#{accept_fqdn}.crt"
rsa_cert="/etc/apache2/ssl/#{node[:web_apache][:accept_fqdn]}.crt"
rsa_key="/etc/apache2/ssl/#{node[:web_apache][:accept_fqdn]}.key"

file pkcs12_cert do
  backup false
  action :nothing
end

file rsa_pair do
  backup false
  action :nothing
end

aws_s3 "Get the PKCS12 file" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:web_apache][:s3_cert_bucket]
  s3_file "#{underscored_accept_fqdn}.pkcs12"
  file_path pkcs12_cert
  action :get
end

bash "Convert PKCS12 to RSA Pair" do
  code <<-EOF
openssl pkcs12 -passin pass:#{pkcs12_pass} -in #{pkcs12_cert} -out #{rsa_pair} -nodes
  EOF
  notifies :delete, resources(:file => pkcs12_cert), :immediately
end

ruby_block "Extract pair from converted file" do
  block do
    copy_to_key = false
    copy_to_cert = false
    key = ''
    cert = ''
    ::File.new(rsa_pair, 'r').each_line do |line|
      if line =~ /-----BEGIN RSA PRIVATE KEY-----/
        key = line
        copy_to_key = true
        next
      end
      if copy_to_key
        key += line
        if line =~ /-----END RSA PRIVATE KEY-----/ then copy_to_key = false end
      end
      if line =~ /-----BEGIN CERTIFICATE-----/
        cert = line
        copy_to_cert = true
        next
      end
      if copy_to_cert
        cert += line
        if line =~ /-----END CERTIFICATE-----/ then copy_to_cert = false end
      end
    end
    ::File.open(rsa_cert, 'w') {|cert_file| cert_file.write(cert)}
    ::File.open(rsa_key, 'w') {|key_file| key_file.write(key)}
  end
  notifies :delete, resources(:file => rsa_pair), :immediately
end

apache_module "ssl"
apache_module "proxy_http"

# Disable the default site
apache_site "000-default" do
  enable false
end

docroot=::File.join(node[:web_apache][:content_dir], "#{accept_fqdn}-proxy", "htdocs", "system")

# Create the docroot, used for maintenance
directory docroot do
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

right_link_tag "reverse_proxy:for=https://#{accept_fqdn}"
right_link_tag "reverse_proxy:target=https://#{node[:web_apache][:dest_fqdn]}:#{node[:web_apache][:dest_port]}"


if node[:web_apache][:proxy_http] == "true"
  right_link_tag "reverse_proxy:for=http://#{accept_fqdn}"
  right_link_tag "reverse_proxy:target=http://#{node[:web_apache][:dest_fqdn]}" unless node[:web_apache][:force_https] == "true"
end

node[:web_apache][:aliases].each do |a|
  right_link_tag "reverse_proxy:for=https://#{a}"
  right_link_tag "reverse_proxy:for=http://#{a}" if node[:web_apache][:proxy_http] == "true"
end if node[:web_apache][:aliases]
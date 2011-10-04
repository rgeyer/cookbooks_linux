#
# Cookbook Name:: nginx
# Recipe:: setup_reverse_proxy
#
# Copyright 2011, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rs_utils_marker :begin

include_recipe "skeme::default"

accept_fqdn=node[:nginx][:accept_fqdn]
underscored_accept_fqdn=accept_fqdn.gsub(".","_")

rsa_cert="#{node[:nginx][:dir]}/ssl/#{node[:nginx][:accept_fqdn]}.crt"
rsa_key="#{node[:nginx][:dir]}/ssl/#{node[:nginx][:accept_fqdn]}.key"

do_https=node[:nginx][:proxy_https] == "true"
do_http=node[:nginx][:proxy_http] == "true"

include_recipe "nginx::setup_server"

if(do_https)
  directory "#{node[:nginx][:dir]}/ssl" do
    mode 0644
    owner "root"
    group "root"
    recursive true
    action :create
  end

  rsa_keypair_from_pkcs12 "Convert PKCS12 to RSA keypair" do
    aws_access_key_id node[:aws][:access_key_id]
    aws_secret_access_key node[:aws][:secret_access_key]
    s3_bucket node[:nginx][:s3_cert_bucket]
    s3_file "#{underscored_accept_fqdn}.pkcs12"
    rsa_cert_path rsa_cert
    rsa_key_path rsa_key
    pkcs12_pass node[:nginx][:pkcs12_pass]
  end
end

nginx_enable_vhost accept_fqdn do
  cookbook "nginx"
  template "vhost-proxy.conf.erb"
  fqdn accept_fqdn
  aliases node[:nginx][:aliases]
  dest_fqdn node[:nginx][:dest_fqdn]
  dest_port node[:nginx][:dest_port]
  listen_on_http do_http
  listen_on_https do_https
  force_https node[:nginx][:force_https] == "true"
end

skeme_tag "reverse_proxy:target=http://#{node[:nginx][:dest_fqdn]}:#{node[:nginx][:dest_port]}" do
  action :add
end

if do_https
  skeme_tag "reverse_proxy:for=https://#{accept_fqdn}" do
    action :add
  end
end

if do_http
  skeme_tag "reverse_proxy:for=http://#{accept_fqdn}" do
    action :add
  end
end

# TODO: This is illegal according to RightScale.  Each namespace:key can have only one value
node[:nginx][:aliases].each do |a|
  skeme_tag "reverse_proxy:for=https://#{a}" do
    action :add
  end if do_https
  skeme_tag "reverse_proxy:for=http://#{a}" do
    action :add
  end if do_http
end if node[:nginx][:aliases]

rs_utils_marker :end
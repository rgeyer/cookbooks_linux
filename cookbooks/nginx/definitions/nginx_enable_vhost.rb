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

define :nginx_enable_vhost, :fqdn => nil, :aliases => nil, :create_doc_root => true do
  include_recipe "skeme::default"

  fqdn = params[:fqdn] || params[:name]
  configroot = ::File.join(node[:nginx][:content_dir],fqdn,"nginx_config")
  docroot = ::File.join(node[:nginx][:content_dir],fqdn,"htdocs")
  systemroot = ::File.join(docroot, "system")

  Chef::Log.info "Setting up vhost for fqdn (#{fqdn})"

  if(params[:create_doc_root])
    # Create the sites new home
    directory systemroot do
      mode 0775
      owner node[:nginx][:user]
      group node[:nginx][:user]
      recursive true
      action :create
    end

    directory configroot do
      mode 0775
      owner node[:nginx][:user]
      group node[:nginx][:user]
      recursive true
      action :create
    end
  end

  # Create a directory for extending the vhost config
  directory "/etc/nginx/sites-available/#{fqdn}.d" do
    recursive true
    action :create
  end

  # START - The equivalent of web_app in the apache2 cookbook
  include_recipe "nginx::setup_server"

  template "#{node[:nginx][:dir]}/sites-available/#{fqdn}.conf" do
    source params[:template] || "vhost.conf.erb"
    owner "root"
    group "root"
    mode 0644
  backup false
    if params[:cookbook]
      cookbook params[:cookbook]
    end
    variables(
      :vhost_name => fqdn,
      :params => params
    )
    if ::File.exists?("#{node[:nginx][:dir]}/sites-enabled/#{fqdn}.conf")
      notifies :restart, resources(:service => "nginx"), :immediately
    end
  end

  nginx_site "#{fqdn}.conf" do
    enable enable_setting
  end
  # /END - The equivalent of web_app in the apache2 cookbook

  # TODO: This is illegal according to RightScale.  Each namespace:key can have only one value
  skeme_tag "nginx:vhost=#{fqdn}" do
    action :add
  end
end
listen_host = ""
listen_host = "127.0.0.1" unless node[:openldap][:allow_remote] == "true"

listen_port = node[:openldap][:listen_port]

%w{slapd ldap-utils}.each do |p|
  package p
end

package "Berkley DB Utils" do
  case node[:platform_version]
    when "9.10"
      package_name "db4.2-util"
    when "10.04"
      package_name "db4.7-util"
  end
  action :install
end

service "slapd" do
  action :nothing
end

template "/etc/default/slapd" do
  source "slapd.defaults.erb"
  variables( :listen_host => listen_host, :listen_port => listen_port)
  backup false
  notifies :restart, resources(:service => "slapd"), :immediately
end

# TODO: Do we need to wait for slapd to come back here, like we do in the BASH script?

if node[:platform] == "ubuntu" && node[:platform_version] == "9.10"
  openldap_execute_ldif do
    source "ubuntu-karmic-9.10-fixRootDSE.ldif"
    source_type :remote_file
  end
end

include_recipe "openldap::set_config_admin_creds"

%w{back_bdb back_hdb}.each do |mod|
  openldap_module mod do
    action :enable
  end
end

include_recipe "openldap::enable_schemas"

directory node[:openldap][:db_dir] do
  recursive true
  owner "openldap"
  group "openldap"
  action :create
end

include_recipe "openldap::create_database"
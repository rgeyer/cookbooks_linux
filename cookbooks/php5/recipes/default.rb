#
# Cookbook Name:: php5
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"

%w{php5 php5-cli smarty php-pear}.each do |pkgs|
  package pkgs do
    action :upgrade
  end
end

node[:php5][:module_list].split(' ').each do |mod|
  package "php5-#{mod}" do
    action :upgrade
  end
end

# This just sets the default include path, useful if we intend to extend it later in other
# conf.d/*.ini files.  If the default isn't already set, it will be excluded when extended
# with a statement like include_path=${include_path} ":/appended/path/to/includes"
template "/etc/php5/conf.d/include_path.ini" do
  source "include_path.ini.erb"
end
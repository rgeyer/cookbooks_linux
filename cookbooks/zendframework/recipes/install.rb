#svn export http://framework.zend.com/svn/framework/standard/branches/release-1.11/library

include_recipe "php5::default"

gzipfile="/tmp/zf.tar.gz"

file gzipfile do
  action :nothing
end

directory node[:zendframework][:library_path] do
  recursive true
  action :create
end

remote_file gzipfile do
  source "http://framework.zend.com/releases/ZendFramework-#{node[:zendframework][:version]}/ZendFramework-#{node[:zendframework][:version]}-minimal.tar.gz"
end

bash "Unzip zf to it's home" do
  code "tar --strip-components 1 -zxf #{gzipfile} -C #{node[:zendframework][:library_path]}"
  notifies :delete, resources(:file => gzipfile), :immediately
end

template "/etc/php5/conf.d/zendframework.ini" do
  source "zendframework.ini.erb"
end
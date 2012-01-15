#svn export http://framework.zend.com/svn/framework/standard/branches/release-1.11/library

include_recipe "php5::install_php"

zend_dl_uri="http://framework.zend.com/releases/ZendFramework-#{node[:zendframework][:version]}/ZendFramework-#{node[:zendframework][:version]}-minimal.tar.gz"
Chef::Log.info("About to install Zend Framework, requested version is #{node[:zendframework][:version]}, resulting in a URL request of #{zend_dl_uri}")

gzipfile="/tmp/zf.tar.gz"

directory node[:zendframework][:library_path] do
  recursive true
  action :create
end

# Using remote file is just not doing the trick, gonna go old school
#remote_file gzipfile do
#  source zend_dl_uri
#  backup false
#  action :create
#end

bash "Downloading Zend Framework #{node[:zendframework][:version]}" do
  code "wget -q -O #{gzipfile} #{zend_dl_uri}"
end

bash "Unzip zf to it's home" do
  code <<-EOF
tar --strip-components 1 -zxf #{gzipfile} -C #{node[:zendframework][:library_path]}
rm -rf #{gzipfile}
  EOF
end

template "/etc/php5/conf.d/zendframework.ini" do
  source "zendframework.ini.erb"
end
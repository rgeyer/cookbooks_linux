#
# Cookbook Name:: rjg_utils
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#include_recipe "rvm::load_environment"

#bash "Which gem yo" do
#  code "echo `which gem`"
#end
#
#bash "Here comes env" do
#  code "env"
#end

bash "Load bashrc & show me the gems" do
  code <<-EOF
rvm_bin="#{node[:rvm][:install_path]}/bin/rvm"
echo "Testing for RVM using $rvm_bin"
if [ ! -f $rvm_bin ]
then
  echo "No RVM installation found, not loading RVM environment"
  exit 0
fi

if [[ -s "#{node[:rvm][:install_path]}/environments/default" ]] ; then
  echo "Found a default RVM environment, loading it now"
  source "#{node[:rvm][:install_path]}/environments/default"
else
  echo "No default RVM environment found, can not continue.  Try setting one with rvm --default"
  exit 0
fi

default_ruby=`rvm list default string`

echo "The default RVM environment is $default_ruby"
EOF
end

#bash "Here comes env again" do
#  code "env"
#end


#rjg_utils_dir_pair "Sync some crap" do
#  source "/tmp/dir_pair_test/nslms/htdocs"
#  dest "/tmp/dir_pair_test/wpgold"
#  result_file "/tmp/dir_pair_test/diff.tar.gz"
#  action :tar
#end
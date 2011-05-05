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

bash "Load rvm scirpt & show me the gems" do
  code <<-EOF
rvm_script="#{node[:rvm][:install_path]}/scripts/rvm"
echo "Testing for RVM using $rvm_scripts"
if [ ! -f $rvm_script ]
then
  echo "No RVM installation found, not loading RVM environment"
  exit 0
fi

if [[ -s "$rvm_script" ]] ; then
  echo "Found a default RVM environment, loading it now"
  source "$rvm_script"
else
  echo "No default RVM environment found, can not continue.  Try setting one with rvm --default"
  exit 0
fi

echo "The default RVM environment is $rvm_ruby_string"

echo "Gem List coming right up"

gem list

echo "RVM Info coming right up"

rvm info
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
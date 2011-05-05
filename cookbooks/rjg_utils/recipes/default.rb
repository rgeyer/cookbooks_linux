#
# Cookbook Name:: rjg_utils
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "rvm::load_environment"

bash "Which gem yo" do
  code "echo `which gem`"
end

bash "Here comes env" do
  code "env"
end

bash "Load bashrc" do
  code "/root/.bashrc"
end

bash "Here comes env again" do
  code "env"
end
#rjg_utils_dir_pair "Sync some crap" do
#  source "/tmp/dir_pair_test/nslms/htdocs"
#  dest "/tmp/dir_pair_test/wpgold"
#  result_file "/tmp/dir_pair_test/diff.tar.gz"
#  action :tar
#end
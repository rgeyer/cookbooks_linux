#
# Cookbook Name:: rvm
# Recipe:: load_environment
#
#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

bash "Load RVM default environment (if any)" do
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
  EOF
end
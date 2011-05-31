#
# Cookbook Name:: app_wordpress
# Recipe:: deploy
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

include_recipe "app_wordpress::default"

app_wordpress_site "Deploy Wordpress for a vhost" do
  fqdn node[:app_wordpress][:vhost_fqdn]
  aliases node[:app_wordpress][:vhost_aliases]
  db_pass node[:app_wordpress][:db_pass]
  webserver node[:app_wordpress][:webserver]
  action :install
end
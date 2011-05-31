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

default[:app_wordpress][:version_store_path] = "/mnt/wordpress-home/versions"

case node[:app_wordpress][:webserver]
  when "nginx"
    default[:app_wordpress][:content_dir] = node[:nginx][:content_dir]
  when "apache2"
    default[:app_wordpress][:content_dir] = node[:web_apache][:content_dir]
end

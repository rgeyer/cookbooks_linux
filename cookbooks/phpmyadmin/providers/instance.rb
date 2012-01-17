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

action :create do
  version = new_resource.version
  tar_name = "phpMyAdmin-#{version}-all-languages.tar.gz"
  tar_path = ::File.join("/tmp", tar_name)
  remote_source = "http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/#{version}/#{tar_name}"
  home = new_resource.home
  user = new_resource.user

  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

  newpass = ""
  1.upto(16) { |i| newpass << chars[rand(chars.size-1)] }

  bfsecret = ""
  1.upto(16)  { |i| bfsecret << chars[rand(chars.size-1)] }

  directory home do
    recursive true
    action :create
  end

  package "#{node[:php5][:package_prefix]}mcrypt"

  remote_file tar_path do
    backup false
    source remote_source
  end

  bash "Unzip tarfile" do
    code <<-EOF
tar -zxf #{tar_path} --strip-components=1 -C #{home}
    EOF
  end

  bash "Create phpmyadmin database and tables" do
    code <<-EOF
mysql < #{::File.join(home, "scripts", "create_tables.sql")}
    EOF
  end

  db_mysql_set_privileges "Create pma user and give permissions to phpmyadmin db" do
    preset "user"
    username "pma"
    password newpass
  end

  template ::File.join(home, "config.inc.php") do
    cookbook "phpmyadmin"
    source "config.inc.php.erb"
    backup false
    variables({:blowfish_secret => bfsecret, :pmapass => newpass})
  end

  bash "Make sure file permissions are right" do
    code <<-EOF
chown -R #{user}:#{user} #{home}
    EOF
  end

end
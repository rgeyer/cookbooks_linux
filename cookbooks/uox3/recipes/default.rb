#
# Cookbook Name:: uox3
# Recipe:: default
#
# Copyright 2012, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rs_utils_marker :begin

client_dir = ::File.join(node[:uox3][:install_dir], 'client')
shard_dir = ::File.join(node[:uox3][:install_dir], 'shard')
uoxbin_path = ::File.join(shard_dir, 'uox3')
uoxbinzip_path = '/tmp/uox3bin.zip'
uoxscriptszip_path = '/tmp/uox3scripts.zip'
worldfilerar_path = '/tmp/worldfiles.rar'
worldfiles_path = ::File.join(shard_dir, 'shared')
spawnfilezip_path = '/tmp/spawnfile.zip'
spawnfile_path = ::File.join(shard_dir, 'dfndata', 'spawn', 'spawn.dfn')
uoxinifile_path = ::File.join(shard_dir, 'uox.ini')
accountfile_path = ::File.join(shard_dir, 'accounts', 'accounts.adm')
convert_binary = value_for_platform('centos' => {'default' => 'dos2unix'}, 'ubuntu' => {'default' => 'fromdos'})

# Enable collectd exec plugin
rs_utils_enable_collectd_plugin "exec"

if node[:platform] == 'ubuntu'
  %w{libc6-i386 ia32-libs tofrodos unrar}.each do |p|
    package p
  end
end

if node[:platform] == 'centos'
  package 'dos2unix'

  # Install RPMForge then bruteforce all the cache clearing
  bash "Setup RPMForge" do
    cwd '/tmp'
    code <<-EOF
      wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
      rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
      rpm -i rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
      yum -q makecache
    EOF
    not_if ::File.exists?('/etc/yum.repos.d/rpmforge.repo')
  end

  ruby_block "reload-internal-yum-cache" do
    block do
      Chef::Provider::Package::Yum::YumCache.instance.reload
    end
  end

  package 'unrar'
end

user 'uox3'
group 'uox3'

# Attach or restore a block device
directory client_dir do
  owner 'uox3'
  group 'uox3'
  recursive true
  action :create
end

# Search for client files, if missing grab them from ROS
if !::File.directory?(client_dir) || Dir[::File.join(client_dir, '*')].empty?
  prefix       = node[:uox3][:client][:prefix]
  dumpfilepath = "/tmp/" + prefix + ".gz"
  container    = node[:uox3][:client][:container]
  cloud        = node[:uox3][:client][:storage_account_provider]

  file dumpfilepath do
    backup false
    action :nothing
  end

  # Obtain the client files from ROS
  execute "Download UO Multis/Client files from Remote Object Store" do
    command "/opt/rightscale/sandbox/bin/ros_util get --cloud #{cloud} --container #{container} --dest #{dumpfilepath} --source #{prefix} --latest"
    creates dumpfilepath
    environment ({
      'STORAGE_ACCOUNT_ID' => node[:uox3][:client][:storage_account_id],
      'STORAGE_ACCOUNT_SECRET' => node[:uox3][:client][:storage_account_secret]
    })
  end

  execute "Extract UO Multis/Client files to the client directory" do
    user 'uox3'
    command "tar -zxf #{dumpfilepath} -C #{node[:uox3][:install_dir]}"
    notifies :delete, "file[#{dumpfilepath}]", :immediately
  end
end

# Search for UOX3 binary, if missing download it from UOX (ubuntu) or the cookbook file (centos)
directory shard_dir do
  owner 'uox3'
  group 'uox3'
  recursive true
  action :create
end

if Dir[::File.join(shard_dir, '*')].empty?
  # Search for a backup file first, only bootstrap in it's absence
  shard_prefix       = node[:uox3][:shard][:prefix]
  shard_container    = node[:uox3][:shard][:container]
  shard_cloud        = node[:uox3][:shard][:storage_account_provider]

  if 0 < `STORAGE_ACCOUNT_ID=#{node[:uox3][:shard][:storage_account_id]} STORAGE_ACCOUNT_SECRET=#{node[:uox3][:shard][:storage_account_secret]} /opt/rightscale/sandbox/bin/ros_util list --cloud #{shard_cloud} --container #{shard_container} | grep "^#{shard_prefix}-[0-9]*\.gz" | wc -l`.to_i

    uox_shard_restore "Restore the shard" do
      prefix shard_prefix
      container shard_container
      cloud shard_cloud
    end

    # TODO: Should probably always overwrite the binary, allowing switching between ubuntu & centos

  else

    # The binary first
    if node[:platform] == 'ubuntu'
      remote_file uoxbinzip_path do
        source 'http://www.uox3.org/files/uox3binarylinux_0_99_1.zip'
      end

      bash "Unzip binary and set permissions" do
        user 'uox3'
        code <<-EOF
          unzip #{uoxbinzip_path} -d #{shard_dir}
          chown uox3:uox3 #{uoxbin_path}
          chmod a+x #{uoxbin_path}
        EOF
      end

    elsif node[:platform] == 'centos'
      cookbook_file uoxbin_path do
        source 'uox3_centos_5.6_i386'
        owner 'uox3'
        group 'uox3'
        mode 0755
      end
    end

    # Base scripts next
    remote_file uoxscriptszip_path do
      source 'http://www.uox3.org/files/uox3linuxscripts_0_99_1.zip'
    end

    execute "Unzip base scripts" do
      user 'uox3'
      command "unzip #{uoxscriptszip_path} -d #{shard_dir}"
    end

    # World files yo
    remote_file worldfilerar_path do
      source 'http://www.xoduz.org/files/uox3/defaultWorldfile015.rar'
    end

    bash "Unrar and convert world files" do
      user 'uox3'
      cwd worldfiles_path
      code <<-EOF
        unrar e -o+ #{worldfilerar_path}
        for i in `ls #{worldfiles_path}`; do #{convert_binary} $i; done
      EOF
    end

    # Spawn files too
    remote_file spawnfilezip_path do
      source 'http://home.arcor.de/matthias.nies/binary/dfndata.zip'
    end

    bash "Unzip and convert spawn file" do
      user 'uox3'
      cwd shard_dir
      code <<-EOF
        unzip -o #{spawnfilezip_path}
        #{convert_binary} #{spawnfile_path}
      EOF
    end
  end
end

# Configuration for servername/ip, default admin password, shard name, etc (do this every time)
template uoxinifile_path do
  owner 'uox3'
  group 'uox3'
  source "uox.ini.erb"
  backup false
  variables :client_dir => client_dir
end

template accountfile_path do
  owner 'uox3'
  group 'uox3'
  source "accounts.adm.erb"
  backup false
end

sys_firewall "2593"

template "/etc/init.d/uox3" do
  source "init.d.erb"
  backup false
  mode 00750
  variables :shard_dir => "#{shard_dir}/"
end

service "uox3" do
  supports :status => true, :start => true, :stop => true
  action [ :enable, :start ]
end

sys_dns "default" do
  id node[:uox3][:dns_id]
  address node[:cloud][:public_ips][0]

  action :set_private
end

# Monitoring bits
template ::File.join(node[:uox3][:install_dir], 'uox3.sh') do
  source "uox3.sh.erb"
  mode 00755
  backup false
  variables :screenlog => ::File.join(shard_dir, 'screenlog.0')
end

template ::File.join(node[:rs_utils][:collectd_plugin_dir], 'uox3.conf') do
  source "uox3.conf.erb"
  mode 00644
  backup false
  variables :scriptpath => ::File.join(node[:uox3][:install_dir], 'uox3.sh')
  notifies :restart, resources(:service => "collectd")
end

rs_utils_logrotate_app "uox3_screenlog" do
  cookbook "uox3"
  template "logrotate.erb"
  path [::File.join(shard_dir, 'screenlog.0')]
  frequency "daily"
  rotate 4
  create "660 uox3 uox3"
end

# HTML hosting of appropriate stuff

rs_utils_marker :end
#
# Cookbook Name:: uox3
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

rs_utils_marker :begin

# http://www.uo.com/uoml/downloads.shtml
# http://www.uox3.org/forums/viewtopic.php?f=6&t=457&hilit=how+to+compile

client_dir = ::File.join(node[:uox3][:install_dir], 'client')
shard_dir = ::File.join(node[:uox3][:install_dir], 'shard')
uoxbin_path = ::File.join(shard_dir, 'uox3')
uoxbinzip_path = '/tmp/uox3bin.zip'
uoxscriptszip_path = '/tmp/uox3scripts.zip'
worldfilerar_path = '/tmp/worldfiles.rar'
worldfiles_path = ::File.join(shard_dir, 'shared')
spawnfilezip_path = '/tmp/spawnfile.zip'
spawnfile_path = ::File.join(shard_dir, 'dfndata', 'spawn', 'spawn.dfn')

convert_binary = value_for_platform('centos' => {'default' => 'dos2unix'}, 'ubuntu' => {'default' => 'fromdos'})

if node[:platform] == 'ubuntu'
  %w{libc6-i386 ia32-libs tofrodos}.each do |p|
    package p
  end
end

if node[:platform] == 'centos'
  package 'dos2unix'

  bash "Setup RPMForge" do
    cwd '/tmp'
    code <<-EOF
      wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
      rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
      rpm -i rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
      yum update
    EOF
    not_if ::File.exists?('/etc/yum.repos.d/rpmforge.repo')
  end
end

package 'unrar'

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
    command "tar -zxf #{dumpfilepath} -C #{client_dir}"
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
      unrar e #{worldfilerar_path}
      find i in `ls #{worldfiles_path}`; do #{convert_binary} $i; done
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
      unzip #{spawnfilezip_path}
      #{convert_binary} #{spawnfile_path}
    EOF
  end
end

# Configuration for servername/ip, default admin password, shard name, etc (do this every time)

# Figure out how to daemonize properly, and put that in here

# HTML hosting of appropriate stuff

rs_utils_marker :end
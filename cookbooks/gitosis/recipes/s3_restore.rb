# TODO: This assumes that we're going to successfully find, download, and unpack a backup
# not really an assumption I'm comfortable making.  Needs some more thought..
directory node[:gitosis][:gitosis_home] do
  owner node[:gitosis][:uid]
  group node[:gitosis][:gid]
  mode "0750"
  recursive true
  action :delete
end

directory node[:gitosis][:gitosis_home] do
  owner node[:gitosis][:uid]
  group node[:gitosis][:gid]
  mode "0750"
  recursive true
  action :create
end

aws_s3 "Download gitosis backup to S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:gitosis][:s3_bucket]
  s3_file_prefix node[:gitosis][:backup_prefix]
  file_path "/tmp/gitosis.tar.gz"
  action :get
  notifies :create, resources(:directory => node[:gitosis][:gitosis_home]), :immediately
end

bash "Unpack the backup" do
  code <<-EOF
tar -zxf /tmp/gitosis.tar.gz -C #{node[:gitosis][:gitosis_home]}
chown -R #{node[:gitosis][:uid]}:#{node[:gitosis][:gid]} #{node[:gitosis][:gitosis_home]}
rm -rf /tmp/gitosis.tar.gz
chown 750 #{node[:gitosis][:gitosis_home]}
  EOF
end

link "#{node[:gitosis][:gitosis_home]}/.gitosis.conf" do
  to "#{node[:gitosis][:gitosis_home]}/repositories/gitosis-admin.git/gitosis.conf"
end
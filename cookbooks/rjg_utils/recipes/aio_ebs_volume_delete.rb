include_recipe "aws::default"

bash "Freeze the xfs file system for #{node[:rjg_utils][:aio_ebs_mountpoint]}" do
  code "xfs_freeze -f #{node[:rjg_utils][:aio_ebs_mountpoint]}"
end

# TODO: Is it possible to do this, even with processes running? I suspect not..
mount node[:rjg_utils][:aio_ebs_mountpoint] do
  device "/dev/sdi"
  fstype "xfs"
  action [:umount, :disable]
end

aws_ebs_volume "aio_ebs-#{node[:rjg_utils][:rs_instance_uuid]}" do
  aws_access_key node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  action [:detach, :delete]
end
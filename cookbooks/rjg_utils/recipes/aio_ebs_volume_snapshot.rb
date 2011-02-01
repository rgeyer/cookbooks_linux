include_recipe "aws::default"

bash "Freeze the xfs file system for #{node[:rjg_utils][:aio_ebs_mountpoint]}" do
  code "xfs_freeze -f #{node[:rjg_utils][:aio_ebs_mountpoint]}"
end

aws_ebs_volume "aio_ebs-#{node[:rjg_utils][:rs_instance_uuid]}" do
  aws_access_key node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  action [:snapshot]
end

bash "Unfreeze the xfs file system for #{node[:rjg_utils][:aio_ebs_mountpoint]}" do
  code "xfs_freeze -u #{node[:rjg_utils][:aio_ebs_mountpoint]}"
end
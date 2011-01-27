include_recipe "aws::default"

aws_ebs_volume "aio_ebs-#{node[:rjg_utils][:rs_instance_uuid]}" do
  aws_access_key node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  action [:snapshot]
end
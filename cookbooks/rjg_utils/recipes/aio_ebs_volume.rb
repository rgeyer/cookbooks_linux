include_recipe "aws::default"

package "xfsprogs"

aws_ebs_volume "aio_ebs-#{node[:rjg_utils][:rs_instance_uuid]}" do
  aws_access_key node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  device "/dev/sdi"
  size node[:rjg_utils][:aio_ebs_size_in_gb].to_i
  unless node[:rjg_utils][:aio_ebs_snapshot_id] == "blank"
    snapshot_id node[:rjg_utils][:aio_ebs_snapshot_id]
  end
  action [:create, :attach]
end

bash "Format the AIO EBS volume" do
  user "root"
  code <<-EOF
grep -q xfs /proc/filesystems || modprobe xfs
mkfs.xfs /dev/sdi
  EOF
  not_if "mount --fake /dev/sdi /dev/null"
end

mount node[:rjg_utils][:aio_ebs_mountpoint] do
  device "/dev/sdi"
  fstype "xfs"
  action [:mount, :enable]
end
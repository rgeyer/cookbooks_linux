include_recipe "rjg_aws::default"

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

# TODO: This is a total hack, but if I don't do it, the mount command below fails when I'm attaching
# a new volume from a snapshot.  Probably a symptom of another problem but this seems to fix it.
ruby_block "Wait for /dev/sdi" do
  block do
    while !::File.exist?('/dev/sdi') do
      sleep(2)
    end
  end
end


bash "Format the AIO EBS volume" do
  user "root"
  code <<-EOF
grep -q xfs /proc/filesystems || modprobe xfs
mkfs.xfs -q /dev/sdi
  EOF
  # not_if and only_if run at compile time, when the device wouldn't exist.  I could add an if statement in
  # the bash code, or make an assumption that if I'm creating a new ebs volume (always the case when no snapshot id
  # is supplied) it needs to be formatted.
  #not_if "mkfs.xfs -N /dev/sdi | grep mkfs.xfs"
  only_if {node[:rjg_utils][:aio_ebs_snapshot_id] == "blank"}
end

mount node[:rjg_utils][:aio_ebs_mountpoint] do
  device "/dev/sdi"
  fstype "xfs"
  action [:mount, :enable]
end
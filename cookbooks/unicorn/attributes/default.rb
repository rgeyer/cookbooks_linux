default[:unicorn][:version] = nil
# TODO: Copied from OpsCode sample application recipe, maybe we want something a bit more scientific?
default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min

if node.ec2
  default[:unicorn][:log_path] = "/mnt/log/unicorn"
else
  default[:unicorn][:log_path] = "/var/log/unicorn"
end
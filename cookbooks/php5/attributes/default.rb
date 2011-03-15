default[:php5][:module_list]    = ""
default[:php5_fpm][:listen] = "unix:/var/run/php5-fpm.sock"

if node.ec2
  default[:php5][:fpm_log_dir]  = "/mnt/log/php5-fpm"
else
  default[:php5][:fpm_log_dir]  = "/var/log/php5-fpm"
end
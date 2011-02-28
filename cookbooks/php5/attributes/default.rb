default[:php5][:module_list]    = ""

if node.ec2
  default[:php5][:fpm_log_dir]  = "/mnt/log/php5-fpm"
else
  default[:php5][:fpm_log_dir]  = "/var/log/php5-fpm"
end
default[:php5][:module_list]        = ""
default[:php5_fpm][:listen]         = "socket"
default[:php5_fpm][:listen_socket]  = "/var/run/php5-fpm.sock"
default[:php5_fpm][:listen_ip]      = "127.0.0.1"
default[:php5_fpm][:listen_port]    = "9000"

if node.ec2
  default[:php5][:fpm_log_dir]  = "/mnt/log/php5-fpm"
else
  default[:php5][:fpm_log_dir]  = "/var/log/php5-fpm"
end
default[:php5][:module_list]        = ""
default[:php5_fpm][:listen]         = "socket"
default[:php5_fpm][:listen_socket]  = "/var/run/php5-fpm.sock"
default[:php5_fpm][:listen_ip]      = "127.0.0.1"
default[:php5_fpm][:listen_port]    = "9000"

case node[:platform]
  when "centos", "rhel"
    case
      when node[:platform_version].to_f > 5.4
        default[:php5][:packages_remove] = %w{php php-cli php-common}
        default[:php5][:packages] = %w{php53u php53u-cli php53u-pear}
        default[:php5][:package_prefix] = "php53u-"
        default[:php5][:conf_d_path] = "/etc/php.d"
        default[:php5_fpm][:service_name] = "php-fpm"
        default[:php5_fpm][:configfile] = "/etc/php-fpm.conf"
    end
  when "ubuntu"
    case node[:platform_version]
      when "10.04"
        default[:php5][:packages_remove] = []
        default[:php5][:packages] = %w{php5-cgi php5-cli php-pear}
        default[:php5][:package_prefix] = "php5-"
        default[:php5][:conf_d_path] = "/etc/php5/conf.d"
        default[:php5_fpm][:service_name] = "php5-fpm"
        default[:php5_fpm][:configfile] = "/etc/php5/fpm/main.conf"
    end
end

if attribute?(:ec2)
  default[:php5][:fpm_log_dir]  = "/mnt/log/php5-fpm"
else
  default[:php5][:fpm_log_dir]  = "/var/log/php5-fpm"
end
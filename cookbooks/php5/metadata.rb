maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures php5, pear, and smarty"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.2"

recipe "php5::install_php", "Performs the installation of php5, pear, and the smarty template library.  Additional modules can be specified at runtime"
recipe "php5::install_fpm", "Installs the PHP-FPM FastCGI manager"
recipe "php5::setup_fpm_nginx", "Enables PHP FPM for nginx by including the fastcgi parameters file"
recipe "php5::setup_fpmstats_nginx", "Enables collectd monitoring where PHP FPM is used with nginx"

%w{ubuntu centos}.each do |s|
  supports s
end

depends "rightscale"

recommends "nginx"
recommends "web_apache"
recommends "runit"

attribute "php5",
  :display_name => "php5 hash",
  :description => "php5",
  :type => "hash"

attribute "php5/module_list",
  :display_name => "PHP5 Module List",
  :description => "A list of PHP5 modules to install, separated by spaces. Only supply the module name appearing after php5-.  For instance if you wanted php5-mysql and php5-imap installed, this list should be set to \"mysql imap\".  To view a full list of available php5 modules see the Ubuntu package page http://packages.ubuntu.com/search?searchon=names&keywords=php5- ",
  :default => "",
  :recipes => ["php5::install_php"],
  :type => "string"

attribute "php5/server_usage",
  :display_name => "Server Usage",
  :description => "* dedicated (where the php-fpm config file allocates all existing resources of the machine)\n* shared (where the php-fpm config file is configured to use less resources so that it can be run concurrently with other apps like MySQL for example)",
  :recipes => [ "php5::install_fpm" ],
  :choice => ["shared", "dedicated"],
  :default => "dedicated"

attribute "php5/listen",
  :display_name => "PHP5 FPM Listen Method",
  :description => "The listening method, one of [socket, tcp].  If socket is selected, php5/listen_socket can optionally be supplied.  If tcp is selected, php5/listen_ip and php5/listen_port can optionally be supplied",
  :recipes => [ "php5::install_fpm" ],
  :choice => ["socket", "tcp"],
  :default => "socket"

attribute "php5/listen_socket",
  :display_name => "PHP5 FPM Listen Socket",
  :description => "The full path and filename of the unix socket to listen on",
  :recipes => [ "php5::install_fpm" ],
  :required => "optional",
  :default => "/var/run/php5-fpm.sock"

attribute "php5/listen_ip",
  :display_name => "PHP5 FPM Listen IP",
  :description => "The TCP/IP address for PHP-FPM to listen on",
  :recipes => [ "php5::install_fpm" ],
  :required => "optional",
  :default => "127.0.0.1"

attribute "php5/listen_port",
  :display_name => "PHP5 FPM Listen",
  :description => "The TCP/IP address for PHP-FPM to listen on",
  :recipes => [ "php5::install_fpm" ],
  :required => "optional",
  :default => "9000"

# This is really just to create a directory for the logfile(s), and is set based on the environment in the default attributes. Don't see
# a need to allow the user to define this for now
#attribute "php5/fpm_log_dir",
#  :display_name => "PHP5-FPM Log Directory",
#  :description => "The full path to the php5-fpm error log directory.",
#  :recipes => ["php5::fpm"],
#  :default => ["/var/log/php5-fpm"]

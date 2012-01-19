maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures openldap"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rs_utils"

supports "ubuntu"

recipe "openldap::install_openldap", "Installs a basic, working OpenLDAP server daemon"
recipe "openldap::setup_rightscale_syslog", "Appends configuration for OpenLDAP to the RightScale syslog configuration."
recipe "openldap::setup_config_admin_creds", "Sets the CN (Common Name) and password for the configuration admin"
recipe "openldap::do_create_database", "Creates a new database to contain records for the specified base_dn"
recipe "openldap::do_enable_schemas", "Enables the OpenLDAP schemas listed"

attribute "openldap/allow_remote",
  :display_name => "OpenLDAP Allow Remote?",
  :description => "A boolean indicating if the OpenLDAP server should accept remote connections or not",
  :choice => ["true", "false"],
  :required => "required",
  :recipes => ["openldap::install_openldap"]

attribute "openldap/listen_port",
  :display_name => "OpenLDAP listen port",
  :description => "The TCP/IP port the OpenLDAP server should listen on",
  :default => "389",
  :recipes => ["openldap::install_openldap"]

attribute "openldap/config_admin_cn",
  :display_name => "OpenLDAP Config Admin CN",
  :description => "The desired \"Common Name\" for the slapd configuration (cn=config) administrator",
  :required => "required",
  :recipes => ["openldap::install_openldap", "openldap::setup_config_admin_creds"]

attribute "openldap/config_admin_password",
  :display_name => "OpenLDAP Config Admin password",
  :description => "The desired password for the slapd configuration (cn=config) administrator",
  :required => "required",
  :recipes => ["openldap::install_openldap", "openldap::setup_config_admin_creds"]

attribute "openldap/schemas",
  :display_name => "OpenLDAP Schemas",
  :description => "A list (in the form of an array) of schemas to install",
  :type => "array",
  :default => ["core","cosine","inetorgperson"],
  :recipes => ["openldap::install_openldap", "openldap::do_enable_schemas"]

attribute "openldap/database_admin_cn",
  :display_name => "OpenLDAP Database Admin CN",
  :description => "The desired \"Common Name\" for the administrator of the new database",
  :required => "required",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/database_admin_password",
  :display_name => "OpenLDAP Config Admin password",
  :description => "The desired password for the administrator of the new database",
  :required => "required",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/base_dn",
  :display_name => "OpenLDAP Database Base DN",
  :description => "The base DN of the new database to create, if left blank the new database will contain all DN's other than cn=config",
  :default => "blank",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/db_type",
  :display_name => "OpenLDAP Database Type",
  :description => "The OpenLDAP database type, currently only bdb and hdb are supported",
  :choice =>  ["hdb","bdb"],
  :default => "hdb",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/cache_size",
  :display_name => "OpenLDAP Database Cache Size",
  :description => "A Berkley DB tuning setting, leave it as \"0 2097152 0\" if you don't know what you're doing.",
  :default => "0 2097152 0",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/max_objects",
  :display_name => "OpenLDAP Database Max Objects",
  :description => "A Berkley DB tuning setting, leave it as \"1500\" if you don't know what you're doing.",
  :default => "1500",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/max_locks",
  :display_name => "OpenLDAP Database Max Locks",
  :description => "A Berkley DB tuning setting, leave it as \"1500\" if you don't know what you're doing.",
  :default => "1500",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/max_lockers",
  :display_name => "OpenLDAP Database Max Lockers",
  :description => "A Berkley DB tuning setting, leave it as \"1500\" if you don't know what you're doing.",
  :default => "1500",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]

attribute "openldap/checkpoint",
  :display_name => "OpenLDAP Database Checkpoint",
  :description => "A Berkley DB tuning setting, leave it as \"512 30\" if you don't know what you're doing.",
  :default => "512 30",
  :recipes => ["openldap::install_openldap", "openldap::do_create_database"]
default[:mail_postfix][:db_user]  = "postfix"
default[:mail_postfix][:db_name]  = "postfix"
default[:mail_postfix][:db_host]  = "localhost"
if node[:platform] == "ubuntu"
  default[:mail_postfix][:packages] = ["postfix", "postfix-mysql"]
elsif node[:platform] == "centos"
  default[:mail_postfix][:packages] = ["postfix"]
end

# When we get a little more adventerous and start handling local mail delivery
#default[:mail_postfix][:packages] = ["postfix", "postfix-mysql", "dovecot-common", "dovecot-imapd", "dovecot-pop3d"]

# Defaults for postfix installation
default[:postfix][:smtp_sasl_auth_enable] = "no"
default[:postfix][:mail_type]             = "master"
default[:postfix][:myhostname]            = fqdn
default[:postfix][:mydomain]              = domain
default[:postfix][:myorigin]              = "$myhostname"
default[:postfix][:relayhost]             = ""
default[:postfix][:mail_relay_networks]   = "127.0.0.0/8"

default[:mail_postfix][:backup_history_to_keep] = 7
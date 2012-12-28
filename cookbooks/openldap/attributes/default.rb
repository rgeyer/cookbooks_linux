default[:openldap][:listen_port]  = "389"
default[:openldap][:schemas]      = ["core","cosine","inetorgperson"]
default[:openldap][:db_dir]       = "/mnt/slapd"
default[:openldap][:cache_size]   = "0 2097152 0"
default[:openldap][:max_objects]  = "1500"
default[:openldap][:max_locks]    = "1500"
default[:openldap][:max_lockers]  = "1500"
default[:openldap][:checkpoint]   = "512 30"
default[:openldap][:db_type]      = "hdb"

case node[:platform]
  when "centos","rhel","redhat","amazon","scientific"
    default[:openldap][:packages] = ["openldap-servers","openldap-clients","db4-utils"]
    default[:openldap][:config_dir] = "/etc/openldap"
    default[:openldap][:username] = "ldap"
    default[:openldap][:group] = "ldap"
  when "ubuntu"
    packages = ["slapd","ldap-utils"]
    case node[:platform_version]
      when "9.10"
        packages << "db4.2-util"
      when "10.04"
        packages << "db4.7-util"
    end
    default[:openldap][:packages] = packages

    default[:openldap][:config_dir] = "/etc/ldap"
    default[:openldap][:username] = "openldap"
    default[:openldap][:group] = "openldap"
end
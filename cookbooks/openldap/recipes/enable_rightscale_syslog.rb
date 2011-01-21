include_recipe "rs_utils::setup_logging"

ruby_block "Append OpenLDAP logging to RightScale syslog" do
  block do
    openldap_config = <<-EOF

# log slapd to a file and the RS syslog dashboard
destination d_ldap {
  file("/var/log/slapd");
  # Redirect from local4.debug to local1.notice because the RS syslog apparently doesn't like *.debug & just throws it away
  program("logger -p local1.notice" template("slapd \\$MSG\\n"));
};
# Match only local4 so we don't have an infinite loop of catching slapd messages on local1 and local4
filter f_ldap { facility(local4) and match(slapd); };
log { source(s_sys); filter(f_ldap); destination(d_ldap); };

    EOF
    ::File.open("/etc/syslog-ng/syslog-ng.conf", "a") {|f| f.write(openldap_config)}
  end
  notifies :restart, resources(:service => "syslog-ng")
end
#
# Cookbook Name:: openldap
# Recipe:: setup_rightscale_syslog
#
# Copyright 2011, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rightscale_marker :begin

include_recipe "rightscale::setup_logging"

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
  only_if `grep d_ldap /etc/syslog-ng/syslog-ng.conf` == ""
  notifies :restart, resources(:service => "syslog-ng")
end

rightscale_marker :end
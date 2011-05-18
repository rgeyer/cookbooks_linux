# Load the rrdtool plugin in the main config file
rs_utils_enable_collectd_plugin "rrdtool"
#node[:rs_utils][:plugin_list] += " rrdtool" unless node[:rs_utils][:plugin_list] =~ /rrdtool/

include_recipe "rs_utils::setup_monitoring"

# Nuke & recreate the rrd directory
directory "/var/lib/collectd/rrd" do
  recursive true
  mode 0755
  owner "root"
  group "root"
  action [:delete, :create]
end

file ::File.join(node[:rs_utils][:collectd_plugin_dir], "rrdtool.conf") do
  content <<-EOF
#LoadPlugin rrdtool
<Target "write">
  Plugin "rrdtool"
</Target>
  EOF
  mode 0644
  owner "root"
  group "root"
  backup false
  notifies :restart, resources(:service => "collectd")
  action :create
end

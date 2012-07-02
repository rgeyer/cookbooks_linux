# Load the rrdtool plugin in the main config file
rightscale_enable_collectd_plugin "rrdtool"
#node[:rightscale][:plugin_list] += " rrdtool" unless node[:rightscale][:plugin_list] =~ /rrdtool/

include_recipe "rightscale::setup_monitoring"

# Nuke & recreate the rrd directory
directory "/var/lib/collectd/rrd" do
  recursive true
  mode 0755
  owner "root"
  group "root"
  action [:delete, :create]
end

file ::File.join(node[:rightscale][:collectd_plugin_dir], "rrdtool.conf") do
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

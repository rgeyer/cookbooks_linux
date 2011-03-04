include_recipe "rs_utils::setup_monitoring"

# Nuke & recreate the rrd directory
directory "/var/lib/collectd/rrd" do
  recursive true
  mode 0755
  owner "root"
  group "root"
  action [:delete, :create]
end

ruby_block "Fix BaseDir Directive" do
  block do
    # Replace <BaseDir   "/var/lib/collectd"> with <BaseDir   "/var/lib/collectd/rrd">
    lines = ::File.readlines(node[:rs_utils][:collectd_config])
    ::File.open(node[:rs_utils][:collectd_config], "w") do |f|
      lines.each { |line|
        line.gsub!(/^BaseDir.*$/, 'BaseDir   "/var/lib/collectd/rrd"')
        f.puts(line)
      }
    end
  end
end

file ::File.join(node[:rs_utils][:collectd_plugin_dir], "rrdtool.conf") do
  content <<-EOF
LoadPlugin rrdtool
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

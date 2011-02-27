#::Dir.foreach(node[:web_apache][:content_dir]) {|fileordir|
::Dir.foreach("/srv/www") {|fileordir|
  if (File.directory? fileordir)
    Chef::Log.info "Checking vhost dir #{fileordir}"
    if (File.exist? "#{fileordir}/wordpress.attr.js")
      Chef::Log.info "#{fileordir} appears to be a wordpress vhost, attempting backup"
      node[:web_apache][:vhost_fqdn] = fileordir
      include_recipe "app_wordpress::s3_backup"
    end
  end
}
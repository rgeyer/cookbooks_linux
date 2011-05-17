def update_latest_version()
  require 'net/http'
  require 'uri'

  url = URI.parse('http://api.wordpress.org/core/version-check/1.5/')
  req = Net::HTTP::Get.new(url.path)
  res = Net::HTTP.start(url.host, url.port) { |http|
    http.request(req)
  }

  latest_version_num = res.body.split("\n")[3]
  latest_version_dir = "#{node[:app_wordpress][:version_store_path]}/#{latest_version_num}"

  if !::File.exist? latest_version_dir
    directory latest_version_dir do
      recursive true
      action :create
    end

    bash "Downloading Wordpress #{latest_version_num}" do
      code "wget -q -O #{latest_version_dir}/wordpress.tar.gz http://wordpress.org/wordpress-#{latest_version_num}.tar.gz"
    end

#    remote_file "#{latest_version_dir}/wordpress.tar.gz" do
#      source "http://wordpress.org/wordpress-#{latest_version_num}.tar.gz"
#      backup false
#    end

    link "#{node[:app_wordpress][:version_store_path]}/latest" do
      to latest_version_dir
    end
  end
end

def current_version(path)
  version = nil
  regex = /^\$wp_version\s*=\s*'(.*)'/
  ver_file = ::File.new("#{path}/wp-includes/version.php", "r")
  ver_file.each_line do |line|
    match = regex.match line
    if match && match[1] then version = match[1] end
  end
  return version
end

action :install do
  require 'net/http'
  require 'uri'

  fqdn = new_resource.fqdn
  aliases = new_resource.aliases
  db_pass = new_resource.db_pass

  underscored_fqdn = fqdn.gsub(".", "_")
  underscored_fqdn_16 = underscored_fqdn.slice(0..15)
  vhost_dir = "#{new_resource.content_dir}/#{fqdn}"
  install_dir = "#{vhost_dir}/htdocs"

  Chef::Log.info "Installing a wordpress instance for vhost #{fqdn}"

  # This step creates the directory, so lets do that first
  if new_resource.webserver == "apache2"
    web_apache_enable_vhost fqdn do
      fqdn fqdn
      aliases aliases
      allow_override "FileInfo"
    end
  else
    nginx_enable_vhost fqdn do
      cookbook "app_wordpress"
      template "nginx.conf.erb"
      fqdn fqdn
      aliases aliases
    end
  end

  mysql_database "Create database for this wordpress instance" do
    host "localhost"
    username "root"
    database underscored_fqdn
    action :create_db
  end

  # Grant permissions to the mysql database for this wordpress instance
  db_mysql_set_privileges "Create and authorize wordpress MySQL user" do
    preset "user"
    username underscored_fqdn_16
    password db_pass
    db_name underscored_fqdn
  end

  unless ::File.directory? install_dir

    update_latest_version()

    execute "untar wordpress" do
      cwd "#{node[:app_wordpress][:version_store_path]}/latest"
      command "tar --strip-components 1 -zxf wordpress.tar.gz -C #{install_dir}"
    end

    url = URI.parse('http://api.wordpress.org/secret-key/1.1/')
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }

    # TODO: By leaving this in this block, if a different DB password is provided, things will break.
    # May want to reconsider the unless ::File.directory? above
    template "#{install_dir}/wp-config.php" do
      source "wp-config.php.erb"
      mode 0400
      owner "www-data"
      group "www-data"
      variables(
        :db_name => underscored_fqdn,
        :username => underscored_fqdn_16,
        :auth_unique_keys => res.body,
        :db_pass => db_pass,
        :db_host => "localhost"
      )
    end

  end

  if new_resource.webserver == "nginx"
    bash "Downloading nginx compatibility plugin" do
      cwd "#{install_dir}/wp-content/plugins"
      code <<-EOF
wget -q -O nginx-compatibility.zip http://downloads.wordpress.org/plugin/nginx-compatibility.0.2.5.zip
unzip nginx-compatibility.zip
rm -rf nginx-compatibility.zip
      EOF
      not_if ::File.directory? "#{install_dir}/wp-content/plugins/nginx-compatibility"
    end
  end

  skeme_tag "wordpress:vhost=#{fqdn}" do
    action :add
  end
end

action :update do
  fqdn = new_resource.fqdn
  tempDir = "/tmp/wordpress"
  install_dir = "#{new_resource.content_dir}/#{fqdn}/htdocs"
  wpcontent_dir = "#{install_dir}/wp-content"

  if ::File.directory? wpcontent_dir
    update_latest_version()
    version = current_version(install_dir)
    wp_versions = ::Dir.entries(node[:app_wordpress][:version_store_path]).sort
    if version == wp_versions.last
      Chef::Log.info "#{fqdn} is already updated to version #{wp_versions.last} of wordpress, no update occurred.."
    else
      directory tempDir do
        recursive true
        action :create
      end

      remote_file "#{tempDir}/latest.tar.gz" do
        source "http://wordpress.org/latest.tar.gz"
        backup false
      end

      execute "untar wordpress" do
        cwd tempDir
        command "tar --strip-components 1 -zxf latest.tar.gz -C #{install_dir}"
      end

      directory tempDir do
        recursive true
        action :delete
      end
    end
  else
    raise "#{fqdn} does not appear to be a wordpress site, no update performed.  You may need to run the :install action of app_wordpress[site] first."
  end

end

action :backup do
  fqdn = new_resource.fqdn
  backup_file_path = new_resource.backup_file_path

  underscored_fqdn = fqdn.gsub(".", "_")
  install_dir = "#{new_resource.content_dir}/#{fqdn}/htdocs"
  version = current_version(install_dir)

  tempdir = "/tmp/wordpress-bak"
  wptarfile = "#{tempdir}/wordpress.tar"
  wpgzipfile = "#{wptarfile}.gz"

  dbgzipfile = "#{tempdir}/#{underscored_fqdn}-sql.gz"

  wpcontent_dir = "#{install_dir}/wp-content"

  wpgold_path = "/tmp/wpgold"

  if ::File.directory? wpcontent_dir
    d1 = directory tempdir do
      recursive true
      action :create
    end

    # Create a backup of the database
    db_mysql_gzipfile_backup "Create database backup file" do
      file_path dbgzipfile
      db_name underscored_fqdn
    end

    d2 = directory wpgold_path do
      recursive true
      action :create
    end

    bash "Extract wpgold" do
      code "tar --strip-components 1 -zxf #{node[:app_wordpress][:version_store_path]}/#{version}/wordpress.tar.gz -C #{wpgold_path}"
    end

    # TODO: This is kinda a hack. We're letting this resource tar.gz the stuff it's backing up, plus our sql backup file..
    rjg_utils_dir_pair "Backup wordpress content" do
      source install_dir
      dest wpgold_path
      result_file backup_file_path
      action :tar
    end

    #d1.run_action(:delete)
    #d2.run_action(:delete)

#    bash "Tar and gzip the wp-contents dir" do
#      cwd tempdir
#      code <<-EOF
#cp -R #{wpcontent_dir}/themes #{wpcontent_dir}/plugins #{tempdir}
#tar -cf #{wptarfile} *
#gzip #{wptarfile}
#cp #{wpgzipfile} #{backup_file_path}
#      EOF
#
#      notifies :delete, resources(:directory => tempdir), :immediately
#    end
  else
    raise "#{fqdn} does not appear to be a wordpress site.  No backup created.  Please check your configuration and try again."
  end
end

action :restore do
  fqdn = new_resource.fqdn
  backup_file_path = new_resource.backup_file_path

  underscored_fqdn = fqdn.gsub(".", "_")
  install_dir = "#{new_resource.content_dir}/#{fqdn}/htdocs"
  wpcontent_dir = "#{install_dir}/wp-content"

  tempdir = "/tmp/wordpress-restore"

  Chef::Log.info "Restoring #{fqdn} from latest backup"

  if ::File.directory? wpcontent_dir
    directory tempdir do
      recursive true
      action :create
    end

    # Nuke the directories we're about to replace
    %w{themes plugins}.each do |dir|
      directory "#{wpcontent_dir}/#{dir}" do
        recursive true
        action :delete
      end
    end

    bash "Extract the backup file into temp dir & restore the themes and plugins directories" do
      cwd tempdir
      code <<-EOF
tar -zxf #{backup_file_path} -C #{tempdir}
mv themes plugins #{wpcontent_dir}
      EOF
    end

    # Restore the db
    db_mysql_gzipfile_restore "#{underscored_fqdn} DB restore" do
      db_name underscored_fqdn
      file_path "#{tempdir}/#{underscored_fqdn}-sql.gz"
      notifies :delete, resources(:directory => tempdir), :immediately
    end
  else
    raise "#{fqdn} does not appear to be a wordpress site.  You may need to run the :install action of app_wordpress[site] first."
  end
end
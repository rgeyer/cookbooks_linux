include_recipe "rjg_aws::default"

# Probably should abstract this into a lib or something
#ruby_block "Fetch the YAML" do
#  block do
    require 'rubygems'
    require 'yaml'
    require 'aws/s3'

    AWS::S3::Base.establish_connection!(:access_key_id => node[:aws][:aws_access_key_id], :secret_access_key => node[:aws][:aws_secret_access_key])

    yaml = AWS::S3::S3Object.find node[:rjg_utils][:yaml_file], node[:rjg_utils][:yaml_bucket]

    conf_ary = YAML::load(yaml.value)
    node[:vhost_yaml_config] = conf_ary
    node[:vhost_yaml_config].each do |vhost|
      web_apache_enable_vhost vhost["nickname"] do
        fqdn vhost["fqdn"]
        admin_email vhost["admin_email"]
        aliases vhost["aliases"]
      end

      app_wordpress_install_or_update vhost["nickname"] do
        fqdn vhost["fqdn"]
        db_pass vhost["db_pass"]
        db_host vhost["db_hostname"]
      end if vhost["install_wp"]
    end
#  end
#end

# Seems like this needs to be in a ruby block so that it executes after the above ruby block...
# or maybe none of it neds to be in a ruby block?
#node[:vhost_yaml_config].each do |vhost|
#  web_apache_enable_vhost vhost["nickname"] do
#    fqdn vhost["fqdn"]
#    admin_email vhost["admin_email"]
#    aliases vhost["aliases"]
#  end
#
#  app_wordpress_install_or_upgrade vhost["nickname"] do
#    fqdn vhost["fqdn"]
#    db_pass vhost["db_pass"]
#    db_host vhost["db_hostname"]
#  end if vhost["install_wp"]
#end
maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs and Configures the Python tool (MrClean)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{ubuntu debian centos redhat}.each do |os|
  supports os
end

%w{scheduler rightscale}.each do |dep|
  depends dep
end

recipe "mrclean::install_from_svn", "Fetches the MrClean sourcecode from SVN and sets up a configuration"
recipe "mrclean::do_mrclean", "Executes the MrClean python script"
recipe "mrclean::do_enable_continuous_cleanup", "Schedules the MrClean python script to run daily at the time specifed by running scheduler::default"
recipe "mrclean::do_disable_continuous_cleanup", "Disables the daily scheduled execution of the MrClean python script"

attribute "mrclean/svn_repo",
  :display_name => "MrClean SVN Repo URI",
  :description => "The URI to use when checking out the MrClean source code",
  :required => "required",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/svn_username",
  :display_name => "MrClean SVN Repo username",
  :description => "The username to authenticate with SVN to check out the MrClean source code",
  :required => "optional",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/svn_password",
  :display_name => "MrClean SVN Repo password",
  :description => "The password to authenticate with SVN to check out the MrClean source code",
  :required => "optional",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/api_username",
  :display_name => "MrClean RightScale API username",
  :description => "The username to authenticate with the RightScale API",
  :required => "optional",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/api_password",
  :display_name => "MrClean RightScale API password",
  :description => "The password to authenticate with the RightScale API",
  :required => "optional",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/install_dir",
  :display_name => "MrClean Install Directory",
  :description => "The directory where MrClean will be installed, and run from",
  :required => "optional",
  :default => "/home/mrclean",
  :recipes => ["mrclean::do_mrclean","mrclean::install_from_svn"]

attribute "mrclean/accounts",
  :display_name => "MrClean RightScale Account List",
  :description => "A list of RightScale accounts which MrClean will clean up",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/deployments",
  :display_name => "MrClean RightScale Deployments List",
  :description => "A list of RightScale deployments which MrClean will not delete from the accounts listed in mrclean/accounts",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/arrays",
  :display_name => "MrClean RightScale Server Arrays List",
  :description => "A list of RightScale server arrays which MrClean will not delete from the accounts listed in mrclean/accounts",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/templates",
  :display_name => "MrClean RightScale Server Templates List",
  :description => "A list of RightScale server templates which MrClean will not delete from the accounts listed in mrclean/accounts",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/servers",
  :display_name => "MrClean RightScale Servers List",
  :description => "A list of RightScale servers which MrClean will not delete from the accounts listed in mrclean/accounts",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/macros",
  :display_name => "MrClean RightScale Macros List",
  :description => "A list of RightScale macros which MrClean will not delete from the accounts listed in mrclean/accounts",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/credentials",
  :display_name => "MrClean RightScale Credential List",
  :description => "A list of RightScale credentials which MrClean will not delete from the accounts listed in mrclean/accounts",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

attribute "mrclean/security_groups",
  :display_name => "MrClean RightScale Security Groups List",
  :description => "A list of RightScale security groups which MrClean will not delete from the accounts listed in mrclean/accounts",
  :required => "required",
  :type => "array",
  :recipes => ["mrclean::install_from_svn"]

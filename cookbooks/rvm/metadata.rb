maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures rvm"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

supports "ubuntu"
supports "centos"

depends "rightscale"

recipe "rvm::install_rvm", "Installs Ruby Version Manager (RVM)"
recipe "rvm::compile_gemset", "Creates a binary version of the specified gemset for the arch of the running instance"

attribute "rvm/install_path",
  :display_name => "RVM Installation Path",
  :description => "The full path where RVM will be installed. I.E. /opt/rvm",
  :required => "optional",
  :default => "/opt/rvm",
  :recipes => ["rvm::install_rvm"]

attribute "rvm/ruby",
  :display_name => "RVM Ruby Name",
  :description => "The full RVM version to install and set as default. To find a list run `rvm list known`.  I.E. ruby-1.8.7-head",
  :required => "required",
  :recipes => ["rvm::install_rvm"]

attribute "rvm/compile_gemset/ruby",
  :display_name => "RVM Ruby Name",
  :description => "The full RVM version. To find a list run `rvm list known`.  I.E. ruby-1.8.7-head",
  :required => "required",
  :recipes => ["rvm::compile_gemset"]

attribute "rvm/compile_gemset/gemset_file",
  :display_name => "RVM gemset export file",
  :description => "An RVM exported gemset file that can be found inside of the defined s3_bucket",
  :required => "required",
  :recipes => ["rvm::compile_gemset"]

attribute "rvm/compile_gemset/gemset_name",
  :display_name => "RVM gemset name",
  :description => "The name of the gemset to create and upload to s3",
  :required => "required",
  :recipes => ["rvm::compile_gemset"]

attribute "rvm/compile_gemset/s3_bucket",
  :display_name => "RVM gemset S3 bucket",
  :description => "S3 bucket name",
  :required => "required",
  :recipes => ["rvm::compile_gemset"]

attribute "rvm/compile_gemset/shutdown",
  :display_name => "RVM Shutdown After Compile?",
  :description => "A boolean indicating if the server should be terminated once the the compilation is completed",
  :required => "required",
  :choice => ["true", "false"],
  :recipes => ["rvm::compile_gemset"]

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rvm::compile_gemset"],
  :required => "required"

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rvm::compile_gemset"],
  :required => "required"
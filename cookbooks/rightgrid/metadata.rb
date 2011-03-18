maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures rightgrid"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe "rightgrid::default", "Installs the specified RightGrid application and gets it rolling"

attribute "rightgrid/aws_access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/aws_secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/worker_name",
  :display_name => "Worker Class Name",
  :description => "The name of the class RightGrid will use to complete work",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/worker_count",
  :display_name => "Worker Count",
  :description => "The number of workers (in individual threads) RightGrid start",
  :recipes => ["rightgrid::default"],
  :default => "10"

attribute "rightgrid/input_queue",
  :display_name => "Input Queue",
  :description => "The Amazon SQS queue used for input to RightGrid",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/output_queue",
  :display_name => "Output Queue",
  :description => "The Amazon SQS queue used for output from RightGrid",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/audit_queue",
  :display_name => "Audit Queue",
  :description => "The Amazon SQS queue used for audit info from RightGrid",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/s3_bucket",
  :display_name => "S3 Bucket",
  :description => "An S3 bucket where RightGrid will store it's input, output, and log files",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/worker_gems",
  :display_name => "Worker Gems",
  :description => "A list of additional gems (separated by white space) to be installed which are required by the workers",
  :recipes => ["rightgrid::default"],
  :required => "optional"

attribute "rightgrid/git_repo",
  :display_name => "GIT Repository",
  :description => "A GIT repository containing the grid worker class",
  :recipes => ["rightgrid::default"],
  :required => "required"

attribute "rightgrid/git_reference",
  :display_name => "GIT Branch/Tag/SHA1",
  :description => "The name of a branch, tag, or commit to pull.  If nothing is supplied \"master\" is cloned",
  :recipes => ["rightgrid::default"],
  :required => "optional"

# No real need for the user to be burdened with this yet.
#attribute "rightgrid/rundir",
#  :display_name => "RightGrid Run Directory",
#  :description => "The directory from which the RightGrid application will run",
#  :recipes => ["rightgrid::default"],
#  :default => "/mnt/rightgrid"
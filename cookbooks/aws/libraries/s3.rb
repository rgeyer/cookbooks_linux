begin
  require 'aws/s3'
rescue LoadError
  Chef::Log.warn("Missing gem 'aws/s3', make sure to run aws::default")
end

module RGeyer
  module Aws
    module S3
      def s3
        @@s3 ||= AWS::S3::Base.establish_connection!(
          :access_key_id => new_resource.access_key_id,
          :secret_access_key => new_resource.secret_access_key)
      end
    end
  end
end
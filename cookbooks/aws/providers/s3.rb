#include RGeyer::Aws::S3

def load_aws_gem()
  begin
    require 'aws/s3'
  rescue LoadError
    Chef::Log.warn("Missing gem 'aws/s3', make sure to run aws::default")
  end
end

action :get do
  load_aws_gem()
  # TODO: This would be great to do in some sort of "constructor" or elsewhere since we'll have to
  # do it for all actions
  AWS::S3::Base.establish_connection!(
    :access_key_id => new_resource.access_key_id,
    :secret_access_key => new_resource.secret_access_key
  )

  s3_file=new_resource.s3_file

  if(new_resource.s3_file_prefix)
    file_list = AWS::S3::Bucket.objects(new_resource.s3_bucket, :prefix => new_resource.s3_file_prefix).sort {|x,y| x.key <=> y.key}
    latest_file = file_list.last
    s3_file = latest_file.key
  end

  fq_filepath = new_resource.file_path

  Chef::Log.info("Downloading #{new_resource.s3_bucket}:#{s3_file} to #{fq_filepath}")

  open(fq_filepath, 'w') do |file|
    AWS::S3::S3Object.stream(s3_file, new_resource.s3_bucket) do |chunk|
      file.write chunk
    end
  end
end

action :put do
  load_aws_gem()
  # TODO: This would be great to do in some sort of "constructor" or elsewhere since we'll have to
  # do it for all actions
  AWS::S3::Base.establish_connection!(
    :access_key_id => new_resource.access_key_id,
    :secret_access_key => new_resource.secret_access_key
  )

  s3_bucket = new_resource.s3_bucket
  s3_filekey = new_resource.s3_file
  s3_file_prefix = new_resource.s3_file_prefix
  s3_file_ext = new_resource.s3_file_extension
  history_to_keep = new_resource.history_to_keep
  file_path = new_resource.file_path

  if s3_file_prefix
    datestring = Time.now.strftime("%Y%m%d%H%M")
    s3_filekey = "#{s3_file_prefix}-#{datestring}#{s3_file_ext}"
  end

  Chef::Log.info("Uploading #{file_path} to S3 at #{s3_bucket}:#{s3_filekey}")

  AWS::S3::S3Object.store(
    s3_filekey,
    open(file_path),
    s3_bucket
  )

  if history_to_keep && s3_file_prefix
    file_list = AWS::S3::Bucket.objects(s3_bucket, :prefix => s3_file_prefix).sort {|x,y| x.key <=> x.key}
    num_to_delete = file_list.size - history_to_keep
    Chef::Log.info("Deleting #{num_to_delete} files with the prefix #{s3_file_prefix}.")
    file_list.each_with_index {|file,idx|
      if idx == num_to_delete then break end
      file.delete
      Chef::Log.info("Deleted #{s3_bucket}:#{file.key} from S3")
    } if file_list.size > history_to_keep
  end
end
actions :get, :put

#get and put
attribute :access_key_id, :kind_of => [ String ]
attribute :secret_access_key, :kind_of => [ String ]
attribute :s3_bucket, :kind_of => [ String ]
attribute :s3_file, :kind_of => [ String ]
attribute :s3_file_prefix, :kind_of => [ String ]

#put action
attribute :file_path, :kind_of => [ String ]
attribute :history_to_keep, :kind_of => [ Integer ]
attribute :s3_file_extension, :kind_of => [ String ]
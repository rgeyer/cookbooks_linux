# Copyright 2012, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

define :uox_shard_restore, :prefix => nil, :container => nil, :cloud => nil do
  shard_tar = "/tmp/uoshard.tar.gz"

  file shard_tar do
    action :delete
  end

  execute "Restore UO shard files from Remote Object Store" do
    command "/opt/rightscale/sandbox/bin/ros_util get --cloud #{cloud} --container #{container} --dest #{shard_tar} --source #{prefix} --latest"
    environment ({
      'STORAGE_ACCOUNT_ID' => node[:uox3][:shard][:storage_account_id],
      'STORAGE_ACCOUNT_SECRET' => node[:uox3][:shard][:storage_account_secret]
    })
  end

  bash "Extract the shard tarfile" do
    cwd node[:uox3][:install_dir]
    code "tar -zxf #{shard_tar}"
    notifies :delete, "file[#{shard_tar}]", :immediately
  end

end
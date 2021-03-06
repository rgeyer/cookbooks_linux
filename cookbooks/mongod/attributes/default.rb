#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

if attribute?(:ec2) && node[:ec2][:instance_type] != "t1.micro"
  default[:mongod][:datadir] = "/mnt/db/mongodb"
  default[:mongod][:logfile] = "/mnt/log/mongodb.log"
else
  default[:mongod][:datadir] = "/var/db/mongodb"
  default[:mongod][:logfile] = "/var/log/mongodb.log"
end

default[:mongod][:port] = "27017"
default[:mongod][:bind_ip] = "0.0.0.0"

case node[:platform]
  when "centos","rhel"
    default[:mongod][:packages] = ["mongo-10gen", "mongo-10gen-server"]
    default[:mongod][:username] = "mongod"
    default[:mongod][:group]    = "mongod"
  else
    default[:mongod][:packages] = ["mongodb-10gen"]
    default[:mongod][:username] = "mongodb"
    default[:mongod][:group]    = "mongodb"
end

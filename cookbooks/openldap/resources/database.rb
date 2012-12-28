# Copyright 2011-2012, Ryan J. Geyer
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

actions :create

default_action :create

attribute :base_dn, :kind_of => [ String ]
attribute :db_type, :kind_of => [ String ], :equal_to => ["hdb","bdb"], :required => true
attribute :admin_cn, :kind_of => [ String ], :required => true
attribute :admin_password, :kind_of => [ String ], :required => true
attribute :cache_size, :kind_of => [ String ]
attribute :max_objects, :kind_of => [ String ]
attribute :max_locks, :kind_of => [ String ]
attribute :max_lockers, :kind_of => [ String ]
attribute :checkpoint, :kind_of => [ String ]
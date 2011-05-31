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

actions :install, :update, :backup, :restore

attribute :fqdn, :kind_of => [ String ], :required => true #Required for actions [install, backup, restore]
attribute :webserver, :kind_of => [ String ], :equal_to => ["apache2","nginx"] #Required for actions [install]
attribute :aliases, :kind_of => [ String ] #Optional for actions [install]
attribute :db_pass, :kind_of => [ String ] #Required for actions [install]
attribute :backup_file_path, :kind_of => [ String ] #Required for actions [backup, restore]
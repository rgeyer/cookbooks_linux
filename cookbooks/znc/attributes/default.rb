#
# Cookbook Name:: znc
# Attribute:: default
#
# Copyright 2011, Seth Chisamore
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
#

default['znc']['install_method'] = 'package'

case node["platform"]
when "macosx"
  set['znc']['data_dir'] = '$HOME/.znc'
else
  set['znc']['data_dir'] = '/etc/znc'
  set['znc']['user'] = 'znc'
  set['znc']['group'] = 'znc'
end

default['znc']['conf_dir']        = "#{znc['data_dir']}/configs"
default['znc']['log_dir']         = "#{znc['data_dir']}/moddata/adminlog"
default['znc']['module_dir']      = "#{znc['data_dir']}/modules"
default['znc']['users_dir']       = "#{znc['data_dir']}/users"

default['znc']['port']            = "+7777"
default['znc']['skin']            = "dark-clouds"
default['znc']['max_buffer_size'] = 500
default['znc']['modules']         = %w{ webadmin adminlog }
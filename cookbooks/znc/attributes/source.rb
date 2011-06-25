#
# Cookbook Name:: znc
# Attribute:: source
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

default['znc']['url'] = "http://znc.in/releases/archive"
default['znc']['version'] = "0.098"
default['znc']['checksum'] = "3b88d33c21e464aa82c84b2dc3bcd52dec95c87a052bb80aff6336dbb4043eb4"
default['znc']['configure_options'] = %W{ --enable-extra }

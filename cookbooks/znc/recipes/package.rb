#
# Cookbook Name:: znc
# Recipe:: package
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

case node['platform']
when "macosx"
  # TODO: install via homebrew
else
  znc_pkgs = value_for_platform(
    [ "debian","ubuntu" ] => {
      "default" => %w{ znc znc-dev znc-extra }# znc-webadmin}
    },
    "default" => %w{ znc znc-dev znc-extra }
  )

  znc_pkgs.each do |pkg|
    package pkg do
      action :install
    end
  end

end
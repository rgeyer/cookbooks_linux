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

begin
  require 'net-ldap'
rescue LoadError
  Chef::Log.warn("net-ldap gem not installed, be sure to run openldap::setup_openldap")
end

module Rgeyer
  module Chef
    module NetLdap
      def net_ldap
        @@net_ldap ||= Net::LDAP.new(
          :base => new_resource.base_dn,
          :auth => {
            :method => :simple,
            :username => new_resource.user_cn,
            :password => new_resource.user_password
          }
        )
      end

      def is_consumer
        net_ldap.search(:base => new_resource.base_dn,:filter => Net::LDAP::Filter.new('olcsyncrepl', '*')).length > 0
      end
    end
  end
end
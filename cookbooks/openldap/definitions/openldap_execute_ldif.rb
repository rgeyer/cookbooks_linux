#
# Cookbook Name:: openldap
#
# Copyright 2011, Ryan J. Geyer
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

define :openldap_execute_ldif, :source => nil, :source_type => nil, :executable => "ldapmodify" do

  type_to_delete = params[:source_type]
  dest_file = "/tmp/#{params[:source]}"

  case params[:source_type]
    when :template
      template dest_file do
        backup false
        source params[:source]
        variables params
      end
    when :remote_file
      remote_file dest_file do
        source params[:source]
        backup false
      end
    when :file
      dest_file = params[:source]
      file dest_file do
        backup false
        action :nothing
      end
  end

  ruby_block "Some feedback" do
    block do
      Chef::Log.info("Running the following LDIF file...")
      Chef::Log.info(::File.read(dest_file))
    end
  end
  execute params[:executable] do
    command "#{params[:executable]} -Q -Y EXTERNAL -H ldapi:/// -f #{dest_file}"
    notifies :delete, resources(type_to_delete => dest_file), :immediately
  end
end
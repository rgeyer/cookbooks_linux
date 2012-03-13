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

define :openvpn_add_user do
  execute "generate-openvpn-#{params[:name][:name]}" do
    command "./pkitool #{params[:name][:name]}"
    cwd "/etc/openvpn/easy-rsa"
    environment(
      'EASY_RSA' => '/etc/openvpn/easy-rsa',
      'KEY_CONFIG' => '/etc/openvpn/easy-rsa/openssl.cnf',
      'KEY_DIR' => node["openvpn"]["key_dir"],
      'CA_EXPIRE' => node["openvpn"]["key"]["ca_expire"].to_s,
      'KEY_EXPIRE' => node["openvpn"]["key"]["expire"].to_s,
      'KEY_SIZE' => node["openvpn"]["key"]["size"].to_s,
      'KEY_COUNTRY' => node["openvpn"]["key"]["country"],
      'KEY_PROVINCE' => node["openvpn"]["key"]["province"],
      'KEY_CITY' => node["openvpn"]["key"]["city"],
      'KEY_ORG' => node["openvpn"]["key"]["org"],
      'KEY_EMAIL' => node["openvpn"]["key"]["email"]
    )
    not_if { ::File.exists?("#{node["openvpn"]["key_dir"]}/#{params[:name][:name]}.crt") }
  end

  %w{ conf ovpn }.each do |ext|
    template "#{node["openvpn"]["key_dir"]}/#{params[:name][:name]}.#{ext}" do
      source "client.conf.erb"
      variables :username => params[:name][:name]
    end
  end

  execute "create-openvpn-tar-#{params[:name][:name]}" do
    cwd node["openvpn"]["key_dir"]
    command <<-EOH
      tar zcf #{params[:name][:name]}.tar.gz ca.crt #{params[:name][:name]}.crt #{params[:name][:name]}.key #{params[:name][:name]}.conf #{params[:name][:name]}.ovpn
    EOH
    not_if { ::File.exists?("#{node["openvpn"]["key_dir"]}/#{params[:name][:name]}.tar.gz") }
  end

  if params[:name][:ccd]
    template "/etc/openvpn/ccd/#{params[:name][:name]}" do
      source "ccd.erb"
      variables :ccd => params[:name][:ccd]
    end
  end
end
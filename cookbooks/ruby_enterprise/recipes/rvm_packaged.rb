#
# Cookbook Name:: ruby_enterprise
# Recipe:: rvm_packaged
#
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

include_recipe "rvm::default"

package "libssl-dev"

# TODO: This mechanism for getting the arch is reused in my code a lot, need to either set a node attribute once
# somewhere, or otherwise encapsulate this, maybe ohai?
uname_machine = `uname -m`.strip

machines = {"x86_64" => "amd64", "i386" => "i386", "i686" => "i386"}
arch = machines[uname_machine]

Chef::Log.info "Detected system architecture of #{uname_machine} installing the #{arch} Ruby Enterprise package..."

fullrubyname = "ree-#{node[:ruby_enterprise][:version]}"
targzfile = "rvm-#{fullrubyname}-#{arch}.tar.gz"

remote_file "/tmp/#{targzfile}" do
  source targzfile
end

bash "Extract ree binaries to rvm" do
  code <<-EOF
tar -zxf /tmp/#{targzfile} -C #{node[:rvm][:install_path]}
  EOF
  not_if { ::File.exists?(::File.join(node[:rvm][:install_path], "rubies", fullrubyname)) }
end

bash "Switch to ree if current ruby is system" do
  code "#{node[:rvm][:bin_path]} use #{fullrubyname}"
  only_if { `#{node[:rvm][:bin_path]} current`.strip.downcase == "system" }
end

bash "Make ree the default ruby" do
  code "#{node[:rvm][:bin_path]} #{fullrubyname} --default"
  # TODO: Make it idempotent, using rvm default to see the default apparently does not work
end
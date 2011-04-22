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

define :unicorn_app, :app_name => nil, :app_path => nil, :worker_timeout => 60 do
  if(node[:rvm][:bin_path])
    default_ruby = `#{node[:rvm][:bin_path]} list default string`.strip
    bash "Create a unicorn_rails rvm wrapper" do
      code "#{node[:rvm][:bin_path]} wrapper #{default_ruby}@global init unicorn_rails"
      creates ::File.join(node[:rvm][:install_path], "bin", "init_unicorn_rails")
    end
  end

  template "/etc/unicorn/#{params[:app_name]}.rb" do
    source params[:template] || "unicorn.rb.erb"
    cookbook params[:cookbook] || "unicorn"
    variables(params)
    backup false
  end

  template "/etc/init.d/unicorn-#{params[:app_name]}" do
    source "unicorn-app-init.sh.erb"
    mode 0755
    cookbook "unicorn"
    variables(params)
    backup false
  end

  service "unicorn-#{params[:app_name]}" do
    supports :status => true, :restart => true
    action [ :enable, :start ]
  end

end
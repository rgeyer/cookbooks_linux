#
# Cookbook Name:: ruby
# Recipe:: default
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

# Install the necessary gems
# Note that I'm doing an execute here, rather than gem_package cause it on RightScale, with chef 0.8.x, gem_package sometimes breaks
# or succeeds, but returns a non 0 result causing the recipe to fail.
node[:ruby][:gems_list].split(',').each do |gem|
  name_version_ary = gem.split(' ')
  run_this = `which gem`.strip
  run_this = "/usr/local/bin/gem" if ::File.exists?("/usr/local/bin/ree-version")
  run_this += " install #{name_version_ary[0]} --no-rdoc --no-ri"
  run_this += " -v #{name_version_ary[1]}" if name_version_ary[1]

  execute "Installing #{name_version_ary[0]} gem" do
    command run_this
  end
end if node[:ruby][:gems_list]
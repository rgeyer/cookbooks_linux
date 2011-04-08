#
# Cookbook Name:: deb_package
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{install build-essential autoconf automake autotools-dev dh-make debhelper devscripts fakeroot xutils lintian pbuilder}.each do |p|
  package p
end

# TODO: How to set environment variables?
# DEBEMAIL = node[:deb_package][:maintainer_email]
# DEBFULLNAME = node[:deb_package][:maintainer_name]
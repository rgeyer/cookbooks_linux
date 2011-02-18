#
# Cookbook Name:: collectd_web
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{libjson-perl librrds-perl rrdtool}.each do |p|
  package p
end

# TODO: Changes to collectd.conf, change BaseDir to include /rrd and add a <Target> node
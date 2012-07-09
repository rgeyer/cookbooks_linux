#!/usr/bin/env ruby
#
# Cookbook Name:: php5
#
# Copyright 2012 Ryan J. Geyer <me@ryangeyer.com>
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

require 'uri'
require 'optparse'
require 'net/http'

# Defaults if arguments passed.
@options = {
  :instanceid => ENV['SERVER_UUID'],
  :interval => 20
}


def usage(code = 0)
  out = "\n" + $0.split(' ')[0] + " usage:\n"
  out << "\e[1mDESCRIPTION\e[0m\n"
  out << "\tThis collectd exec plugin is intended to collect the statistics\n"
  out << "\tfrom the php-fpm status page. It then parses the returned counters and\n"
  out << "\tfeeds them into collectd.\n"
  out << "\t-d, --hostid \e[1;4mINSTANCE ID\e[0m\n"
  out << "\t\tThe instance id of which the data is being collected\n"
  out << "\t-n, --sampling-interval \e[1;4mINTERVAL\e[0m\n"
  out << "\t\tThe interval (in second) between each sampling.\n"
  out << "\t-h, --help\n\n"
  puts "\n" + out
  Kernel.exit(code)
end

def outputstats(now)

  ignore_keys = ['pool', 'process manager']
  uri_str = @options[:stats_uri]
  uri = URI.parse(uri_str)
  response = Net::HTTP.get_response(uri)
  hostname = @options[:instanceid]

  metrics = response.body.to_a

  metrics.each do |metric|
    key_val_ary = metric.split(':')
    key = key_val_ary[0].strip
    val = key_val_ary[1].strip
    puts "PUTVAL \"#{hostname}/php-fpm/gauge-#{key.gsub(/\s/, '_')}\" interval=#{@options[:interval]} #{now}:#{val.to_i}" unless ignore_keys.include? key
  end

end

# Parse arguments.
opts = OptionParser.new
opts.banner = "Usage: php-fpm.rb"
opts.on("-d ID", "--hostid ID") { |str| @options[:instanceid] = str }
opts.on("-n INTERVAL", "--sampling-interval INTERVAL") { |str| @options[:interval] = str }
opts.on("-u URI", "--uri URI") { |str| @options[:stats_uri] = str }

begin
  opts.parse(ARGV)
rescue Exception => e
  usage(-1)
end

# Main loop to handle timing.
begin

  $stdout.sync = true

  while true do
    last_run = Time.now.to_i
    next_run = last_run + @options[:interval].to_i

    now = Time.now.to_i
    outputstats(now)
    while (time_left = (next_run - Time.now.to_i)) > 0 do
      sleep(time_left)
    end
  end

end
#!/usr/bin/env ruby
#
# Cookbook Name:: unicorn
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

require 'optparse'

# Defaults if arguments passed.
@options = {
  :instanceid => ENV['SERVER_UUID'],
  :interval => 20
}


def usage(code = 0)
  out = "\n" + $0.split(' ')[0] + " usage:\n"
  out << "\e[1mDESCRIPTION\e[0m\n"
  out << "\tThis collectd exec plugin is intended to collect the running process info\n"
  out << "\tfor unicorn_rails processes.\n"
  out << "\t-d, --hostid \e[1;4mINSTANCE ID\e[0m\n"
  out << "\t\tThe instance id of which the data is being collected\n"
  out << "\t-n, --sampling-interval \e[1;4mINTERVAL\e[0m\n"
  out << "\t\tThe interval (in second) between each sampling.\n"
  out << "\t-h, --help\n\n"
  puts "\n" + out
  Kernel.exit(code)
end

def outputstats(now)
  hostname = @options[:instanceid]

  unicorn_processes = Dir.glob("/var/run/unicorn/*.pid")
  unicorn_processes.each do |pidfile|
    ps_name = /.*\/(.*)\.pid/.match(pidfile)[1]
    pid = `cat #{pidfile} 2>/dev/null`.strip
    ps_output = `ps -eLF | grep #{pid} | grep -v grep 2>/dev/null`.split(/\n/)
    threads = 0

    ps_output.each do |ps|
      ps_vals = /([a-zA-z]+)[\t\s]+([0-9]+)[\t\s]+([0-9]+)[\t\s]+([0-9]+)[\t\s]+([0-9]+)[\t\s]+([0-9]+)[\t\s]+/.match(ps)
      if ps_vals[6]
        threads += ps_vals[6].to_i
      end
    end

    puts "PUTVAL \"#{hostname}/unicorns-#{ps_name}/ps_count\" interval=#{@options[:interval]} #{now}:#{ps_output.length}:#{threads}"
  end
end

# Parse arguments.
opts = OptionParser.new
opts.banner = "Usage: unicorns.rb"
opts.on("-d ID", "--hostid ID") { |str| @options[:instanceid] = str }
opts.on("-n INTERVAL", "--sampling-interval INTERVAL") { |str| @options[:interval] = str }

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
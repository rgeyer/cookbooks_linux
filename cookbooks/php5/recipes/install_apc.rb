#
# Cookbook Name:: php5
# Recipe:: install_apc
#
#  Copyright 2011-2012 Ryan J. Geyer
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

# http://php.net/manual/en/book.apc.php

#Stats
# http://www.php.net/manual/en/function.apc-cache-info.php
# http://www.php.net/manual/en/function.apc-sma-info.php
# /usr/share/doc/php-apc/apc.php.gz

rightscale_marker :begin

package "php-apc"

rightscale_marker :end
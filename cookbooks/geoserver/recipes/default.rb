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
#

raise "Undefined attribtue node['geoserver']['user']" unless node['geoserver']['user']
raise "Undefined attribtue node['geoserver']['group']" unless node['geoserver']['group']

directory node['geoserver']['base_dir'] do
  owner node['geoserver']['user']
  group node['geoserver']['group']
  mode 0700
  recursive true
end

cached_package_filename = "#{Chef::Config[:file_cache_path]}/geoserver-#{node['geoserver']['version']}.zip"
check_proc = Proc.new { ::File.exists?("#{node['geoserver']['base_dir']}/geoserver-#{node['geoserver']['version']}.war") }

remote_file cached_package_filename do
  source node['geoserver']['package_url']
  mode '0600'
  action :create_if_missing
  not_if { check_proc.call }
end

package 'unzip'

bash 'unpack_geoserver' do
  code <<-EOF
cd #{node['geoserver']['base_dir']}
unzip -qq #{cached_package_filename} geoserver.war
chown #{node['geoserver']['user']}:#{node['geoserver']['group']} geoserver.war
mv geoserver.war geoserver-#{node['geoserver']['version']}.war
test -f geoserver-#{node['geoserver']['version']}.war
  EOF
  not_if { check_proc.call }
end

include_recipe 'geoserver::_setup_data_dir'

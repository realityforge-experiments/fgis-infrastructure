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

node.override['geoserver']['glassfish']['domain'] = 'geo'

node.override['glassfish']['domains'][node['geoserver']['glassfish']['domain']] =
  {
    'config' => {
      'min_memory' => 412,
      'max_memory' => 512,
      'max_perm_size' => 200,
      'port' => 80,
      'admin_port' => 8085,
      'max_stack_size' => 200,
      'username' => 'geo_admin',
      'password' => 'G3TzM3Inith!PLZ',
      'remote_access' => 'true',
    },
    'recipes' => {
      'before' => %w(fgis::_geoserver)
    },
    'extra_libraries' => {
      'postgresql' => 'http://jdbc.postgresql.org/download/postgresql-9.2-1002.jdbc4.jar'
    },
    'jdbc_connection_pools' => {
      'GeoServerPool' => {
        'config' => {
          'datasourceclassname' => 'org.postgresql.ds.PGConnectionPoolDataSource',
          'restype' => 'javax.sql.ConnectionPoolDataSource',
          'isconnectvalidatereq' => 'true',
          'validationmethod' => 'auto-commit',
          'ping' => 'true',
          'description' => 'GeoServer Connection Pool',
          'properties' => {
            'databaseName' => node['fgis']['database']['db_name'],
            'user' => node['fgis']['database']['username'],
            'password' => node['fgis']['database']['password'],
            'serverName' => '127.0.0.1',
            'portNumber' => '5432',
          }
        },
        'resources' => {
          'jdbc/GeoServer' => {
            'description' => 'GeoServer Connection Resource'
          }
        }
      }
    },
    'deployables' => {
      'fgis' => {
        'url' => 'https://github.com/realityforge/repository/raw/master/org/realityforge/fgis/fgis/0.3/fgis-0.3.war',
        'context_root' => '/fgis'
      }
    },
  }

include_recipe 'glassfish::attribute_driven_domain'
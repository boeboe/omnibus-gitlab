#
# Copyright:: Copyright (c) 2017 GitLab Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "#{Omnibus::Config.project_root}/lib/gitlab/version"

name 'node-exporter'
version = Gitlab::Version.new('node-exporter', '0.14.0')
default_version version.print

license 'APACHE-2.0'
license_file 'LICENSE'

source git: version.remote

relative_path 'src/github.com/prometheus/node_exporter'

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['GOPATH'] = "#{Omnibus::Config.source_dir}/node-exporter"
  exporter_source_dir = "#{Omnibus::Config.source_dir}/node-exporter"
  cwd = "#{exporter_source_dir}/src/github.com/prometheus/node_exporter"

  command 'go build', env: env, cwd: cwd
  copy 'node_exporter', "#{install_dir}/embedded/bin/"
end

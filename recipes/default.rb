include_recipe 'apt'
include_recipe 'runit'

package 'make'
package 'git'
package 'g++'

directory "#{node[:golang][:gopath]}/skydb" do
  recursive true
  mode 0755
  owner node[:skydb][:user]
end

git '/usr/local/src/sky-deps' do
  repository 'https://github.com/skydb/sky-deps'
  revision node[:skydb][:version]
  action :sync
end

directory '/usr/local/man/man1' do
  recursive true
  mode 0755
  owner 'root'
end

bash 'install skydb dependencies' do
  cwd '/usr/local/src/sky-deps'
  code "make && make install"
end

directory "#{node[:golang][:gopath]}/src/github.com/skydb" do
  recursive true
  mode 0755
  owner node[:skydb][:user]
end

git "#{node[:golang][:gopath]}/src/github.com/skydb/sky" do
  repository 'https://github.com/skydb/sky'
  revision node[:skydb][:version]
  action :sync
end

bash 'install skydb' do
  cwd "#{node[:golang][:gopath]}/src/github.com/skydb/sky"
  environment 'GOPATH' => node[:golang][:gopath]
  code "go get && cd skyd && go build -a && cp ./skyd /usr/local/bin"
end

bash 'configure skydb' do
  code "echo '/usr/local/lib' > /etc/ld.so.conf.d/sky.conf && ldconfig"
end

runit_service 'skydb'

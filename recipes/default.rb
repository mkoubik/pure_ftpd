#
# Cookbook Name:: pure_ftpd
# Recipe:: default
#
# Fork & use as you like
#

package "pure-ftpd-mysql"

group "ftpgroup"

user "ftpuser" do
  comment "Virtual pureFTPd Account"
  gid "ftpgroup"
  home "/bin/null"
  shell "/bin/false"
end

%w(ChrootEveryone CreateHomeDir DontResolve NoAnonymous).each do |file|
  file "/etc/pure-ftpd/conf/#{file}" do
    content "yes"
  end
end

file "/etc/pure-ftpd/conf/ForcePassiveIP" do
  content node[:ec2] ? node[:ec2][:public_ipv4] : node[:ipaddress]
end

file "/etc/pure-ftpd/conf/PassivePortRange" do
  content "60010 60030"
end

service "pure-ftpd-mysql" do
  supports :status => true, :restart => true
  action [:enable, :start]
end
 
template "/etc/pure-ftpd/db/mysql.conf" do
  source "mysql.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :mysql_user => node[:pure_ftpd][:mysql_user],
    :mysql_password => node[:pure_ftpd][:mysql_password],
    :mysql_database => node[:pure_ftpd][:mysql_database],
    :mysql_server => node[:pure_ftpd][:mysql_server],
    :mysql_port => node[:pure_ftpd][:mysql_port]
  )
  notifies :restart, resources(:service => "pure-ftpd-mysql")
end

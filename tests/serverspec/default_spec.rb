require "spec_helper"
require "serverspec"

package = "sensu_go_agent"
service = "sensu_go_agent"
config  = "/etc/sensu_go_agent/sensu_go_agent.conf"
user    = "sensu_go_agent"
group   = "sensu_go_agent"
ports   = [PORTS]
log_dir = "/var/log/sensu_go_agent"
db_dir  = "/var/lib/sensu_go_agent"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/sensu_go_agent.conf"
  db_dir = "/var/db/sensu_go_agent"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("sensu_go_agent") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/sensu_go_agent") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

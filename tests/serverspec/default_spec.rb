require "spec_helper"
require "serverspec"

package = nil
service = "sensu-agent"
config  = "/etc/sensu/agent.yml"
user    = "sensu"
group   = "sensu"
ports   = []
log_dir = "/var/log/sensu"
db_dir  = "/var/lib/sensu/sensu-agent"
cache_dir = "/var/cache/sensu/sensu-agent"
admin_user = "admin"
admin_password = "P@ssw0rd!"
default_group = "root"
extra_packages = []
backend_url = "ws://localhost:8081"

case os[:family]
when "redhat"
  package = "sensu-go-agent"
  extra_packages = ["sensu-go-cli"]
when "ubuntu"
  package = "sensu-go-agent"
  extra_packages = ["sensu-go-cli"]
when "freebsd"
  package = "sysutils/sensu-go"
  config = "/usr/local/etc/sensu-agent.yml"
  db_dir = "/var/db/sensu/sensu-agent"
  default_group = "wheel"
end

describe package(package) do
  it { should be_installed }
end

extra_packages.each do |p|
  describe package p do
    it { should be_installed }
  end
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("# Managed by ansible") }
  its(:content_as_yaml) { should include("backend-url" => backend_url) }
  its(:content_as_yaml) { should include("cache-dir" => cache_dir) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(cache_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/sensu_agent") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
  end
when "redhat"
  describe file("/etc/sysconfig/sensu-agent") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
  end
when "ubuntu"
  describe file("/etc/default/sensu-agent") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
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

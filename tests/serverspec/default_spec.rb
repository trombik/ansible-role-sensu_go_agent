# frozen_string_literal: true

require "spec_helper"
require "serverspec"

package = nil
service = "sensu-agent"
config  = "/etc/sensu/agent.yml"
user    = "sensu"
group   = "sensu"
extra_groups = %w[bin]
ports = []
log_dir = "/var/log/sensu"
cache_dir = "/var/cache/sensu/sensu-agent"
default_group = "root"
extra_packages = []
backend_url = "ws://localhost:8081"
gems = %w[sensu-plugin sensu-plugins-disk-checks]

case os[:family]
when "redhat"
  package = "sensu-go-agent"
  extra_packages = ["sensu-go-cli"]
when "ubuntu"
  package = "sensu-go-agent"
  extra_packages = ["sensu-go-cli"]
when "freebsd"
  package = "sysutils/sensu-go-agent"
  extra_packages = ["sysutils/sensu-go-cli"]
  config = "/usr/local/etc/sensu/agent.yml"
  default_group = "wheel"
end

describe package(package) do
  it { should be_installed }
end

describe user(user) do
  it { should exist }
  it { should belong_to_primary_group group }
  extra_groups.each do |extra_group|
    it { should belong_to_group extra_group }
  end
  it { should have_home_directory "/home/#{user}" }
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

gems.each do |g|
  case os[:family]
  when "redhat"
    describe command "/opt/sensu-plugins-ruby/embedded/bin/gem list --local" do
      its(:stderr) { should eq "" }
      its(:stdout) { should match(/#{g}/) }
    end
  else
    describe package g do
      let(:sudo_options) { "-u #{user} --set-home" }
      it { should be_installed.by("gem") }
    end
  end
end

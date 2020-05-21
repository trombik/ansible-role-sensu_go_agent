# `trombik.sensu_go_agent`

[![Build Status](https://travis-ci.com/trombik/ansible-role-sensu_go_agent.svg?branch=master)](https://travis-ci.com/trombik/ansible-role-sensu_go_agent)

`ansible` role for `sensu-go` version of `sensu-agent`.

## Notes for FreeBSD users

As of this writing (2020/04/16), the official FreeBSD ports tree does not have
the latest version of `sensu-go`. [The available version of the
port](https://www.freshports.org/sysutils/sensu-go/) does not
install `sensu-backend`. You have to fix the port yourself, or install my port
from
`[freebsd-ports-sensu-go](https://github.com/trombik/freebsd-ports-sensu-go)`,
and place the package somewhere.

# Requirements

Ruby must be installed.

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `sensu_go_agent_user` | user of `sensu-agent` | `{{ __sensu_go_agent_user }}` |
| `sensu_go_agent_group` | group of `sensu-agent` | `{{ __sensu_go_agent_group }}` |
| `sensu_go_agent_extra_groups` | list of extra groups `sensu_go_agent_user` belongs to | `[]` |
| `sensu_go_agent_home` | home directory of `sensu-agent` user | `/home/{{ sensu_go_agent_user }}` |
| `sensu_go_agent_package` | package name of `sensu-agent` | `{{ __sensu_go_agent_package }}` |
| `sensu_go_agent_extra_packages` | list of extra packages to install | `{{ __sensu_go_agent_extra_packages }}` |
| `sensu_go_agent_log_dir` | path to log directory | `/var/log/sensu` |
| `sensu_go_agent_cache_dir` | path to `cache-dir` | `{{ __sensu_go_agent_cache_dir }}` |
| `sensu_go_agent_service` | service name of `sensu-agent` | `{{ __sensu_go_agent_service }}` |
| `sensu_go_agent_conf_dir` | path to base directory of `sensu_go_agent_conf_file` | `{{ __sensu_go_agent_conf_dir }}` |
| `sensu_go_agent_conf_file` | path to `sensu-agent.yml` | `{{ sensu_go_agent_conf_dir }}/sensu-agent.yml` |
| `sensu_go_agent_config` | content of `sensu-agent.yml` | `""` |
| `sensu_go_agent_flags` | see below | `""` |
| `sensu_go_agent_ruby_plugins` | list of ruby gems to install | `[]` |
| `sensu_go_agent_use_embedded_ruby` | use embedded ruby instead | `false` |
| `sensu_go_agent_embedded_ruby_dir` | path to embedded ruby directory | `/opt/sensu-plugins-ruby/embedded` |
| `sensu_go_agent_embedded_ruby_gem` | path to embedded ruby gem | `{{ sensu_go_agent_embedded_ruby_dir }}/bin/gem` |

## `sensu_go_agent_flags`

This variable is used to configure startup options for the service. What it
does depends on platform.

### FreeBSD

`sensu_go_agent_flags` is the content of `/etc/rc.conf.d/sensu_agent`.

### Debian

`sensu_go_agent_flags` is the content of `/etc/default/sensu-agent`.

### RedHat

`sensu_go_agent_flags` is the content of `/etc/sysconfig/sensu-agent`.

## Debian

| Variable | Default |
|----------|---------|
| `__sensu_go_agent_user` | `sensu` |
| `__sensu_go_agent_group` | `sensu` |
| `__sensu_go_agent_package` | `sensu-go-agent` |
| `__sensu_go_agent_extra_packages` | `[]` |
| `__sensu_go_agent_cache_dir` | `/var/cache/sensu/sensu-agent` |
| `__sensu_go_agent_service` | `sensu-agent` |
| `__sensu_go_agent_conf_dir` | `/etc/sensu` |
| `__sensu_go_agent_conf_file` | `{{ __sensu_go_agent_conf_dir }}/agent.yml` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__sensu_go_agent_user` | `sensu` |
| `__sensu_go_agent_group` | `sensu` |
| `__sensu_go_agent_package` | `sysutils/sensu-go-agent` |
| `__sensu_go_agent_extra_packages` | `[]` |
| `__sensu_go_agent_cache_dir` | `/var/cache/sensu/sensu-agent` |
| `__sensu_go_agent_service` | `sensu-agent` |
| `__sensu_go_agent_conf_dir` | `/usr/local/etc` |
| `__sensu_go_agent_conf_file` | `{{ __sensu_go_agent_conf_dir }}/sensu-agent.yml` |

## RedHat

| Variable | Default |
|----------|---------|
| `__sensu_go_agent_user` | `sensu` |
| `__sensu_go_agent_group` | `sensu` |
| `__sensu_go_agent_package` | `sensu-go-agent` |
| `__sensu_go_agent_extra_packages` | `[]` |
| `__sensu_go_agent_cache_dir` | `/var/cache/sensu/sensu-agent` |
| `__sensu_go_agent_service` | `sensu-agent` |
| `__sensu_go_agent_conf_dir` | `/etc/sensu` |
| `__sensu_go_agent_conf_file` | `{{ __sensu_go_agent_conf_dir }}/agent.yml` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - role: trombik.freebsd_pkg_repo
      when: ansible_os_family == 'FreeBSD'
    - role: trombik.apt_repo
      when: ansible_os_family == 'Debian'
    - role: trombik.redhat_repo
      when: ansible_os_family == 'RedHat'
    - role: trombik.language_ruby
      when: ansible_os_family != 'RedHat'
    - role: ansible-role-sensu_go_agent
  vars:
    os_sensu_go_agent_use_embedded_ruby:
      FreeBSD: no
      Debian: no
      RedHat: yes
    sensu_go_agent_use_embedded_ruby: "{{ os_sensu_go_agent_use_embedded_ruby[ansible_os_family] }}"
    sensu_go_agent_ruby_plugins:
      - sensu-plugin
      - sensu-plugins-disk-checks

    #  EMBEDDED_RUBY=true in /etc/default/sensu
    sensu_go_agent_config:
      backend-url: ws://localhost:8081
      cache-dir: "{{ sensu_go_agent_cache_dir }}"

    os_sensu_go_agent_extra_packages:
      FreeBSD:
        - sysutils/sensu-go-cli
      Debian:
        - sensu-go-cli
        - ruby-dev
      RedHat:
        - sensu-go-cli
        - sensu-plugins-ruby
    sensu_go_agent_extra_packages: "{{ os_sensu_go_agent_extra_packages[ansible_os_family] }}"
    os_sensu_go_agent_flags:
      FreeBSD: ""
      Debian: ""
      RedHat: |
        EMBEDDED_RUBY=true
    sensu_go_agent_flags: "{{ os_sensu_go_agent_flags[ansible_os_family] }}"
    freebsd_pkg_repo:
      # disable the default package repository
      FreeBSD:
        enabled: "false"
        state: present
      # enable my own package repository, where the latest package is
      # available
      FreeBSD_devel:
        enabled: "true"
        state: present
        url: "http://pkg.i.trombik.org/{{ ansible_distribution_version | regex_replace('\\.', '') }}{{ansible_architecture}}-default-default/"
        mirror_type: http
        signature_type: none
        priority: 100

    # see https://packagecloud.io/install/repositories/sensu/stable/script.deb.sh
    apt_repo_keys_to_add:
      - https://packagecloud.io/sensu/stable/gpgkey
    apt_repo_to_add:
      - deb https://packagecloud.io/sensu/stable/ubuntu/ bionic main
    apt_repo_enable_apt_transport_https: True

    redhat_repo_extra_packages:
      - epel-release

    # see https://packagecloud.io/install/repositories/sensu/stable/config_file.repo?os=centos&dist=7&source=script
    redhat_repo:
      sensu:
        baseurl: "https://packagecloud.io/sensu/stable/el/{{ ansible_distribution_major_version }}/$basearch"
        # Package sensu-go-cli-5.19.1-10989.x86_64.rpm is not signed
        gpgcheck: no
        enabled: yes
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes
      sensu_community:
        baseurl: https://packagecloud.io/sensu/community/el/{{ ansible_distribution_major_version }}/$basearch
        gpgkey: https://packagecloud.io/sensu/community/gpgkey
        repo_gpgcheck: yes
        gpgcheck: no
        enabled: yes
```

# License

```
Copyright (c) 2020 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)

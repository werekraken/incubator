#!/bin/bash

set -e

[[ -f /vagrant/Vagrantfile ]]

yum remove -y \
  nginx

rm -f /etc/nginx/conf.d/*

yum install -y \
  "$(
    ls /vagrant/nginx-1.31.6-1.el9.ngx.src/packages/*/x86_64/nginx-1.31.6-1.el9.ngx.x86_64.rpm \
      | sort -V \
      | tail -1
  )"

install -m 644 \
    /vagrant/helpers/log_format_patched.conf \
    /vagrant/helpers/test_servers.conf \
  /etc/nginx/conf.d/

systemctl start nginx

#!/bin/bash

set -e

[[ -f /vagrant/Vagrantfile ]]

yum remove -y \
  nginx

rm -f /etc/nginx/conf.d/*

yum install -y \
  https://nginx.org/packages/mainline/centos/9/x86_64/RPMS/nginx-1.31.6-1.el9.ngx.x86_64.rpm

install -m 644 \
    /vagrant/helpers/log_format_vanilla.conf \
    /vagrant/helpers/test_servers.conf \
  /etc/nginx/conf.d/

systemctl start nginx

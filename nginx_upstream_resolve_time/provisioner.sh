#!/bin/bash

set -e

yum install -y \
  epel-release

yum install -y \
  git \
  mock \
  rpm-build \
  rpmdevtools \
  yum-utils

usermod -a -G mock vagrant

setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' \
  /etc/selinux/config

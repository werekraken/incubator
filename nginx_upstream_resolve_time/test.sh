#!/bin/bash

set -e

echo "$1" | grep '^vanilla$\|^patched$' || {
  echo >&2 "$0 <vanilla|patched>"
  false
}

vagrant ssh \
  -c 'sudo /vagrant/helpers/install_'"$1"'_nginx.sh && sudo /vagrant/helpers/test.sh'

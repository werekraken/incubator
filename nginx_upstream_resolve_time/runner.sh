#!/bin/bash

[[ -z ${RUNNER_VAGRANT_MACHINE+x} ]] &&
  RUNNER_VAGRANT_MACHINE="default"

do_rsync=0
vagrant status "$RUNNER_VAGRANT_MACHINE" \
    | grep -q "${RUNNER_VAGRANT_MACHINE} *running" \
  && do_rsync=1

vagrant up "$RUNNER_VAGRANT_MACHINE"

((do_rsync)) \
  && vagrant rsync "$RUNNER_VAGRANT_MACHINE"

vagrant ssh "$RUNNER_VAGRANT_MACHINE" \
    -c 'cd /vagrant/nginx-1.31.6-1.el9.ngx.src && ./build.sh'

[[ "$RUNNER_VAGRANT_DESTROY" == "true" ]] \
  && vagrant destroy "$RUNNER_VAGRANT_MACHINE" -f

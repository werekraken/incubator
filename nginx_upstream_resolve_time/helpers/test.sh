#!/bin/bash

set -e

[[ -f /vagrant/Vagrantfile ]]

grep '^  # command: ' \
    /etc/nginx/conf.d/test_servers.conf \
  | while read line; do
      fgrep -A2 "$line" \
          /etc/nginx/conf.d/test_servers.conf \
        | {
            read line1
            read line2
            read line3
            _command="$(
	      echo "$line1" \
                | grep '^# command: ' \
                | sed 's/^# command: //'
            )"
            _status="$(
              echo "$line2" \
                | grep '^# status: ' \
                | sed 's/^# status: //'
            )"
            _error="$(
              echo "$line3" \
                | grep '^# error: ' \
                | sed 's/^# error: //'
            )"

            bash -c "$_command" >/dev/null 2>&1 \
              || true

	    sudo tail -1 /var/log/nginx/json.log \
              | awk -F'"' '{print "\""$4"\"","\""$8"\"","\""$12"\"","\""$16"\"","\""$20"\""}' \
              | sed 's/ ""$//' \
              | {
                  read line
                  echo "$line $_error"
                }
          }
    done

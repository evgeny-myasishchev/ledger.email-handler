#!/bin/bash
set -e

/usr/sbin/rsyslogd

exec "$@"

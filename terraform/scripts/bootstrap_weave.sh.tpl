#!/bin/bash

function log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

sed -i 's/trust-ad//' /etc/resolv.conf

# pipe console output to a log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# TODO: Launch peers

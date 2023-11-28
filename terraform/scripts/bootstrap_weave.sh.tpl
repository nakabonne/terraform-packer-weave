#!/bin/bash

function log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

sed -i 's/trust-ad//' /etc/resolv.conf

# TODO: Launch peers

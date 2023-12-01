#!/bin/bash

function log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

# Temporal fix for https://github.com/weaveworks/weave/issues/3903#issuecomment-1043199975
sed -i 's/trust-ad//' /etc/resolv.conf

# pipe console output to a log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

log "Waiting for other cluster instances to become ready ..."
sleep 120

# weave setup
log "Setting up weave"
mkdir -p /etc/sysconfig

# Retrieve PEERS var from ASG
export AWS_DEFAULT_REGION=${aws_region}
private_ips=$(aws ec2 describe-instances --instance-ids --filters Name=tag:weave,Values=enabled \
    Name=instance-state-name,Values=running \
    | jq -r '.Reservations[].Instances[].PrivateIpAddress' | paste -s -d " ")

log "private ips are:"
echo $private_ips

echo PEERS=\"$(echo $private_ips)\" > /etc/sysconfig/weave
echo WEAVE_STATUS_ADDR=\"0.0.0.0:6782\" >> /etc/sysconfig/weave

systemctl daemon-reload
systemctl start docker.service
systemctl start weave.service

log "Launching weave..."
weave prime
log "Weave has started"

# Temporal fix for lingering iptables rules
ufw disable

#!/bin/bash
#
# Requires: autossh
#
# Establishes a persistent outgoing SSH connection with reverse port forwarding.
# This allows connections to a remote (public) host to be forwarded to a host
# behind a NAT in the local network.
# Disconnections and re-connections will be gracefully handled by autossh. For this
# to work you should setup automatic authentication using SSH keys.
# 1. First run ssh-keygen on local machine and save to .ssh/nopwd.pub
# 2. Then run ssh-copy-id -i .ssh/nopwd.pub -p 22 root@REMOTE_HOST
# 3. Then run this script with nohup: nohup ./reverse-tunnel.sh &  Or add it to /etc/rc.local script
#
#
# It does the following:
# 1) Establishes an SSH connection to REMOTE_HOST;
# 2) binds one or more REMOTE_PORTs in REMOTE_HOST;
# 3) forwards incoming connections to LOCAL_PORTs in LOCAL_HOSTs
#
#
# Note: In order to bind REMOTE_PORTs to all interfaces in REMOTE_HOST,
#       you may need to add 'GatewayPorts yes' to the sshd configuration of REMOTE_HOST.
#       Failing to do this may result in the tunnel refusing external connections.
#       Also, LOCAL_HOST is relative to the host where you run this script from,
#       and can either be `localhost` itself, or any other host accessible by it.
#
# Default configuration forwards REMOTE_HOST port 8880 to LOCAL_HOST port 80 and
# REMOTE_HOST port 8443 to LOCAL_HOST port 443.
#
# Copyright (C) 2015-2019 Filipe Farinha - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 17/10/2019

# The remote host that we connect to via SSH, and establish the listening remote port(s)
REMOTE_HOST=101.37.82.72
REMOTE_HOST_SSH_PORT=22
REMOTE_HOST_SSH_USER=root


# Define reverse port forwards
# Format: 'REMOTE_PORT:LOCAL_HOST:LOCAL_PORT' (where LOCAL_HOST can be actual localhost or any host acessible by localhost)
PORTS=(
     "2222:192.168.0.80:22"    # 8880 -> 80
     "3030:192.168.0.80:3030"   # 8443 -> 443
     "3300:192.168.0.80:3300"   # 8443 -> 443
     "9527:192.168.0.80:9527"   # 8443 -> 443
     "61000:192.168.0.80:61000"   # 8443 -> 443
     "61001:192.168.0.80:61001"   # 8443 -> 443
     "61002:192.168.0.80:61002"   # 8443 -> 443
     "61003:192.168.0.80:61003"   # 8443 -> 443
    )


for PORT in ${PORTS[@]}
do
  PORT_STR="$PORT_STR -R 0.0.0.0:$PORT"
done


# Ignore early failed connections at boot
export AUTOSSH_GATETIME=0

autossh -4 -M 0 -N -o PubkeyAuthentication=yes -o PasswordAuthentication=no -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -i /root/.ssh/nopwd $PORT_STR -p$REMOTE_HOST_SSH_PORT $REMOTE_HOST_SSH_USER@$REMOTE_HOST


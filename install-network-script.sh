#!/bin/bash

source ./network-script/setup-global.sh

echo "scp network-script to DUT($DUT_SSH_IPADDR)"
scp -r network-script/* root@$DUT_SSH_IPADDR:${NETSCRIPT_INSTALL}
echo "scp network-script to LP($LP_SSH_IPADDR)"
scp -r network-script/* root@$LP_SSH_IPADDR:${NETSCRIPT_INSTALL}

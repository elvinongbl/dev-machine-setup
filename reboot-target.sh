#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

ROLE=$1
ROLE_SSH_IPADDR=$(role2sshipaddr $ROLE)

print_banner "Reboot @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"

set_target $ROLE
run_target "reboot"
unset_target

# Clear Self-report
flush_selfreport $ROLE
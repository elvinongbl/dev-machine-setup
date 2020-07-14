#!/bin/bash
#

# include global library
source ../setup-global.sh
source ../helper-lib.sh
source ../ethtool-lib.sh

print_banner "iperf3 Client started "

bash ./iperf3-client-setup.sh

loop_test_cnt "./iperf3-client-run.sh 5300 5600 tcp" 50

############################################################################
# Show baseline platform
############################################################################
#system_info_show

#!/bin/bash
#

# include global library
source ../setup-global.sh
source ../helper-lib.sh
source ../ethtool-lib.sh

print_banner "iperf3 Server started "

bash ./iperf3-server-setup.sh

loop_test_cnt "./iperf3-server-run.sh 5300 5600" 50

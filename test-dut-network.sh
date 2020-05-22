#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

alive=$(alive_test)
if [ x"$alive" != x"PASS" ]; then
        echo "ABORT: $alive"
        exit 0
fi

# Delete previous authorized public keys
rm ${TC_HOME}/.ssh/authorized_keys
# Keep personal vscode private keys
cp ${TC_HOME}/.ssh/bong5-win-vscode.pub ${TC_HOME}/.ssh/authorized_keys

# Update all network scripts in both DUT & LP
./install-network-script.sh DUT
./install-network-script.sh LP

TEST_TIME=$(print_time)
echo -e "Test runs at ${TEST_TIME}"

# Set DUT & LP test's time
setup_test_time ${TEST_TIME}

# Ping Test
test_dut "test-01-ping.sh"
test_lp "test-01-ping.sh"
# Auto-negotiation with speed change Test
test_dut "test-02-autoneg.sh"
test_lp "test-02-autoneg.sh"

# Get result from DUT
getlogs_dut
getlogs_lp

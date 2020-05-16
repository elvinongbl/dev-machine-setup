#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

alive=$(alive_test)
if [ x"$alive" != x"PASS" ]; then
        echo "ISSUE: $alive"
        cat ${TC_LOGS}/${DUT_REPORT}*
        cat ${TC_LOGS}/${DUT_REPORT}*
        exit 0
fi

echo "DUT & LP are alive!"
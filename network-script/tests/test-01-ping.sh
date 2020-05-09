#!/bin/bash
#
# To run a series of ping test for all packet sizes

# include global library
source ../setup-global.sh
source ../helper-lib.sh

ROLE=$1
DEVNAME=$(role2devname $ROLE)
DEVIPADDR=$(role2ipaddr $ROLE)
PARTNERIPADDR=$(role2ipaddr $(role2lp $ROLE))

print_banner "Ping test on $ROLE ($DEVIPADDR)"

function test_ping () {
	# Ping packet size is always +8-Byte
	SIZE=$[$1-8]
	COUNT=$2
	print_topic "Ping - size=$1 [count=$2]"
	ping -c $COUNT -s $SIZE -i 0.001 $PARTNERIPADDR
}

test_ping 64 1024
test_ping 128 1024
test_ping 256 1024
test_ping 512 1024
test_ping 800 1024
test_ping 1024 1024
test_ping 1518 1024
test_ping 2048 1024
test_ping 4096 1024

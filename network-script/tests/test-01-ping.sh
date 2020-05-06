#!/bin/bash
#
# To run a series of ping test for all different speeds
# as toggled through ethtool
#
# Global variables:-
# LP_B2B_IPADDR - Link Partner's IP address

# include global library
source ../setup-global.sh
source ../helper-lib.sh

# Basic Rapid Ping test
print_banner "Ping 512 packet at 0.01s apart"
ping -c 512 -i 0.01 $LP_B2B_IPADDR

#!/bin/bash
#
# To run a series of ping test for all packet sizes

# include global library
source ../setup-global.sh
source ../helper-lib.sh

# Basic Rapid Ping test
print_banner "Ping 1024x 56+8=64Byte packet at 0.01s apart"
ping -c 1024 -s 56 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 120+8=128Byte packet at 0.01s apart"
ping -c 1024 -s 120 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 248+8=256Byte packet at 0.01s apart"
ping -c 1024 -s 248 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 504+8=512Byte packet at 0.01s apart"
ping -c 1024 -s 504 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 792+8=800Byte packet at 0.01s apart"
ping -c 1024 -s 792 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 1016+8=1024Byte packet at 0.01s apart"
ping -c 1024 -s 1016 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 1510+8=1518Byte packet at 0.01s apart"
ping -c 1024 -s 1510 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 2040+8=2048Byte packet at 0.01s apart"
ping -c 1024 -s 2040 -i 0.001 $LP_B2B_IPADDR

print_banner "Ping 1024x 4088+8=4096Byte packet at 0.01s apart"
ping -c 1024 -s 4088 -i 0.001 $LP_B2B_IPADDR

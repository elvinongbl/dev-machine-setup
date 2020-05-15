#!/bin/bash

source /home/root/network-script/setup-global.sh

devname=$(cat /home/root/network-script/devrole.txt)

echo "Hello from $devname at $(date)" > /home/root/$devname-self-report.txt
echo "$(ip addr show enp0s20f0u4u4 | grep "inet ")" >> /home/root/$devname-self-report.txt

scp -o StrictHostKeyChecking=no /home/root/$devname-self-report.txt ${TC_USER}@${TC_IPADDR}:~/test-logs

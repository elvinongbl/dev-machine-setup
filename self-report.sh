#!/bin/bash

source /home/root/network-script/setup-global.sh

target_name=$(cat /home/root/network-script/devrole.txt)
target_info=$(dmidecode -t 1 | grep "Product Name" | cut -d":" -f2)

if [ "${target_name}" == "${DUT_REPORT}" ]; then
	ROLE=DUT
else
	ROLE=LP
fi

target_ssh_devname=$(role2sshdevname $ROLE)

echo "Hello from ${target_name}[${target_info}] at $(date)" > /home/root/${target_name}-self-report.txt
echo "$(ip addr show ${target_ssh_devname} | grep "inet " | grep "${target_ssh_devname}")" >> /home/root/${target_name}-self-report.txt

scp -o StrictHostKeyChecking=no /home/root/${target_name}-self-report.txt ${TC_USER}@${TC_IPADDR}:${TC_LOGS}

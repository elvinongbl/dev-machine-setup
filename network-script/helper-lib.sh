#!/bin/bash
#
# print_separator
# print_banner "title"

function print_separator_short () {
	echo -e "#############################"
}

function print_separator () {
	echo -e "###############################################################"
	echo -e "\n"
}

function print_banner () {
	echo -e "###############################################################"
	echo -e "# $1 "
	echo -e "# Time = $(date)"
	echo -e "###############################################################"
	echo -e "\n"
}

function run_dut() {
	echo -e "dut> $1"
	ssh root@$DUT_SSH_IPADDR $1
}

function run_dut_silence() {
	ssh root@$DUT_SSH_IPADDR $1
}

function scp2dut() {
	SRC=$1
	DST=$2
	echo "scp $SRC to $DUT_SSH_IPADDR:$DST"
	scp $SRC root@$DUT_SSH_IPADDR:$DST
}

function run_lp() {
	echo -e "lp> $1"
	ssh root@$LP_SSH_IPADDR $1
}

function run_lp_silence() {
	ssh root@$LP_SSH_IPADDR $1
}

function scp2lp() {
	SRC=$1
	DST=$2
	echo "scp $SRC to $LP_SSH_IPADDR:$DST"
	scp $SRC root@$LP_SSH_IPADDR:$DST
}

# display_eth_info $DEVNAME $COMMENT_STRING
# e.g. display_eth_info $LP_B2B_DEVNAME "Link Partner"
function display_eth_info () {
	DEVNAME=$1
	COMMENT=$2

	print_banner "Display Basic Eth Info for $DEVNAME - $COMMENT"

	# Show IP address
	ip address show dev $DEVNAME
	print_separator_short

	# Show driver information
	ethtool -i $DEVNAME

	# Show Permanent address
	ethtool -P $DEVNAME

	# Show Current Link Speed, Duplex, AN, LP
	ethtool $DEVNAME

	print_separator
}

function remove_all_ipaddr () {
	DEVNAME=$1
	ip address flush dev $DEVNAME
}

function add_ipaddr () {
	DEVNAME=$1
	ADDR=$2
	ip address add $ADDR/24 dev $DEVNAME
}

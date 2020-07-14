#!/bin/bash
#

################################################################################
# Helper Functions for Printing/Displaying
################################################################################

function print_separator_short () {
	echo -e "#############################"
}

function print_separator () {
	echo -e "###############################################################"
}

function print_banner () {
	echo -e "###############################################################"
	echo -e "# $1 "
	echo -e "# Time = $(date)"
	echo -e "###############################################################"
}

function print_topic () {
	echo -e "\n"
	print_separator_short
	echo -e "# $1 "
	print_separator_short
}

function print_line() {
	echo -e "# $1"
}

function print_time() {
	date +"%Y%m%d-%HH%MM"
}

function run_cmd() {
	echo -e "> $1"
	eval $1
}

function run_bash() {
	echo -e "bash> $1"
	bash -c "$1"
}

function run_cmd_ret() {
	$1
	echo -e "> $? = $1"
}

################################################################################
# Misc Helper Functions
################################################################################

function saferm() {
	local DIRECTORY=$1

	if [ -d $DIRECTORY ]; then
		run_cmd "rm -rf $DIRECTORY"
	else
		echo -e "NO directory found. rm -f : skipped"
	fi
}

################################################################################
# Helper Functions for Role Conversion
################################################################################

function devname2role() {
	local DEVNAME=$1
	if [ "$DEVNAME" == "$DUT_B2B_DEVNAME" ]; then
		echo "DUT"
		exit 0
	fi
	if [ "$DEVNAME" == "$LP_B2B_DEVNAME" ]; then
		echo "LP"
		exit 0
	fi
	echo "UNKNOWN"
}

function role2devname() {
	local ROLE=$1
	if [ "$ROLE" == "DUT" ]; then
		echo "$DUT_B2B_DEVNAME"
		exit 0
	fi
	if [ "$ROLE" == "LP" ]; then
		echo "$LP_B2B_DEVNAME"
		exit 0
	fi
	echo "UNKNOWN"
}

function role2ipaddr() {
	local ROLE=$1
	if [ "$ROLE" == "DUT" ]; then
		echo "$DUT_B2B_IPADDR"
		exit 0
	fi
	if [ "$ROLE" == "LP" ]; then
		echo "$LP_B2B_IPADDR"
		exit 0
	fi
	echo "UNKNOWN"
}

function role2lp() {
	local ROLE=$1
	if [ "$ROLE" == "DUT" ]; then
		echo "LP"
		exit 0
	fi
	if [ "$ROLE" == "LP" ]; then
		echo "DUT"
		exit 0
	fi
	echo "UNKNOWN"
}

function role2home() {
	local ROLE=$1
	if [ "$ROLE" == "DUT" ]; then
		echo "${DUT_HOME}"
		exit 0
	fi
	if [ "$ROLE" == "LP" ]; then
		echo "${LP_HOME}"
		exit 0
	fi
	echo "UNKNOWN"
}

function role2sshipaddr() {
	local ROLE=$1
	if [ "$ROLE" == "DUT" ]; then
		echo "$DUT_SSH_IPADDR"
		exit 0
	fi
	if [ "$ROLE" == "LP" ]; then
		echo "$LP_SSH_IPADDR"
		exit 0
	fi
	echo "UNKNOWN"
}

function role2report() {
	local ROLE=$1
	if [ "$ROLE" == "DUT" ]; then
		echo "$DUT_REPORT"
		exit 0
	fi
	if [ "$ROLE" == "LP" ]; then
		echo "$LP_REPORT"
		exit 0
	fi
	echo "UNKNOWN"
}

function role2sshdevname() {
	local ROLE=$1
	if [ "$ROLE" == "DUT" ]; then
		echo "$DUT_SSH_DEVNAME"
		exit 0
	fi
	if [ "$ROLE" == "LP" ]; then
		echo "$LP_SSH_DEVNAME"
		exit 0
	fi
	echo "UNKNOWN"
}

################################################################################
# Helper Functions for DUT
################################################################################

function run_dut() {
	echo -e "dut> $1"
	ssh -o StrictHostKeyChecking=no root@$DUT_SSH_IPADDR $1
}

function run_dut_silence() {
	ssh -o StrictHostKeyChecking=no root@$DUT_SSH_IPADDR $1
}

function test_dut() {
	local TESTSCRIPT=$1
	local LOGDIR=$(run_dut_silence "cat ${NETSCRIPT_INSTALL}/.logpath")
	local LOG=DUT-$(echo "$TESTSCRIPT" | sed -e "s#\.sh#\.log#g")
	echo -e "dut test> $TESTSCRIPT [$LOGDIR/$LOG]"
	ssh -o StrictHostKeyChecking=no root@$DUT_SSH_IPADDR "cd $NETSCRIPT_INSTALL/tests; ./$TESTSCRIPT DUT > $LOGDIR/$LOG"
}

function getlogs_dut() {
	local LOGDIRPATH=$(run_dut_silence "cat ${NETSCRIPT_INSTALL}/.logpath")
	local LOGDIR=$(echo $LOGDIRPATH | grep -o -P "(?<=${NETSCRIPT_LOG}/).*")
	run_dut_silence "cd $LOGDIRPATH/..; tar -jcvf $LOGDIR.tar.bz2 $LOGDIR"
	mkdir -p ${TC_LOGS}
	run_dut_silence "scp -o StrictHostKeyChecking=no $LOGDIRPATH/../$LOGDIR.tar.bz2 ${TC_USER}@${TC_IPADDR}:${TC_LOGS}/"
	local CWD=$(pwd)
	cd ${TC_LOGS}
	tar xf $LOGDIR.tar.bz2
	rm $LOGDIR.tar.bz2
	cd $CWD
}

function scp2dut() {
	local SRC=$1
	local DST=$2
	echo "scp $SRC to $DUT_SSH_IPADDR:$DST"
	scp -o StrictHostKeyChecking=no $SRC root@$DUT_SSH_IPADDR:$DST
}

################################################################################
# Helper Functions for LP
################################################################################

function run_lp() {
	echo -e "lp> $1"
	ssh -o StrictHostKeyChecking=no root@$LP_SSH_IPADDR $1
}

function run_lp_silence() {
	ssh -o StrictHostKeyChecking=no root@$LP_SSH_IPADDR $1
}

function test_lp() {
	local TESTSCRIPT=$1
	local LOGDIR=$(run_lp_silence "cat ${NETSCRIPT_INSTALL}/.logpath")
	local LOG=LP-$(echo "$TESTSCRIPT" | sed -e "s#\.sh#\.log#g")
	echo -e "lp test> $TESTSCRIPT [$LOGDIR/$LOG]"
	ssh -o StrictHostKeyChecking=no root@$LP_SSH_IPADDR "cd $NETSCRIPT_INSTALL/tests; ./$TESTSCRIPT LP > $LOGDIR/$LOG"
}

function getlogs_lp() {
	local LOGDIRPATH=$(run_lp_silence "cat ${NETSCRIPT_INSTALL}/.logpath")
	local LOGDIR=$(echo $LOGDIRPATH | grep -o -P "(?<=${NETSCRIPT_LOG}/).*")
	run_lp_silence "cd $LOGDIRPATH/..; tar -jcvf $LOGDIR.tar.bz2 $LOGDIR"
	mkdir -p ${TC_LOGS}
	run_lp_silence "scp -o StrictHostKeyChecking=no $LOGDIRPATH/../$LOGDIR.tar.bz2 ${TC_USER}@${TC_IPADDR}:${TC_LOGS}/"
	local CWD=$(pwd)
	cd ${TC_LOGS}
	tar xf $LOGDIR.tar.bz2
	rm $LOGDIR.tar.bz2
}

function scp2lp() {
	local SRC=$1
	local DST=$2
	echo "scp $SRC to $LP_SSH_IPADDR:$DST"
	scp -o StrictHostKeyChecking=no $SRC root@$LP_SSH_IPADDR:$DST
}

function setup_test_time() {
	local TIME=$1
	run_dut "mkdir -p ${NETSCRIPT_LOG}/$TIME"
	run_dut "echo "${NETSCRIPT_LOG}/$TIME" > ${NETSCRIPT_INSTALL}/.logpath"
	run_lp "mkdir -p ${NETSCRIPT_LOG}/$TIME"
	run_lp "echo "${NETSCRIPT_LOG}/$TIME" > ${NETSCRIPT_INSTALL}/.logpath"
}

################################################################################
# Helper Functions for running on target
#
# set_target and unset_target must be included to use the below functions
################################################################################

# set_target and unset_target must be included to use the below functions
function set_target() {
	export NS_GLOBAL_TARGET=$1
}

function unset_target() {
	unset NS_GLOBAL_TARGET
}

function run_target() {
	local TARGET=$(echo $NS_GLOBAL_TARGET)
	local CMD="$1"
	if [ "$TARGET" == "DUT" ]; then
		run_dut "$CMD"
	else
		run_lp "$CMD"
	fi
}

function run_target_silence() {
	local TARGET=$(echo $NS_GLOBAL_TARGET)
	local CMD="$1"
	if [ "$TARGET" == "DUT" ]; then
		run_dut_silence "$CMD"
	else
		run_lp_silence "$CMD"
	fi
}

function test_target() {
	local TARGET=$(echo $NS_GLOBAL_TARGET)
	local TESTSCRIPT="$1"
	if [ "$TARGET" == "DUT" ]; then
		test_dut "$TESTSCRIPT"
	else
		test_lp "$TESTSCRIPT"
	fi
}

function getlogs_target() {
	local TARGET=$(echo $NS_GLOBAL_TARGET)
	if [ "$TARGET" == "DUT" ]; then
		getlogs_dut
	else
		getlogs_lp
	fi
}

function flush_testlogs() {
	YEAR=$(date +"%Y")
	saferm ${TC_LOGS}/${YEAR}*
}

function flush_selfreport() {
	local ROLE=$1
	if [ x"$ROLE" == x"DUT" ]; then
		rm ${TC_LOGS}/${DUT_REPORT}*
	else
		rm ${TC_LOGS}/${LP_REPORT}*
	fi

}

function scp2target() {
	local TARGET=$(echo $NS_GLOBAL_TARGET)
	local SRC="$1"
	local DST="$2"
	if [ "$TARGET" == "DUT" ]; then
		scp2dut "$SRC" "$DST"
	else
		scp2lp "$SRC" "$DST"
	fi
}

function targets_alive_test() {
	local dut_alive=$(echo $(run_dut_silence "cat ~/${DUT_REPORT}*") | grep ${DUT_REPORT} -c)
	local lp_alive=$(echo $(run_lp_silence "cat ~/${LP_REPORT}*") | grep ${LP_REPORT} -c)

	if [ x"$dut_alive" == x"0" ] || [ x"$lp_alive" == x"0" ]; then
		echo "FAIL!!! DUT=$dut_alive LP=$lp_alive"
	else
		echo "PASS"
	fi
}

################################################################################
# System Info & Control Helper Functions
################################################################################
function system_info_show() {
	print_line
	dmidecode -t processor
	dmidecode -t bios
	print_line
	uname -a
	print_line
}

function system_irqaffinity_remap() {
	local IRQ_NUM=$1
	local CORE=$2
	run_cmd "echo $CORE > /proc/irq/$IRQ_NUM/smp_affinity"
}

function system_process_show() {
	print_line
	ps
	print_line
}

################################################################################
# Network Info Helper Functions
################################################################################

# display_eth_info $DEVNAME $COMMENT_STRING
# e.g. display_eth_info $LP_B2B_DEVNAME "Link Partner"
function display_eth_info () {
	local DEVNAME=$1
	local COMMENT=$2

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
	local DEVNAME=$1
	run_cmd "ip address flush dev $DEVNAME"
}

function add_ipaddr () {
	local DEVNAME=$1
	local ADDR=$2
	run_cmd "ip address add $ADDR/24 dev $DEVNAME"
}

function run_lp_restore_ipaddr() {
	local ROLE=$1
	if [ x"$ROLE" == x"DUT" ]; then
		run_lp "source $NETSCRIPT_INSTALL/setup-global.sh; \
			source $NETSCRIPT_INSTALL/helper-lib.sh; \
			source $NETSCRIPT_INSTALL/ethtool-lib.sh; \
			remove_all_ipaddr $LP_B2B_DEVNAME; \
			add_ipaddr $LP_B2B_DEVNAME $LP_B2B_IPADDR \
			"
	else
		run_dut "source $NETSCRIPT_INSTALL/setup-global.sh; \
			source $NETSCRIPT_INSTALL/helper-lib.sh; \
			source $NETSCRIPT_INSTALL/ethtool-lib.sh; \
			remove_all_ipaddr $DUT_B2B_DEVNAME; \
			add_ipaddr $DUT_B2B_DEVNAME $DUT_B2B_IPADDR \
			"
	fi
}

function dut_restore_ipaddr() {
	local ROLE=$1
	if [ x"$ROLE" == x"LP" ]; then
		remove_all_ipaddr $LP_B2B_DEVNAME;
		sleep 1
		add_ipaddr $LP_B2B_DEVNAME $LP_B2B_IPADDR;
	else
		remove_all_ipaddr $DUT_B2B_DEVNAME;
		sleep 1
		add_ipaddr $DUT_B2B_DEVNAME $DUT_B2B_IPADDR;
	fi
}

function eth_irqaffinity_remap() {
	IFACE=$1
	QUEUE=$2
	CORE=$3

	# For /proc/interrupts format used by igb and stmmac
	IRQ_NUM=$(cat /proc/interrupts | grep -e "$IFACE:$QUEUE\|$IFACE-$QUEUE" | awk '{print $1}' | rev | cut -c 2- | rev)
	system_irqaffinity_remap $IRQ_NUM $CORE
}

################################################################################
# Test Framework Functions
################################################################################
# non-block listen
function target_listen_nb() {
	local port=$1
	echo "$(nc -w 5 -l -p $port)"
}

function target_talk() {
	local server=$1
	local port=$2
	local mesg=$3
	# '-c' close socket on echo EOF
	run_cmd "echo -e $mesg | nc -c $server $port"
	echo -e $mesg | nc -c $server $port
}

function target_ack_on() {
	TARGET_IP=$1
	TARGET_PORT=$2
	TALKMSG=$3
	ACKMSG=$4
	while true ; do
		target_talk $TARGET_IP $TARGET_PORT $TALKMSG
		mesg=$(target_listen_nb $TARGET_PORT)
		if [ x"$mesg" == x"$ACKMSG" ]; then
			echo -e "Target receives $mesg"
			# Relay talkmsg one more to avoid catch 22 scenario
			target_talk $TARGET_IP $TARGET_PORT $TALKMSG
			sleep 1
			# Relay talkmsg one more to avoid catch 22 scenario
			target_talk $TARGET_IP $TARGET_PORT $TALKMSG
			break
		fi

		if [ x"$mesg" == x"TEST_ABORT" ]; then
			echo -e "TEST ABORT!!!"
			exit
		fi
	done
}

function loop_test_cnt() {
	SCRIPT=$1
	MAX=$2
	count=0

	print_topic "Loop Test: $CMD"
	print_time
	while true; do
		count=$[$count+1]
		if [ $count -gt $MAX ]; then
			break
		fi

		print_topic "Loop=$count"
		bash $SCRIPT $count

		if [ x"$GLOBAL_STATUS" == x"LOOP_ABORT" ]; then
			break;
		fi
		# Sleep a while to give process chance to reset its memory
		sleep 3
	done

	print_banner "DONE: Loop Test: $CMD - Complete=$[$count-1]/$MAX"
}

function setup_tracelog_tc(){
	local TC_LOGIN=$1
	local DSTDIR=$2

	echo -e "ssh $TC_LOGIN: mkdir -p $DSTDIR"
	sshpass -p 'mypasscode' ssh -o StrictHostKeyChecking=no $TC_LOGIN "mkdir -p $DSTDIR"
}

function send_tracelog_tc() {
	local TC_LOGIN=$1
	local SRCFILE=$2
	local DSTDIR=$3

	echo -e "scp $TC_LOGIN: $SRCFILE"
	sshpass -p 'mypasscode' scp -o StrictHostKeyChecking=no $SRCFILE $TC_LOGIN:$DSTDIR/$SRCFILE
}

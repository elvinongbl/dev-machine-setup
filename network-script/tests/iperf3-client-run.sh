#!/bin/bash

# include global library
source ../setup-global.sh
source ../helper-lib.sh
source ../ethtool-lib.sh

test_port=$1
com_port=$2
test_traffic=$3
test_count=$4

# Select which NIC to test
test_server=$STMMAC_SERVER_IP
BOARDA_IP="$DUT_SSH_IPADDR"
BOARDB_IP="$LP_SSH_IPADDR"

# Change trace_on|off
test_trace="trace_on"

function iperf3_frame_size() {
	local server=$1
	local port=$2
	local traffic=$3
	local size=$4
	local test_trace=$5
	local test_count=$6
	print_line

	if [ x"$test_trace" == x"trace_on" ]; then
		tracedat=$port-iperf3-client-$test_count-$size.dat
		tracetxt=$port-iperf3-client-$test_count-$size.txt

		# Capture traces for iperf client
		if [ x"$traffic" == x"udp" ]; then
			run_cmd "iperf3 -c $server -p $port -t 20 -b 0 -l $size -u &"
		else
			run_cmd "iperf3 -c $server -p $port -t 20 -b 0 -l $size &"
		fi
		pid_iperf3=$!

		#run_cmd "taskset -p 4 $pid_iperf3"

		run_cmd "trace-cmd record -p nop -d -P $pid_iperf3 -o $tracedat"

		# Wait for trace-cmd to exit before stop it
		sleep 5

		run_cmd "trace-cmd stop"
		run_cmd "trace-cmd report -i $tracedat > $tracetxt"
		# Delete all instance buffers and also reset the top instance
		run_cmd "trace-cmd reset -t -a -d"

		# Check if "stmmac_tx_timeout" happens... if not, delete trace files to save storage
		has_txtimeout=$(cat $tracetxt | grep "stmmac_tx_timeout" -c)
		if [ $has_txtimeout -eq 0 ]; then
			rm $tracedat
			#rm $tracetxt
		else
			echo "ERROR: count=$count size=$size stmmac_tx_timeout FOUND"
			exit
		fi
	else
		if [ x"$traffic" == x"udp" ]; then
			#run_cmd "iperf3 -c  $server -p $port -b 0 -l $size -u | grep -e '- - - - - - -' -A4"
			run_cmd "iperf3 -c  $server -p $port -b 0 -l $size -u | grep -e '- - - - - - -' -A4"
		else
			#run_cmd "iperf3 -c  $server -p $port -b 0 -l $size | grep -e '- - - - - - -' -A4"
			run_cmd "iperf3 -c  $server -p $port -b 0 -l $size | grep -e '- - - - - - -' -A4"
		fi
	fi
}

function iperf3_test() {
	local SERVER_IP=$1
	local SERVER_PORT=$2
	local test_trace=$3
	local TRAFFICTYPE=$4
	local test_count=$5

	# UDP by frame size test
	iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 64 $test_trace $test_count
	#iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 65 $test_trace $test_count
	#iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 128 $test_trace $test_count
	#iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 256 $test_trace $test_count
	#iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 512 $test_trace $test_count
	#iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 1024 $test_trace $test_count
	#iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 1280 $test_trace $test_count
	#iperf3_frame_size $SERVER_IP $SERVER_PORT $TRAFFICTYPE 1450 $test_trace $test_count
}

echo -e "Waiting for Board A to send SERV_STARTED"
target_ack_on $BOARDA_IP $com_port CLIENT_START SERV_STARTED

ping -c 4 $test_server

print_banner "iperf3 client: STARTED - <$test_traffic> [$test_count]"

#iperf3_udp_test $test_server $test_port $test_trace $test_count
iperf3_test $test_server $test_port $test_trace $test_traffic $test_count

echo -e "Waiting for Board A to signal SERV_CLOSE"
target_ack_on $BOARDA_IP $com_port CLIENT_CLOSE SERV_CLOSE

print_banner "iperf3 client: CLOSED [$test_count]"

# Check on dmesg
dmesg_log="Kernel log: $(dmesg -c)"
result=$(echo $dmesg_log | grep "$STMMACIFNAME: Reset adapter")
is_reset=$(echo $dmesg_log | grep "$STMMACIFNAME: Reset adapter" -c)

if [ $is_reset -gt 0 ]; then
	print_topic "Reset Adapter detected: $result"
	export GLOBAL_STATUS="LOOP_ABORT"
fi

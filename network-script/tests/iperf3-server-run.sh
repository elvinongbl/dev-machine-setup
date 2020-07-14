#!/bin/bash

# include global library
source ../setup-global.sh
source ../helper-lib.sh
source ../ethtool-lib.sh

port=$1
com_port=$2
count=$3

BOARDA_IP="$DUT_SSH_IPADDR"
BOARDB_IP="$LP_SSH_IPADDR"

# Trace file name
tracedat=$port-iperf3-server-$count.dat
tracetxt=$port-iperf3-server-$count.txt

# Change trace_on|off
test_trace="trace_on"

print_banner "iperf3 server: STARTED [$count]"

# Clear kernel dmesg
dmesg -c

run_cmd "iperf3 -s -p $port &"
pid_iperf3=$!

system_process_show

#run_cmd "taskset -p 4 $pid_iperf3"

if [ x"$test_trace" == x"trace_on" ]; then
	run_cmd "trace-cmd record -p nop -d -P $pid_iperf3 -o $tracedat &"
fi

echo -e "Waiting for Board B to signal CLIENT_CLOSE"
target_ack_on $BOARDB_IP $com_port SERV_STARTED CLIENT_CLOSE

kill -9 $pid_iperf3

if [ x"$test_trace" == x"trace_on" ]; then
	system_process_show
	# Wait for trace-cmd to exit before stop it
	sleep 5
	run_cmd "trace-cmd stop"
	run_cmd "trace-cmd report -i $tracedat > $tracetxt"
	# Delete all instance buffers and also reset the top instance
	run_cmd "trace-cmd reset -t -a -d"
fi

echo -e "Waiting for Board B to signal CLIENT_CLOSE"
target_ack_on $BOARDB_IP $com_port SERV_CLOSE CLIENT_CLOSE

print_banner "iperf3 server: CLOSED [$count]"

# Check on dmesg
dmesg_log="Kernel log: $(dmesg -c)"
result=$(echo $dmesg_log | grep "$STMMACIFNAME: Reset adapter")
is_reset=$(echo $dmesg_log | grep "$STMMACIFNAME: Reset adapter" -c)

if [ $is_reset -gt 0 ]; then
	print_topic "Reset Adapter detected: $result"
	export GLOBAL_STATUS="LOOP_ABORT"
else
	if [ x"$test_trace" == x"trace_on" ]; then
		# If no reset adapter detected, then we clear the trace
		rm $tracedat
		#rm $tracetxt
	fi
fi

#!/bin/bash
# This script collects PHY layer info
#   - extracts the average tx power and average transmission rate on the channel (from horst log)
#   - extracts active, busy, receive and transmit time on the channel (from iw survey dump) 
#   - the info is collected simultaneously and jointly log to the same file
# 
# 
# 

LOG="./tmp/"
TIME=3600
REMOTE_HOST="192.168.1.1"
iface="wlan0"
freq="2412"
ITERATION=15
COUNT=0

ifconfig $iface down
iw $iface set freq $freq HT20
ifconfig $iface up

until [ $COUNT -eq $ITERATION ]; do
	#ping -c 5 -i 0.005 $REMOTE_HOST  
	echo 'password' | sudo -S iw $iface interface add mon0 type monitor &>/dev/null	
	if [ $? -ne 0 ]; then
	    	    
		sudo horst -i mon0 -o $LOG"tmp-horstlog.log" &
		echo "hosrt scan completed!"
		
		# while true; do
			iw $iface survey dump | grep -A 5 "in use" > $LOG"tmp-dump.log" &&
			
			FREQ=`cat $LOG"tmp-dump.log" | awk '/frequency/ {print $2}'`
			CH_ACTIVE=`cat $LOG"tmp-dump.log" | awk  '/channel active time/ {print $4}'`
			CH_BUSY=`cat $LOG"tmp-dump.log" | awk  '/channel busy time/ {print $4}'`
			CH_RX=`cat $LOG"tmp-dump.log" | awk  '/channel receive time/ {print $4}'`
			CH_TX=`cat $LOG"tmp-dump.log" | awk  '/channel transmit time/ {print $4}'`
            
			cci=$(awk -v busy=$CH_BUSY -v active=$CH_ACTIVE "BEGIN {print (active ? (busy/active) : 0) }")
			echo "channel busy, active and % interference"
			echo $CH_BUSY, $CH_ACTIVE, $cci*100

			usage=$(awk -v rx="$CH_RX" -v tx="$CH_TX" -v active="$CH_ACTIVE" "BEGIN {print (active ? ((rx+tx)/active): 0)}")
			rx=$(awk -v sta_rx=$CH_RX -v active=$CH_ACTIVE "BEGIN {print (active ? (sta_rx/active) : 0) }")
			tx=$(awk -v sta_tx=$CH_TX -v active=$CH_ACTIVE "BEGIN {print (active ? (sta_tx/active) : 0) }")
			echo "channel rx, tx and % usage"
			echo $CH_RX, $CH_TX, $usage*100
		
			# sleep $TIME
			echo -n $FREQ, $cci, $rx, $tx", "  >> $LOG"$(date -u +"%Y-%m-%d")-exp.log"
			./awkfile.awk $LOG"tmp-horstlog.log" >> $LOG"$(date -u +"%Y-%m-%d")-exp.log"
		# done
	fi
	let COUNT=COUNT+1  
    echo iteration $COUNT completed!
	echo ""
	kill $!
done
#rm $LOG"-tmp*"

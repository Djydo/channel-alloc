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
ITERATION=3
COUNT=0

horst_n_timeout(){
	sudo horst -i mon0 -o $LOG"tmp-horstlog.log" & pid=&!
	( sleep $TIMEOUT && kill -HUP $pid ) 2>/dev/null & watcher=$!
	wait $pid 2>/dev/null && pkill -HUP -P $watcher
}

until [ $COUNT -eq $ITERATION ]; do
	ping -c 5 -i 0.005 $REMOTE_HOST  
	echo 'password' | sudo -S iw $iface interface add mon0 type monitor &>/dev/null	
	if [ $? -ne 0 ]; then
	    	    
		# sudo horst -i mon0 -o $LOG"tmp-horstlog.log" &
		horst_n_timeout &
		echo "hosrt scan completed!"
		
		# while true; do
			iw mon0 survey dump | grep -A 5 "in use" > $LOG"tmp-dump.log" 
			
			FREQ=`cat $LOG"tmp-dump.log" | awk '/frequency/ {print $2}'`
			CH_ACTIVE=`cat $LOG"tmp-dump.log" | awk  '/channel active time/ {print $4}'`
			CH_BUSY=`cat $LOG"tmp-dump.log" | awk  '/channel busy time/ {print $4}'`
			CH_RX=`cat $LOG"tmp-dump.log" | awk  '/channel receive time/ {print $4}'`
			CH_TX=`cat $LOG"tmp-dump.log" | awk  '/channel transmit time/ {print $4}'`
            
			cci=`awk "BEGIN {print $CH_BUSY/$CH_ACTIVE }"`
			echo "channel busy, active and % interference"
			echo $CH_BUSY, $CH_ACTIVE, $cci*100

			usage=`awk "BEGIN {print ($CH_RX+$CH_TX)/$CH_ACTIVE}"`
			echo "channel rx, tx and % usage"
			echo $CH_RX, $CH_TX, $usage*100
		
			# sleep $TIME
			echo -n $FREQ, $cci, $usage", "  >> $LOG"$(date -u +"%Y-%m-%d")-exp.log"
			./awkfile.awk $LOG"tmp-horstlog.log" >> $LOG"$(date -u +"%Y-%m-%d")-exp.log"
		# done
	fi
	let COUNT=COUNT+1  
    echo iteration $COUNT completed!
	echo ""
done
#rm $LOG"-tmp*"

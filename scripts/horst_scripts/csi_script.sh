#!/bin/bash


COUNT=200
INTERVAL=0.02

#hostapd
sudo ./hostapd/hostapd  hostapd/hostapd.conf > hostapdtmp_log.log

#csiTool
sudo ./recv_csi ~/Documents/data/ch_capture/sample7/ch11.dat
iperf3 -t 30 -c 192.168.1.1 | grep KBytes | awk '{ print $3"\t"$5"\t"$7"\t"$9 }' > ~/Documents/data/ch_capture/sample7/iperf_ch10.dat

#iperf3 for bandwidth measurement  
iperf3 -s
iperf3 -c 192.168.1.1 -R -u -b 20m -t 30 -i 1

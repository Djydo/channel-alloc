#!/bin/bash
# enumerate all center channel frequencies
declare -A frequency  
frequency=([2412]=1
   [2417]=2
   [2422]=3
   [2427]=4
   [2432]=5
   [2437]=6
   [2442]=7
   [2447]=8
   [2452]=9
   [2457]=10
   [2462]=11
   [2467]=12
   [2472]=12)

sudo service network-manager stop;
sudo ifconfig wlan0 down;
sudo iw wlan0 interface add mon0 type monitor;
sudo iwconfig wlan0 mode managed;
# sudo dhclient -r wlan0;
sudo ifconfig wlan0 up;
# sudo iwconfig wlan0 essid "OpenWrt";
sudo ifconfig mon0 up;
sudo iw dev mon0 set freq 2437;
iwconfig;


# get wlan interface 
#WIFI_NIC=$(iw dev | grep Interface | awk '{print $2}')   # assume there's only 1 wlan interface
#NUMBER_OF_SCANNED_CHANNELS=$(iw dev $WIFI_NIC scan | grep -E 'freq:'| sort | uniq | awk '{print $2}'|wc -l)


# add new interface on machine, assign new mac address
iw phy0 interface add mon0 type monitor
#iw $WIFI_NIC del
ifconfig mon0 down
ip link set mon0 address 04:f0:21:32:bd:a5
ifconfig mon0 up

#scan wireless network for available/occupied channels, and save channels(uniq)
#set a do-loop
  # assign channel in turns to computer wlan (monitor client) and access point (AP)
  # launch recv_csi on client to save csi data 
  # inject frames from AP and capture on monitor client

iw dev wlan0 scan | grep -E 'freq:'| sort | uniq | awk '{print $2}'| while read line
do
	# assign frequency to the new interface
	iw mon0 set freq $line HT20

	# start recv_csi and save to CSIdata_freqindex.dat e.g. csidata_CH6
	~/Atheros-CSI-Tool-UserSpace-APP/recvCSI/recv_csi ../data/csidata_"CH"$line".dat"
        while [ $? -ne 0 ]; do
          # sudo  ~/Atheros-CSI-Tool-UserSpace-APP/recvCSI/recv_csi ../data/csi_data_${frequency['$line']}
           sudo /home/dais/Atheros-CSI-Tool-UserSpace-APP/recvCSI/recv_csi ../data/csi_data_$line".dat"
        done 

	# ssh into the AP, set frequency and run bash script 
	cat iw wlan0 set freq '$line' HT20 | ssh root@192.168.1.1 
	cat ./ap_injector.sh | ssh root@192.168.1.1  
done

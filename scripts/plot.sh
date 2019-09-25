# gnuplot script to generate three graphs from iperfs data
# It is assumed the iperf data is captured in results.dat
# using this command:
# iperf3 -t 60 -c ${ip} | grep KBytes | awk '{ print $3"\t"$5"\t"$7"\t"$9 }' > results.dat

openWRT="ch11.dat"
hostapd="ch1.dat"
CSI_entropy="ch1.dat"


unset log
unset label
set terminal jpeg enhanced
set terminal jpeg size 600,200
set grid
set key off

# Plot the transfer to Transfer.jpg
#set title "Data Transfer"
#set ylabel "MBytes/sec"
#set xlabel "Second"
#set output "Transfer.jpg"
#plot "results.dat" using 1:2 title 'Transfer' smooth csplines

# Plot the retries to ReTries.jpg
#set title "Packet Retries"
#set ylabel "Count"
#set output "ReTries.jpg"
#plot "results.dat" using 1:4 title 'ReTries' smooth csplines

# Plot the bandwidth to Bandwidth.jpg
set title "Bandwidth"
set ylabel "MBits/sec"
set yrange [0:20]
set output "Bandwidth.jpg"
plot $openWRT using 1:3 with linespoints title 'openWRT' smooth csplines,\
     $hostapd using 1:3 with linespoints title 'hostapd' smooth csplines,\
     $CSI_entropy using 1:3 with linespoints title 'entropy' smooth csplines



#plot  "file1.csv" using 1:2 ls 1 title "one" with lines ,\
#  "file2.csv" using 1:2 ls 2 title "two" with lines ,\
#  "file3.csv" using 1:2 ls 3 title "three" with lines
#set output


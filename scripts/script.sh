file1="iperf_ch1.dat"
file2="iperf_ch2.dat"
file3="iperf_ch8.dat"

awk -f ./process.awk $file1 > temp1
awk -f ./process.awk $file2 > temp2
awk -f ./process.awk $file3 > temp3

paste <(awk '{print $1 " " $2}' temp1 ) <(awk '{print $2}' temp2 ) <(awk '{print $2}' temp3 ) >temp_out

gnuplot -p << EOF
  unset log
  unset label
  set terminal jpeg enhanced
  set terminal jpeg size 600,350
  set grid
  #set key off

  # Plot the bandwidth to throughput.jpg
  set title "Throughput"
  set ylabel "MBits/sec"
  set yrange [0:150]
  set output "Throughput.jpg"
  plot 'temp_out' using 1:2  title 'openWRT' with linespoints, \
       '' using  1:3   title 'hostapd' with linespoints, \
       '' using  1:4   title 'csi-entropy' with linespoints 
EOF
rm temp*

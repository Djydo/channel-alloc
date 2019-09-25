#"----------------- usage---------------------
#injector -i wlan0 -c 4HT20 -m 0 -n 100 -d 1000
#   -i:interface
#   -c:channel High Throughput bandwidth 20
#   -m:modulation and coding scheme (MCS) index
#   -n:number of packets
#   -d:delay between packets (ms)

ITERATION=3
COUNT=0

until [ $COUNT -eq $ITERATION ]; do

    # try to inject five packets
    injector -i wlan1 -m 2 -n 5 -d 1000   # channel is ommitted 
    
    while [ $? -ne 0 ]; do
        injector -i wlan1 -m 0 -n 5 -d 1000
    done     
    let COUNT=COUNT+1  
    echo iteration $COUNT completed!
    echo ""
done


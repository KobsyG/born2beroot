#!/bin/bash
 
while true ; do
   echo -n -e "\t#Architecture: " > monitoring.txt
   uname -a >> monitoring.txt
   echo -n -e "\t#CPU physical: " >> monitoring.txt
   lscpu | grep "par socket" | awk '{print $4}' >> monitoring.txt
   echo -n -e "\t#vCPU: " >> monitoring.txt
   lscpu | grep Thread | awk '{print $4}' >> monitoring.txt
   echo -n -e "\t#Memory Usage: " >> monitoring.txt
   free -m | grep Mem | awk '{printf $3}' >> monitoring.txt
   echo -n -e "/" >> monitoring.txt
   free -m | grep Mem | awk '{printf $2}' >> monitoring.txt
   echo -n -e "MB (" >> monitoring.txt
   free | grep Mem | awk '{printf "%.2f", $3 / $2 * 100}' >> monitoring.txt
   echo "%)" >> monitoring.txt
   USED=$(df -P | awk 'NR > 2 {value += $3} END {printf "%.2f", value / (1024 * 1024)}')
   TOTAL=$(df -P | awk 'NR > 2 {value += $2} END {printf "%.2f", value / (1024 * 1024)}')
   echo -n -e "\t#Disk Usage: $USED/$TOTAL (" >> monitoring.txt
   echo "$USED $TOTAL" | awk '{printf "%.2f", 100 * $1 / $2}' >> monitoring.txt
   echo "%)" >> monitoring.txt
   echo -n -e "\t#CPU Load: " >> monitoring.txt
   top -n1 -b | sed -n 3p | awk '{printf $2}' >> monitoring.txt
   echo "%" >> monitoring.txt
   who -b | awk '{print "\t#Last Boot: " $3 " " $4}' >> monitoring.txt
   echo -n -e "\t#LVM use: " >> monitoring.txt
   lsblk | grep lvm | grep / | wc -l | awk '{if ($1 > 0) print "yes"; else print "no"}' >> monitoring.txt
   echo -n -e "\t#Connexions TCP: " >> monitoring.txt
   ECO=$(ss -tunlp | grep LISTEN | wc -l)
   echo "$ECO ESTABLISHED" >> monitoring.txt
   echo -n -e "\t#User log: " >> monitoring.txt
   who | wc -l >> monitoring.txt
   echo -n -e "\t#Network: IP " >> monitoring.txt
   ip addr show | grep -v 127.0.0.1 | grep inet | grep -v inet6 | awk '{printf $2}' | awk -F "/" '{printf $1}' >> monitoring.txt
	echo -n " (" >> monitoring.txt
   ip addr show | grep ether | awk '{printf $2}' >> monitoring.txt
   echo ")" >> monitoring.txt
   echo -n -e "\t#Sudo: " >> monitoring.txt
   CMD=$(cat /var/log/sudo/seq)
   echo -n $((36#$CMD)) >> monitoring.txt
   echo " cmd" >> monitoring.txt
   wall monitoring.txt
   sleep 600
done

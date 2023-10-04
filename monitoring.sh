#!/bin/bash
arch=$(uname -a)
npcpu=$(cat /proc/cpuinfo | grep 'physical id' | wc -l)
nvcpu=$(cat /proc/cpuinfo | grep 'processor' | wc -l)
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
tram=$(free -m | awk '$1 == "Mem:" {print $2}')
pram=$(free -m | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
udisk=$(df -BM | grep '^/dev' | grep -v '/boot$' | awk '{used+=$3} END {print used}')
tdisk=$(df -BG | grep '^/dev' | grep -v '/boot$' | awk '{total+=$2} END {print total}')
pdisk=$(df -BM | grep '^/dev' | grep -v '/boot$' | awk '{total+=$2} {used+=$3} END {printf("%d"), used/total*100}')
cpul=$(top -bn1 | grep '^%Cpu' | tr -d 'ni,' | xargs | awk '{printf("%.1f"), 100-$7}')
lrbtime=$(who -b | awk '$1 == "system" {printf("%s %s"), $3, $4}')
slvm=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
nconnect=$(ss state established | grep 'tcp' | wc -l)
nuser=$(users | wc -w)
ip=$(hostname -I)
mac=$(ip link | grep 'ether' | awk '{print $2}')
ncmd=$(journalctl _COMM=sudo -q | grep 'COMMAND' | wc -l)

wall "
#Architecture: $arch
#CPU physical: $npcpu
#vCPU: $nvcpu
#Memory Usage: $uram/${tram}MB ($pram%)
#Disk Usage: $udisk/${tdisk}Gb ($pdisk%)
#CPU load: $cpul%
#Last boot: $lrbtime
#LVM use: $slvm
#Connections TCP: $nconnect ESTABLISHED
#User log: $nuser
#Network: IP $ip ($mac)
#Sudo: $ncmd cmd
"

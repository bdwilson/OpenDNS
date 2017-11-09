#!/bin/sh
# Check to see how quickly a domain is blocked via OpenDNS. 
HOST=$1
if [ -z $HOST ]; then
	echo "Usage: $0 <domain to check>"
	exit;
fi
c=1
BLOCKED=0
while [ $c -eq 1 ]
do
 IP=`host -t A $HOST 208.67.222.222 | grep address | head -1 | awk '{print $4}'`;
 NETWORK=`echo $IP | awk -F. '{print $1 "" $2}'`;
 if [ "$NETWORK" -eq "146112" ]; then 
 	DOMAIN=`host -t A $IP | awk '{print $5}'`;
	CLASS=`echo $DOMAIN | sed s/hit\-//g | sed s/\.opendns\.com\.//g`;
	if [ $BLOCKED -eq 2 ]; then
		TIME=`date`;
		echo "$HOST Blocked ($CLASS) at $TIME"; 
		c=0
	else 
		echo "$HOST Blocked ($CLASS)"
	fi
	sleep 15
	BLOCKED=1
 else  
	if [ $BLOCKED -eq 1 ]; then
		TIME=`date`;
		echo "$HOST Unblocked at $TIME"
		c=0
	else
		echo "$HOST is not blocked ($IP)"
	fi
	BLOCKED=2
	sleep 15
 fi 
done

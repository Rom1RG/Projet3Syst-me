#!/bin/bash
IP=var/log/apache2/access.log
DATE=`date '+%d-%m-%y %kh%M'`

touch $DATE.csv
cat $IP | cut -d' ' -f1 | sort | uniq -c > $DATE.csv

#!/bin/bash
echo -n file_upload_start | nc -w 1  $1 88
echo  -n $2 | nc  -w 1  $1 88
echo ""
#while read -r x; do sleep 0.05; echo "$x"; echo -n "$x" | nc -w 1 $1 88 ; done < $2
while read -r x; do sleep 0.03; echo -n $x | nc -w 1 $1 88 ; done < $2
echo ""
echo -n file_upload_stop | nc -w 2  $1 88
read -p  "Do you want to restart(r) esp or continue(c) recovery (r/c)?" RC
if echo "$RC" | grep -iq "^R" ;then
#if [ "$RC" == "r" ];then
    echo "restarting esp"
    echo -n node_restart | nc -w 2  $1 88
else
    echo "done, waiting for next file"
fi


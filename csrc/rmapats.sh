#!/bin/sh -f
cd "/afs/andrew.cmu.edu/usr16/ishikhar/Documents/lab3"
PIDS=""
cd "/afs/andrew.cmu.edu/usr16/ishikhar/Documents/lab3/csrc/"
make  -f Makefile.hsopt -j 16 rmapats.so &
PIDS+=" $!"
cd "/afs/andrew.cmu.edu/usr16/ishikhar/Documents/lab3"

STATUS=""
for pid in ${PIDS[@]}; do
	wait ${pid}
	STATUS+=" $?"
done

for st in ${STATUS[@]}; do
	if [[ ${st} -ne 0 ]]; then
		exit -1
	fi
done

PIDS=""

exit 0

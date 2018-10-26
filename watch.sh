#!/bin/bash
p=
while :; do
	inotifywait -qre modify test.asm
	kickass -afo test.asm
	if [ ! -z $p ]; then
		kill -9 $p
	fi
	#python sock.py p test.prg 172.28.1.105
	#x64 -moncommands breakpoints.txt test.prg &
	xxd test.prg
	x64 test.prg >/dev/null &
	p=$!
done

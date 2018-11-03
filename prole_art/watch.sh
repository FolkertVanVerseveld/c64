#!/bin/bash
p=
while :; do
	inotifywait -qre modify test.asm
	kickass -afo test.asm
	if [ ! -z $p ]; then
		kill -9 $p
		p=
	fi
	emu=yes
	for i in $(hostname -I | \grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'); do
		if [[ $i =~ 172\.28\.1\.[0-9] ]]; then
			emu=no
			break
		fi
	done
	#if [ $emu == no ]; then
		#python ../sock.py p test.prg 172.28.1.105
		python ../sock.py p test.prg 192.168.2.64
		if [ $? -eq 0 ]; then
			continue
		fi
	#fi

	#x64 -moncommands breakpoints.txt test.prg &
	#xxd test.prg
	x64 test.prg >/dev/null &
	p=$!
done

#!/bin/bash
while :; do
	inotifywait -qre modify test.asm
	java -jar /home/methos/bin/kickass-4.4/KickAss.jar test.asm
	python sock.py p test.prg 192.168.2.64
done

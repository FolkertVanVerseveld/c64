#!/bin/bash
while :; do
	inotifywait -qre modify test.asm
	kickass test.asm
	python sock.py p test.prg 172.28.1.105
done

ACME=acme
ACME_OPTIONS_DEBUG=-v3 -f cbm -DDEBUG=1

.PHONY: clean

macros.prg: macros.asm
	$(ACME) $(ACME_OPTIONS_DEBUG) $<
clean:
	rm -f *.prg *.sym

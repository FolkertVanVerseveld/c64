#importonce
/* http://sta.c64.org/cbm64mem.html */
.const spr0x = $d000
.const spr0y = $d001
.const spr1x = $d002
.const spr1y = $d003
.const spr2x = $d004
.const spr2y = $d005
.const spr3x = $d006
.const spr3y = $d007
.const spr4x = $d008
.const spr4y = $d009
.const spr5x = $d00a
.const spr5y = $d00b
.const spr6x = $d00c
.const spr6y = $d00d
.const spr7x = $d00e
.const spr7y = $d00f
.const sprxmsb = $d010
.const scrctl1 = $d011
.const raster  = $d012
.const lpenx   = $d013
.const lpeny   = $d014
.const sprshow = $d015
.const scrctl2 = $d016
.const sprhctl = $d017
.const vicmem  = $d018
.const vicisr  = $d019
.const vicicr  = $d01a
.const sprprio = $d01b
.const colmr   = $d01c
.const sprwctl = $d01d
.const sprspr  = $d01e
.const sprbkg  = $d01f
.const vicbrdr = $d020
.const vicbkg  = $d021
.const vicbkg1 = $d022
.const vicbkg2 = $d023
.const vicbkg3 = $d024
.const sprecol1 = $d025
.const sprecol2 = $d026
.const sprcol0  = $d027
.const sprcol1  = $d028
.const sprcol2  = $d029
.const sprcol3  = $d02a
.const sprcol4  = $d02b
.const sprcol5  = $d02c
.const sprcol6  = $d02d
.const sprcol7  = $d02e
/*
repeats every $40 bytes in range [$d000, $d3ff]
unusable range: [$d02f, $d03f] (also repeats)
*/

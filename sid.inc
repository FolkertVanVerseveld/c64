#importonce
/* http://sta.c64.org/cbm64mem.html */
.const ch1freq0 = $d400
.const ch1freq1 = $d401
.const ch1pw0   = $d402 // pulse width
.const ch1pw1   = $d403
.const ch1ctl   = $d404
.const ch1atkdc = $d405 // attack decay
.const ch1susrl = $d406 // sustain release

.const ch2freq0 = $d407
.const ch2freq1 = $d408
.const ch2pw0   = $d409
.const ch2pw1   = $d40a
.const ch2ctl   = $d40b
.const ch2atkdc = $d40c
.const ch2susrl = $d40d

.const ch3freq0 = $d40e
.const ch3freq1 = $d40f
.const ch3pw0   = $d410
.const ch3pw1   = $d411
.const ch3ctl   = $d412
.const ch3atkdc = $d413
.const ch3susrl = $d414

.const fltfreq0 = $d415 // filter frequency 0-2
.const fltfreq1 = $d416 // filter frequency 3-10
.const fltctl   = $d417 // filter control
.const volfilt  = $d418 // volume and filter mode

.const sidpadlx = $d419 // selected x paddle value
.const sidpadly = $d41a // selected y paddle value

.const ch3wave  = $d41b
.const ch3adsr  = $d41c

/*
repeats every $20 bytes in range [$d400, $d7ff]
unusable range: [$d41d, $d41f] (also repeats)
*/
